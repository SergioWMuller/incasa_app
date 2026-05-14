import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/marketplace/category.dart';

enum MarketplaceStatus { loading, loaded, error }

class MarketplaceState extends Equatable {
  final MarketplaceStatus status;
  final List<Product>? products;
  final List<Category>? categories;
  final String? errorMessage;

  const MarketplaceState({
    this.status = MarketplaceStatus.loading,
    this.products,
    this.categories,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, products, categories, errorMessage];

  MarketplaceState copyWith({
    MarketplaceStatus? status,
    List<Product>? products,
    List<Category>? categories,
    String? errorMessage,
  }) {
    return MarketplaceState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
