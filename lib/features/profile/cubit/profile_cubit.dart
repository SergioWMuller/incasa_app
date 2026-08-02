import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/usecases/profile/get_user_profile.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfile getUserProfileUseCase;

  ProfileCubit({required this.getUserProfileUseCase})
    : super(const ProfileState());

  void setOnboardingPhase(bool isOnboardingPhase) {
    getUserProfileUseCase.setOnboardingPhase(isOnboardingPhase);
    emit(state.copyWith(isOnboardingPhase: isOnboardingPhase));
  }

  Future<void> loadProfile() async {
    emit(const ProfileState(status: ProfileStatus.loading));

    final result = await getUserProfileUseCase(const NoParams());

    switch (result) {
      case Success(:final data):
        emit(ProfileState(status: ProfileStatus.loaded, user: data));
      case Error(:final failure):
        emit(
          ProfileState(
            status: ProfileStatus.error,
            errorMessage: failure.message,
          ),
        );
    }
  }

  /// Limpa o estado do perfil (usado ao fazer logout)
  void clearProfile() {
    emit(const ProfileState(status: ProfileStatus.loading));
  }
}
