import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/data/datasources/local/design_mock_data_source.dart';
import 'package:incasa_app/features/home/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final DesignMockDataSource mockDataSource;

  HomeCubit({required this.mockDataSource}) : super(const HomeState());

  /// Carrega o feed de descoberta (vizinhos + produtos mock)
  void loadHome() {
    emit(
      HomeState(
        status: HomeStatus.loaded,
        neighborhoodName: mockDataSource.neighborhoodName,
        neighbors: mockDataSource.getNeighborsSellingToday(),
        products: mockDataSource.getFeedProducts(),
      ),
    );
  }

  /// Alterna o toggle segmentado Produtos | Vizinhos
  void toggleViewMode(HomeViewMode mode) {
    emit(state.copyWith(viewMode: mode));
  }

  /// Atualiza a busca do Início (filtra os produtos do feed)
  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// Favorita/desfavorita um produto (toggle visual local, como no design)
  void toggleFavorite(String productId) {
    final favorites = Set<String>.from(state.favoriteIds);
    if (!favorites.add(productId)) {
      favorites.remove(productId);
    }
    emit(state.copyWith(favoriteIds: favorites));
  }
}
