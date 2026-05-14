# 🎯 Guia Rápido - Copiar Schema do Supabase Automaticamente

## 🚀 Forma Mais Rápida (2 minutos)

### Passo 1: Abra o Supabase Dashboard
1. Acesse https://supabase.com
2. Entre no seu projeto
3. Clique em **SQL Editor** (menu lateral esquerdo)

### Passo 2: Execute Esta Query
```sql
-- ✂️ COPIE E COLE ESTA QUERY COMPLETA
-- Depois só troque 'products' pelo nome da sua tabela

SELECT 
  column_name as "Campo SQL (snake_case)",
  -- Converter para camelCase automaticamente
  regexp_replace(
    array_to_string(
      array_agg(
        CASE 
          WHEN row_number = 1 THEN part
          ELSE initcap(part)
        END
      ), ''
    ), '', ''
  ) as "Campo Dart (camelCase)",
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
    WHEN is_nullable = 'YES' THEN '✅ nullable (?)'
    ELSE '❌ required'
  END as "Obrigatório"
FROM (
  SELECT 
    column_name,
    data_type,
    is_nullable,
    ordinal_position,
    regexp_split_to_table(column_name, '_') as part,
    row_number() OVER (PARTITION BY column_name ORDER BY ordinal_position) as row_number
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'products'  -- ⬅️⬅️⬅️ TROQUE AQUI
) subq
GROUP BY column_name, data_type, is_nullable, ordinal_position
ORDER BY ordinal_position;
```

### Passo 3: Copie o Resultado
Clique em **"Copy"** no canto superior direito do resultado

### Passo 4: Use na Sua Model
Agora você tem tudo que precisa:
- Nome do campo em SQL (snake_case)
- Nome do campo em Dart (camelCase)
- Tipo correto
- Se é nullable ou required

---

## 🎯 Exemplo Real

### Input (Tabela `products` no Supabase):
```
id               | uuid           | NOT NULL
store_id         | uuid           | NOT NULL
name            | text           | NOT NULL
price           | numeric        | NOT NULL
image_url       | text           | NULL
created_at      | timestamptz    | NOT NULL
updated_at      | timestamptz    | NULL
```

### Output da Query:
```
| Campo SQL    | Campo Dart | Tipo Dart | Obrigatório      |
|--------------|------------|-----------|------------------|
| id           | id         | String    | ❌ required      |
| store_id     | storeId    | String    | ❌ required      |
| name         | name       | String    | ❌ required      |
| price        | price      | double    | ❌ required      |
| image_url    | imageUrl   | String    | ✅ nullable (?)  |
| created_at   | createdAt  | DateTime  | ❌ required      |
| updated_at   | updatedAt  | DateTime  | ✅ nullable (?)  |
```

### Use Para Criar a Entity:
```dart
class Product extends Equatable {
  final String id;
  final String storeId;
  final String name;
  final double price;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    storeId,
    name,
    price,
    imageUrl,
    createdAt,
    updatedAt,
  ];
}
```

### E a Model:
```dart
factory ProductModel.fromSupabase(Map<String, dynamic> map) {
  return ProductModel(
    id: map['id'] as String,
    storeId: map['store_id'] as String,
    name: map['name'] as String,
    price: (map['price'] as num).toDouble(),
    imageUrl: map['image_url'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: map['updated_at'] != null 
        ? DateTime.parse(map['updated_at'] as String) 
        : null,
  );
}

Map<String, dynamic> toSupabase() {
  return {
    'id': id,
    'store_id': storeId,
    'name': name,
    'price': price,
    'image_url': imageUrl,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
```

---

## 🔥 Query Ainda Mais Rápida (Gera Código Dart Direto)

Se você quiser que a query já gere o código Dart pronto:

```sql
-- 🚀 GERA CÓDIGO DART AUTOMATICAMENTE
-- Execute no Supabase e copie o output direto!

WITH RECURSIVE split_parts AS (
  SELECT 
    column_name,
    data_type,
    is_nullable,
    ordinal_position,
    regexp_split_to_array(column_name, '_') as parts
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'products'  -- ⬅️⬅️⬅️ TROQUE AQUI
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
  ' ' ||
  parts[1] || 
  coalesce(
    (SELECT string_agg(initcap(p), '') FROM unnest(parts[2:array_length(parts,1)]) p),
    ''
  ) ||
  ';  // SQL: ' || column_name as "📋 Código Dart - Cole na Entity"
FROM split_parts
ORDER BY ordinal_position;
```

**Output direto:**
```dart
  final String id;  // SQL: id
  final String storeId;  // SQL: store_id
  final String name;  // SQL: name
  final double price;  // SQL: price
  final String? imageUrl;  // SQL: image_url
  final DateTime createdAt;  // SQL: created_at
  final DateTime? updatedAt;  // SQL: updated_at
```

**Copie e cole direto na sua Entity!** 🎉

---

## 📚 Queries Disponíveis

Para mais queries prontas (constructor, fromSupabase, toSupabase, etc):

👉 Veja: **[scripts/generate_supabase_queries.md](generate_supabase_queries.md)**

---

## 💡 Dica Final

**Não perca tempo anotando manualmente!**

1. ✅ Use as queries SQL acima
2. ✅ Execute no Supabase Dashboard
3. ✅ Copie o resultado
4. ✅ Cole nas suas Models
5. ✅ Profit! 🚀

**Tempo total:** 2-3 minutos por tabela!
