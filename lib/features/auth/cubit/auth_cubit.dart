import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:incasa_app/data/datasources/local/auth_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/user_supabase_data_source.dart';
import 'package:incasa_app/data/models/profile/user_model.dart';
import 'package:incasa_app/features/auth/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;
  final AuthLocalDataSource authLocalDataSource;
  final UserSupabaseDataSource userSupabaseDataSource;

  AuthCubit({
    required this.authService,
    required this.authLocalDataSource,
    required this.userSupabaseDataSource,
  }) : super(const AuthState()) {
    checkAuthStatus();
  }

  /// Converte User do Firebase para Map (apenas campos não nulos)
  Map<String, dynamic> _userToMap(User user, {String? cpf}) {
    final map = <String, dynamic>{
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
      // Busca dados completos do Supabase
      final supabaseUser = await userSupabaseDataSource.getUserByUid(
        currentUser.uid,
      );

      // Salva os dados completos do usuário no SharedPreferences
      await _saveUserToLocal(currentUser, cpf: supabaseUser?.cpf);
      emit(AuthState(status: AuthStatus.authenticated, user: currentUser));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  /// Salva dados do usuário no SharedPreferences
  Future<void> _saveUserToLocal(User user, {String? cpf}) async {
    try {
      final userData = _userToMap(user, cpf: cpf);
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

      // 1. Salva/Atualiza os dados do usuário no Supabase (remoto)
      await _syncUserToSupabase(firebaseUser);

      // 2. Busca dados completos do Supabase (incluindo cpf)
      final supabaseUser = await userSupabaseDataSource.getUserByUid(
        firebaseUser.uid,
      );

      // 3. Salva os dados completos no SharedPreferences (local)
      await _saveUserToLocal(firebaseUser, cpf: supabaseUser?.cpf);

      emit(AuthState(status: AuthStatus.authenticated, user: firebaseUser));
    } else {
      emit(AuthState(status: AuthStatus.error, errorMessage: result.message));
    }
  }

  /// Sincroniza dados do usuário do Firebase para o Supabase
  Future<void> _syncUserToSupabase(User firebaseUser) async {
    try {
      // Verifica se usuário já existe no Supabase
      final existingUser = await userSupabaseDataSource.getUserByUid(
        firebaseUser.uid,
      );

      if (existingUser == null) {
        // Cria novo usuário no Supabase
        final newUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          fullName: firebaseUser.displayName,
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
          phoneNumber: firebaseUser.phoneNumber,
          emailVerified: firebaseUser.emailVerified,
          createdAt: DateTime.now(),
        );

        await userSupabaseDataSource.createUser(newUser);
      } else {
        // Atualiza dados do usuário existente (caso tenha mudado algo no Firebase)
        final updatedUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? existingUser.email,
          fullName: firebaseUser.displayName ?? existingUser.fullName,
          displayName: firebaseUser.displayName ?? existingUser.displayName,
          photoUrl: firebaseUser.photoURL ?? existingUser.photoUrl,
          phoneNumber: firebaseUser.phoneNumber ?? existingUser.phoneNumber,
          emailVerified: firebaseUser.emailVerified,
          createdAt: existingUser.createdAt,
          // Mantém dados adicionais do Supabase
          cpf: existingUser.cpf,
          lastSignInTime: DateTime.now(),
          sellerRating: existingUser.sellerRating,
          isSeller: existingUser.isSeller,
          defaultShippingStreet: existingUser.defaultShippingStreet,
          defaultShippingNumber: existingUser.defaultShippingNumber,
          defaultShippingComplement: existingUser.defaultShippingComplement,
          defaultShippingNeighborhood: existingUser.defaultShippingNeighborhood,
          defaultShippingCity: existingUser.defaultShippingCity,
          defaultShippingState: existingUser.defaultShippingState,
          defaultShippingZipCode: existingUser.defaultShippingZipCode,
          phoneVerified: existingUser.phoneVerified,
          isPhoneWhatsApp: existingUser.isPhoneWhatsApp,
        );

        await userSupabaseDataSource.updateUser(firebaseUser.uid, updatedUser);
      }
    } catch (e) {
      // Log do erro mas não bloqueia o fluxo de autenticação
      // Em produção, envie para um serviço de logging (Sentry, Firebase Crashlytics, etc)
    }
  }

  Future<void> signOut() async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      await authService.signOut();
      await authLocalDataSource.clearUserData();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(
        AuthState(
          status: AuthStatus.error,
          errorMessage: 'Erro ao fazer logout: $e',
        ),
      );
    }
  }
}
