import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends ChangeNotifier {
  static const _kLocaleKey = 'app_locale'; // 'en' | 'ar'

  Locale? _locale;
  bool _loaded = false;

  Locale? get locale => _locale;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey);

    if (code == 'ar') {
      _locale = const Locale('ar');
    } else if (code == 'en') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('en');
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }

  Future<void> toggle() async {
    final next = (_locale?.languageCode ?? 'en') == 'ar'
        ? const Locale('en')
        : const Locale('ar');

    await setLocale(next);
  }
}
