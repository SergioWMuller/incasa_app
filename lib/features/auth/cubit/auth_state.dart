import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  // Getters para facilitar verificações (seguindo padrão do projeto)
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isUnauthenticated =>
      status == AuthStatus.unauthenticated || user == null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  @override
  List<Object?> get props => [status, user, errorMessage];

  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
