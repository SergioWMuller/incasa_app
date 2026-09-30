import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/profile/registration_info.dart';
import 'package:incasa_app/domain/repositories/profile/registration_repository.dart';

class GetRegistrationInfo extends UseCase<RegistrationInfo, NoParams> {
  final RegistrationRepository repository;

  GetRegistrationInfo(this.repository);

  @override
  Future<Result<RegistrationInfo>> call(NoParams params) {
    return repository.getRegistrationInfo();
  }
}
