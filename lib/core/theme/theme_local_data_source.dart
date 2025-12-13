import 'package:shared_preferences/shared_preferences.dart';

class ThemeLocalDataSource {
  static const String _keyIsDark = 'is_dark_mode';

  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDark) ?? false; // false = Light by default
  }

  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDark, isDark);
  }
}
