import 'package:flutter/material.dart';
import 'theme_repository.dart';

class ThemeNotifier extends ChangeNotifier {
  final ThemeRepository _repository;

  bool _isDark = false;
  bool _isLoaded = false;

  ThemeNotifier(this._repository) {
    _loadTheme();
  }

  bool get isDark => _isDark;
  bool get isLoaded => _isLoaded;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> _loadTheme() async {
    _isDark = await _repository.getSavedTheme();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDark = value;
    await _repository.saveTheme(value);
    notifyListeners();
  }
}
