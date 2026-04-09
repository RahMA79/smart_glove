import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_glove/features/auth/presentation/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'core/theme/theme_local_data_source.dart';
import 'core/theme/theme_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_notifier.dart';

const String supabaseUrl = 'https://gxiytqblojeitrebecfw.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd4aXl0cWJsb2plaXRyZWJlY2Z3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNzM3NjgsImV4cCI6MjA4ODg0OTc2OH0.FYg-TRwVoB5P9qNGdAkcMphfhgly9yv-ehGgTnoHLls';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final themeLocalDataSource = ThemeLocalDataSource();
  final themeRepository = ThemeRepository(themeLocalDataSource);

  final localeNotifier = LocaleNotifier();
  await localeNotifier.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier(themeRepository)),
        ChangeNotifierProvider(create: (_) => localeNotifier),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    if (!themeNotifier.isLoaded || !localeNotifier.isLoaded) {
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
      locale: localeNotifier.locale,
      supportedLocales: AppLocalizations.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(),
    );
  }
}
