import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/usecases/marketplace/get_products.dart';
import 'package:incasa_app/domain/usecases/marketplace/get_categories.dart';
import 'package:incasa_app/domain/usecases/marketplace/search_products.dart';
import 'package:incasa_app/features/marketplace/cubit/marketplace_state.dart';
import 'package:incasa_app/domain/entities/marketplace/category.dart';

class MarketplaceCubit extends Cubit<MarketplaceState> {
  final GetProducts getProductsUseCase;
  final GetCategories getCategoriesUseCase;
  final SearchProducts searchProductsUseCase;

  MarketplaceCubit({
    required this.getProductsUseCase,
    required this.getCategoriesUseCase,
    required this.searchProductsUseCase,
  }) : super(const MarketplaceLoading());

  /// Carrega produtos e categorias
  Future<void> loadMarketplace() async {
    emit(const MarketplaceLoading());

    // Busca produtos e categorias em paralelo
    final productsResult = await getProductsUseCase(const NoParams());
    final categoriesResult = await getCategoriesUseCase(const NoParams());

    // Pattern matching para tratar resultados
    switch (productsResult) {
      case Success():
        switch (categoriesResult) {
          case Success():
            emit(
              MarketplaceLoaded(
                products: productsResult.data,
                categories: categoriesResult.data,
              ),
            );
          case Error(:final failure):
            emit(MarketplaceError(failure.message));
        }
      case Error(:final failure):
        emit(MarketplaceError(failure.message));
    }
  }

  /// Busca produtos por query
  Future<void> searchProducts(String query) async {
    emit(const MarketplaceLoading());

    final result = await searchProductsUseCase(SearchParams(query));

    switch (result) {
      case Success(:final data):
        // Mantém as categorias atuais
        final currentState = state;
        final categories = currentState is MarketplaceLoaded
            ? currentState.categories
            : <Category>[];

        emit(MarketplaceLoaded(products: data, categories: categories));
      case Error(:final failure):
        emit(MarketplaceError(failure.message));
    }
  }
}
