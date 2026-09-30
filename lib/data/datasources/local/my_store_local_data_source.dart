import 'dart:convert';
import 'package:incasa_app/data/models/marketplace/product_model.dart';
import 'package:incasa_app/data/models/my_store/store_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data Source Local para MyStore (SharedPreferences)
abstract class MyStoreLocalDataSource {
  Future<StoreModel> getMyStore();
  Future<List<ProductModel>> getMyProducts();
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
}

class MyStoreLocalDataSourceImpl implements MyStoreLocalDataSource {
  static const String _productsKey = 'my_products';

  // Mock da loja do usuário (por enquanto)
  final Map<String, dynamic> _mockStore = {
    "id": "store001",
    "name": "Loja do Sergio",
    "description": "Produtos tradicionas da Alemanha",
    "ownerId": "user001",
    "imageUrl": "https://via.placeholder.com/300",
    "isActive": true,
    "createdAt": "2024-01-01T10:00:00",
  };

  @override
  Future<StoreModel> getMyStore() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return StoreModel.fromJson(_mockStore);
  }

  @override
  Future<List<ProductModel>> getMyProducts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString(_productsKey);
    
    if (productsJson == null || productsJson.isEmpty) {
      return [];
    }
    
    final List<dynamic> decoded = jsonDecode(productsJson);
    return decoded.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final products = await getMyProducts();
    products.add(product);
    
    await _saveProducts(products);
    return product;
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final products = await getMyProducts();
    final index = products.indexWhere((p) => p.id == product.id);
    
    if (index == -1) {
      throw Exception('Produto não encontrado');
    }
    
    products[index] = product;
    await _saveProducts(products);
    return product;
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final products = await getMyProducts();
    products.removeWhere((p) => p.id == productId);
    await _saveProducts(products);
  }

  Future<void> _saveProducts(List<ProductModel> products) async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = jsonEncode(
      products.map((p) => p.toJson()).toList(),
    );
    await prefs.setString(_productsKey, productsJson);
  }
}
