import 'package:incasa_app/core/constants/theme_mode_constants.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/repositories/profile/theme_repository.dart';

class GetThemeMode extends UseCase<AppThemeMode, NoParams> {
  final ThemeRepository repository;

  GetThemeMode(this.repository);

  @override
  Future<Result<AppThemeMode>> call(NoParams params) async {
    return await repository.getThemeMode();
  }
}
