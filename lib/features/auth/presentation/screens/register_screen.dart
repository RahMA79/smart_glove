import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/app_text_field.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import '../widgets/login_function.dart' show ensureRoleDoc;

const List<String> kDoctorDomains = [
  "clinic.com",
  "hospital.com",
  "smartgloves.org",
  "doc.com",
];

bool isDoctorEmail(String email) {
  final parts = email.trim().toLowerCase().split("@");
  if (parts.length != 2) return false;
  final domain = parts[1];
  return kDoctorDomains.contains(domain);
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image');

    if (path != null && File(path).existsSync()) {
      setState(() {
        _image = File(path);
      });
    }
  }

  Future<void> pickAndSaveImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    // الحصول على مجلد التطبيق الداخلي
    final directory = await getApplicationDocumentsDirectory();
    final String newPath = '${directory.path}/profile_image.png';

    // نسخ الصورة للمجلد الداخلي
    final File newImage = await File(pickedFile.path).copy(newPath);

    // حفظ المسار في SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', newImage.path);

    // تحديث الحالة لإظهار الصورة
    setState(() {
      _image = newImage;
    });
  }

  Widget buildProfileImage() {
    if (_image != null) {
      return Image.file(_image!, fit: BoxFit.cover, width: 120, height: 120);
    } else {
      return Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    }
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
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;
      final name = _nameController.text.trim();
      final ageText = _ageController.text.trim();
      final age = int.parse(ageText);

      final role = isDoctorEmail(email) ? "doctor" : "patient";

      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Register failed: user is null'))),
        );
        return;
      }

      await user.updateDisplayName(name);

      await firestore.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "email": email,
        "name": name,
        "age": age,
        "role": role,
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await ensureRoleDoc(
        uid: user.uid,
        email: email,
        role: role,
        name: name,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('Register successful as {role}', params: {'role': role}),
          ),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Register error")));
    } on FormatException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Age must be a valid number'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('Unexpected error: {error}', params: {'error': '$e'}),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Create Account'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 5,
          vertical: SizeConfig.blockHeight * 3,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: SizeConfig.blockHeight * 1.5),

              Text(
                context.tr('Sign up'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: SizeConfig.blockHeight * 3),

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
                  if (!value.contains('@'))
                    return context.tr('Enter a valid email');
                  return null;
                },
              ),

              SizedBox(height: SizeConfig.blockHeight * 2),

              AppTextField(
                label: context.tr('Password'),
                hint: context.tr('Enter your password'),
                controller: _passwordController,
                obscureText: true,
                validator: (v) {
                  final value = v ?? '';
                  if (value.isEmpty)
                    return context.tr('Password is required');
                  if (value.length < 6) return context.tr('Min 6 characters');
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
                  if (age == null) return context.tr('Enter a valid number');
                  if (age < 5 || age > 120) return context.tr('Enter a valid age');
                  return null;
                },
              ),
              TextButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.image),
                label: Text(context.tr('Upload Image')),
              ),

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
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(context.tr('Login')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
