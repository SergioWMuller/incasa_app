# Sincronizar Models com Schema do Supabase

## 🎯 Problema
As tabelas e campos no Supabase são diferentes das models no código Flutter.

## 📋 Estratégias para Sincronização

### Estratégia 1: Copiar Estrutura Automaticamente via SQL ⭐ (MAIS RÁPIDO)

1. **Acesse SQL Editor** no Supabase Dashboard
2. **Execute este query** para uma tabela específica:

```sql
-- Copie ESTE QUERY e execute no Supabase SQL Editor
SELECT 
  column_name as "Campo",
  data_type as "Tipo SQL",
  CASE 
    WHEN data_type = 'uuid' THEN 'String'
    WHEN data_type IN ('text', 'character varying') THEN 'String'
    WHEN data_type IN ('integer', 'smallint', 'bigint') THEN 'int'
    WHEN data_type IN ('numeric', 'decimal', 'real', 'double precision') THEN 'double'
    WHEN data_type = 'boolean' THEN 'bool'
    WHEN data_type IN ('timestamp with time zone', 'timestamp without time zone', 'date') THEN 'DateTime'
    WHEN data_type = 'jsonb' OR data_type = 'json' THEN 'Map<String, dynamic>'
    WHEN data_type = 'ARRAY' THEN 'List'
    ELSE 'dynamic'
  END as "Tipo Dart",
  CASE 
    WHEN is_nullable = 'YES' THEN 'nullable'
    ELSE 'required'
  END as "Nullable",
  column_default as "Default"
FROM information_schema.columns
WHERE table_name = 'products'  -- ⬅️ TROQUE AQUI pelo nome da sua tabela
  AND table_schema = 'public'
ORDER BY ordinal_position;
```

3. **Copie o resultado** - O Supabase permite exportar como CSV ou copiar diretamente

4. **Para todas as tabelas de uma vez:**

```sql
-- Ver estrutura de TODAS as tabelas
SELECT 
  table_name as "Tabela",
  column_name as "Campo",
  data_type as "Tipo SQL",
  CASE 
    WHEN data_type = 'uuid' THEN 'String'
    WHEN data_type IN ('text', 'character varying') THEN 'String'
    WHEN data_type IN ('integer', 'smallint', 'bigint') THEN 'int'
    WHEN data_type IN ('numeric', 'decimal', 'real', 'double precision') THEN 'double'
    WHEN data_type = 'boolean' THEN 'bool'
    WHEN data_type IN ('timestamp with time zone', 'timestamp without time zone', 'date') THEN 'DateTime'
    WHEN data_type = 'jsonb' OR data_type = 'json' THEN 'Map<String, dynamic>'
    ELSE 'dynamic'
  END as "Tipo Dart",
  is_nullable as "Nullable"
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('users', 'products', 'categories', 'stores')  -- ⬅️ SUAS TABELAS
ORDER BY table_name, ordinal_position;
```

💡 **Dica:** No Supabase SQL Editor, após executar o query, você pode:
- Clicar em "Copy" para copiar tudo
- Clicar em "Download CSV" para baixar

---

### Estratégia 1b: Inspecionar via Dashboard (Visual)

1. **Acesse o Supabase Dashboard**
   - Vá para [supabase.com](https://supabase.com)
   - Selecione seu projeto
   - Clique em **Table Editor** no menu lateral

2. **Para cada tabela:**
   - Clique na tabela
   - Na aba "Definition" ou "Columns" você vê tudo
   - Copie direto ou tire screenshot

3. **Atualize as Models** baseado no que viu

---

### Estratégia 2: Gerar Código Dart Diretamente via SQL 🚀

Execute este query **no Supabase SQL Editor** e ele já gera código Dart pronto:

```sql
-- 🎯 QUERY QUE GERA CÓDIGO DART AUTOMATICAMENTE
-- Execute no Supabase e copie o resultado!

SELECT 
  '  final ' || 
  CASE 
    WHEN data_type = 'uuid' THEN 'String'
    WHEN data_type IN ('text', 'character varying') THEN 'String'
    WHEN data_type IN ('integer', 'smallint', 'bigint') THEN 'int'
    WHEN data_type IN ('numeric', 'decimal', 'real', 'double precision') THEN 'double'
    WHEN data_type = 'boolean' THEN 'bool'
    WHEN data_type IN ('timestamp with time zone', 'timestamp without time zone', 'date') THEN 'DateTime'
    WHEN data_type = 'jsonb' OR data_type = 'json' THEN 'Map<String, dynamic>'
    ELSE 'dynamic'
  END ||
  CASE WHEN is_nullable = 'YES' THEN '?' ELSE '' END ||
  ' ' ||
  -- Converter snake_case para camelCase
  regexp_replace(
    regexp_replace(column_name, '_([a-z])', E'\\U\\1', 'g'),
    '^([a-z])', E'\\U\\1'
  ) ||
  ';  // ' || column_name as "Código Dart"
FROM information_schema.columns
WHERE table_name = 'products'  -- ⬅️ TROQUE pelo nome da tabela
  AND table_schema = 'public'
ORDER BY ordinal_position;
```

**Resultado exemplo:**
```dart
final String id;  // id
final String storeId;  // store_id
final String name;  // name
final double price;  // price
final String? imageUrl;  // image_url
final DateTime createdAt;  // created_at
```

**Copie e cole direto na sua Entity/Model!** ✨

---

### Estratégia 3: Script Dart para Inspecionar Schema 🔧

Crie um arquivo temporário para executar:

**`scripts/inspect_supabase_schema.dart`**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para inspecionar schema do Supabase
/// Uso: dart run scripts/inspect_supabase_schema.dart
void main() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'SUA_URL_AQUI',
    anonKey: 'SUA_ANON_KEY_AQUI',
  );

  final supabase = Supabase.instance.client;

  print('🔍 Inspecionando Schema do Supabase...\n');

  // Lista de tabelas para inspecionar
  final tables = ['users', 'products', 'categories', 'stores'];

  for (final table in tables) {
    await inspectTable(supabase, table);
  }
}

Future<void> inspectTable(SupabaseClient supabase, String tableName) async {
  print('📊 Tabela: $tableName');
  print('=' * 50);

  try {
    // Buscar um registro para ver a estrutura
    final response = await supabase
        .from(tableName)
        .select()
        .limit(1)
        .maybeSingle();

    if (response == null) {
      print('⚠️  Tabela vazia ou não existe\n');
      return;
    }

    final data = response as Map<String, dynamic>;
    
    print('Campos encontrados:');
    data.forEach((key, value) {
      final type = _inferDartType(value);
      final nullable = value == null ? '?' : '';
      print('  - $key: $type$nullable');
    });
    
    print('\n📝 Exemplo de dados:');
    print(data);
    print('\n');

  } catch (e) {
    print('❌ Erro ao inspecionar tabela: $e\n');
  }
}

String _inferDartType(dynamic value) {
  if (value == null) return 'dynamic';
  if (value is String) return 'String';
  if (value is int) return 'int';
  if (value is double) return 'double';
  if (value is bool) return 'bool';
  if (value is List) return 'List';
  if (value is Map) return 'Map<String, dynamic>';
  return 'dynamic';
}
```

**Como executar:**
```bash
# Na raiz do projeto
dart run scripts/inspect_supabase_schema.dart
```

---

### Estratégia 4: Fetch Real Data e Ver JSON 🚀

Crie um arquivo de teste:

**`lib/core/utils/supabase_inspector.dart`**

```dart
import 'package:incasa_app/core/network/supabase_client.dart';

/// Helper para inspecionar dados reais do Supabase
class SupabaseInspector {
  final SupabaseClientWrapper supabase;

  SupabaseInspector(this.supabase);

  /// Busca e imprime estrutura de uma tabela
  Future<void> inspectTable(String tableName) async {
    try {
      print('🔍 Inspecionando tabela: $tableName');
      
      final response = await supabase
          .from(tableName)
          .select()
          .limit(3); // Pega 3 registros como exemplo

      if (response.isEmpty) {
        print('⚠️  Tabela vazia');
        return;
      }

      print('\n📊 Estrutura encontrada:');
      final firstRecord = response[0] as Map<String, dynamic>;
      
      firstRecord.forEach((key, value) {
        print('  $key: ${value.runtimeType} = $value');
      });

      print('\n📝 JSON completo do primeiro registro:');
      print(firstRecord);
      
    } catch (e) {
      print('❌ Erro: $e');
    }
  }

  /// Busca todas as colunas de todas as tabelas
  Future<void> inspectAllTables() async {
    final tables = ['users', 'products', 'categories', 'stores'];
    
    for (final table in tables) {
      await inspectTable(table);
      print('\n' + '=' * 60 + '\n');
    }
  }
}
```

**Como usar em um teste ou widget temporário:**

```dart
// Em algum lugar do código (ex: botão de debug)
final inspector = SupabaseInspector(sl<SupabaseClientWrapper>());
await inspector.inspectTable('products');
```

---

## 🔄 Processo de Atualização das Models

### Passo 1: Identificar Diferenças

Exemplo - você descobriu que no Supabase a tabela `products` tem:
```
id: uuid
name: text
price: numeric
store_id: uuid (foreign key)
image_url: text
created_at: timestamptz
updated_at: timestamptz
```

Mas sua model tem campos diferentes.

### Passo 2: Atualizar a Entity (Domain)

```dart
// lib/domain/entities/marketplace/product.dart
class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final String storeId;        // ✅ Adicionar
  final String? imageUrl;      // ✅ Renomear de image
  final DateTime createdAt;
  final DateTime? updatedAt;   // ✅ Adicionar

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.storeId,     // ✅ Adicionar
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,            // ✅ Adicionar
  });

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    storeId,                   // ✅ Adicionar
    imageUrl,
    createdAt,
    updatedAt,                 // ✅ Adicionar
  ];
}
```

### Passo 3: Atualizar a Model (Data)

```dart
// lib/data/models/marketplace/product_model.dart
import 'package:incasa_app/domain/entities/marketplace/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.storeId,
    super.imageUrl,
    required super.createdAt,
    super.updatedAt,
  });

  // ========================================
  // SUPABASE (MVP - USAR AGORA) ✅
  // ========================================

  /// Converte dados do Supabase para ProductModel
  factory ProductModel.fromSupabase(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      storeId: map['store_id'] as String,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Converte ProductModel para Supabase
  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'store_id': storeId,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ========================================
  // LARAVEL API (FUTURO) 📦
  // ========================================

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      storeId: json['storeId'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'storeId': storeId,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ========================================
  // CONVERSÃO DE/PARA ENTITY
  // ========================================

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
      storeId: product.storeId,
      imageUrl: product.imageUrl,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }
}
```

---

## 📝 Checklist de Sincronização

Para cada tabela no Supabase:

- [ ] **1. Inspecionar Schema**
  - Via Dashboard ou SQL query
  - Anotar todos os campos e tipos

- [ ] **2. Atualizar Entity (Domain)**
  - Adicionar/remover/renomear campos
  - Atualizar `props` do Equatable
  - Não importar nada de Supabase aqui!

- [ ] **3. Atualizar Model (Data)**
  - Adicionar `.fromSupabase()` constructor
  - Adicionar `.toSupabase()` method
  - Mapear nomes corretos das colunas
  - Manter `.fromJson()` para Laravel futuro

- [ ] **4. Atualizar DataSource**
  - Usar `supabase.from('nome_correto_da_tabela')`
  - Garantir que os campos selecionados existem

- [ ] **5. Testar**
  - Fazer query real
  - Ver se os dados são parseados corretamente

---

## 🗺️ Mapeamento de Tipos SQL → Dart

| PostgreSQL (Supabase) | Dart |
|----------------------|------|
| `uuid` | `String` |
| `text` / `varchar` | `String` |
| `integer` / `int4` | `int` |
| `bigint` / `int8` | `int` |
| `numeric` / `decimal` | `double` |
| `boolean` | `bool` |
| `timestamptz` / `timestamp` | `DateTime` |
| `date` | `DateTime` |
| `json` / `jsonb` | `Map<String, dynamic>` ou `List` |
| `array` | `List<T>` |

**Nullable?**
- Se coluna permite NULL → adicione `?` no tipo Dart
- Se coluna é NOT NULL → tipo sem `?`

---

## 🔧 Dicas de Snake_case → camelCase

Supabase/PostgreSQL usa `snake_case`, Dart usa `camelCase`:

```dart
// No fromSupabase():
storeId: map['store_id']           // ✅
imageUrl: map['image_url']         // ✅
createdAt: map['created_at']       // ✅

// No toSupabase():
'store_id': storeId               // ✅
'image_url': imageUrl             // ✅
'created_at': createdAt           // ✅
```

---

## ⚡ Script Rápido de Geração (Avançado)

Se você quer gerar models automaticamente, pode usar o **supabase-cli**:

```bash
# Instalar Supabase CLI
npm install -g supabase

# Gerar tipos TypeScript (pode converter para Dart)
supabase gen types typescript --project-id seu-projeto-id > schema.ts
```

Depois converta os tipos TypeScript para Dart manualmente ou use ferramentas como `quicktype`.

---

## 📚 Exemplo Completo de Workflow

### 1. Descobrir campos da tabela `users`

```sql
-- No SQL Editor do Supabase
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'users';
```

Resultado:
```
id               | uuid           | NO
firebase_uid     | text           | NO
email           | text           | NO
display_name    | text           | YES
photo_url       | text           | YES
created_at      | timestamptz    | NO
updated_at      | timestamptz    | YES
```

### 2. Atualizar UserModel

```dart
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.firebaseUid,
    required super.email,
    super.displayName,
    super.photoUrl,
    required super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromSupabase(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      firebaseUid: map['firebase_uid'] as String,
      email: map['email'] as String,
      displayName: map['display_name'] as String?,
      photoUrl: map['photo_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
```

---

## 🎯 Recomendação Final

**Abordagem mais prática e RÁPIDA:**

### ⚡ Opção 1: SQL Queries Automáticas (MAIS RÁPIDO) ⭐
1. ✅ Abra o Supabase Dashboard → SQL Editor
2. ✅ Use as queries prontas em **[scripts/generate_supabase_queries.md](scripts/generate_supabase_queries.md)**
3. ✅ Execute e copie o código gerado automaticamente
4. ✅ Cole nas suas Models
5. ✅ **Tempo: 2-3 minutos por tabela!**

### 🎯 Opção 2: Guia Rápido Passo a Passo
👉 Veja: **[scripts/QUICK_START.md](scripts/QUICK_START.md)** para um tutorial com exemplo completo

### 💻 Opção 3: Script Dart Executável
```bash
# Configure credenciais e execute:
dart run scripts/generate_dart_from_schema.dart
```

### 📋 Opção 4: Ferramentas de Inspeção
- Use o teste: `flutter test test/tools/inspect_supabase_schema_test.dart`
- Use o helper: `SupabaseInspector` (veja [TOOLS_README.md](TOOLS_README.md))

---

**Não tente automatizar tudo sozinho** - use as ferramentas já prontas! ⚡

**Arquivos úteis:**
- 📄 [scripts/QUICK_START.md](scripts/QUICK_START.md) - Tutorial rápido com exemplos
- 📄 [scripts/generate_supabase_queries.md](scripts/generate_supabase_queries.md) - Queries SQL prontas
- 📄 [scripts/README.md](scripts/README.md) - Visão geral de todas as ferramentas
- 📄 [TOOLS_README.md](TOOLS_README.md) - Ferramentas Dart de inspeção
