import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/my_store/store.dart';

/// Repository interface para MyStore
abstract class MyStoreRepository {
  Future<Result<Store>> getMyStore();
  Future<Result<List<Product>>> getMyProducts();
  Future<Result<Product>> addProduct(Product product);
  Future<Result<Product>> updateProduct(Product product);
  Future<Result<void>> deleteProduct(String productId);
}
