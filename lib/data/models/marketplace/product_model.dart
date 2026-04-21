import 'package:incasa_app/domain/entities/marketplace/product.dart';

/// Model (DTO) para Product
/// Responsável por serialização/deserialização JSON
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.category,
    required super.createdAt,
  });

  // Criar ProductModel a partir de JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image'] as String? ?? json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
      createdAt: DateTime.parse(
        json['created'] as String? ?? json['createdAt'] as String,
      ),
    );
  }

  // Converter ProductModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Converter Entity para Model
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      createdAt: product.createdAt,
    );
  }
}
