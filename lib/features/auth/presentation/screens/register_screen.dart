import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/app_text_field.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import '../../patient/presentation/screens/patient_home_screen.dart'; // عدّلي المسار حسب مشروعك
import 'login_screen.dart';

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

      final cred = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = cred.user!;
      await user.updateDisplayName(_nameController.text.trim());

      // 🔥 تخزين البروفايل في Firestore
      await firestore.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "email": _emailController.text.trim(),
        "name": _nameController.text.trim(),
        "age": int.parse(_ageController.text.trim()),
        "role": "doctor", // أو patient
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Register successful")));

      Navigator.pop(context); // يرجع Login
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
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
                'Sign up',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: SizeConfig.blockHeight * 3),

              AppTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: _nameController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  return null;
                },
              ),

              SizedBox(height: SizeConfig.blockHeight * 2),

              AppTextField(
                label: 'Email',
                hint: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Email is required';
                  if (!value.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),

              SizedBox(height: SizeConfig.blockHeight * 2),

              AppTextField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passwordController,
                obscureText: true,
                validator: (v) {
                  final value = v ?? '';
                  if (value.isEmpty) return 'Password is required';
                  if (value.length < 6) return 'Min 6 characters';
                  return null;
                },
              ),

              SizedBox(height: SizeConfig.blockHeight * 2),

              AppTextField(
                label: 'Age',
                hint: 'Enter your age',
                controller: _ageController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Age is required';
                  final age = int.tryParse(value);
                  if (age == null) return 'Enter a valid number';
                  if (age < 5 || age > 120) return 'Enter a valid age';
                  return null;
                },
              ),

              SizedBox(height: SizeConfig.blockHeight * 3),

              PrimaryButton(
                text: _loading ? 'Creating...' : 'Create Account',
                onPressed: () {
                  if (!_loading) _onSignUpPressed();
                },
              ),
              SizedBox(height: SizeConfig.blockHeight * 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Login'),
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
