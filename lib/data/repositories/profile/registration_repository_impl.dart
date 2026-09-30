import 'package:dio/dio.dart';
import 'package:incasa_app/core/error/failures.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/data/datasources/remote/registration_supabase_data_source.dart';
import 'package:incasa_app/data/models/profile/registration_info_request_model.dart';
import 'package:incasa_app/domain/entities/profile/registration_info.dart';
import 'package:incasa_app/domain/repositories/profile/registration_repository.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationSupabaseDataSource dataSource;

  RegistrationRepositoryImpl({required this.dataSource});

  @override
  Future<Result<RegistrationInfo>> getRegistrationInfo() async {
    try {
      final info = await dataSource.getRegistrationInfo(
        const RegistrationInfoRequestModel(),
      );
      return Success(info);
    } on DioException catch (e) {
      return Error(_mapDioException(e));
    } catch (_) {
      return const Error(
        UnexpectedFailure('Não foi possível carregar seus dados cadastrais.'),
      );
    }
  }

  /// Resposta do PostgREST (`{code, message}`) → `ServerFailure`; sem resposta
  /// (timeout, sem conexão) → `NetworkFailure`.
  Failure _mapDioException(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ServerFailure(data['message'] as String);
    }
    if (e.response != null) {
      return const ServerFailure(
        'Não foi possível carregar seus dados cadastrais.',
      );
    }
    return const NetworkFailure(
      'Sem conexão com o servidor. Verifique sua internet e tente novamente.',
    );
  }
}
