import 'package:supabase_flutter/supabase_flutter.dart';

/// Client wrapper para Supabase
///
/// Este client encapsula a comunicação com o Supabase seguindo
/// a arquitetura limpa do projeto. Apenas a camada Data deve usar esta classe.
///
/// **MVP - Supabase (USAR AGORA) ✅**
/// - Gerencia conexão com Supabase
/// - Fornece acesso ao SupabaseClient
/// - Configura timeouts e logging
class SupabaseClientWrapper {
  late final SupabaseClient _client;

  SupabaseClientWrapper() {
    _client = Supabase.instance.client;
  }

  /// Acesso ao client do Supabase
  SupabaseClient get client => _client;

  /// Helper: Acesso rápido ao .from() para queries
  SupabaseQueryBuilder from(String table) => _client.from(table);

  /// Helper: Acesso rápido ao .rpc() para funções
  PostgrestFilterBuilder rpc(String fnName, {Map<String, dynamic>? params}) =>
      _client.rpc(fnName, params: params);

  /// Helper: Acesso ao Storage
  SupabaseStorageClient get storage => _client.storage;

  /// Helper: Acesso ao Auth
  GoTrueClient get auth => _client.auth;
}
