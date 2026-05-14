import 'package:incasa_app/core/network/supabase_client.dart';
import 'package:incasa_app/data/datasources/remote/product_supabase_data_source.dart';
import 'package:incasa_app/data/models/marketplace/product_model.dart';
import 'package:incasa_app/data/models/my_store/store_model.dart';

/// Data Source Remote para MyStore
abstract class MyStoreRemoteDataSource {
  Future<StoreModel> getMyStore();
  Future<List<ProductModel>> getMyProducts(String ownerId);
  Future<ProductModel> addProduct(ProductModel product, String ownerId);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
}

class MyStoreRemoteDataSourceImpl implements MyStoreRemoteDataSource {
  final ProductSupabaseDataSource productDataSource;
  final SupabaseClientWrapper supabase;

  MyStoreRemoteDataSourceImpl({
    required this.productDataSource,
    required this.supabase,
  });

  @override
  Future<StoreModel> getMyStore() async {
    // TODO: Implementar quando criar tabela de stores no Supabase
    throw UnimplementedError('getMyStore ainda não implementado');
  }

  @override
  Future<List<ProductModel>> getMyProducts(String ownerId) async {
    return await productDataSource.getMyProducts(ownerId);
  }

  @override
  Future<ProductModel> addProduct(ProductModel product, String ownerId) async {
    return await productDataSource.createProduct(product, ownerId);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    return await productDataSource.updateProduct(product.id, product);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await productDataSource.deleteProduct(productId);
  }
}
