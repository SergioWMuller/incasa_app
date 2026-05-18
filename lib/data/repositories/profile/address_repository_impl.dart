import 'package:incasa_app/core/error/failures.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/data/datasources/remote/address_supabase_data_source.dart';
import 'package:incasa_app/data/models/profile/address_model.dart';
import 'package:incasa_app/domain/entities/profile/address.dart';
import 'package:incasa_app/domain/repositories/profile/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressSupabaseDataSource dataSource;

  AddressRepositoryImpl({required this.dataSource});

  @override
  Future<Result<List<Address>>> getUserAddresses(String userId) async {
    try {
      final addresses = await dataSource.getUserAddresses(userId);
      return Success(addresses);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> getUserAddressCount(String userId) async {
    try {
      final count = await dataSource.getUserAddressCount(userId);
      return Success(count);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Address>> saveAddress(Address address) async {
    print('🔵 ========== REPOSITORY SAVE ADDRESS ==========');
    print('📋 Address Entity:');
    print('   - addressId: ${address.addressId}');
    print('   - userId: ${address.userId}');
    print('   - isPrimary: ${address.isPrimary}');
    print('   - street: ${address.street}');
    print('   - number: ${address.number}');
    print('   - city: ${address.city}');
    print('   - state: ${address.state}');
    print('   - countryCode: ${address.countryCode}');
    print('   - zipCode: ${address.zipCode}');
    print('   - addressType: ${address.addressType}');

    try {
      final addressModel = AddressModel.fromEntity(address);

      print('📦 AddressModel criado');

      // Se addressId for null, cria. Se não, atualiza.
      if (address.addressId == null) {
        print('➕ CREATE: Chamando dataSource.createAddress...');
        final created = await dataSource.createAddress(addressModel);
        print('✅ CREATE bem-sucedido! addressId: ${created.addressId}');
        print('🔵 ==========================================');
        return Success(created);
      } else {
        print('🔄 UPDATE: Chamando dataSource.updateAddress...');
        final updated = await dataSource.updateAddress(
          address.addressId!,
          addressModel,
        );
        print('✅ UPDATE bem-sucedido!');
        print('🔵 ==========================================');
        return Success(updated);
      }
    } catch (e, stackTrace) {
      print('🔴 ========== ERRO NO REPOSITORY ==========');
      print('🔴 Exception: $e');
      print('🔴 Tipo: ${e.runtimeType}');
      print('🔴 StackTrace:');
      print(stackTrace);
      print('🔴 ==========================================');
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAddress(String addressId) async {
    try {
      await dataSource.deleteAddress(addressId);
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
