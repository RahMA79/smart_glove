import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/app_text_field.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:smart_glove/core/services/storage_service.dart';
import 'package:smart_glove/core/utils/auth_error_handler.dart';
import 'login_screen.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import '../widgets/login_function.dart' show ensureRoleDoc, isDoctorEmail;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _uploadingAvatar = false;
  bool _uploadingRecord = false;

  File? _avatarFile;
  File? _medicalRecordFile;
  final ImagePicker _picker = ImagePicker();

  // ignore: unused_element
  bool get _isPatient =>
      !isDoctorEmail(_emailController.text.trim().toLowerCase());

  Future<void> _pickAvatar() async {
    final XFile? f = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (f != null) setState(() => _avatarFile = File(f.path));
  }

  Future<void> _pickMedicalRecord() async {
    final XFile? f = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (f != null) setState(() => _medicalRecordFile = File(f.path));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUpPressed() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;
      final name = _nameController.text.trim();
      final age = int.parse(_ageController.text.trim());
      final role = isDoctorEmail(email) ? "doctor" : "patient";

      // 1. Sign up
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'age': age, 'role': role},
      );

      final user = response.user;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Please try again.'),
          ),
        );
        return;
      }

      // 2. Upload avatar
      String? avatarUrl;
      if (_avatarFile != null) {
        setState(() => _uploadingAvatar = true);
        avatarUrl = await StorageService.uploadAvatar(
          userId: user.id,
          file: _avatarFile!,
        );
        setState(() => _uploadingAvatar = false);
      }

      // 3. Upload medical record (patients only)
      String? medicalRecordUrl;
      if (role == 'patient' && _medicalRecordFile != null) {
        setState(() => _uploadingRecord = true);
        medicalRecordUrl = await StorageService.uploadMedicalRecord(
          userId: user.id,
          file: _medicalRecordFile!,
        );
        setState(() => _uploadingRecord = false);
      }

      // 4. Save to public.users
      final userData = <String, dynamic>{
        'id': user.id,
        'email': email,
        'name': name,
        'age': age,
        'role': role,
      };
      if (avatarUrl != null) userData['avatar_url'] = avatarUrl;
      await Supabase.instance.client
          .from('users')
          .upsert(userData, onConflict: 'id');

      // 5. Save role-specific row
      await ensureRoleDoc(
        uid: user.id,
        email: email,
        role: role,
        name: name,
        avatarUrl: avatarUrl,
        medicalRecordUrl: medicalRecordUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created successfully as ${role == 'doctor' ? 'Doctor' : 'Patient'}!',
          ),
          backgroundColor: Colors.green.shade600,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyAuthError(e.message))));
    } on FormatException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid age (numbers only).'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyAuthError(e.toString()))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isPatient = !isDoctorEmail(_emailController.text);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Create Account'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 5,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  context.tr('Sign up'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 2.5),

              // ── Profile image picker ──────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: cs.primary.withOpacity(0.1),
                        backgroundImage: _avatarFile != null
                            ? FileImage(_avatarFile!)
                            : null,
                        child: _avatarFile == null
                            ? Icon(
                                Icons.person_outline,
                                size: 44,
                                color: cs.primary.withOpacity(0.6),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Tap to upload profile photo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.blockHeight * 2.5),

              // ── Fields ────────────────────────────────────────
              AppTextField(
                label: context.tr('Full Name'),
                hint: context.tr('Enter your full name'),
                controller: _nameController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return context.tr('Name is required');
                  return null;
                },
              ),
              SizedBox(height: SizeConfig.blockHeight * 2),

              AppTextField(
                label: context.tr('Email'),
                hint: context.tr('Enter your email'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return context.tr('Email is required');
                  final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.\w{2,}$');
                  if (!emailRegex.hasMatch(value))
                    return context.tr('Please enter a valid email address');
                  return null;
                },
              ),
              SizedBox(height: SizeConfig.blockHeight * 2),

              AppTextField(
                label: context.tr('Password'),
                hint: context.tr('Enter your password'),
                controller: _passwordController,
                isPassword: true,
                validator: (v) {
                  final value = v ?? '';
                  if (value.isEmpty) return context.tr('Password is required');
                  if (value.length < 6)
                    return context.tr('Password must be at least 6 characters');
                  return null;
                },
              ),
              SizedBox(height: SizeConfig.blockHeight * 2),

              AppTextField(
                label: context.tr('Age'),
                hint: context.tr('Enter your age'),
                controller: _ageController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return context.tr('Age is required');
                  final age = int.tryParse(value);
                  if (age == null)
                    return context.tr('Please enter a valid number');
                  if (age < 5 || age > 120)
                    return context.tr('Please enter a valid age (5–120)');
                  return null;
                },
              ),

              // ── Medical record (patients only) ───────────────
              SizedBox(height: SizeConfig.blockHeight * 2),
              if (isPatient) ...[
                Text(
                  'Medical Record',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickMedicalRecord,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _medicalRecordFile != null
                            ? cs.primary
                            : cs.outline.withOpacity(0.2),
                        width: _medicalRecordFile != null ? 1.5 : 1,
                      ),
                    ),
                    child: _medicalRecordFile != null
                        ? Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _medicalRecordFile!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Record selected',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: cs.primary,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap to change',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: cs.onSurface.withOpacity(
                                              0.5,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.check_circle, color: cs.primary),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file_outlined,
                                color: cs.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Upload Medical Record (optional)',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight * 1),
              ],

              // Upload status indicators
              if (_uploadingAvatar)
                _UploadIndicator(label: 'Uploading profile photo...'),
              if (_uploadingRecord)
                _UploadIndicator(label: 'Uploading medical record...'),

              SizedBox(height: SizeConfig.blockHeight * 3),

              PrimaryButton(
                text: _loading
                    ? context.tr('Creating...')
                    : context.tr('Create Account'),
                onPressed: () {
                  if (!_loading) _onSignUpPressed();
                },
              ),

              SizedBox(height: SizeConfig.blockHeight * 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.tr('Already have an account?'),
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: Text(context.tr('Login')),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.blockHeight * 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadIndicator extends StatelessWidget {
  final String label;
  const _UploadIndicator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
