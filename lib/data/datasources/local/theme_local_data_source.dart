import 'package:incasa_app/core/constants/theme_mode_constants.dart';
import 'package:incasa_app/core/constants/theme_color_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemeLocalDataSource {
  Future<AppThemeMode> getThemeMode();
  Future<void> saveThemeMode(AppThemeMode mode);
  Future<AppThemeColor> getThemeColor();
  Future<void> saveThemeColor(AppThemeColor color);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  static const String _keyModoTema = 'modoTema';
  static const String _keyCorTema = 'corTema';

  SharedPreferences? _cachedPrefs;

  Future<SharedPreferences> get _prefs async {
    _cachedPrefs ??= await SharedPreferences.getInstance();
    return _cachedPrefs!;
  }

  /// Inicializa os valores padrão se for a primeira vez
  Future<void> _initializeDefaults() async {
    final prefs = await _prefs;

    if (!prefs.containsKey(_keyModoTema)) {
      await prefs.setString(_keyModoTema, AppThemeMode.light.name);
    }

    if (!prefs.containsKey(_keyCorTema)) {
      await prefs.setString(_keyCorTema, AppThemeColor.blue.name);
    }
  }

  @override
  Future<AppThemeMode> getThemeMode() async {
    await _initializeDefaults();
    final prefs = await _prefs;
    final modeString = prefs.getString(_keyModoTema) ?? AppThemeMode.light.name;
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == modeString,
      orElse: () => AppThemeMode.light,
    );
  }

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {
    final prefs = await _prefs;
    await prefs.setString(_keyModoTema, mode.name);
  }

  @override
  Future<AppThemeColor> getThemeColor() async {
    await _initializeDefaults();
    final prefs = await _prefs;
    final colorString = prefs.getString(_keyCorTema) ?? AppThemeColor.blue.name;
    return AppThemeColor.values.firstWhere(
      (color) => color.name == colorString,
      orElse: () => AppThemeColor.blue,
    );
  }

  @override
  Future<void> saveThemeColor(AppThemeColor color) async {
    final prefs = await _prefs;
    await prefs.setString(_keyCorTema, color.name);
  }
}
