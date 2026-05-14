# Guia Rápido: Desenvolvimento com Arquitetura Migratória

## 🎯 Objetivo
Desenvolver features que funcionam com Firebase (MVP) e migram para Laravel sem refatoração.

---

## 📋 Checklist Antes de Começar Qualquer Feature

```bash
# ✅ Sempre faça essas perguntas:
1. Esta entidade tem algum import de Firebase/Dio?       → ❌ Não pode!
2. Este repository do domain é abstrato?                 → ✅ Sim, sempre!
3. Este model tem fromFirestore E fromJson?              → ✅ Ambos!
4. Este datasource tem interface abstrata?               → ✅ Sim!
5. O cubit usa UseCase ou Repository direto?             → UseCase!
6. O state usa Entity ou Model?                          → Entity!
```

---

## 🏗️ Template: Nova Feature em 6 Passos

### Exemplo: Feature "Product"

#### 1️⃣ Domain - Entity (Puro)
```dart
// lib/domain/entities/product/product.dart
import 'package:equatable/equatable.dart'; // ✅ Único import permitido

class Product extends Equatable {
  final String id;
  final String name;
  // ... campos
  
  const Product({required this.id, required this.name});
  
  @override
  List<Object?> get props => [id, name];
}
```

#### 2️⃣ Domain - Repository Interface
```dart
// lib/domain/repositories/product/product_repository.dart
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/product/product.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts();
  Future<Result<Product>> getProductById(String id);
  // ... métodos
}
```

#### 3️⃣ Domain - UseCase
```dart
// lib/domain/usecases/product/get_products.dart
import 'package:incasa_app/domain/entities/product/product.dart';
import 'package:incasa_app/domain/repositories/product/product_repository.dart';

class GetProducts {
  final ProductRepository repository;
  GetProducts(this.repository);
  
  Future<Result<List<Product>>> call() => repository.getProducts();
}
```

#### 4️⃣ Data - Model (Firebase + Laravel)
```dart
// lib/data/models/product/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incasa_app/domain/entities/product/product.dart';

class ProductModel extends Product {
  const ProductModel({required super.id, required super.name});
  
  // FIREBASE (MVP)
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }
  
  Map<String, dynamic> toFirestore() => {'name': name};
  
  // LARAVEL (Futuro)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  
  // Conversão Entity
  factory ProductModel.fromEntity(Product p) => 
    ProductModel(id: p.id, name: p.name);
}
```

#### 5️⃣ Data - DataSource (Abstrato + 2 Implementações)
```dart
// lib/data/datasources/remote/product_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incasa_app/core/network/dio_client.dart';
import 'package:incasa_app/data/models/product/product_model.dart';

// Interface
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

// Implementação Firebase (MVP - USAR AGORA)
class ProductFirebaseDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore firestore;
  ProductFirebaseDataSourceImpl(this.firestore);
  
  @override
  Future<List<ProductModel>> getProducts() async {
    final snapshot = await firestore.collection('products').get();
    return snapshot.docs.map((doc) => 
      ProductModel.fromFirestore(doc)
    ).toList();
  }
}

// Implementação Laravel (FUTURO)
class ProductApiDataSourceImpl implements ProductRemoteDataSource {
  final DioClient dioClient;
  ProductApiDataSourceImpl(this.dioClient);
  
  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await dioClient.get('/api/products');
    return (response.data['data'] as List)
      .map((json) => ProductModel.fromJson(json))
      .toList();
  }
}
```

#### 6️⃣ Data - Repository Implementation
```dart
// lib/data/repositories/product/product_repository_impl.dart
import 'package:incasa_app/data/datasources/remote/product_remote_data_source.dart';
import 'package:incasa_app/domain/repositories/product/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  ProductRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return Success(products);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
```

---

## 🔌 Injeção de Dependências

```dart
// lib/core/di/service_locator.dart
void setupProductDependencies() {
  // ✅ MVP - Firebase (USAR AGORA)
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductFirebaseDataSourceImpl(sl()),
  );
  
  // ⏳ Produção - Laravel (COMENTADO)
  // sl.registerLazySingleton(() => DioClient(baseUrl: 'https://api.incasa.com'));
  // sl.registerLazySingleton<ProductRemoteDataSource>(
  //   () => ProductApiDataSourceImpl(sl()),
  // );
  
  // ✅ Não muda na migração
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetProducts(sl()));
}
```

---

## 🚫 Erros Comuns a Evitar

### ❌ ERRADO
```dart
// ❌ Domain com import de Firebase
import 'package:firebase_auth/firebase_auth.dart';
class User extends Equatable { ... }

// ❌ Cubit usando Repository direto
class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository repository; // ❌
}

// ❌ State usando Model
class ProductsState {
  final List<ProductModel> products; // ❌
}

// ❌ Model só com Firebase OU só com JSON
class ProductModel {
  factory ProductModel.fromFirestore(...) {...} // ❌ Falta fromJson
}
```

### ✅ CORRETO
```dart
// ✅ Domain sem imports externos
import 'package:equatable/equatable.dart';
class User extends Equatable { ... }

// ✅ Cubit usando UseCase
class ProductsCubit extends Cubit<ProductsState> {
  final GetProducts getProducts; // ✅
}

// ✅ State usando Entity
class ProductsState {
  final List<Product> products; // ✅
}

// ✅ Model com ambos construtores
class ProductModel {
  factory ProductModel.fromFirestore(...) {...} // ✅
  factory ProductModel.fromJson(...) {...}       // ✅
  Map<String, dynamic> toFirestore() {...}       // ✅
  Map<String, dynamic> toJson() {...}            // ✅
}
```

---

## 🔍 Comandos de Verificação

### Verificar imports indevidos no Domain
```bash
# Não deve retornar nenhum resultado!
grep -r "firebase\|dio\|http" lib/domain/
```

### Verificar se Models têm ambos construtores
```bash
# Deve ter fromFirestore E fromJson
grep -A 20 "class.*Model" lib/data/models/product/product_model.dart
```

### Listar todos os DataSources
```bash
ls -la lib/data/datasources/remote/
```

---

## 📊 Resumo Visual

```
┌─────────────────────────────────────────────────────────┐
│                     FEATURES LAYER                      │
│  (Cubit + View)                                         │
│  - Usa UseCases                                         │
│  - States com Entities                                  │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                     DOMAIN LAYER                        │
│  ❌ ZERO imports externos (exceto equatable)            │
│  - Entities (modelos puros)                             │
│  - Repositories (interfaces abstratas)                  │
│  - UseCases (regras de negócio)                         │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                      DATA LAYER                         │
│  ✅ ÚNICA camada que conhece Firebase/Laravel           │
│  - Models (fromFirestore + fromJson)                    │
│  - DataSources (abstrato + Firebase + Laravel)          │
│  - Repositories (implementação)                         │
└─────────────────────┬───────────────────────────────────┘
                      │
        ┌─────────────┴─────────────┐
        │                           │
┌───────▼────────┐         ┌────────▼──────┐
│   FIREBASE     │         │    LARAVEL    │
│   (MVP)        │  ════>  │   (Produção)  │
│  Firestore     │         │   PostgreSQL  │
└────────────────┘         └───────────────┘
```

---

## 🎯 Resultado Final

**Tempo de migração por módulo:** ~5 minutos  
**Arquivos a mudar:** Apenas DI (service_locator.dart)  
**Refatoração necessária:** Nenhuma (se arquitetura correta)  

---

## 📚 Documentos Relacionados

- [MIGRATION_STRATEGY.md](./MIGRATION_STRATEGY.md) - Estratégia completa
- [EXAMPLE_MODULE_MIGRATION.md](./EXAMPLE_MODULE_MIGRATION.md) - Exemplo completo
- [/memories/repo/architecture-rules.md](./memories/repo/architecture-rules.md) - Regras rápidas

---

**Mantra:** *"Firebase hoje, Laravel amanhã, zero refatoração sempre!"* 🚀
