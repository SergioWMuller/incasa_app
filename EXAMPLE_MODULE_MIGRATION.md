# Exemplo Prático: Módulo Product (Firebase → Laravel)

Este exemplo mostra como estruturar um módulo que usa Firebase durante o MVP e pode migrar para Laravel sem refatoração das camadas superiores.

## 📁 Estrutura de Arquivos

```
lib/
├── domain/
│   ├── entities/
│   │   └── product/
│   │       └── product.dart
│   ├── repositories/
│   │   └── product/
│   │       └── product_repository.dart
│   └── usecases/
│       └── product/
│           ├── get_products.dart
│           ├── get_product_by_id.dart
│           └── create_product.dart
│
├── data/
│   ├── models/
│   │   └── product/
│   │       └── product_model.dart
│   ├── datasources/
│   │   └── remote/
│   │       └── product_remote_data_source.dart
│   └── repositories/
│       └── product/
│           └── product_repository_impl.dart
│
└── features/
    └── marketplace/
        ├── cubit/
        │   ├── products_cubit.dart
        │   └── products_state.dart
        └── view/
            └── marketplace_view.dart
```

---

## 📄 Código Completo

### 1. Domain Layer (Puro - Sem dependências externas)

#### `domain/entities/product/product.dart`
```dart
import 'package:equatable/equatable.dart';

/// Entity pura - Modelo de negócio
/// ❌ NÃO pode importar: firebase, dio, http, etc
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String sellerId;
  final DateTime createdAt;
  final bool isActive;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.sellerId,
    required this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        sellerId,
        createdAt,
        isActive,
      ];
}
```

#### `domain/repositories/product/product_repository.dart`
```dart
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/product/product.dart';

/// Interface abstrata - Contrato
/// Não sabe se implementação usa Firebase ou Laravel
abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts();
  Future<Result<Product>> getProductById(String id);
  Future<Result<Product>> createProduct(Product product);
  Future<Result<Product>> updateProduct(Product product);
  Future<Result<void>> deleteProduct(String id);
}
```

#### `domain/usecases/product/get_products.dart`
```dart
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/product/product.dart';
import 'package:incasa_app/domain/repositories/product/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<Result<List<Product>>> call() async {
    return await repository.getProducts();
  }
}
```

---

### 2. Data Layer (Conhece Firebase E Laravel)

#### `data/models/product/product_model.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incasa_app/domain/entities/product/product.dart';

/// Model - DTO (Data Transfer Object)
/// Responsável por converter entre Entity e fontes de dados
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.sellerId,
    required super.createdAt,
    super.isActive,
  });

  // ========================================
  // FIREBASE (MVP)
  // ========================================
  
  /// Converte DocumentSnapshot do Firestore para ProductModel
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      sellerId: data['sellerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  /// Converte ProductModel para Map do Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  // ========================================
  // LARAVEL API (Futuro)
  // ========================================
  
  /// Converte JSON da API Laravel para ProductModel
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'] ?? '', // snake_case do Laravel
      sellerId: json['seller_id'].toString(),
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  /// Converte ProductModel para JSON para API Laravel
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl, // Laravel usa snake_case
      'seller_id': sellerId,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  // ========================================
  // CONVERSÃO DE/PARA ENTITY
  // ========================================
  
  /// Converte Entity pura para Model
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      sellerId: product.sellerId,
      createdAt: product.createdAt,
      isActive: product.isActive,
    );
  }
}
```

#### `data/datasources/remote/product_remote_data_source.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incasa_app/core/network/dio_client.dart';
import 'package:incasa_app/data/models/product/product_model.dart';

/// Interface abstrata do DataSource
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}

// ========================================
// IMPLEMENTAÇÃO FIREBASE (MVP - USAR ESTA)
// ========================================

class ProductFirebaseDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductFirebaseDataSourceImpl(this.firestore);

  @override
  Future<List<ProductModel>> getProducts() async {
    final snapshot = await firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final doc = await firestore.collection('products').doc(id).get();
    
    if (!doc.exists) {
      throw Exception('Product not found');
    }
    
    return ProductModel.fromFirestore(doc);
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final docRef = await firestore
        .collection('products')
        .add(product.toFirestore());
    
    final doc = await docRef.get();
    return ProductModel.fromFirestore(doc);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    await firestore
        .collection('products')
        .doc(product.id)
        .update(product.toFirestore());
    
    final doc = await firestore.collection('products').doc(product.id).get();
    return ProductModel.fromFirestore(doc);
  }

  @override
  Future<void> deleteProduct(String id) async {
    // Soft delete - apenas marca como inativo
    await firestore.collection('products').doc(id).update({
      'isActive': false,
    });
  }
}

// ========================================
// IMPLEMENTAÇÃO LARAVEL API (FUTURO)
// ========================================

class ProductApiDataSourceImpl implements ProductRemoteDataSource {
  final DioClient dioClient;

  ProductApiDataSourceImpl(this.dioClient);

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await dioClient.get('/api/products');
    final List data = response.data['data'];
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await dioClient.get('/api/products/$id');
    return ProductModel.fromJson(response.data['data']);
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await dioClient.post(
      '/api/products',
      data: product.toJson(),
    );
    return ProductModel.fromJson(response.data['data']);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await dioClient.put(
      '/api/products/${product.id}',
      data: product.toJson(),
    );
    return ProductModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await dioClient.delete('/api/products/$id');
  }
}
```

#### `data/repositories/product/product_repository_impl.dart`
```dart
import 'package:incasa_app/core/error/failures.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/data/datasources/remote/product_remote_data_source.dart';
import 'package:incasa_app/data/models/product/product_model.dart';
import 'package:incasa_app/domain/entities/product/product.dart';
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

  @override
  Future<Result<Product>> getProductById(String id) async {
    try {
      final product = await remoteDataSource.getProductById(id);
      return Success(product);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Product>> createProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      final result = await remoteDataSource.createProduct(productModel);
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Product>> updateProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      final result = await remoteDataSource.updateProduct(productModel);
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
```

---

### 3. Injeção de Dependências

#### `core/di/service_locator.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:incasa_app/core/network/dio_client.dart';
import 'package:incasa_app/data/datasources/remote/product_remote_data_source.dart';
import 'package:incasa_app/data/repositories/product/product_repository_impl.dart';
import 'package:incasa_app/domain/repositories/product/product_repository.dart';
import 'package:incasa_app/domain/usecases/product/get_products.dart';

final sl = GetIt.instance;

void setupProductDependencies() {
  // ========================================
  // MVP - FIREBASE (Usar esta configuração)
  // ========================================
  
  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  
  // DataSource - Implementação Firebase
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductFirebaseDataSourceImpl(sl()),
  );
  
  // ========================================
  // PRODUÇÃO - LARAVEL (Trocar para esta)
  // ========================================
  
  // External
  // sl.registerLazySingleton(() => DioClient(
  //   baseUrl: 'https://api.incasa.com',
  // ));
  
  // DataSource - Implementação Laravel
  // sl.registerLazySingleton<ProductRemoteDataSource>(
  //   () => ProductApiDataSourceImpl(sl()),
  // );
  
  // ========================================
  // CAMADAS SUPERIORES (Não mudam!)
  // ========================================
  
  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  
  // UseCases
  sl.registerLazySingleton(() => GetProducts(sl()));
}
```

---

## 🔄 Processo de Migração

### Durante MVP (Agora)
1. Usar `ProductFirebaseDataSourceImpl`
2. Registrar no DI conforme comentário "MVP - FIREBASE"

### Ao Migrar para Laravel
1. Descomentar/trocar registro DI para `ProductApiDataSourceImpl`
2. **Nenhuma outra mudança necessária!**
3. Domain, UseCases, Features permanecem intactos

---

## ✅ Checklist de Qualidade

- [x] Entity sem imports externos
- [x] Repository abstrato no domain
- [x] Model com `.fromFirestore()` / `.toFirestore()`
- [x] Model com `.fromJson()` / `.toJson()`
- [x] DataSource com interface abstrata
- [x] Duas implementações de DataSource (Firebase + API)
- [x] DI permite trocar implementação facilmente
- [x] Features usam UseCases, não Repositories
- [x] States usam Entities, não Models

---

**Resultado:** Migração do Firebase para Laravel em ~5 minutos por módulo! 🎯
