import 'package:incasa_app/core/constants/theme_color_constants.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/repositories/profile/theme_repository.dart';

class GetThemeColor extends UseCase<AppThemeColor, NoParams> {
  final ThemeRepository repository;

  GetThemeColor(this.repository);

  @override
  Future<Result<AppThemeColor>> call(NoParams params) async {
    return await repository.getThemeColor();
  }
}
