import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/data/datasources/local/design_mock_data_source.dart';
import 'package:incasa_app/features/seller_store/cubit/seller_store_state.dart';

class SellerStoreCubit extends Cubit<SellerStoreState> {
  final DesignMockDataSource mockDataSource;

  SellerStoreCubit({required this.mockDataSource})
    : super(const SellerStoreState());

  /// Carrega a loja mock do vendedor
  void load(String sellerId) {
    emit(
      SellerStoreState(
        status: SellerStoreStatus.loaded,
        store: mockDataSource.getSellerStore(sellerId),
      ),
    );
  }

  /// Seguir/deixar de seguir (toggle visual local)
  void toggleFollow() {
    emit(state.copyWith(isFollowing: !state.isFollowing));
  }
}
