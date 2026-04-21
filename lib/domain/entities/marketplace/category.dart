import 'package:equatable/equatable.dart';

/// Entity de Categoria no domínio
class Category extends Equatable {
  final String id;
  final String title;
  final String value;
  final String imageUrl;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.title,
    required this.value,
    required this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, value, imageUrl, createdAt];
}
