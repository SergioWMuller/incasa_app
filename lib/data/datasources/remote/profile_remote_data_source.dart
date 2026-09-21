import 'package:firebase_auth/firebase_auth.dart';
import 'package:incasa_app/core/network/dio_client.dart';
import 'package:incasa_app/data/datasources/remote/user_supabase_data_source.dart';
import 'package:incasa_app/data/models/profile/user_model.dart';

// ========================================
// INTERFACE (Contrato - não muda)
// ========================================

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile();
  Future<UserModel> updateUserProfile(UserModel user);
}

// ========================================
// IMPLEMENTAÇÃO SUPABASE (MVP - USAR AGORA) ✅
// ========================================

class ProfileSupabaseDataSourceImpl implements ProfileRemoteDataSource {
  final UserSupabaseDataSource userSupabaseDataSource;
  final FirebaseAuth firebaseAuth;

  ProfileSupabaseDataSourceImpl({
    required this.userSupabaseDataSource,
    required this.firebaseAuth,
  });

  /// UID do Firebase do usuário autenticado — resolvido para o UUID do
  /// Supabase (`users.id`) pelo próprio `UserSupabaseDataSource` via `providers`.
  String get _firebaseUid {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }
    return user.uid;
  }

  @override
  Future<UserModel> getUserProfile() async {
    final user = await userSupabaseDataSource.getUserById(_firebaseUid);
    if (user == null) {
      throw Exception('Perfil não encontrado no Supabase');
    }
    return user;
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    return userSupabaseDataSource.updateUser(_firebaseUid, user);
  }
}

// ========================================
// IMPLEMENTAÇÃO LARAVEL API (FUTURO) 📦
// ========================================

class ProfileApiDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileApiDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> getUserProfile() async {
    final response = await dioClient.get('/user/profile');
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    final response = await dioClient.put('/user/profile', data: user.toJson());
    return UserModel.fromJson(response.data);
  }
}
