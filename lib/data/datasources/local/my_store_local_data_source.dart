import 'package:incasa_app/data/models/marketplace/product_model.dart';
import 'package:incasa_app/data/models/my_store/store_model.dart';

/// Data Source Local para MyStore (dados mock)
abstract class MyStoreLocalDataSource {
  Future<StoreModel> getMyStore();
  Future<List<ProductModel>> getMyProducts();
}

class MyStoreLocalDataSourceImpl implements MyStoreLocalDataSource {
  // Mock da loja do usuário
  final Map<String, dynamic> _mockStore = {
    "id": "store001",
    "name": "Minha Loja de Móveis",
    "description": "Móveis artesanais de qualidade",
    "ownerId": "user001",
    "imageUrl": "https://via.placeholder.com/300",
    "isActive": true,
    "createdAt": "2024-01-01T10:00:00",
  };

  // Mock dos produtos do vendedor
  final List<Map<String, dynamic>> _mockProducts = [
    {
      "id": "myp0001",
      "name": "Mesa Artesanal",
      "description": "Mesa de madeira maciça feita à mão",
      "price": 1599.90,
      "image": "https://via.placeholder.com/300",
      "category": "a0001",
      "created": "2024-10-01T10:00:00",
    },
    {
      "id": "myp0002",
      "name": "Cadeira Rústica",
      "description": "Cadeira de madeira reciclada",
      "price": 399.90,
      "image": "https://via.placeholder.com/300",
      "category": "a0001",
      "created": "2024-10-02T10:00:00",
    },
    {
      "id": "myp0003",
      "name": "Estante Personalizada",
      "description": "Estante sob medida para seus livros",
      "price": 899.90,
      "image": "https://via.placeholder.com/300",
      "category": "a0002",
      "created": "2024-10-03T10:00:00",
    },
  ];

  @override
  Future<StoreModel> getMyStore() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return StoreModel.fromJson(_mockStore);
  }

  @override
  Future<List<ProductModel>> getMyProducts() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockProducts.map((json) => ProductModel.fromJson(json)).toList();
  }
}
