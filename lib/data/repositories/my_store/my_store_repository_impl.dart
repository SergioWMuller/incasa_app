import 'package:incasa_app/core/error/failures.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/data/datasources/local/auth_local_data_source.dart';
import 'package:incasa_app/data/datasources/local/my_store_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/my_store_remote_data_source.dart';
import 'package:incasa_app/data/models/marketplace/product_model.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/my_store/store.dart';
import 'package:incasa_app/domain/repositories/my_store/my_store_repository.dart';

class MyStoreRepositoryImpl implements MyStoreRepository {
  final MyStoreRemoteDataSource remoteDataSource;
  final MyStoreLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;

  MyStoreRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authLocalDataSource,
  });

  /// UUID interno (`users.id`) do usuário logado, salvo no cache pelo AuthCubit.
  ///
  /// Não usamos `client.auth` porque o GoTrue do Supabase fica desativado quando
  /// o cliente é inicializado com `accessToken` (a identidade vem do Firebase).
  Future<String?> _resolveOwnerId() async {
    final userData = await authLocalDataSource.getUserData();
    return userData?['id'] as String?;
  }

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
      final ownerId = await _resolveOwnerId();
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
      final ownerId = await _resolveOwnerId();
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
