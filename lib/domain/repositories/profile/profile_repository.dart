import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/profile/user.dart';

abstract class ProfileRepository {
  void setOnboardingPhase(bool isOnboardingPhase);
  Future<Result<User>> getUserProfile();
  Future<Result<User>> updateUserProfile(User user);
}
