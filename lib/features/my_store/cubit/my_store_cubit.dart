import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/usecases/my_store/add_product.dart';
import 'package:incasa_app/domain/usecases/my_store/get_my_products.dart';
import 'package:incasa_app/domain/usecases/my_store/get_my_store.dart';
import 'my_store_state.dart';

class MyStoreCubit extends Cubit<MyStoreState> {
  final GetMyStore getMyStoreUseCase;
  final GetMyProducts getMyProductsUseCase;
  final AddProduct addProductUseCase;

  MyStoreCubit({
    required this.getMyStoreUseCase,
    required this.getMyProductsUseCase,
    required this.addProductUseCase,
  }) : super(const MyStoreState());

  Future<void> loadMyStore() async {
    emit(const MyStoreState(status: MyStoreStatus.loading));

    final storeResult = await getMyStoreUseCase(const NoParams());
    final productsResult = await getMyProductsUseCase(const NoParams());

    switch (storeResult) {
      case Success():
        switch (productsResult) {
          case Success():
            emit(
              MyStoreState(
                status: MyStoreStatus.loaded,
                store: storeResult.data,
                products: productsResult.data,
              ),
            );
          case Error(:final failure):
            emit(
              MyStoreState(
                status: MyStoreStatus.error,
                errorMessage: failure.message,
              ),
            );
        }
      case Error(:final failure):
        emit(
          MyStoreState(
            status: MyStoreStatus.error,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<bool> addProduct(Product product) async {
    emit(state.copyWith(isAddingProduct: true, clearError: true));

    final result = await addProductUseCase(AddProductParams(product: product));

    switch (result) {
      case Success(:final data):
        // Adiciona o produto à lista atual
        final currentProducts = List<Product>.from(state.products ?? []);
        currentProducts.add(data);

        emit(
          state.copyWith(
            products: currentProducts,
            isAddingProduct: false,
            clearError: true,
          ),
        );
        return true;

      case Error(:final failure):
        emit(
          state.copyWith(isAddingProduct: false, errorMessage: failure.message),
        );
        return false;
    }
  }
}
