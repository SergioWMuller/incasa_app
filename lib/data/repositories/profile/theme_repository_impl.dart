import 'package:incasa_app/core/constants/theme_mode_constants.dart';
import 'package:incasa_app/core/constants/theme_color_constants.dart';
import 'package:incasa_app/core/error/failures.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/data/datasources/local/theme_local_data_source.dart';
import 'package:incasa_app/domain/repositories/profile/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource localDataSource;

  ThemeRepositoryImpl(this.localDataSource);

  @override
  Future<Result<AppThemeMode>> getThemeMode() async {
    try {
      final mode = await localDataSource.getThemeMode();
      return Success(mode);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveThemeMode(AppThemeMode mode) async {
    try {
      await localDataSource.saveThemeMode(mode);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<AppThemeColor>> getThemeColor() async {
    try {
      final color = await localDataSource.getThemeColor();
      return Success(color);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveThemeColor(AppThemeColor color) async {
    try {
      await localDataSource.saveThemeColor(color);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }
}
