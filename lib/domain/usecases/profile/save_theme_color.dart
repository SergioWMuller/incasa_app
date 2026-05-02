import 'package:equatable/equatable.dart';
import 'package:incasa_app/core/constants/theme_color_constants.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/repositories/profile/theme_repository.dart';

class SaveThemeColorParams extends Equatable {
  final AppThemeColor color;

  const SaveThemeColorParams(this.color);

  @override
  List<Object?> get props => [color];
}

class SaveThemeColor extends UseCase<void, SaveThemeColorParams> {
  final ThemeRepository repository;

  SaveThemeColor(this.repository);

  @override
  Future<Result<void>> call(SaveThemeColorParams params) async {
    return await repository.saveThemeColor(params.color);
  }
}
