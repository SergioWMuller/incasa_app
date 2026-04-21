import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/marketplace/category.dart';

/// Repository interface (contrato) para Marketplace
/// Define APENAS as assinaturas - implementação fica na camada Data
abstract class MarketplaceRepository {
  Future<Result<List<Product>>> getProducts();
  Future<Result<Product>> getProductById(String id);
  Future<Result<List<Category>>> getCategories();
  Future<Result<List<Product>>> getProductsByCategory(String categoryId);
  Future<Result<List<Product>>> searchProducts(String query);
}
