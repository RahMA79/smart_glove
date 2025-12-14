/*
import 'package:flutter/material.dart';
import 'package:graduation_app/config/appcolors.dart';
//import '../theme/colors.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Image.network('https://cdn-icons-png.freepik.com/256/2248/2248611.png?semt=ais_white_label'),
              //Image.asset('assets\images\logo.png'),
              //Icon(Icons.pan_tool_alt, size: 45, color: AppColors.primary),
            ),
            SizedBox(height: 20),
            Text(
              "Smart\nRehabilitation Glove",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:smart_glove/features/auth/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (Context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Image.asset('assets/images/logo.png'),
              //Image.network('https://cdn-icons-png.freepik.com/256/2248/2248611.png?semt=ais_white_label'),
              //Icon(Icons.pan_tool_alt, size: 45, color: Color(0xFF3E8BFF)),
            ),
            const SizedBox(height: 20),
            const Text(
              "Smart\nRehabilitation Glove",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
