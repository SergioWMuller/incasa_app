import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/profile/address.dart';

/// Repository abstrato para operações com endereços
abstract class AddressRepository {
  /// Busca todos os endereços de um usuário
  Future<Result<List<Address>>> getUserAddresses(String userId);

  /// Busca a quantidade de endereços de um usuário
  Future<Result<int>> getUserAddressCount(String userId);

  /// Salva endereço (cria se addressId for null, atualiza se não for)
  Future<Result<Address>> saveAddress(Address address);

  /// Deleta endereço
  Future<Result<void>> deleteAddress(String addressId);
}
