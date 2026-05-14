import 'package:incasa_app/core/network/supabase_client.dart';
import 'dart:convert';

/// Helper para inspecionar dados reais do Supabase e facilitar
/// a sincronização das Models com o schema real do banco
///
/// **Uso:**
/// ```dart
/// final inspector = SupabaseInspector(sl<SupabaseClientWrapper>());
/// await inspector.inspectTable('products');
/// await inspector.inspectAllTables();
/// ```
class SupabaseInspector {
  final SupabaseClientWrapper supabase;

  SupabaseInspector(this.supabase);

  /// Busca e imprime estrutura de uma tabela específica
  ///
  /// [tableName] - Nome da tabela no Supabase (ex: 'products', 'users')
  /// [limit] - Número de registros para examinar (padrão: 3)
  Future<void> inspectTable(String tableName, {int limit = 3}) async {
    try {
      print('\n${'=' * 60}');
      print('🔍 INSPECIONANDO TABELA: $tableName');
      print('=' * 60);

      final response = await supabase.from(tableName).select().limit(limit);

      if (response.isEmpty) {
        print('⚠️  Tabela vazia ou não existe');
        print('💡 Dica: Verifique se o nome está correto e se há dados');
        return;
      }

      final firstRecord = response[0];

      print('\n📊 CAMPOS ENCONTRADOS:');
      print('-' * 60);

      firstRecord.forEach((key, value) {
        final dartType = _inferDartType(value);
        final isNullable = value == null ? '?' : '';
        final snakeCase = key;
        final camelCase = _toCamelCase(key);

        print('  ✓ $snakeCase');
        print('    → Dart type: $dartType$isNullable');
        print('    → camelCase: $camelCase');
        print('    → Exemplo: $value');
        print('');
      });

      print('📝 CÓDIGO SUGERIDO PARA fromSupabase():');
      print('-' * 60);
      _generateFromSupabaseCode(tableName, firstRecord);

      print('\n📝 CÓDIGO SUGERIDO PARA toSupabase():');
      print('-' * 60);
      _generateToSupabaseCode(firstRecord);

      print('\n📋 JSON COMPLETO (primeiro registro):');
      print('-' * 60);
      print(JsonEncoder.withIndent('  ').convert(firstRecord));

      if (response.length > 1) {
        print('\n💡 Total de registros examinados: ${response.length}');
      }
    } catch (e, stackTrace) {
      print('❌ ERRO ao inspecionar tabela "$tableName"');
      print('   Detalhes: $e');
      print('   Stack: $stackTrace');
      print('\n💡 Dicas:');
      print('   - Verifique se a tabela existe no Supabase');
      print('   - Verifique as permissões RLS (Row Level Security)');
      print('   - Verifique sua conexão com o Supabase');
    }
  }

  /// Busca estrutura de múltiplas tabelas
  Future<void> inspectAllTables() async {
    final tables = ['users', 'products', 'categories', 'stores'];

    print('\n🚀 INICIANDO INSPEÇÃO DE TODAS AS TABELAS');
    print('Tabelas: ${tables.join(', ')}');

    for (final table in tables) {
      await inspectTable(table);
      print('\n');
    }

    print('✅ INSPEÇÃO COMPLETA!');
  }

  /// Infere o tipo Dart baseado no valor
  String _inferDartType(dynamic value) {
    if (value == null) return 'dynamic';
    if (value is String) {
      // Tentar detectar se é DateTime
      if (_isDateTime(value)) return 'DateTime';
      return 'String';
    }
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is List) {
      if (value.isEmpty) return 'List<dynamic>';
      final firstType = _inferDartType(value.first);
      return 'List<$firstType>';
    }
    if (value is Map) return 'Map<String, dynamic>';
    return 'dynamic';
  }

  /// Verifica se uma string parece ser um DateTime ISO8601
  bool _isDateTime(String value) {
    try {
      DateTime.parse(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Converte snake_case para camelCase
  String _toCamelCase(String snakeCase) {
    final parts = snakeCase.split('_');
    if (parts.length == 1) return snakeCase;

    final camelCase =
        parts.first +
        parts
            .skip(1)
            .map((part) => part[0].toUpperCase() + part.substring(1))
            .join('');

    return camelCase;
  }

  /// Gera código exemplo para fromSupabase()
  void _generateFromSupabaseCode(
    String tableName,
    Map<String, dynamic> record,
  ) {
    final className = _toClassName(tableName);

    print('''
factory ${className}Model.fromSupabase(Map<String, dynamic> map) {
  return ${className}Model(''');

    record.forEach((key, value) {
      final camelCase = _toCamelCase(key);
      final dartType = _inferDartType(value);

      if (value == null) {
        print("    $camelCase: map['$key'] as $dartType?,");
      } else if (dartType == 'DateTime') {
        print("    $camelCase: DateTime.parse(map['$key'] as String),");
      } else if (dartType.startsWith('List')) {
        print(
          "    $camelCase: (map['$key'] as List).cast<${dartType.replaceAll('List<', '').replaceAll('>', '')}>(),",
        );
      } else {
        print("    $camelCase: map['$key'] as $dartType,");
      }
    });

    print('''  );
}''');
  }

  /// Gera código exemplo para toSupabase()
  void _generateToSupabaseCode(Map<String, dynamic> record) {
    print('''
Map<String, dynamic> toSupabase() {
  return {''');

    record.forEach((key, value) {
      final camelCase = _toCamelCase(key);
      final dartType = _inferDartType(value);

      if (dartType == 'DateTime') {
        print("    '$key': $camelCase.toIso8601String(),");
      } else {
        print("    '$key': $camelCase,");
      }
    });

    print('''  };
}''');
  }

  /// Converte nome da tabela para nome de classe (PascalCase)
  String _toClassName(String tableName) {
    // Remove 's' do final se for plural
    String singular = tableName.endsWith('s')
        ? tableName.substring(0, tableName.length - 1)
        : tableName;

    // Converte para PascalCase
    final parts = singular.split('_');
    return parts
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join('');
  }

  /// Compara uma Model existente com o schema real
  ///
  /// Útil para verificar se há diferenças entre o código e o banco
  Future<void> compareModelWithSchema(
    String tableName,
    Map<String, Type> modelFields,
  ) async {
    try {
      final response = await supabase
          .from(tableName)
          .select()
          .limit(1)
          .maybeSingle();

      if (response == null) {
        print('⚠️  Não há dados na tabela para comparar');
        return;
      }

      final schemaFields = response;

      print('\n🔄 COMPARANDO MODEL COM SCHEMA REAL');
      print('Tabela: $tableName');
      print('-' * 60);

      // Campos no schema mas não na model
      final missingInModel = <String>[];
      schemaFields.forEach((key, value) {
        final camelCase = _toCamelCase(key);
        if (!modelFields.containsKey(camelCase)) {
          missingInModel.add(key);
        }
      });

      // Campos na model mas não no schema
      final missingInSchema = <String>[];
      modelFields.forEach((key, type) {
        final snakeCase = _toSnakeCase(key);
        if (!schemaFields.containsKey(snakeCase)) {
          missingInSchema.add(key);
        }
      });

      if (missingInModel.isEmpty && missingInSchema.isEmpty) {
        print('✅ Model está sincronizada com o schema!');
      } else {
        if (missingInModel.isNotEmpty) {
          print('⚠️  Campos no Schema mas NÃO na Model:');
          for (final field in missingInModel) {
            print('   - $field (${_toCamelCase(field)})');
          }
        }

        if (missingInSchema.isNotEmpty) {
          print('\n⚠️  Campos na Model mas NÃO no Schema:');
          for (final field in missingInSchema) {
            print('   - $field');
          }
        }
      }
    } catch (e) {
      print('❌ Erro ao comparar: $e');
    }
  }

  /// Converte camelCase para snake_case
  String _toSnakeCase(String camelCase) {
    return camelCase.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }
}
