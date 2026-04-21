import 'package:incasa_app/core/network/dio_client.dart';
import 'package:incasa_app/data/models/marketplace/product_model.dart';
import 'package:incasa_app/data/models/marketplace/category_model.dart';

/// Data Source Remote para Marketplace (API)
/// Faz requisições HTTP usando Dio
abstract class MarketplaceRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<List<ProductModel>> searchProducts(String query);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final DioClient dioClient;

  MarketplaceRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await dioClient.get('/products');
    final List<dynamic> data = response.data;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await dioClient.get('/products/$id');
    return ProductModel.fromJson(response.data);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dioClient.get('/categories');
    final List<dynamic> data = response.data;
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final response = await dioClient.get(
      '/products',
      queryParameters: {'category': categoryId},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await dioClient.get(
      '/products/search',
      queryParameters: {'q': query},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }
}
