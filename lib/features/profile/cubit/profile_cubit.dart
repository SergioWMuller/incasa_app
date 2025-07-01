import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    emit(LoadingProfileState());
  }
}
