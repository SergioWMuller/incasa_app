import 'package:equatable/equatable.dart';

/// Produto do feed de descoberta (telas Início/Produto do design handoff).
class HomeProduct extends Equatable {
  final String id;
  final String name;
  final double price;
  final String category;
  final String description;
  final String availabilityLabel;
  final String sellerId;
  final String sellerName;
  final String distanceLabel;
  final double rating;
  final String thumbLabel;

  const HomeProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.availabilityLabel,
    required this.sellerId,
    required this.sellerName,
    required this.distanceLabel,
    required this.rating,
    required this.thumbLabel,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    category,
    description,
    availabilityLabel,
    sellerId,
    sellerName,
    distanceLabel,
    rating,
    thumbLabel,
  ];
}
