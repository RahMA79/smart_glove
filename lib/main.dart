import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/doctor/presentation/screens/doctor_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Rehab Glove',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const DoctorHomeScreen(),
    );
  }
}
