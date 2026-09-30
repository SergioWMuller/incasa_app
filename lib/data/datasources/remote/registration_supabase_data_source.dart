import 'package:dio/dio.dart';
import 'package:incasa_app/core/constants/supabase_constants.dart';
import 'package:incasa_app/data/models/profile/registration_info_model.dart';
import 'package:incasa_app/data/models/profile/registration_info_request_model.dart';

/// DataSource da RPC `get_registration_info` (incasa-api.yaml).
///
/// `POST <SUPABASE_URL>/rest/v1/rpc/get_registration_info` via Dio. Exige o
/// JWT do Supabase (`role = authenticated`): a RPC resolve o usuário por
/// `app_user_id()` e é negada para `anon`. Propaga a `DioException` original
/// para o repository traduzir em `Failure`.
abstract class RegistrationSupabaseDataSource {
  Future<RegistrationInfoModel> getRegistrationInfo(
    RegistrationInfoRequestModel request,
  );
}

class RegistrationSupabaseDataSourceImpl
    implements RegistrationSupabaseDataSource {
  /// Dio do REST do Supabase (ver `createSupabaseRestDio`).
  final Dio dio;

  RegistrationSupabaseDataSourceImpl({required this.dio});

  @override
  Future<RegistrationInfoModel> getRegistrationInfo(
    RegistrationInfoRequestModel request,
  ) async {
    final response = await dio.post(
      '/rpc/${SupabaseConstants.rpcGetRegistrationInfo}',
      data: request.toSupabase(),
    );

    return RegistrationInfoModel.fromSupabase(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
