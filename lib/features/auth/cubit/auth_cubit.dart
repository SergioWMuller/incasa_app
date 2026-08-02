import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:incasa_app/core/network/supabase_session.dart';
import 'package:incasa_app/data/datasources/local/auth_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/user_supabase_data_source.dart';
import 'package:incasa_app/data/models/profile/user_model.dart';
import 'package:incasa_app/features/auth/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  void logAuth(String message) {
    print('[AUTH] $message');
  }

  final AuthService authService;
  final AuthLocalDataSource authLocalDataSource;
  final UserSupabaseDataSource userSupabaseDataSource;

  AuthCubit({
    required this.authService,
    required this.authLocalDataSource,
    required this.userSupabaseDataSource,
  }) : super(const AuthState()) {
    // Permite ao cliente Supabase renovar o JWT (exp ~1h) sob demanda.
    SupabaseSession.instance.registerRefresher(
      authService.refreshSupabaseAccessToken,
    );
  }

  /// Converte User do Firebase para Map (apenas campos não nulos).
  ///
  /// E-mail/telefone vêm da identidade do Firebase; o `id` é o UUID interno
  /// resolvido no Supabase (recurso `users`).
  Map<String, dynamic> _userToMap(User user, {String? supabaseUserId}) {
    final map = <String, dynamic>{
      if (supabaseUserId != null) 'id': supabaseUserId,
      'uid': user.uid,
      'displayName': user.displayName,
      'email': user.email,
      'emailVerified': user.emailVerified,
      'photoURL': user.photoURL,
      'phoneNumber': user.phoneNumber,
    };

    // Remove valores nulos
    map.removeWhere((key, value) => value == null);
    return map;
  }

  void checkAuthStatus() async {
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      // Renova o JWT do Supabase para que as chamadas REST/RPC autentiquem como
      // o próprio usuário (app_user_id()). Sem isso, caem na anon key.
      SupabaseSession.instance.setToken(
        await authService.refreshSupabaseAccessToken(),
      );

      UserModel? supabaseUser;
      try {
        // Busca dados completos do Supabase
        supabaseUser = await userSupabaseDataSource.getUserById(
          currentUser.uid,
        );
        logAuth('SupabaseUser: ${supabaseUser?.toJson()}');
      } catch (e) {
        // Não bloqueia autenticação local caso Supabase esteja sem sessão/chave.
        logAuth('Falha ao buscar usuário no Supabase no bootstrap: $e');
      }

      // Salva os dados completos do usuário no SharedPreferences
      await _saveUserToLocal(currentUser, supabaseUser: supabaseUser);
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: currentUser,
          needsOnboarding: _needsOnboarding(supabaseUser, isNewUser: false),
        ),
      );
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  /// Decide se o onboarding ainda precisa ser feito.
  ///
  /// Novo usuário sempre precisa. Para os demais, usamos a ausência de
  /// `cpf_hmac` como sinal — o CPF é a última etapa, então sem ele o cadastro
  /// está incompleto. Se não conseguimos ler o usuário, não forçamos (evita
  /// abrir o wizard por falha de rede/sessão).
  bool _needsOnboarding(UserModel? supabaseUser, {required bool isNewUser}) {
    if (isNewUser) return true;
    if (supabaseUser == null) return false;
    final cpfHmac = supabaseUser.cpfHmac;
    return cpfHmac == null || cpfHmac.isEmpty;
  }

  /// Reavalia o status do onboarding (ex.: ao voltar do wizard).
  Future<void> refreshOnboardingStatus() async {
    final currentUser = authService.currentUser;
    if (currentUser == null) return;

    UserModel? supabaseUser;
    try {
      supabaseUser = await userSupabaseDataSource.getUserById(currentUser.uid);
    } catch (e) {
      logAuth('Falha ao reavaliar onboarding: $e');
    }

    emit(
      state.copyWith(
        needsOnboarding: _needsOnboarding(supabaseUser, isNewUser: false),
      ),
    );
  }

  /// Salva dados do usuário no SharedPreferences
  Future<void> _saveUserToLocal(User user, {UserModel? supabaseUser}) async {
    try {
      final userData = _userToMap(user, supabaseUserId: supabaseUser?.id);
      await authLocalDataSource.saveUserData(userData);
    } catch (e) {
      // Falha silenciosa - não bloqueia o fluxo de autenticação
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthState(status: AuthStatus.loading));
    final result = await authService.signInWithGoogle();

    if (result.userCredential?.user != null) {
      final firebaseUser = result.userCredential!.user!;

      // Guarda o JWT do Supabase para autenticar as próximas chamadas.
      SupabaseSession.instance.setToken(result.supabaseAccessToken);

      if (!result.supabaseSaved) {
        logAuth(
          'Aviso: login Firebase ok, mas sincronização via Edge falhou: ${result.message}',
        );
      }

      // 1. Busca dados completos do Supabase (incluindo cpf)
      UserModel? supabaseUser;
      try {
        supabaseUser = await userSupabaseDataSource.getUserById(
          firebaseUser.uid,
        );
        logAuth('SupabaseUser: ${supabaseUser?.toJson()}');
      } catch (e) {
        // Não bloqueia login Firebase se leitura Supabase falhar.
        logAuth('Falha ao buscar usuário no Supabase após login: $e');
      }

      final mergedSupabaseUser =
          supabaseUser ??
          (result.userId != null
              ? UserModel(
                  id: result.userId!,
                  fullName: firebaseUser.displayName ?? '',
                  displayName: firebaseUser.displayName,
                  photoUrl: firebaseUser.photoURL,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                )
              : null);

      // 2. Salva os dados completos no SharedPreferences (local)
      await _saveUserToLocal(firebaseUser, supabaseUser: mergedSupabaseUser);

      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: firebaseUser,
          needsOnboarding: _needsOnboarding(
            supabaseUser,
            isNewUser: result.isNewUser,
          ),
        ),
      );
    } else {
      logAuth(
        'AuthErrorResponse: ${<String, dynamic>{'message': result.message, 'supabaseSaved': result.supabaseSaved, 'hasUserCredential': result.userCredential != null, 'hasUser': result.userCredential?.user != null}}',
      );
      emit(AuthState(status: AuthStatus.error, errorMessage: result.message));
    }
  }

  Future<void> signOut() async {
    emit(const AuthState(status: AuthStatus.loading));
    logAuth('Iniciando logout');
    try {
      await authService.signOut();
      await authLocalDataSource.clearUserData();
      SupabaseSession.instance.clear();
      logAuth('Logout realizado com sucesso');
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (e) {
      logAuth('Erro ao fazer logout: $e');
      emit(
        AuthState(
          status: AuthStatus.error,
          errorMessage: 'Erro ao fazer logout: $e',
        ),
      );
    }
  }
}
