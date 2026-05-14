# Configuração do Supabase - InCasa App

## 📋 Visão Geral
Este documento explica como o Supabase foi integrado ao InCasa App seguindo a Clean Architecture.

### Estratégia MVP
- **Firebase**: Autenticação (Google Sign-In)
- **Supabase**: Banco de dados (PostgreSQL)
- **Futuro**: Migração para Laravel + PostgreSQL no VPS

## 🔧 Arquivos Criados/Modificados

### 1. Dependências (`pubspec.yaml`)
```yaml
supabase_flutter: ^2.9.1
```

### 2. Constantes (`lib/core/constants/supabase_constants.dart`)
- ⚠️ **AÇÃO NECESSÁRIA**: Substituir `supabaseUrl` e `supabaseAnonKey` pelos valores do seu projeto

### 3. Client Wrapper (`lib/core/network/supabase_client.dart`)
- Encapsula o `SupabaseClient` oficial
- Fornece helpers para queries comuns
- Único ponto de acesso ao Supabase na camada Data

### 4. Inicialização (`lib/main.dart`)
- Supabase inicializado antes do DI
- Configurado com URL e Anon Key

### 5. Dependency Injection (`lib/core/di/injection_container.dart`)
- `SupabaseClientWrapper` registrado como singleton
- Injetado nos RemoteDataSources

## 🏗️ Como Usar na Arquitetura

### ❌ NUNCA Fazer
```dart
// NÃO usar diretamente no Domain ou Features
import 'package:supabase_flutter/supabase_flutter.dart'; // ❌

class MyUseCase {
  Future<void> getData() {
    Supabase.instance.client.from('table'); // ❌ ERRADO!
  }
}
```

### ✅ Padrão Correto

#### 1. No RemoteDataSource (camada Data)
```dart
import 'package:incasa_app/core/network/supabase_client.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductSupabaseDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClientWrapper supabase;
  
  ProductSupabaseDataSourceImpl({required this.supabase});
  
  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await supabase
        .from('products')
        .select()
        .order('created_at', ascending: false);
      
      return (response as List)
        .map((json) => ProductModel.fromSupabase(json))
        .toList();
    } catch (e) {
      throw ServerException();
    }
  }
}
```

#### 2. No Model
```dart
class ProductModel extends ProductEntity {
  // ... constructors normais
  
  // Constructor para Supabase (MVP)
  factory ProductModel.fromSupabase(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'] as String?,
      // ... outros campos
    );
  }
  
  // Serialização para Supabase
  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      // ... outros campos
    };
  }
  
  // Constructor para API futura (Laravel)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      // ... ajustar nomes de campos conforme API
    );
  }
}
```

#### 3. Registro no DI
```dart
// injection_container.dart

// Data Source
sl.registerLazySingleton<ProductRemoteDataSource>(
  () => ProductSupabaseDataSourceImpl(supabase: sl()),
);

// Repository
sl.registerLazySingleton<ProductRepository>(
  () => ProductRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
  ),
);
```

## 📊 Schema do Supabase

### Tabelas Recomendadas

#### `users`
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  firebase_uid TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  display_name TEXT,
  photo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `stores`
```sql
CREATE TABLE stores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `products`
```sql
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT,
  category_id UUID REFERENCES categories(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `categories`
```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Row Level Security (RLS)

```sql
-- Habilitar RLS nas tabelas
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Policies (exemplo para users)
CREATE POLICY "Users can view own data" 
  ON users FOR SELECT 
  USING (firebase_uid = auth.uid());

CREATE POLICY "Users can update own data" 
  ON users FOR UPDATE 
  USING (firebase_uid = auth.uid());
```

## 🔐 Configuração

### 1. Obter Credenciais do Supabase
1. Acesse [supabase.com](https://supabase.com)
2. Crie/abra seu projeto
3. Vá em **Settings > API**
4. Copie:
   - Project URL
   - anon/public key

### 2. Atualizar Constantes
Edite [`lib/core/constants/supabase_constants.dart`](lib/core/constants/supabase_constants.dart):
```dart
static const String supabaseUrl = 'https://seu-projeto.supabase.co';
static const String supabaseAnonKey = 'sua-anon-key-aqui';
```

### 3. Instalar Dependências
```bash
flutter pub get
```

## 🔄 Migração de Firebase para Supabase

Para migrar um módulo existente (ex: Profile):

1. **Adicionar métodos Supabase no Model**:
   ```dart
   factory UserModel.fromSupabase(Map<String, dynamic> map) { ... }
   Map<String, dynamic> toSupabase() { ... }
   ```

2. **Criar nova implementação do DataSource**:
   ```dart
   class ProfileSupabaseDataSourceImpl implements ProfileRemoteDataSource {
     final SupabaseClientWrapper supabase;
     // ...
   }
   ```

3. **Trocar registro no DI**:
   ```dart
   // Comentar Firebase
   // sl.registerLazySingleton<ProfileRemoteDataSource>(
   //   () => ProfileFirebaseDataSourceImpl(...)
   // );
   
   // Ativar Supabase
   sl.registerLazySingleton<ProfileRemoteDataSource>(
     () => ProfileSupabaseDataSourceImpl(supabase: sl())
   );
   ```

4. **Domain e Features**: Nenhuma mudança necessária! ✅

## 📚 Operações Comuns

### SELECT
```dart
final response = await supabase
  .from('products')
  .select()
  .eq('category_id', categoryId)
  .order('created_at', ascending: false);
```

### INSERT
```dart
await supabase
  .from('products')
  .insert(productModel.toSupabase());
```

### UPDATE
```dart
await supabase
  .from('products')
  .update(productModel.toSupabase())
  .eq('id', productId);
```

### DELETE
```dart
await supabase
  .from('products')
  .delete()
  .eq('id', productId);
```

### JOIN
```dart
final response = await supabase
  .from('products')
  .select('*, categories(*), stores(*)')
  .eq('store_id', storeId);
```

### RPC (Stored Procedures)
```dart
final response = await supabase.rpc('search_products', params: {
  'search_term': searchTerm,
});
```

## ⚠️ Importante

1. **Apenas Data Layer**: Nunca importar Supabase fora de `data/datasources/remote/`
2. **Models Duplos**: Manter `.fromSupabase()` (MVP) e `.fromJson()` (futuro Laravel)
3. **Error Handling**: Converter exceções do Supabase em `Failure` da camada Domain
4. **Segurança**: Nunca commitar keys em produção (usar env vars)

## 🚀 Próximos Passos

1. ✅ Supabase configurado
2. ⏳ Atualizar constantes com suas credenciais
3. ⏳ Criar schema no Supabase
4. ⏳ Migrar Marketplace para Supabase
5. ⏳ Migrar MyStore para Supabase
6. ⏳ Migrar Profile para Supabase

---

**Configurado em: Maio 2026**
