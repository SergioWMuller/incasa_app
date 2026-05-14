import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:incasa_app/core/network/dio_client.dart';
import 'package:incasa_app/data/models/profile/user_model.dart';

// ========================================
// INTERFACE (Contrato - não muda)
// ========================================

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile();
  Future<UserModel> updateUserProfile(UserModel user);
}

// ========================================
// IMPLEMENTAÇÃO FIREBASE (MVP - USAR AGORA) ✅
// ========================================

class ProfileFirebaseDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ProfileFirebaseDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  /// Obtém o ID do usuário autenticado
  String get _currentUserId {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }
    return user.uid;
  }

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final doc = await firestore.collection('users').doc(_currentUserId).get();

      if (!doc.exists) {
        throw Exception('Perfil não encontrado');
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao buscar perfil: $e');
    }
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      await firestore
          .collection('users')
          .doc(_currentUserId)
          .update(user.toFirestore());

      // Retorna o perfil atualizado
      return getUserProfile();
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
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
