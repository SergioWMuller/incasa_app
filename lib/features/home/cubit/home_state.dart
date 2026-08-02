import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/design/home_product.dart';
import 'package:incasa_app/domain/entities/design/neighbor_seller.dart';

enum HomeStatus { loading, loaded, error }

enum HomeViewMode { produtos, vizinhos }

class HomeState extends Equatable {
  final HomeStatus status;
  final String neighborhoodName;
  final List<NeighborSeller> neighbors;
  final List<HomeProduct> products;
  final HomeViewMode viewMode;
  final Set<String> favoriteIds;
  final String searchQuery;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.loading,
    this.neighborhoodName = '',
    this.neighbors = const [],
    this.products = const [],
    this.viewMode = HomeViewMode.produtos,
    this.favoriteIds = const {},
    this.searchQuery = '',
    this.errorMessage,
  });

  /// Produtos do feed filtrados pela busca do Início
  List<HomeProduct> get visibleProducts {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return products;
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query) ||
              p.sellerName.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  List<Object?> get props => [
    status,
    neighborhoodName,
    neighbors,
    products,
    viewMode,
    favoriteIds,
    searchQuery,
    errorMessage,
  ];

  HomeState copyWith({
    HomeStatus? status,
    String? neighborhoodName,
    List<NeighborSeller>? neighbors,
    List<HomeProduct>? products,
    HomeViewMode? viewMode,
    Set<String>? favoriteIds,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      neighborhoodName: neighborhoodName ?? this.neighborhoodName,
      neighbors: neighbors ?? this.neighbors,
      products: products ?? this.products,
      viewMode: viewMode ?? this.viewMode,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
