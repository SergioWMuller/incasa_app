import 'package:incasa_app/core/error/failures.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/data/datasources/local/profile_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/profile_remote_data_source.dart';
import 'package:incasa_app/data/models/profile/user_model.dart';
import 'package:incasa_app/domain/entities/profile/user.dart';
import 'package:incasa_app/domain/repositories/profile/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<User>> getUserProfile() async {
    try {
      final user = await localDataSource.getUserProfile();
      return Success(user);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<User>> updateUserProfile(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final result = await remoteDataSource.updateUserProfile(userModel);
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
