import 'package:dio/dio.dart';
import 'package:incasa_app/core/constants/supabase_constants.dart';

/// Nome da instância do `Dio` do REST do Supabase no `get_it`.
const String supabaseRestDioName = 'supabaseRest';

/// Cria o [Dio] usado nas chamadas REST/RPC do Supabase
/// (`<SUPABASE_URL>/rest/v1`).
///
/// - `apikey`: chave anon do projeto.
/// - `Authorization`: JWT do Supabase do usuário logado (via [accessToken]);
///   sem JWT, cai na anon key — igual ao comportamento do SDK.
///
/// Sem `LogInterceptor` de propósito: ele imprimiria o JWT nos logs.
Dio createSupabaseRestDio({
  required String supabaseUrl,
  required String anonKey,
  required Future<String?> Function() accessToken,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '$supabaseUrl/rest/v1',
      connectTimeout: SupabaseConstants.connectTimeout,
      receiveTimeout: SupabaseConstants.receiveTimeout,
      headers: {
        'apikey': anonKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await accessToken();
        options.headers['Authorization'] =
            'Bearer ${(token != null && token.isNotEmpty) ? token : anonKey}';
        handler.next(options);
      },
    ),
  );

  return dio;
}
