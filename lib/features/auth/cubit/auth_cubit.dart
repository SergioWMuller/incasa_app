import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/features/auth/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;

  AuthCubit({required this.authService}) : super(const AuthInitial()) {
    checkAuthStatus();
  }

  void checkAuthStatus() {
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      emit(AuthAuthenticated(user: currentUser));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    final result = await authService.signInWithGoogle();

    if (result.userCredential?.user != null) {
      emit(AuthAuthenticated(user: result.userCredential!.user!));
    } else {
      emit(AuthError(message: result.message));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await authService.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Erro ao fazer logout: $e'));
    }
  }
}
