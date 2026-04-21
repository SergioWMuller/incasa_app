import 'package:incasa_app/core/network/dio_client.dart';
import 'package:incasa_app/data/models/marketplace/product_model.dart';
import 'package:incasa_app/data/models/my_store/store_model.dart';

/// Data Source Remote para MyStore
abstract class MyStoreRemoteDataSource {
  Future<StoreModel> getMyStore();
  Future<List<ProductModel>> getMyProducts();
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
}

class MyStoreRemoteDataSourceImpl implements MyStoreRemoteDataSource {
  final DioClient dioClient;

  MyStoreRemoteDataSourceImpl(this.dioClient);

  @override
  Future<StoreModel> getMyStore() async {
    final response = await dioClient.get('/store/my');
    return StoreModel.fromJson(response.data);
  }

  @override
  Future<List<ProductModel>> getMyProducts() async {
    final response = await dioClient.get('/store/my/products');
    final List<dynamic> data = response.data;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    final response = await dioClient.post(
      '/store/my/products',
      data: product.toJson(),
    );
    return ProductModel.fromJson(response.data);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await dioClient.put(
      '/store/my/products/${product.id}',
      data: product.toJson(),
    );
    return ProductModel.fromJson(response.data);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await dioClient.delete('/store/my/products/$productId');
  }
}
