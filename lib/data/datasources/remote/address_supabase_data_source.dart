import 'dart:developer';
import 'package:incasa_app/core/network/supabase_client.dart';
import 'package:incasa_app/data/models/profile/address_model.dart';

/// DataSource para operações de endereços no Supabase
///
/// Endpoint base: https://rhmmjsjbvfivtathuviv.supabase.co/rest/v1/address
abstract class AddressSupabaseDataSource {
  /// Busca todos os endereços de um usuário
  Future<List<AddressModel>> getUserAddresses(String userId);

  /// Busca a quantidade de endereços de um usuário
  Future<int> getUserAddressCount(String userId);

  /// Cria novo endereço
  Future<AddressModel> createAddress(AddressModel address);

  /// Atualiza endereço existente
  Future<AddressModel> updateAddress(String addressId, AddressModel address);

  /// Deleta endereço
  Future<void> deleteAddress(String addressId);
}

class AddressSupabaseDataSourceImpl implements AddressSupabaseDataSource {
  final SupabaseClientWrapper supabase;

  AddressSupabaseDataSourceImpl({required this.supabase});

  @override
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    try {
      final response = await supabase
          .from('address')
          .select()
          .eq('user_id', userId)
          .order('is_primary', ascending: false) // Endereço principal primeiro
          .order('created_at', ascending: false); // Depois por data

      if (response.isEmpty) return [];

      return (response as List)
          .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar endereços no Supabase: $e');
    }
  }

  @override
  Future<int> getUserAddressCount(String userId) async {
    try {
      final response = await supabase
          .from('address')
          .select()
          .eq('user_id', userId);

      return response.length;
    } catch (e) {
      throw Exception('Erro ao contar endereços no Supabase: $e');
    }
  }

  @override
  Future<AddressModel> createAddress(AddressModel address) async {
    log('🟡 ========== DATASOURCE CREATE ADDRESS ==========');
    try {
      final json = address.toJson();
      log('📤 JSON sendo enviado para Supabase:');
      log(
        '   ${json.entries.map((e) => '${e.key}: ${e.value}').join('\n   ')}',
      );

      final response = await supabase
          .from('address')
          .insert(json)
          .select()
          .single();

      log('✅ Response recebido do Supabase:');
      log(
        '   ${response.entries.map((e) => '${e.key}: ${e.value}').join('\n   ')}',
      );
      log('🟡 ==========================================');

      return AddressModel.fromJson(response);
    } catch (e, stackTrace) {
      log('🔴 ========== ERRO NO DATASOURCE CREATE ==========');
      log('🔴 Exception: $e');
      log('🔴 Tipo: ${e.runtimeType}');
      log('🔴 StackTrace:');
      log(stackTrace.toString());
      log('🔴 ==========================================');
      throw Exception('Erro ao criar endereço no Supabase: $e');
    }
  }

  @override
  Future<AddressModel> updateAddress(
    String addressId,
    AddressModel address,
  ) async {
    log('🟡 ========== DATASOURCE UPDATE ADDRESS ==========');
    log('📌 addressId: $addressId');
    try {
      final json = address.toJson();
      log('📤 JSON sendo enviado para Supabase:');
      log(
        '   ${json.entries.map((e) => '${e.key}: ${e.value}').join('\n   ')}',
      );

      final response = await supabase
          .from('address')
          .update(json)
          .eq('address_id', addressId)
          .select()
          .single();

      log('✅ Response recebido do Supabase:');
      log(
        '   ${response.entries.map((e) => '${e.key}: ${e.value}').join('\n   ')}',
      );
      log('🟡 ==========================================');

      return AddressModel.fromJson(response);
    } catch (e, stackTrace) {
      log('🔴 ========== ERRO NO DATASOURCE UPDATE ==========');
      log('🔴 Exception: $e');
      log('🔴 Tipo: ${e.runtimeType}');
      log('🔴 StackTrace:');
      log(stackTrace.toString());
      log('🔴 ==========================================');
      throw Exception('Erro ao atualizar endereço no Supabase: $e');
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      await supabase.from('address').delete().eq('address_id', addressId);
    } catch (e) {
      throw Exception('Erro ao deletar endereço no Supabase: $e');
    }
  }
}
