import 'package:flutter_test/flutter_test.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/utils/supabase_inspector.dart';
import 'package:incasa_app/core/network/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:incasa_app/core/constants/supabase_constants.dart';

/// Teste utilitário para inspecionar o schema do Supabase
///
/// ⚠️ ATENÇÃO: Este não é um teste unitário real!
/// É uma ferramenta de desenvolvimento para inspecionar suas tabelas.
///
/// **Como usar:**
///
/// 1. Certifique-se de que as credenciais do Supabase estão corretas
///    em `lib/core/constants/supabase_constants.dart`
///
/// 2. Execute este teste específico:
///    ```bash
///    flutter test test/tools/inspect_supabase_schema_test.dart
///    ```
///
/// 3. Veja o output no console com os detalhes das tabelas
///
/// 4. Copie o código gerado para suas Models
void main() {
  setUpAll(() async {
    // Inicializar Supabase
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
    );

    // Inicializar DI (apenas o necessário para o teste)
    await _setupMinimalDI();
  });

  group('Supabase Schema Inspector Tool', () {
    late SupabaseInspector inspector;

    setUp(() {
      inspector = SupabaseInspector(sl<SupabaseClientWrapper>());
    });

    test('Inspecionar tabela users', () async {
      print('\n\n');
      print('=' * 80);
      print('INSPECTING TABLE: users');
      print('=' * 80);

      await inspector.inspectTable('users');

      // Este teste sempre passa - é só uma ferramenta
      expect(true, true);
    });

    test('Inspecionar tabela products', () async {
      print('\n\n');
      print('=' * 80);
      print('INSPECTING TABLE: products');
      print('=' * 80);

      await inspector.inspectTable('products');

      expect(true, true);
    });

    test('Inspecionar tabela categories', () async {
      print('\n\n');
      print('=' * 80);
      print('INSPECTING TABLE: categories');
      print('=' * 80);

      await inspector.inspectTable('categories');

      expect(true, true);
    });

    test('Inspecionar tabela stores', () async {
      print('\n\n');
      print('=' * 80);
      print('INSPECTING TABLE: stores');
      print('=' * 80);

      await inspector.inspectTable('stores');

      expect(true, true);
    });

    test('Inspecionar TODAS as tabelas de uma vez', () async {
      print('\n\n');
      print('=' * 80);
      print('INSPECTING ALL TABLES');
      print('=' * 80);

      await inspector.inspectAllTables();

      expect(true, true);
    });

    // ⬇️ ADICIONE MAIS TABELAS AQUI CONFORME NECESSÁRIO

    // test('Inspecionar tabela orders', () async {
    //   await inspector.inspectTable('orders');
    //   expect(true, true);
    // });
  });

  group('Comparar Models com Schema Real', () {
    late SupabaseInspector inspector;

    setUp(() {
      inspector = SupabaseInspector(sl<SupabaseClientWrapper>());
    });

    test('Comparar ProductModel com schema real', () async {
      print('\n\n');
      print('=' * 80);
      print('COMPARING ProductModel WITH SCHEMA');
      print('=' * 80);

      // Defina os campos que sua ProductModel ATUAL possui
      final currentModelFields = <String, Type>{
        'id': String,
        'tipo': String,
        'name': String,
        'description': String,
        'price': double,
        'imageUrl': String,
        'category': String,
        'estoque': int,
        'prazoProducaoDias': int,
        'prazoEntregaHoras': int,
        'prazoMinimoEncomendaDias': int,
        'disponivelVenda': bool,
        'prontaEntrega': bool,
        'aceitaEncomenda': bool,
        'createdAt': DateTime,
      };

      await inspector.compareModelWithSchema('products', currentModelFields);

      expect(true, true);
    });

    test('Comparar UserModel com schema real', () async {
      print('\n\n');
      print('=' * 80);
      print('COMPARING UserModel WITH SCHEMA');
      print('=' * 80);

      final currentModelFields = <String, Type>{
        'id': String,
        'name': String,
        'email': String,
        'avatarUrl': String,
        'phone': String,
        'createdAt': DateTime,
      };

      await inspector.compareModelWithSchema('users', currentModelFields);

      expect(true, true);
    });
  });
}

/// Setup mínimo do DI para o teste funcionar
Future<void> _setupMinimalDI() async {
  // Registrar apenas o que é necessário para o inspector
  sl.registerLazySingleton<SupabaseClientWrapper>(
    () => SupabaseClientWrapper(),
  );
}
