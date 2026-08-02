import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/design/home_product.dart';

/// Loja do vendedor (tela 06 do design handoff).
class SellerStoreInfo extends Equatable {
  final String id;
  final String name;
  final double rating;
  final String distanceLabel;
  final int salesCount;
  final String bio;
  final HomeProduct highlight;
  final List<HomeProduct> moreProducts;

  const SellerStoreInfo({
    required this.id,
    required this.name,
    required this.rating,
    required this.distanceLabel,
    required this.salesCount,
    required this.bio,
    required this.highlight,
    required this.moreProducts,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    rating,
    distanceLabel,
    salesCount,
    bio,
    highlight,
    moreProducts,
  ];
}
