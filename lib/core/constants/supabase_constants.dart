import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConstants {
  // Supabase Configuration
  // Credenciais carregadas do arquivo .env
  // Base URL: https://rhmmjsjbvfivtathuviv.supabase.co
  // REST API Base: https://rhmmjsjbvfivtathuviv.supabase.co/rest/v1/
  // O SDK adiciona /rest/v1/ automaticamente

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://rhmmjsjbvfivtathuviv.supabase.co';

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // URL base para Edge Functions.
  // Em self-hosted pode ser algo como: http://SEU_HOST:8000
  // Se não informado, usa SUPABASE_URL.
  static String get supabaseFunctionsUrl =>
      dotenv.env['SUPABASE_FUNCTIONS_URL'] ?? supabaseUrl;

  static bool _looksLikeJwt(String value) {
    if (value.isEmpty) return false;
    return value.split('.').length == 3;
  }

  static void validateEnvOrThrow() {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL não configurada no .env.');
    }

    if (!_looksLikeJwt(supabaseAnonKey)) {
      throw Exception(
        'SUPABASE_ANON_KEY inválida no .env. A chave anon deve ser um JWT com 3 partes separadas por ponto.',
      );
    }
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoints / Table Names
  // Exemplo de URL completa: https://rhmmjsjbvfivtathuviv.supabase.co/rest/v1/users
  static const String usersTable = 'users';
  static const String phonesTable = 'phones';
  static const String providersTable = 'providers';
  static const String productsTable = 'products';
  static const String categoriesTable = 'categories';
  static const String storesTable = 'stores';
  static const String addressesTable = 'addresses';

  // RPCs
  static const String rpcSetUserCpf = 'set_user_cpf';
}
