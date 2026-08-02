import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/profile/user.dart';
import 'package:incasa_app/domain/repositories/profile/profile_repository.dart';

class GetUserProfile extends UseCase<User, NoParams> {
  final ProfileRepository repository;

  GetUserProfile(this.repository);

  void setOnboardingPhase(bool isOnboardingPhase) {
    repository.setOnboardingPhase(isOnboardingPhase);
  }

  @override
  Future<Result<User>> call(NoParams params) async {
    return await repository.getUserProfile();
  }
}
