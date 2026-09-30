import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/profile/registration_info.dart';

/// Repository abstrato dos dados cadastrais mascarados (e-mail, telefone, CPF).
abstract class RegistrationRepository {
  /// Busca os dados cadastrais do usuário autenticado, já mascarados.
  Future<Result<RegistrationInfo>> getRegistrationInfo();
}
