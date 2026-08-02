import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/design/home_product.dart';

enum ProductDetailStatus { loading, loaded, error }

class ProductDetailState extends Equatable {
  final ProductDetailStatus status;
  final HomeProduct? product;
  final bool isFavorite;
  final String? errorMessage;

  const ProductDetailState({
    this.status = ProductDetailStatus.loading,
    this.product,
    this.isFavorite = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, product, isFavorite, errorMessage];

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    HomeProduct? product,
    bool? isFavorite,
    String? errorMessage,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product ?? this.product,
      isFavorite: isFavorite ?? this.isFavorite,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
