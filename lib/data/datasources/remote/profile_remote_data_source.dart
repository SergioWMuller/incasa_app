import 'package:incasa_app/core/network/dio_client.dart';
import 'package:incasa_app/data/models/profile/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile();
  Future<UserModel> updateUserProfile(UserModel user);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSourceImpl(this.dioClient);

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
