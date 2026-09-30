// Teste unitário do endpoint `POST /rest/v1/rpc/get_registration_info`
// (incasa-api.yaml / ai/supabase-estado-atual.md §3.4).
//
// Cobre, de ponta a ponta e sem rede: Request model → DataSource (Dio real com
// `HttpClientAdapter` falso) → Repository → UseCase → Cubit.
//
// Rodar: flutter test testes/get_registration_info_test.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incasa_app/core/error/failures.dart';
import 'package:incasa_app/core/network/supabase_rest_dio.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/data/datasources/remote/registration_supabase_data_source.dart';
import 'package:incasa_app/data/models/profile/registration_info_model.dart';
import 'package:incasa_app/data/models/profile/registration_info_request_model.dart';
import 'package:incasa_app/data/repositories/profile/registration_repository_impl.dart';
import 'package:incasa_app/domain/entities/profile/registration_info.dart';
import 'package:incasa_app/domain/entities/profile/registration_phone.dart';
import 'package:incasa_app/domain/repositories/profile/registration_repository.dart';
import 'package:incasa_app/domain/usecases/profile/get_registration_info.dart';
import 'package:incasa_app/features/onboarding/cubit/registration_cubit.dart';
import 'package:incasa_app/features/onboarding/cubit/registration_state.dart';
import 'package:incasa_app/features/onboarding/utils/registration_formatters.dart';

const _baseUrl = 'https://api.test.incasa';
const _anonKey = 'anon-key-de-teste';
const _jwt = 'jwt-de-teste';

/// Corpo de resposta (200) esperado da RPC, com todos os dados cadastrados.
const _fullJson = {
  'email': 'maria@gmail.com',
  'phone': {
    'country_code': '55',
    'area_code': '41',
    'number': '998123489',
    'full_number': '5541998123489',
    'has_whatsapp': true,
    'is_verified': false,
  },
  'cpf': '123.***.**9-12',
};

/// Adapter falso do Dio: intercepta a requisição e devolve a resposta montada.
class _FakeAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions) handler;
  _FakeAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, [int status = 200]) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

/// Data source sobre o **mesmo Dio de produção** (`createSupabaseRestDio`),
/// trocando só o adapter. `captured` recebe a requisição feita.
RegistrationSupabaseDataSource _dataSource(
  Future<ResponseBody> Function(RequestOptions) handler, {
  void Function(RequestOptions)? captured,
}) {
  final dio = createSupabaseRestDio(
    supabaseUrl: _baseUrl,
    anonKey: _anonKey,
    accessToken: () async => _jwt,
  );
  dio.httpClientAdapter = _FakeAdapter((options) {
    captured?.call(options);
    return handler(options);
  });
  return RegistrationSupabaseDataSourceImpl(dio: dio);
}

class _FakeRepository implements RegistrationRepository {
  final Result<RegistrationInfo> result;
  int calls = 0;
  _FakeRepository(this.result);

  @override
  Future<Result<RegistrationInfo>> getRegistrationInfo() async {
    calls++;
    return result;
  }
}

void main() {
  group('Request model', () {
    test('não envia parâmetros (usuário vem do JWT, nunca do cliente)', () {
      expect(const RegistrationInfoRequestModel().toSupabase(), isEmpty);
    });
  });

  group('Response model (fromSupabase)', () {
    test('e-mail e telefone completos; CPF mascarado pelo banco', () {
      final model = RegistrationInfoModel.fromSupabase(_fullJson);

      expect(model.email, 'maria@gmail.com');
      expect(model.phone?.countryCode, '55');
      expect(model.phone?.areaCode, '41');
      expect(model.phone?.number, '998123489');
      expect(model.phone?.fullNumber, '5541998123489');
      expect(model.phone?.hasWhatsapp, isTrue);
      expect(model.phone?.isVerified, isFalse);
      expect(model.cpf, '123.***.**9-12');
    });

    test('usuário sem telefone e sem CPF → campos null', () {
      final model = RegistrationInfoModel.fromSupabase(const {
        'email': 'maria@gmail.com',
        'phone': null,
        'cpf': null,
      });

      expect(model.email, 'maria@gmail.com');
      expect(model.phone, isNull);
      expect(model.cpf, isNull);
    });

    test('tolera chaves ausentes e ignora chaves extras', () {
      final model = RegistrationInfoModel.fromSupabase(const {
        'cpf_hmac': 'nao-deve-ser-lido',
      });

      expect(model.email, isNull);
      expect(model.phone, isNull);
      expect(model.cpf, isNull);
    });

    test('telefone sem area_code/full_number e flags ausentes usa defaults',
        () {
      final model = RegistrationInfoModel.fromSupabase(const {
        'phone': {'country_code': '55', 'number': '998123489'},
      });

      expect(model.phone?.areaCode, isNull);
      expect(model.phone?.fullNumber, isNull);
      expect(model.phone?.hasWhatsapp, isFalse);
      expect(model.phone?.isVerified, isFalse);
    });

    test('contrato: CPF sempre no formato mascarado', () {
      final model = RegistrationInfoModel.fromSupabase(_fullJson);

      expect(model.cpf, matches(RegExp(r'^\d{3}\.\*{3}\.\*{2}\d-\d{2}$')));
    });

    test('nunca contém CPF completo (11 dígitos)', () {
      final model = RegistrationInfoModel.fromSupabase(_fullJson);

      expect(RegExp(r'\d{11}').hasMatch(model.cpf!), isFalse);
    });
  });

  group('Formatter do telefone (apresentação)', () {
    test('celular BR de 9 dígitos', () {
      final phone = RegistrationInfoModel.fromSupabase(_fullJson).phone!;

      expect(formatRegistrationPhone(phone), '+55 (41) 99812-3489');
    });

    test('número de 8 dígitos', () {
      const phone = RegistrationPhone(
        countryCode: '55',
        areaCode: '41',
        number: '98123489',
      );

      expect(formatRegistrationPhone(phone), '+55 (41) 9812-3489');
    });

    test('sem DDD cai no número completo', () {
      const phone = RegistrationPhone(
        countryCode: '55',
        number: '998123489',
        fullNumber: '55998123489',
      );

      expect(formatRegistrationPhone(phone), '+55998123489');
    });
  });

  group('DataSource (requisição Dio real, adapter falso)', () {
    test('faz POST em /rest/v1/rpc/get_registration_info com JWT e corpo {}',
        () async {
      late RequestOptions request;
      final ds = _dataSource(
        (_) async => _json(_fullJson),
        captured: (r) => request = r,
      );

      await ds.getRegistrationInfo(const RegistrationInfoRequestModel());

      expect(request.method, 'POST');
      expect(
        request.uri.toString(),
        '$_baseUrl/rest/v1/rpc/get_registration_info',
      );
      expect(request.headers['apikey'], _anonKey);
      expect(request.headers['Authorization'], 'Bearer $_jwt');
      expect(request.data, isEmpty);
    });

    test('sem JWT do usuário, cai na anon key (e o banco nega a RPC)',
        () async {
      late RequestOptions request;
      final dio = createSupabaseRestDio(
        supabaseUrl: _baseUrl,
        anonKey: _anonKey,
        accessToken: () async => null,
      );
      dio.httpClientAdapter = _FakeAdapter((options) async {
        request = options;
        return _json(_fullJson);
      });

      await RegistrationSupabaseDataSourceImpl(
        dio: dio,
      ).getRegistrationInfo(const RegistrationInfoRequestModel());

      expect(request.headers['Authorization'], 'Bearer $_anonKey');
    });

    test('converte a resposta 200 no model', () async {
      final ds = _dataSource((_) async => _json(_fullJson));

      final model = await ds.getRegistrationInfo(
        const RegistrationInfoRequestModel(),
      );

      expect(model.email, 'maria@gmail.com');
      expect(model.phone?.fullNumber, '5541998123489');
      expect(model.cpf, '123.***.**9-12');
    });

    test('propaga DioException quando o banco nega (anon / sem JWT)',
        () async {
      final ds = _dataSource(
        (_) async => _json({
          'code': '42501',
          'message': 'permission denied for function get_registration_info',
        }, 401),
      );

      expect(
        () => ds.getRegistrationInfo(const RegistrationInfoRequestModel()),
        throwsA(
          isA<DioException>()
              .having((e) => e.response?.statusCode, 'status', 401)
              .having((e) => e.response?.data['code'], 'code', '42501'),
        ),
      );
    });
  });

  group('Repository', () {
    test('sucesso → Success(RegistrationInfo)', () async {
      final repo = RegistrationRepositoryImpl(
        dataSource: _dataSource((_) async => _json(_fullJson)),
      );

      final result = await repo.getRegistrationInfo();

      expect(result, isA<Success<RegistrationInfo>>());
      final info = (result as Success<RegistrationInfo>).data;
      expect(info.email, 'maria@gmail.com');
      expect(info.phone?.number, '998123489');
      expect(info.cpf, '123.***.**9-12');
    });

    test('erro do banco → ServerFailure com a mensagem do Postgres', () async {
      final repo = RegistrationRepositoryImpl(
        dataSource: _dataSource(
          (_) async => _json({
            'code': 'P0001',
            'message': 'Usuário não identificado (token ausente ou inválido).',
          }, 400),
        ),
      );

      final result = await repo.getRegistrationInfo();

      expect(result, isA<Error<RegistrationInfo>>());
      final failure = (result as Error<RegistrationInfo>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.message, contains('Usuário não identificado'));
    });

    test('falha de rede → NetworkFailure sem vazar exceção crua', () async {
      final repo = RegistrationRepositoryImpl(
        dataSource: _dataSource(
          (options) async => throw DioException.connectionError(
            requestOptions: options,
            reason: 'sem conexão',
          ),
        ),
      );

      final result = await repo.getRegistrationInfo();

      final failure = (result as Error<RegistrationInfo>).failure;
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, isNot(contains('DioException')));
    });
  });

  group('UseCase', () {
    test('delega ao repository e devolve o resultado', () async {
      const info = RegistrationInfo(cpf: '123.***.**9-12');
      final repo = _FakeRepository(const Success(info));

      final result = await GetRegistrationInfo(repo)(const NoParams());

      expect(repo.calls, 1);
      expect((result as Success<RegistrationInfo>).data, info);
    });
  });

  group('RegistrationCubit', () {
    test('estado inicial é loading, sem dados', () {
      final cubit = RegistrationCubit(
        getRegistrationInfoUseCase: GetRegistrationInfo(
          _FakeRepository(const Success(RegistrationInfo())),
        ),
      );
      addTearDown(cubit.close);

      expect(cubit.state.status, RegistrationStatus.loading);
      expect(cubit.state.info, isNull);
    });

    test('loadRegistration → loaded com os dados mascarados', () async {
      const info = RegistrationInfo(
        email: 'maria@gmail.com',
        phone: RegistrationPhone(
          countryCode: '55',
          areaCode: '41',
          number: '998123489',
          fullNumber: '5541998123489',
          hasWhatsapp: true,
        ),
        cpf: '123.***.**9-12',
      );
      final cubit = RegistrationCubit(
        getRegistrationInfoUseCase: GetRegistrationInfo(
          _FakeRepository(const Success(info)),
        ),
      );
      addTearDown(cubit.close);

      await cubit.loadRegistration();

      expect(
        cubit.state,
        const RegistrationState(
          status: RegistrationStatus.loaded,
          info: info,
        ),
      );
    });

    test('loadRegistration com falha → error com mensagem', () async {
      final cubit = RegistrationCubit(
        getRegistrationInfoUseCase: GetRegistrationInfo(
          _FakeRepository(const Error(ServerFailure('permission denied'))),
        ),
      );
      addTearDown(cubit.close);

      await cubit.loadRegistration();

      expect(cubit.state.status, RegistrationStatus.error);
      expect(cubit.state.errorMessage, 'permission denied');
      expect(cubit.state.info, isNull);
    });

    test('"Tentar novamente" após erro volta a carregar e conclui', () async {
      var attempt = 0;
      final repo = _SequencedRepository(() {
        attempt++;
        return attempt == 1
            ? const Error(ServerFailure('falhou'))
            : const Success(RegistrationInfo(cpf: '123.***.**9-12'));
      });
      final cubit = RegistrationCubit(
        getRegistrationInfoUseCase: GetRegistrationInfo(repo),
      );
      addTearDown(cubit.close);

      await cubit.loadRegistration();
      expect(cubit.state.status, RegistrationStatus.error);

      await cubit.loadRegistration();
      expect(cubit.state.status, RegistrationStatus.loaded);
      expect(cubit.state.info?.cpf, '123.***.**9-12');
    });
  });
}

class _SequencedRepository implements RegistrationRepository {
  final Result<RegistrationInfo> Function() next;
  _SequencedRepository(this.next);

  @override
  Future<Result<RegistrationInfo>> getRegistrationInfo() async => next();
}
