import 'package:equatable/equatable.dart';

/// Entity Store (Loja do vendedor)
class Store extends Equatable {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;

  const Store({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    ownerId,
    imageUrl,
    isActive,
    createdAt,
  ];
}
