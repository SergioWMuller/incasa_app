import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/data/datasources/local/design_mock_data_source.dart';
import 'package:incasa_app/features/product_detail/cubit/product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final DesignMockDataSource mockDataSource;

  ProductDetailCubit({required this.mockDataSource})
    : super(const ProductDetailState());

  /// Carrega o produto mock pelo id
  void load(String productId) {
    emit(
      ProductDetailState(
        status: ProductDetailStatus.loaded,
        product: mockDataSource.getProductById(productId),
      ),
    );
  }

  /// Favorita/desfavorita (toggle visual local)
  void toggleFavorite() {
    emit(state.copyWith(isFavorite: !state.isFavorite));
  }
}
