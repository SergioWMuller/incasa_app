import 'package:incasa_app/core/error/failures.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/data/datasources/local/my_store_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/my_store_remote_data_source.dart';
import 'package:incasa_app/data/models/marketplace/product_model.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/my_store/store.dart';
import 'package:incasa_app/domain/repositories/my_store/my_store_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyStoreRepositoryImpl implements MyStoreRepository {
  final MyStoreRemoteDataSource remoteDataSource;
  final MyStoreLocalDataSource localDataSource;

  MyStoreRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Helper para obter o ID do usuário logado
  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

  @override
  Future<Result<Store>> getMyStore() async {
    try {
      // Usando dados locais (mock) até implementar tabela stores
      final store = await localDataSource.getMyStore();
      return Success(store);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Product>>> getMyProducts() async {
    try {
      final ownerId = _currentUserId;
      if (ownerId == null) {
        return Error(UnexpectedFailure('Usuário não autenticado'));
      }

      // Usando Supabase agora! ✅
      final products = await remoteDataSource.getMyProducts(ownerId);
      return Success(products);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Product>> addProduct(Product product) async {
    try {
      final ownerId = _currentUserId;
      if (ownerId == null) {
        return Error(UnexpectedFailure('Usuário não autenticado'));
      }

      // Usando Supabase agora! ✅
      final productModel = ProductModel.fromEntity(product);
      final result = await remoteDataSource.addProduct(productModel, ownerId);
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Product>> updateProduct(Product product) async {
    try {
      // Usando Supabase agora! ✅
      final productModel = ProductModel.fromEntity(product);
      final result = await remoteDataSource.updateProduct(productModel);
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteProduct(String productId) async {
    try {
      // Usando Supabase agora! ✅
      await remoteDataSource.deleteProduct(productId);
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
