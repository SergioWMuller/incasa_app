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

  // Durante onboarding, evita depender do backend remoto para render inicial.
  // Após onboarding, prioriza remoto com fallback local.
  bool _isOnboardingPhase = false;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  void setOnboardingPhase(bool isOnboardingPhase) {
    _isOnboardingPhase = isOnboardingPhase;
  }

  @override
  Future<Result<User>> getUserProfile() async {
    Future<User> fetchLocal() => localDataSource.getUserProfile();
    Future<User> fetchRemote() => remoteDataSource.getUserProfile();

    try {
      final user = _isOnboardingPhase
          ? await fetchLocal()
          : await fetchRemote();
      return Success(user);
    } catch (e) {
      // Fallback cruzado garante robustez nas transições de fase.
      try {
        final fallbackUser = _isOnboardingPhase
            ? await fetchRemote()
            : await fetchLocal();
        return Success(fallbackUser);
      } catch (_) {
        return Error(UnexpectedFailure(e.toString()));
      }
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
