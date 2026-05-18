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

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoints / Table Names
  // Exemplo de URL completa: https://rhmmjsjbvfivtathuviv.supabase.co/rest/v1/users
  static const String usersTable = 'users';
  static const String productsTable = 'products';
  static const String categoriesTable = 'categories';
  static const String storesTable = 'stores';
  static const String addressesTable = 'addresses';
}
