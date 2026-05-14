# 🔧 Queries SQL para Copiar Schema do Supabase Automaticamente

Execute estes queries no **Supabase SQL Editor** e copie os resultados.

---

## 📊 Query 1: Ver Estrutura Completa de UMA Tabela

```sql
-- ✂️ COPIE ESTE QUERY COMPLETO E EXECUTE NO SUPABASE
-- Depois troque 'products' pelo nome da sua tabela

SELECT 
  column_name as "Campo SQL",
  CASE 
    WHEN data_type = 'uuid' THEN 'String'
    WHEN data_type IN ('text', 'character varying', 'varchar') THEN 'String'
    WHEN data_type IN ('integer', 'smallint', 'bigint', 'int4', 'int8') THEN 'int'
    WHEN data_type IN ('numeric', 'decimal', 'real', 'double precision') THEN 'double'
    WHEN data_type = 'boolean' THEN 'bool'
    WHEN data_type IN ('timestamp with time zone', 'timestamp without time zone', 'timestamptz', 'date') THEN 'DateTime'
    WHEN data_type IN ('jsonb', 'json') THEN 'Map<String, dynamic>'
    WHEN data_type = 'ARRAY' THEN 'List'
    ELSE 'dynamic'
  END as "Tipo Dart",
  CASE 
    WHEN is_nullable = 'YES' THEN 'nullable (?)'
    ELSE 'required'
  END as "Obrigatório",
  data_type as "Tipo SQL Original",
  column_default as "Valor Default"
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'products'  -- ⬅️⬅️⬅️ TROQUE AQUI
ORDER BY ordinal_position;
```

**Como usar:**
1. Cole no SQL Editor do Supabase
2. Troque `'products'` pelo nome da sua tabela
3. Execute (Run)
4. Clique em "Copy" ou "Download CSV"
5. Use a informação para atualizar sua Model

---

## 🎯 Query 2: Gerar Código Dart Automaticamente (Entity Fields)

```sql
-- 🚀 GERA CÓDIGO DART PRONTO PARA COPIAR
-- Execute no Supabase e copie o output direto para sua Entity!

WITH snake_to_camel AS (
  SELECT 
    column_name,
    data_type,
    is_nullable,
    -- Converter snake_case para camelCase
    string_agg(
      CASE 
        WHEN row_number() OVER (PARTITION BY column_name ORDER BY pos) = 1 
        THEN part
        ELSE initcap(part)
      END,
      ''
    ) as camel_case
  FROM information_schema.columns,
       LATERAL regexp_split_to_table(column_name, '_') WITH ORDINALITY AS t(part, pos)
  WHERE table_schema = 'public'
    AND table_name = 'products'  -- ⬅️⬅️⬅️ TROQUE AQUI
  GROUP BY column_name, data_type, is_nullable, ordinal_position
  ORDER BY ordinal_position
)
SELECT 
  '  final ' || 
  CASE 
    WHEN data_type = 'uuid' THEN 'String'
    WHEN data_type IN ('text', 'character varying', 'varchar') THEN 'String'
    WHEN data_type IN ('integer', 'smallint', 'bigint', 'int4', 'int8') THEN 'int'
    WHEN data_type IN ('numeric', 'decimal', 'real', 'double precision') THEN 'double'
    WHEN data_type = 'boolean' THEN 'bool'
    WHEN data_type IN ('timestamp with time zone', 'timestamp without time zone', 'timestamptz', 'date') THEN 'DateTime'
    WHEN data_type IN ('jsonb', 'json') THEN 'Map<String, dynamic>'
    ELSE 'dynamic'
  END ||
  CASE WHEN is_nullable = 'YES' THEN '?' ELSE '' END ||
  ' ' || camel_case || ';' ||
  '  // ' || column_name as "📋 Copie este código Dart"
FROM snake_to_camel;
```

**Output exemplo:**
```dart
  final String id;  // id
  final String storeId;  // store_id
  final String name;  // name
  final double price;  // price
  final String? imageUrl;  // image_url
  final DateTime createdAt;  // created_at
  final DateTime? updatedAt;  // updated_at
```

---

## 📦 Query 3: Gerar Constructor Completo da Entity

```sql
-- 🎯 GERA O CONSTRUCTOR COMPLETO
-- Execute e copie direto para sua Entity

WITH snake_to_camel AS (
  SELECT 
    column_name,
    data_type,
    is_nullable,
    ordinal_position,
    string_agg(
      CASE 
        WHEN row_number() OVER (PARTITION BY column_name ORDER BY pos) = 1 
        THEN part
        ELSE initcap(part)
      END,
      ''
    ) as camel_case
  FROM information_schema.columns,
       LATERAL regexp_split_to_table(column_name, '_') WITH ORDINALITY AS t(part, pos)
  WHERE table_schema = 'public'
    AND table_name = 'products'  -- ⬅️⬅️⬅️ TROQUE AQUI
  GROUP BY column_name, data_type, is_nullable, ordinal_position
)
SELECT 
  CASE 
    WHEN is_nullable = 'NO' THEN '    required super.' || camel_case || ','
    ELSE '    super.' || camel_case || ','
  END as "📋 Copie para o constructor"
FROM snake_to_camel
ORDER BY ordinal_position;
```

**Output exemplo:**
```dart
    required super.id,
    required super.storeId,
    required super.name,
    required super.price,
    super.imageUrl,
    required super.createdAt,
    super.updatedAt,
```

---

## 🔄 Query 4: Gerar fromSupabase() Completo

```sql
-- 🚀 GERA O MÉTODO fromSupabase() AUTOMATICAMENTE

WITH snake_to_camel AS (
  SELECT 
    column_name,
    data_type,
    is_nullable,
    ordinal_position,
    string_agg(
      CASE 
        WHEN row_number() OVER (PARTITION BY column_name ORDER BY pos) = 1 
        THEN part
        ELSE initcap(part)
      END,
      ''
    ) as camel_case
  FROM information_schema.columns,
       LATERAL regexp_split_to_table(column_name, '_') WITH ORDINALITY AS t(part, pos)
  WHERE table_schema = 'public'
    AND table_name = 'products'  -- ⬅️⬅️⬅️ TROQUE AQUI
  GROUP BY column_name, data_type, is_nullable, ordinal_position
)
SELECT 
  '    ' || camel_case || ': ' ||
  CASE 
    WHEN data_type IN ('timestamp with time zone', 'timestamp without time zone', 'timestamptz', 'date') THEN
      CASE 
        WHEN is_nullable = 'YES' THEN 'map[''' || column_name || '''] != null ? DateTime.parse(map[''' || column_name || '''] as String) : null,'
        ELSE 'DateTime.parse(map[''' || column_name || '''] as String),'
      END
    WHEN data_type IN ('numeric', 'decimal', 'real', 'double precision') THEN
      CASE 
        WHEN is_nullable = 'YES' THEN 'map[''' || column_name || '''] != null ? (map[''' || column_name || '''] as num).toDouble() : null,'
        ELSE '(map[''' || column_name || '''] as num).toDouble(),'
      END
    ELSE
      CASE 
        WHEN is_nullable = 'YES' THEN 'map[''' || column_name || '''] as ' || 
          CASE 
            WHEN data_type = 'uuid' THEN 'String?,'
            WHEN data_type IN ('text', 'character varying') THEN 'String?,'
            WHEN data_type IN ('integer', 'smallint', 'bigint') THEN 'int?,'
            WHEN data_type = 'boolean' THEN 'bool?,'
            ELSE 'dynamic,'
          END
        ELSE 'map[''' || column_name || '''] as ' ||
          CASE 
            WHEN data_type = 'uuid' THEN 'String,'
            WHEN data_type IN ('text', 'character varying') THEN 'String,'
            WHEN data_type IN ('integer', 'smallint', 'bigint') THEN 'int,'
            WHEN data_type = 'boolean' THEN 'bool,'
            ELSE 'dynamic,'
          END
      END
  END as "📋 Copie para fromSupabase()"
FROM snake_to_camel
ORDER BY ordinal_position;
```

**Output exemplo:**
```dart
    id: map['id'] as String,
    storeId: map['store_id'] as String,
    name: map['name'] as String,
    price: (map['price'] as num).toDouble(),
    imageUrl: map['image_url'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
```

---

## 🔄 Query 5: Gerar toSupabase() Completo

```sql
-- 🚀 GERA O MÉTODO toSupabase() AUTOMATICAMENTE

WITH snake_to_camel AS (
  SELECT 
    column_name,
    data_type,
    ordinal_position,
    string_agg(
      CASE 
        WHEN row_number() OVER (PARTITION BY column_name ORDER BY pos) = 1 
        THEN part
        ELSE initcap(part)
      END,
      ''
    ) as camel_case
  FROM information_schema.columns,
       LATERAL regexp_split_to_table(column_name, '_') WITH ORDINALITY AS t(part, pos)
  WHERE table_schema = 'public'
    AND table_name = 'products'  -- ⬅️⬅️⬅️ TROQUE AQUI
  GROUP BY column_name, data_type, ordinal_position
)
SELECT 
  '    ''' || column_name || ''': ' ||
  CASE 
    WHEN data_type IN ('timestamp with time zone', 'timestamp without time zone', 'timestamptz', 'date') THEN
      camel_case || '.toIso8601String(),'
    ELSE
      camel_case || ','
  END as "📋 Copie para toSupabase()"
FROM snake_to_camel
ORDER BY ordinal_position;
```

**Output exemplo:**
```dart
    'id': id,
    'store_id': storeId,
    'name': name,
    'price': price,
    'image_url': imageUrl,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
```

---

## 📊 Query 6: Ver TODAS as Tabelas de Uma Vez

```sql
-- Ver resumo de todas as tabelas do banco
SELECT 
  table_name as "Tabela",
  column_name as "Campo",
  data_type as "Tipo SQL",
  is_nullable as "Nullable"
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('users', 'products', 'categories', 'stores')  -- ⬅️ SUAS TABELAS
ORDER BY table_name, ordinal_position;
```

---

## 🎯 Como Usar Este Arquivo

### Workflow Rápido:

1. **Abra o Supabase Dashboard** → SQL Editor

2. **Copie a Query 1** primeiro para ver a estrutura

3. **Copie a Query 2** para gerar os fields da Entity

4. **Copie a Query 3** para gerar o constructor

5. **Copie a Query 4** para gerar `fromSupabase()`

6. **Copie a Query 5** para gerar `toSupabase()`

7. **Cole tudo na sua Model** e ajuste se necessário!

---

## 💡 Dicas

- ✅ Execute uma query de cada vez
- ✅ Use "Copy" ou "Download CSV" no resultado
- ✅ Sempre revise o código gerado antes de usar
- ✅ Ajuste tipos complexos manualmente (arrays, json, etc)
- ✅ Teste com dados reais depois

---

## ⚠️ Limitações

Estas queries geram código básico. Você ainda precisa:
- Adicionar `@override` e `List<Object?> get props` na Entity
- Importar arquivos necessários
- Ajustar tipos complexos (nested objects, arrays personalizados)
- Adicionar validações se necessário

Mas economiza **90% do trabalho manual!** 🚀
