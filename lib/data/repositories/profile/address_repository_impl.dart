import 'dart:developer';
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
    log('🔵 ========== REPOSITORY SAVE ADDRESS ==========');
    log('📋 Address Entity:');
    log('   - addressId: ${address.addressId}');
    log('   - userId: ${address.userId}');
    log('   - isPrimary: ${address.isPrimary}');
    log('   - street: ${address.street}');
    log('   - number: ${address.number}');
    log('   - city: ${address.city}');
    log('   - state: ${address.state}');
    log('   - countryCode: ${address.countryCode}');
    log('   - zipCode: ${address.zipCode}');
    log('   - addressType: ${address.addressType}');

    try {
      final addressModel = AddressModel.fromEntity(address);

      log('📦 AddressModel criado');

      // Se addressId for null, cria. Se não, atualiza.
      if (address.addressId == null) {
        log('➕ CREATE: Chamando dataSource.createAddress...');
        final created = await dataSource.createAddress(addressModel);
        log('✅ CREATE bem-sucedido! addressId: ${created.addressId}');
        log('🔵 ==========================================');
        return Success(created);
      } else {
        log('🔄 UPDATE: Chamando dataSource.updateAddress...');
        final updated = await dataSource.updateAddress(
          address.addressId!,
          addressModel,
        );
        log('✅ UPDATE bem-sucedido!');
        log('🔵 ==========================================');
        return Success(updated);
      }
    } catch (e, stackTrace) {
      log('🔴 ========== ERRO NO REPOSITORY ==========');
      log('🔴 Exception: $e');
      log('🔴 Tipo: ${e.runtimeType}');
      log('🔴 StackTrace:');
      log(stackTrace.toString());
      log('🔴 ==========================================');
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
