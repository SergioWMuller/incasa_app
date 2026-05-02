import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/constants/theme_mode_constants.dart';
import 'package:incasa_app/core/constants/theme_color_constants.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/usecases/profile/get_theme_mode.dart';
import 'package:incasa_app/domain/usecases/profile/save_theme_mode.dart';
import 'package:incasa_app/domain/usecases/profile/get_theme_color.dart';
import 'package:incasa_app/domain/usecases/profile/save_theme_color.dart';

class ThemeState extends Equatable {
  final AppThemeMode mode;
  final AppThemeColor color;

  const ThemeState({required this.mode, required this.color});

  @override
  List<Object?> get props => [mode, color];

  ThemeState copyWith({AppThemeMode? mode, AppThemeColor? color}) {
    return ThemeState(mode: mode ?? this.mode, color: color ?? this.color);
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  final GetThemeMode getThemeModeUseCase;
  final SaveThemeMode saveThemeModeUseCase;
  final GetThemeColor getThemeColorUseCase;
  final SaveThemeColor saveThemeColorUseCase;

  ThemeCubit({
    required this.getThemeModeUseCase,
    required this.saveThemeModeUseCase,
    required this.getThemeColorUseCase,
    required this.saveThemeColorUseCase,
  }) : super(
         const ThemeState(mode: AppThemeMode.light, color: AppThemeColor.blue),
       );

  Future<void> loadThemeSettings() async {
    final modeResult = await getThemeModeUseCase(const NoParams());
    final colorResult = await getThemeColorUseCase(const NoParams());

    final mode = switch (modeResult) {
      Success(:final data) => data,
      Error() => AppThemeMode.light,
    };

    final color = switch (colorResult) {
      Success(:final data) => data,
      Error() => AppThemeColor.blue,
    };

    emit(ThemeState(mode: mode, color: color));
  }

  Future<void> changeThemeMode(AppThemeMode mode) async {
    emit(state.copyWith(mode: mode));
    await saveThemeModeUseCase(SaveThemeModeParams(mode));
  }

  Future<void> changeThemeColor(AppThemeColor color) async {
    emit(state.copyWith(color: color));
    await saveThemeColorUseCase(SaveThemeColorParams(color));
  }
}
