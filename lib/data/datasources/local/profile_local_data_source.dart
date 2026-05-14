import 'package:incasa_app/data/datasources/local/auth_local_data_source.dart';
import 'package:incasa_app/data/models/profile/user_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserModel> getUserProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final AuthLocalDataSource authLocalDataSource;

  ProfileLocalDataSourceImpl({required this.authLocalDataSource});

  @override
  Future<UserModel> getUserProfile() async {
    // Busca os dados do usuário autenticado salvos no SharedPreferences
    final userData = await authLocalDataSource.getUserData();

    if (userData == null) {
      throw Exception('Usuário não autenticado');
    }

    // Mapeia os dados do Firebase Auth para o formato do UserModel
    final userMap = {
      "uid": userData['uid'] ?? '',
      "email": userData['email'],
      "fullName": userData['displayName'],
      "displayName": userData['displayName'],
      "photoUrl": userData['photoURL'],
      "phoneNumber": userData['phoneNumber'],
      "emailVerified": userData['emailVerified'] ?? false,
      "createdAt": DateTime.now()
          .toIso8601String(), // Firebase não retorna createdAt facilmente
    };

    return UserModel.fromJson(userMap);
  }
}
