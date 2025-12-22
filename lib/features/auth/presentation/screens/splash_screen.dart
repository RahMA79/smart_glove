import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_glove/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:smart_glove/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/doctor_home_screen.dart';
import 'package:smart_glove/features/patient/presentation/screens/patient_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _floatY;
  late final Animation<double> _fadeIn;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _scale = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _floatY = Tween<double>(
      begin: -12,
      end: 12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glow = Tween<double>(
      begin: 0.15,
      end: 0.35,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
    _controller.repeat(reverse: true);

    // ✅ بعد وقت السبلاتش: قرري تروحي فين
    Future.delayed(const Duration(seconds: 4), () async {
      if (!mounted) return;
      await _routeAfterSplash();
    });
  }

  Future<void> _routeAfterSplash() async {
    final prefs = await SharedPreferences.getInstance();

    final seenOnboarding = prefs.getBool("seenOnboarding") ?? false;
    final isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    final role = prefs.getString("role"); // doctor / patient

    final user = FirebaseAuth.instance.currentUser;

    if (isLoggedIn && user != null && role != null) {
      if (!mounted) return;

      if (role == "doctor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PatientHomeScreen(userId: user.uid),
          ),
        );
      }
      return;
    }

    // ✅ مش logged in
    if (!mounted) return;

    if (!seenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    final imageSize = (size.shortestSide * 0.62).clamp(220.0, 520.0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF070B16), Color(0xFF0B1020)]
                : const [Color(0xFFF7F9FB), Color(0xFFEFF4FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.translate(
                    offset: Offset(0, _floatY.value),
                    child: Transform.scale(
                      scale: _scale.value,
                      child: SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isDark
                                                ? const Color(0xFF6EA8FF)
                                                : const Color(0xFF2B6DFF))
                                            .withOpacity(_glow.value),
                                    blurRadius: 50,
                                    spreadRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              'assets/images/splash_glove.png',
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              isAntiAlias: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
