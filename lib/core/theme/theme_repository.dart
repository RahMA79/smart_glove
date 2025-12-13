import 'theme_local_data_source.dart';

class ThemeRepository {
  final ThemeLocalDataSource localDataSource;

  ThemeRepository(this.localDataSource);

  Future<bool> getSavedTheme() async {
    return await localDataSource.loadTheme();
  }

  Future<void> saveTheme(bool isDark) async {
    await localDataSource.saveTheme(isDark);
  }
}
