import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Script executável para gerar código Dart automaticamente
/// baseado no schema real do Supabase
///
/// **Como usar:**
/// 1. Configure o arquivo .env na raiz do projeto com suas credenciais
/// 2. Ajuste a tabela e nome da classe abaixo
/// 3. Execute: dart run scripts/generate_dart_from_schema.dart
/// 4. Copie o código gerado no console
/// 5. Cole nas suas Models
void main() async {
  // ⬇️ CONFIGURE AQUI
  const tableName = 'users'; // ⬅️ TROQUE pelo nome da tabela
  const className = 'User'; // ⬅️ Nome da Entity/Model

  print('🚀 Gerando código Dart para tabela: $tableName\n');

  try {
    // Carregar variáveis de ambiente
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      print('❌ ERRO: Credenciais não encontradas no arquivo .env');
      print('💡 Certifique-se de que .env existe e contém:');
      print('   SUPABASE_URL=https://seu-projeto.supabase.co');
      print('   SUPABASE_ANON_KEY=sua-chave-aqui');
      return;
    }

    // Inicializar Supabase
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    final supabase = Supabase.instance.client;

    // Buscar um registro de exemplo
    final response = await supabase
        .from(tableName)
        .select()
        .limit(1)
        .maybeSingle();

    if (response == null) {
      print('⚠️  Tabela vazia! Adicione pelo menos um registro de teste.');
      return;
    }

    final data = response;
    final fields = <String, dynamic>{};

    data.forEach((key, value) {
      fields[key] = value;
    });

    print('=' * 80);
    print('📊 SCHEMA DETECTADO DA TABELA: $tableName');
    print('=' * 80);
    print('');

    // 1. Gerar fields da Entity
    _generateEntityFields(fields, className);
    print('');

    // 2. Gerar constructor
    _generateConstructor(fields, className);
    print('');

    // 3. Gerar props (Equatable)
    _generateProps(fields);
    print('');

    // 4. Gerar fromSupabase()
    _generateFromSupabase(fields, className);
    print('');

    // 5. Gerar toSupabase()
    _generateToSupabase(fields);
    print('');

    print('=' * 80);
    print('✅ CÓDIGO GERADO COM SUCESSO!');
    print('💡 Copie e cole nas suas Models');
    print('=' * 80);
  } catch (e, stack) {
    print('❌ ERRO: $e');
    print('Stack: $stack');
  }
}

void _generateEntityFields(Map<String, dynamic> fields, String className) {
  print('// ==========================================');
  print('// 1️⃣ ENTITY FIELDS (domain/entities/)');
  print('// ==========================================');
  print('');
  print('class $className extends Equatable {');

  fields.forEach((key, value) {
    final dartType = _inferDartType(value);
    final isNullable = value == null;
    final camelCase = _toCamelCase(key);

    print('  final $dartType${isNullable ? '?' : ''} $camelCase;');
  });

  print('}');
}

void _generateConstructor(Map<String, dynamic> fields, String className) {
  print('// ==========================================');
  print('// 2️⃣ CONSTRUCTOR');
  print('// ==========================================');
  print('');
  print('const ${className}Model({');

  fields.forEach((key, value) {
    final isNullable = value == null;
    final camelCase = _toCamelCase(key);

    if (!isNullable) {
      print('  required super.$camelCase,');
    } else {
      print('  super.$camelCase,');
    }
  });

  print('});');
}

void _generateProps(Map<String, dynamic> fields) {
  print('// ==========================================');
  print('// 3️⃣ EQUATABLE PROPS');
  print('// ==========================================');
  print('');
  print('@override');
  print('List<Object?> get props => [');

  fields.forEach((key, value) {
    final camelCase = _toCamelCase(key);
    print('  $camelCase,');
  });

  print('];');
}

void _generateFromSupabase(Map<String, dynamic> fields, String className) {
  print('// ==========================================');
  print('// 4️⃣ fromSupabase() - MVP Supabase');
  print('// ==========================================');
  print('');
  print('factory ${className}Model.fromSupabase(Map<String, dynamic> map) {');
  print('  return ${className}Model(');

  fields.forEach((key, value) {
    final dartType = _inferDartType(value);
    final isNullable = value == null;
    final camelCase = _toCamelCase(key);

    if (dartType == 'DateTime') {
      if (isNullable) {
        print(
          "    $camelCase: map['$key'] != null ? DateTime.parse(map['$key'] as String) : null,",
        );
      } else {
        print("    $camelCase: DateTime.parse(map['$key'] as String),");
      }
    } else if (dartType == 'double') {
      if (isNullable) {
        print(
          "    $camelCase: map['$key'] != null ? (map['$key'] as num).toDouble() : null,",
        );
      } else {
        print("    $camelCase: (map['$key'] as num).toDouble(),");
      }
    } else {
      if (isNullable) {
        print("    $camelCase: map['$key'] as $dartType?,");
      } else {
        print("    $camelCase: map['$key'] as $dartType,");
      }
    }
  });

  print('  );');
  print('}');
}

void _generateToSupabase(Map<String, dynamic> fields) {
  print('// ==========================================');
  print('// 5️⃣ toSupabase()');
  print('// ==========================================');
  print('');
  print('Map<String, dynamic> toSupabase() {');
  print('  return {');

  fields.forEach((key, value) {
    final dartType = _inferDartType(value);
    final camelCase = _toCamelCase(key);

    if (dartType == 'DateTime') {
      print(
        "    '$key': $camelCase${value == null ? '?' : ''}.toIso8601String(),",
      );
    } else {
      print("    '$key': $camelCase,");
    }
  });

  print('  };');
  print('}');
}

String _inferDartType(dynamic value) {
  if (value == null) return 'dynamic';
  if (value is String) {
    if (_isDateTime(value)) return 'DateTime';
    return 'String';
  }
  if (value is int) return 'int';
  if (value is double) return 'double';
  if (value is bool) return 'bool';
  if (value is List) {
    if (value.isEmpty) return 'List<dynamic>';
    return 'List<${_inferDartType(value.first)}>';
  }
  if (value is Map) return 'Map<String, dynamic>';
  return 'dynamic';
}

bool _isDateTime(String value) {
  try {
    DateTime.parse(value);
    return true;
  } catch (_) {
    return false;
  }
}

String _toCamelCase(String snakeCase) {
  final parts = snakeCase.split('_');
  if (parts.length == 1) return snakeCase;

  return parts.first +
      parts
          .skip(1)
          .map((part) => part[0].toUpperCase() + part.substring(1))
          .join('');
}
