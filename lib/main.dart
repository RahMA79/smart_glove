import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_glove/features/auth/presentation/screens/splash_screen.dart';
import 'package:smart_glove/features/auth/presentation/widgets/login_function.dart';
import 'package:smart_glove/features/doctor/presentation/screens/doctor_home_screen.dart';
import 'package:smart_glove/features/patient/patient_report/data/models/patient_report_model.dart';
import 'package:smart_glove/features/patient/patient_report/presentation/screens/patient_report_screen.dart';
import 'package:smart_glove/features/patient/presentation/screens/patient_home_screen.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'core/theme/theme_local_data_source.dart';
import 'core/theme/theme_repository.dart';

void main() async {
  final themeLocalDataSource = ThemeLocalDataSource();
  final themeRepository = ThemeRepository(themeLocalDataSource);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(themeRepository),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final report = PatientReportModel(
      conditionTitle: "Flexor Tendon Injury",
      duration: const Duration(minutes: 5),
      exercisesDone: 3,
      painLevel: 2,
      sessionAccuracy: 0.95,
      progressRate: 0.03,
      patientLevel: "Flaccid",
    );
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    if (!themeNotifier.isLoaded) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Smart Rehab Glove',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeNotifier.themeMode,

      home: SplashScreen(),
    );
  }
}
