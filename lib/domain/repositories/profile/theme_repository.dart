import 'package:incasa_app/core/constants/theme_mode_constants.dart';
import 'package:incasa_app/core/utils/result.dart';

abstract class ThemeRepository {
  Future<Result<AppThemeMode>> getThemeMode();
  Future<Result<void>> saveThemeMode(AppThemeMode mode);
}
