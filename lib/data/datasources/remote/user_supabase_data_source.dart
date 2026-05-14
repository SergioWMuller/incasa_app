import 'package:incasa_app/core/constants/supabase_constants.dart';
import 'package:incasa_app/core/network/supabase_client.dart';
import 'package:incasa_app/data/models/profile/user_model.dart';

/// DataSource para operações de usuário no Supabase
///
/// Endpoint base: https://rhmmjsjbvfivtathuviv.supabase.co/rest/v1/users
abstract class UserSupabaseDataSource {
  /// Busca usuário pelo UID
  Future<UserModel?> getUserByUid(String uid);

  /// Cria novo usuário
  Future<UserModel> createUser(UserModel user);

  /// Atualiza usuário existente
  Future<UserModel> updateUser(String uid, UserModel user);
}

class UserSupabaseDataSourceImpl implements UserSupabaseDataSource {
  final SupabaseClientWrapper supabase;

  UserSupabaseDataSourceImpl({required this.supabase});

  @override
  Future<UserModel?> getUserByUid(String uid) async {
    try {
      final response = await supabase
          .from(SupabaseConstants.usersTable)
          .select()
          .eq('uid', uid)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Erro ao buscar usuário no Supabase: $e');
    }
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      final response = await supabase
          .from(SupabaseConstants.usersTable)
          .insert(user.toSupabase())
          .select()
          .single();

      return UserModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Erro ao criar usuário no Supabase: $e');
    }
  }

  @override
  Future<UserModel> updateUser(String uid, UserModel user) async {
    try {
      print('🔵 ========== SUPABASE UPDATE USER ==========');
      print('📌 UID: $uid');

      final dataToSend = user.toSupabase();
      print('📤 DADOS ENVIADOS:');
      print('   - phone_number: ${dataToSend['phone_number']}');
      print('   - phone_verified: ${dataToSend['phone_verified']}');
      print('   - is_phone_whatsapp: ${dataToSend['is_phone_whatsapp']}');
      print('   - cpf: ${dataToSend['cpf']}');
      print('   - email_verified: ${dataToSend['email_verified']}');

      final response = await supabase
          .from(SupabaseConstants.usersTable)
          .update(dataToSend)
          .eq('uid', uid)
          .select()
          .single();

      print('📥 RESPONSE RECEBIDO:');
      print('   - Tipo: ${response.runtimeType}');
      print('   - phone_number: ${response['phone_number']}');
      print('   - phone_verified: ${response['phone_verified']}');
      print('   - is_phone_whatsapp: ${response['is_phone_whatsapp']}');
      print('   - cpf: ${response['cpf']}');
      print('   - email_verified: ${response['email_verified']}');
      print('   - Campos completos: ${response.keys.toList()}');
      print('🔵 ==========================================');

      return UserModel.fromSupabase(response);
    } catch (e) {
      print('🔴 ========== ERRO SUPABASE UPDATE ==========');
      print('🔴 Erro completo: $e');
      print('🔴 Tipo do erro: ${e.runtimeType}');
      print('🔴 ==========================================');
      throw Exception('Erro ao atualizar usuário no Supabase: $e');
    }
  }
}
