import 'package:incasa_app/data/models/profile/user_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserModel> getUserProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final Map<String, dynamic> _mockUser = {
    "id": "user001",
    "name": "João Silva",
    "email": "joao.silva@email.com",
    "avatarUrl": "https://via.placeholder.com/150",
    "phone": "(11) 98765-4321",
    "createdAt": "2024-01-01T10:00:00",
  };

  @override
  Future<UserModel> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UserModel.fromJson(_mockUser);
  }
}
