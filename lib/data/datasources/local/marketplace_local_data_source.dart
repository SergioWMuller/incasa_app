import 'package:incasa_app/data/models/marketplace/product_model.dart';
import 'package:incasa_app/data/models/marketplace/category_model.dart';

/// Data Source Local para Marketplace (dados mock)
/// Simula um banco de dados local ou cache
abstract class MarketplaceLocalDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> searchProducts(String query);
}

class MarketplaceLocalDataSourceImpl implements MarketplaceLocalDataSource {
  // Dados mock simulando o que está em data/products.dart e data/categories.dart
  final List<Map<String, dynamic>> _mockCategories = [
    {
      "id": "a0001",
      "title": "Mais Vendidos",
      "value": "mais_vendidos",
      "image": "https://via.placeholder.com/150",
      "created": "2024-10-04T14:00:00",
    },
    {
      "id": "a0002",
      "title": "Melhor Avaliados",
      "value": "melhor_avaliados",
      "image": "https://via.placeholder.com/150",
      "created": "2024-10-04T14:00:00",
    },
    {
      "id": "a0003",
      "title": "Próximos a Você",
      "value": "proximos",
      "image": "https://via.placeholder.com/150",
      "created": "2024-10-04T14:00:00",
    },
    {
      "id": "a0004",
      "title": "Lançamentos",
      "value": "lancamentos",
      "image": "https://via.placeholder.com/150",
      "created": "2024-10-04T14:00:00",
    },
    {
      "id": "a0005",
      "title": "Mais Amados",
      "value": "mais_amados",
      "image": "https://via.placeholder.com/150",
      "created": "2024-10-04T14:00:00",
    },
  ];

  final List<Map<String, dynamic>> _mockProducts = [
    {
      "id": "p0001",
      "name": "Mesa de Jantar",
      "description": "Mesa de madeira maciça para 6 pessoas",
      "price": 1299.90,
      "image": "https://via.placeholder.com/300",
      "category": "a0001",
      "created": "2024-10-04T14:00:00",
    },
    {
      "id": "p0002",
      "name": "Sofá 3 Lugares",
      "description": "Sofá confortável com tecido premium",
      "price": 2499.90,
      "image": "https://via.placeholder.com/300",
      "category": "a0002",
      "created": "2024-10-04T14:00:00",
    },
    {
      "id": "p0003",
      "name": "Estante para Livros",
      "description": "Estante moderna com 5 prateleiras",
      "price": 599.90,
      "image": "https://via.placeholder.com/300",
      "category": "a0001",
      "created": "2024-10-04T14:00:00",
    },
  ];

  @override
  Future<List<CategoryModel>> getCategories() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockCategories.map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockProducts.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allProducts = _mockProducts
        .map((json) => ProductModel.fromJson(json))
        .toList();

    if (query.isEmpty) return allProducts;

    return allProducts
        .where(
          (product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
