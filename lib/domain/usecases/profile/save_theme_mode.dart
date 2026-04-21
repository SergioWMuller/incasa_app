import 'package:equatable/equatable.dart';
import 'package:incasa_app/core/constants/theme_mode_constants.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/repositories/profile/theme_repository.dart';

class SaveThemeModeParams extends Equatable {
  final AppThemeMode mode;

  const SaveThemeModeParams(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SaveThemeMode extends UseCase<void, SaveThemeModeParams> {
  final ThemeRepository repository;

  SaveThemeMode(this.repository);

  @override
  Future<Result<void>> call(SaveThemeModeParams params) async {
    return await repository.saveThemeMode(params.mode);
  }
}
