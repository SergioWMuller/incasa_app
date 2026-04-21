import 'package:incasa_app/core/constants/theme_mode_constants.dart';

abstract class ThemeLocalDataSource {
  Future<AppThemeMode> getThemeMode();
  Future<void> saveThemeMode(AppThemeMode mode);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  AppThemeMode _currentMode = AppThemeMode.system;

  @override
  Future<AppThemeMode> getThemeMode() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentMode;
  }

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentMode = mode;
  }
}
