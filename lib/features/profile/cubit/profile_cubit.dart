import 'package:flutter_bloc/flutter_bloc.dart';

import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(LoadingProfileState());

  void loadProfile() {
    try {
      emit(LoadedProfileState());
    } catch (e) {
      emit(
        ErrorProfileState(
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
