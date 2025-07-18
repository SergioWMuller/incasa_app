import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_incasa_app/features/auth/services/auth_service.dart';
import 'package:projeto_incasa_app/data/models/auth_result_google.dart';
import '../states/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthService authService;

  ProfileCubit({AuthService? authService})
      : authService = authService ?? AuthService(),
        super(ProfileInitial());

  void loadProfile() {
    emit(ProfileLoading());
    final user = FirebaseAuth.instance.currentUser;
    emit(ProfileLoaded(user: user));
  }

  Future<void> signInWithGoogle() async {
    emit(ProfileLoading());
    final AuthResult result =
        await authService.signInWithGoogleAndSaveToSupabase();
    final user = result.userCredential?.user;
    if (user != null) {
      emit(ProfileLoggedIn(user: user, supabaseSaved: result.supabaseSaved));
      emit(ProfileLoaded(user: user)); // Para atualizar avatar na tela
    } else {
      emit(ProfileLoginFailed(message: result.message));
    }
  }

  Future<void> signOut() async {
    emit(ProfileLoading());
    await authService.signOut();
    emit(ProfileLoggedOut());
    emit(ProfileLoaded(user: null));
  }
}
