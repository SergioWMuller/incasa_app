import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:incasa_app/data/datasources/local/auth_local_data_source.dart';
import 'package:incasa_app/features/auth/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;
  final AuthLocalDataSource authLocalDataSource;

  AuthCubit({required this.authService, required this.authLocalDataSource})
    : super(const AuthInitial()) {
    checkAuthStatus();
  }

  /// Converte User do Firebase para Map (apenas campos não nulos)
  Map<String, dynamic> _userToMap(User user) {
    final map = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'phoneNumber': user.phoneNumber,
      'emailVerified': user.emailVerified,
    };

    // Remove valores nulos
    map.removeWhere((key, value) => value == null);
    return map;
  }

  void checkAuthStatus() {
    print('🔍 Verificando status de autenticação...');
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      print('👤 Usuário já logado: ${currentUser.email}');
      // Salva os dados do usuário no SharedPreferences
      _saveUserToLocal(currentUser);
      emit(AuthAuthenticated(user: currentUser));
    } else {
      print('🚫 Nenhum usuário logado');
      emit(const AuthUnauthenticated());
    }
  }

  /// Salva dados do usuário no SharedPreferences
  Future<void> _saveUserToLocal(User user) async {
    try {
      final userData = _userToMap(user);
      print('🔐 Salvando dados: $userData');
      await authLocalDataSource.saveUserData(userData);
      print('✅ Dados salvos com sucesso!');
    } catch (e) {
      print('❌ Erro ao salvar: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    print('🚀 Iniciando signInWithGoogle...');
    emit(const AuthLoading());

    print('📞 Chamando authService.signInWithGoogle()...');
    final result = await authService.signInWithGoogle();

    print(
      '📦 Resultado recebido: userCredential=${result.userCredential}, message=${result.message}',
    );

    if (result.userCredential?.user != null) {
      final user = result.userCredential!.user!;
      print('✅ Usuário autenticado: ${user.email}');

      // Salva os dados do usuário no SharedPreferences
      await _saveUserToLocal(user);

      emit(AuthAuthenticated(user: user));
    } else {
      print('❌ Login falhou ou foi cancelado: ${result.message}');
      emit(AuthError(message: result.message));
    }
  }

  Future<void> signOut() async {
    print('🚪 Iniciando logout...');
    emit(const AuthLoading());
    try {
      print('🔵 Fazendo signOut no Firebase...');
      await authService.signOut();

      print('🗑️ Limpando dados do SharedPreferences...');
      await authLocalDataSource.clearUserData();

      print('✅ Logout concluído com sucesso!');
      emit(const AuthUnauthenticated());
    } catch (e) {
      print('❌ Erro ao fazer logout: $e');
      emit(AuthError(message: 'Erro ao fazer logout: $e'));
    }
  }
}
