import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/app_text_field.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:smart_glove/sensor.dart';
import 'package:provider/provider.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/core/localization/locale_notifier.dart';

import '../widgets/login_function.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await validate_email_password(
        context,
        _auth,
        _emailController,
        _passwordController,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Login')),
        actions: [
          IconButton(
            tooltip: context.tr('Language'),
            icon: const Icon(Icons.language),
            onPressed: () => context.read<LocaleNotifier>().toggle(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 5,
          vertical: SizeConfig.blockHeight * 3,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                'assets/images/login.png',
                fit: BoxFit.cover,
                height: SizeConfig.blockHeight * 35,
              ),

              SizedBox(height: SizeConfig.blockHeight * 4),

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
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                validator: (v) {
                  final value = v ?? '';
                  if (value.isEmpty)
                    return context.tr('Password is required');
                  if (value.length < 6)
                    return context.tr('Min 6 characters');
                  return null;
                },
              ),

              SizedBox(height: SizeConfig.blockHeight * 3),

              PrimaryButton(
                text: _loading ? context.tr('Loading...') : context.tr('Login'),
                onPressed: () {
                  if (!_loading) _onLoginPressed();
                },
              ),

              SizedBox(height: SizeConfig.blockHeight * 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.tr("Don't have an account?"),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(context.tr('Sign up')),
                  ),
                ],
              ),

              TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SensorScreen(),
                        ),
                      );
                    },
                    child: Text(context.tr('sensor_screen')),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
