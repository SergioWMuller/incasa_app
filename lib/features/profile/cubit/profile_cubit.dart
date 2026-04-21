import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/usecases/profile/get_user_profile.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfile getUserProfileUseCase;

  ProfileCubit({required this.getUserProfileUseCase})
    : super(const ProfileLoading());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());

    final result = await getUserProfileUseCase(const NoParams());

    switch (result) {
      case Success(:final data):
        emit(ProfileLoaded(data));
      case Error(:final failure):
        emit(ProfileError(failure.message));
    }
  }
}
