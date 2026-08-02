import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  /// Indica que o usuário autenticado ainda não concluiu o onboarding
  /// (novo usuário ou sem CPF gravado). A UI usa isso para abrir o wizard.
  final bool needsOnboarding;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.needsOnboarding = false,
  });

  // Getters para facilitar verificações (seguindo padrão do projeto)
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isUnauthenticated =>
      status == AuthStatus.unauthenticated || user == null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  @override
  List<Object?> get props => [status, user, errorMessage, needsOnboarding];

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? needsOnboarding,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      needsOnboarding: needsOnboarding ?? this.needsOnboarding,
    );
  }
}
