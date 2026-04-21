import 'package:incasa_app/core/utils/result.dart';

/// Classe base abstrata para todos os Use Cases
/// T = tipo de retorno
/// Params = parâmetros necessários (use NoParams se não houver)
abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Classe para use cases sem parâmetros
class NoParams {
  const NoParams();
}
