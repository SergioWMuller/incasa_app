import 'package:incasa_app/domain/entities/marketplace/category.dart';

/// Model (DTO) para Category
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.title,
    required super.value,
    required super.imageUrl,
    required super.createdAt,
  });

  // Criar CategoryModel a partir de JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      value: json['value'] as String,
      imageUrl: json['image'] as String? ?? json['imageUrl'] as String? ?? '',
      createdAt: DateTime.parse(
        json['created'] as String? ?? json['createdAt'] as String,
      ),
    );
  }

  // Converter CategoryModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Converter Entity para Model
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      title: category.title,
      value: category.value,
      imageUrl: category.imageUrl,
      createdAt: category.createdAt,
    );
  }
}
