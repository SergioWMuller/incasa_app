# Endpoints do Supabase - InCasa App

## 🌐 Configuração Base

**Base URL:** `https://rhmmjsjbvfivtathuviv.supabase.co`  
**REST API Base:** `https://rhmmjsjbvfivtathuviv.supabase.co/rest/v1/`

> 💡 O Supabase Flutter SDK adiciona `/rest/v1/` automaticamente quando usamos `.from()`

## 📋 Endpoints Implementados

### 1. **Users** (`/users`)

**URL Completa:** `https://rhmmjsjbvfivtathuviv.supabase.co/rest/v1/users`

**Tabela:** `users`

**Operações:**

#### 1.1 Buscar usuário por UID
```dart
// GET /users?uid=eq.{uid}&select=*
final user = await userSupabaseDataSource.getUserByUid('firebase-uid-123');
```

**SQL Equivalente:**
```sql
SELECT * FROM users WHERE uid = 'firebase-uid-123';
```

#### 1.2 Criar novo usuário
```dart
// POST /users
final newUser = await userSupabaseDataSource.createUser(userModel);
```

**SQL Equivalente:**
```sql
INSERT INTO users (uid, email, full_name, display_name, photo_url, ...)
VALUES ('firebase-uid-123', 'user@example.com', 'John Doe', ...);
```

#### 1.3 Atualizar usuário existente
```dart
// PATCH /users?uid=eq.{uid}
final updatedUser = await userSupabaseDataSource.updateUser('firebase-uid-123', userModel);
```

**SQL Equivalente:**
```sql
UPDATE users 
SET email = 'newemail@example.com', last_sign_in_time = NOW()
WHERE uid = 'firebase-uid-123';
```

## 🔐 Autenticação

Todas as requisições incluem automaticamente o header:
```
Authorization: Bearer {supabaseAnonKey}
```

O Supabase Flutter SDK gerencia isso automaticamente após a inicialização em `main.dart`:
```dart
await Supabase.initialize(
  url: SupabaseConstants.supabaseUrl,
  anonKey: SupabaseConstants.supabaseAnonKey,
);
```

## 📦 Como Adicionar Novos Endpoints

### Passo 1: Adicionar tabela em `supabase_constants.dart`
```dart
class SupabaseConstants {
  static const String productsTable = 'products';
  static const String ordersTable = 'orders';
}
```

### Passo 2: Criar DataSource
```dart
// lib/data/datasources/remote/product_supabase_data_source.dart
abstract class ProductSupabaseDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> createProduct(ProductModel product);
}

class ProductSupabaseDataSourceImpl implements ProductSupabaseDataSource {
  final SupabaseClientWrapper supabase;

  ProductSupabaseDataSourceImpl({required this.supabase});

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await supabase
        .from(SupabaseConstants.productsTable)
        .select()
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => ProductModel.fromSupabase(json))
        .toList();
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await supabase
        .from(SupabaseConstants.productsTable)
        .insert(product.toSupabase())
        .select()
        .single();
    
    return ProductModel.fromSupabase(response);
  }
}
```

### Passo 3: Registrar no DI (`injection_container.dart`)
```dart
sl.registerLazySingleton<ProductSupabaseDataSource>(
  () => ProductSupabaseDataSourceImpl(supabase: sl()),
);
```

## 🔍 Exemplos de Queries

### Filtros
```dart
// WHERE nome = 'João'
.eq('nome', 'João')

// WHERE idade > 18
.gt('idade', 18)

// WHERE cidade IN ('São Paulo', 'Rio')
.in_('cidade', ['São Paulo', 'Rio'])

// WHERE nome LIKE '%Silva%'
.ilike('nome', '%Silva%')
```

### Ordenação
```dart
// ORDER BY created_at DESC
.order('created_at', ascending: false)
```

### Limites
```dart
// LIMIT 10
.limit(10)

// LIMIT 10 OFFSET 20
.range(20, 29)
```

### Joins (Relacionamentos)
```dart
// SELECT users.*, orders.* FROM users JOIN orders
.select('*, orders(*)')
```

## 🛡️ Row Level Security (RLS)

As políticas RLS devem ser configuradas no Supabase Dashboard:

```sql
-- Usuários só podem ver seus próprios dados
CREATE POLICY "Users can view own data"
ON users FOR SELECT
USING (auth.uid()::text = uid);

-- Usuários só podem atualizar seus próprios dados
CREATE POLICY "Users can update own data"
ON users FOR UPDATE
USING (auth.uid()::text = uid);
```

## 📚 Referências

- [Supabase Dart SDK](https://pub.dev/packages/supabase_flutter)
- [PostgREST API](https://postgrest.org/en/stable/api.html)
- [Supabase Dashboard](https://app.supabase.com/project/rhmmjsjbvfivtathuviv)
