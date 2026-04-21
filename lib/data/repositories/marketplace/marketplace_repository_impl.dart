import 'package:incasa_app/core/error/failures.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/data/datasources/local/marketplace_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/marketplace_remote_data_source.dart';
import 'package:incasa_app/domain/entities/marketplace/category.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/repositories/marketplace/marketplace_repository.dart';

/// Implementação concreta do MarketplaceRepository
/// Decide entre usar dados remotos (API) ou locais (cache/mock)
class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource remoteDataSource;
  final MarketplaceLocalDataSource localDataSource;

  MarketplaceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      // Por enquanto, usa dados locais (mock)
      // Depois você pode mudar para remoteDataSource quando a API estiver pronta
      final products = await localDataSource.getProducts();
      return Success(products);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
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
  Future<Result<List<Category>>> getCategories() async {
    try {
      // Usando dados locais (mock)
      final categories = await localDataSource.getCategories();
      return Success(categories);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Product>>> getProductsByCategory(String categoryId) async {
    try {
      final products = await remoteDataSource.getProductsByCategory(categoryId);
      return Success(products);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Product>>> searchProducts(String query) async {
    try {
      // Usando busca local (mock)
      final products = await localDataSource.searchProducts(query);
      return Success(products);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
