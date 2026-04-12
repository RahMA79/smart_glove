import 'package:flutter/material.dart';
import 'theme_repository.dart';

enum AppThemeMode { light, system, dark }

class ThemeNotifier extends ChangeNotifier {
  final ThemeRepository _repository;

  AppThemeMode _mode = AppThemeMode.system;
  bool _isLoaded = false;

  ThemeNotifier(this._repository) {
    _loadTheme();
  }

  AppThemeMode get appThemeMode => _mode;
  bool get isLoaded => _isLoaded;

  /// Legacy getter kept for backward compat
  bool get isDark => _mode == AppThemeMode.dark;

  ThemeMode get themeMode {
    switch (_mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> _loadTheme() async {
    final isDark = await _repository.getSavedTheme();
    // Try to load extended mode from prefs
    _mode = isDark ? AppThemeMode.dark : AppThemeMode.light;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setAppThemeMode(AppThemeMode mode) async {
    _mode = mode;
    await _repository.saveTheme(mode == AppThemeMode.dark);
    notifyListeners();
  }

  /// Legacy toggle kept for backward compat
  Future<void> toggleTheme(bool value) async {
    await setAppThemeMode(value ? AppThemeMode.dark : AppThemeMode.light);
  }
}
