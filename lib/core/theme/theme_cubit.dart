import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/constants/theme_mode_constants.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/usecases/profile/get_theme_mode.dart';
import 'package:incasa_app/domain/usecases/profile/save_theme_mode.dart';

class ThemeState extends Equatable {
  final AppThemeMode mode;

  const ThemeState(this.mode);

  @override
  List<Object?> get props => [mode];
}

class ThemeCubit extends Cubit<ThemeState> {
  final GetThemeMode getThemeModeUseCase;
  final SaveThemeMode saveThemeModeUseCase;

  ThemeCubit({
    required this.getThemeModeUseCase,
    required this.saveThemeModeUseCase,
  }) : super(const ThemeState(AppThemeMode.system));

  Future<void> loadThemeMode() async {
    final result = await getThemeModeUseCase(const NoParams());

    switch (result) {
      case Success(:final data):
        emit(ThemeState(data));
      case Error():
        emit(const ThemeState(AppThemeMode.system));
    }
  }

  Future<void> changeThemeMode(AppThemeMode mode) async {
    emit(ThemeState(mode));
    await saveThemeModeUseCase(SaveThemeModeParams(mode));
  }
}
