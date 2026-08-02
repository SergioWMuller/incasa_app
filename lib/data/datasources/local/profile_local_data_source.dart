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

    // Mapeia os dados do cache (derivados do Firebase Auth) para o recurso
    // `users`. E-mail/telefone não pertencem a este recurso e são lidos da
    // identidade do Firebase onde necessário.
    final userMap = {
      "id": userData['id'] ?? userData['uid'] ?? '',
      "full_name": userData['displayName'] ?? '',
      "display_name": userData['displayName'],
      "photo_url": userData['photoURL'],
      "created_at": DateTime.now().toIso8601String(),
    };

    return UserModel.fromJson(userMap);
  }
}
