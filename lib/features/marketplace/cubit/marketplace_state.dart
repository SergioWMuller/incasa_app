import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/marketplace/category.dart';

/// Sealed class para o estado do Marketplace
/// Garante exhaustiveness checking no pattern matching
sealed class MarketplaceState extends Equatable {
  const MarketplaceState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial/carregando
class MarketplaceLoading extends MarketplaceState {
  const MarketplaceLoading();
}

/// Estado com dados carregados
class MarketplaceLoaded extends MarketplaceState {
  final List<Product> products;
  final List<Category> categories;

  const MarketplaceLoaded({required this.products, required this.categories});

  @override
  List<Object?> get props => [products, categories];
}

/// Estado de erro
class MarketplaceError extends MarketplaceState {
  final String message;

  const MarketplaceError(this.message);

  @override
  List<Object?> get props => [message];
}
