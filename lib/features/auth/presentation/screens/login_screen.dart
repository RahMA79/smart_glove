import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/app_text_field.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header image
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/login.png',
                  fit: BoxFit.cover,
                  height: SizeConfig.blockHeight * 30,
                  width: double.infinity,
                ),
              ),

              SizedBox(height: SizeConfig.blockHeight * 3),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.tr('Welcome Back'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 0.5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.tr('Login to your account'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.blockHeight * 3),

              // Email
              AppTextField(
                label: context.tr('Email'),
                hint: context.tr('Enter your email'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return context.tr('Email is required');
                  final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.\w{2,}$');
                  if (!emailRegex.hasMatch(value)) {
                    return context.tr('Please enter a valid email address');
                  }
                  return null;
                },
              ),

              SizedBox(height: SizeConfig.blockHeight * 2),

              // Password with toggle
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

              SizedBox(height: SizeConfig.blockHeight * 3.5),

              PrimaryButton(
                text: _loading
                    ? context.tr('Logging in...')
                    : context.tr('Login'),
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
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: Text(context.tr('Sign up')),
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
