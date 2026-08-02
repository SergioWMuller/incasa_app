import 'package:incasa_app/core/constants/supabase_constants.dart';
import 'package:incasa_app/core/network/supabase_client.dart';
import 'package:incasa_app/data/models/profile/user_model.dart';

/// DataSource para operações de usuário no Supabase
///
/// Endpoint base: https://rhmmjsjbvfivtathuviv.supabase.co/rest/v1/users
abstract class UserSupabaseDataSource {
  /// Busca usuário por UUID da tabela users ou por provider_uid (ex: Firebase UID)
  Future<UserModel?> getUserById(String id);

  /// Busca usuário por email
  Future<UserModel?> getUserByEmail(String email);

  /// Cria novo usuário
  Future<UserModel> createUser(UserModel user);

  /// Atualiza usuário existente
  Future<UserModel> updateUser(String uid, UserModel user);

  /// Atualiza campos específicos do usuário por UUID (PK da tabela users)
  Future<UserModel> updateUserFieldsById(
    String userId,
    Map<String, dynamic> fields,
  );

  /// Busca user_id pelo provider e provider_uid (para novo fluxo multi-provider)
  Future<String?> getUserIdByProvider(String provider, String providerUid);

  /// Vincula um provider de autenticação a um usuário existente
  Future<void> linkProviderToUser(
    String userId,
    String provider,
    String providerUid,
    String? email,
  );

  /// Grava o CPF do usuário autenticado via RPC `set_user_cpf`.
  ///
  /// O banco identifica o dono pelo token (`app_user_id()`) e armazena apenas
  /// `cpf_hmac`/`cpf_encrypted` — nunca o CPF em texto puro. [cpf] deve ter
  /// exatamente 11 dígitos numéricos.
  Future<void> setUserCpf(String cpf);
}

class UserSupabaseDataSourceImpl implements UserSupabaseDataSource {
  final SupabaseClientWrapper supabase;

  UserSupabaseDataSourceImpl({required this.supabase});

  bool _isUuid(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(value);
  }

  Future<String?> _resolveUserUuid(String idOrProviderUid) async {
    if (_isUuid(idOrProviderUid)) {
      return idOrProviderUid;
    }

    final providerLink = await supabase
        .from('providers')
        .select('user_id')
        .eq('provider_uid', idOrProviderUid)
        .maybeSingle();

    return providerLink?['user_id'] as String?;
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      final userUuid = await _resolveUserUuid(id);
      if (userUuid == null) return null;

      final response = await supabase
          .from(SupabaseConstants.usersTable)
          .select()
          .eq('id', userUuid)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Erro ao buscar usuário no Supabase: $e');
    }
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response = await supabase
          .from(SupabaseConstants.usersTable)
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Erro ao buscar usuário por email no Supabase: $e');
    }
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      print('🟡 [SUPABASE] users.insert: Criando novo usuário');
      print('   - ID: ${user.id}');
      print('   - Full Name: ${user.fullName}');

      final userSupabaseData = user.toSupabase();
      print('   - Dados a enviar: ${userSupabaseData.keys.toList()}');

      final response = await supabase
          .from(SupabaseConstants.usersTable)
          .insert(userSupabaseData)
          .select()
          .single();

      print('✅ [SUPABASE] users.insert: Usuário criado com sucesso');
      print('   - Response: ${response['id']}');

      return UserModel.fromSupabase(response);
    } catch (e) {
      print('🔴 [SUPABASE] users.insert ERROR: $e');
      throw Exception('Erro ao criar usuário no Supabase: $e');
    }
  }

  @override
  Future<UserModel> updateUser(String id, UserModel user) async {
    try {
      final userUuid = await _resolveUserUuid(id);
      if (userUuid == null) {
        throw Exception(
          'Usuário não encontrado para o identificador informado: $id',
        );
      }

      print('🔵 ========== SUPABASE UPDATE USER ==========');
      print('📌 ID: $id -> UUID: $userUuid');

      final dataToSend = user.toSupabase();
      print('📤 DADOS ENVIADOS: ${dataToSend.keys.toList()}');

      final response = await supabase
          .from(SupabaseConstants.usersTable)
          .update(dataToSend)
          .eq('id', userUuid)
          .select()
          .single();

      print('📥 RESPONSE: ${response.keys.toList()}');
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

  @override
  Future<UserModel> updateUserFieldsById(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    try {
      if (!_isUuid(userId)) {
        throw Exception('ID informado não é UUID válido: $userId');
      }

      final response = await supabase
          .from(SupabaseConstants.usersTable)
          .update(fields)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Erro ao atualizar campos do usuário no Supabase: $e');
    }
  }

  @override
  Future<String?> getUserIdByProvider(
    String provider,
    String providerUid,
  ) async {
    try {
      print(
        '🟡 [SUPABASE] Buscando user_id: provider=$provider, providerUid=$providerUid',
      );
      final response = await supabase
          .from('providers')
          .select('user_id')
          .eq('provider', provider)
          .eq('provider_uid', providerUid)
          .maybeSingle();

      if (response == null) {
        print('✅ [SUPABASE] providers: Nenhum registro encontrado');
        return null;
      }

      final userId = response['user_id'] as String?;
      print('✅ [SUPABASE] providers: User ID encontrado: $userId');
      return userId;
    } catch (e) {
      print('🔴 [SUPABASE] providers ERROR: $e');
      throw Exception('Erro ao buscar user_id por provider: $e');
    }
  }

  @override
  Future<void> linkProviderToUser(
    String userId,
    String provider,
    String providerUid,
    String? email,
  ) async {
    try {
      print('🟡 [SUPABASE] providers.insert: Vinculando provider');
      print('   - User ID: $userId');
      print('   - Provider: $provider');
      print('   - Provider UID: $providerUid');
      print('   - Email: $email');

      final now = DateTime.now().toIso8601String();
      final dataToInsert = {
        'user_id': userId,
        'provider': provider,
        'provider_uid': providerUid,
        'email': email,
        'is_primary': true,
        'is_verified': true,
        'created_at': now,
        'last_login_at': now,
      };

      print('   - Dados: ${dataToInsert.keys.toList()}');

      await supabase.from('providers').insert(dataToInsert);

      print(
        '✅ [SUPABASE] providers.insert: Provider vinculado com sucesso',
      );
    } catch (e) {
      print('🔴 [SUPABASE] providers.insert ERROR: $e');
      throw Exception('Erro ao vincular provider ao usuário: $e');
    }
  }

  @override
  Future<void> setUserCpf(String cpf) async {
    try {
      await supabase.rpc(
        SupabaseConstants.rpcSetUserCpf,
        params: {'p_cpf': cpf},
      );
    } catch (e) {
      // Repassa a mensagem do banco (ex.: "Este CPF já está cadastrado em outra
      // conta.") para o cubit tratar/exibir.
      throw Exception('Erro ao salvar CPF no Supabase: $e');
    }
  }
}
