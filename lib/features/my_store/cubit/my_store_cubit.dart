import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/usecases/my_store/get_my_products.dart';
import 'package:incasa_app/domain/usecases/my_store/get_my_store.dart';
import 'my_store_state.dart';

class MyStoreCubit extends Cubit<MyStoreState> {
  final GetMyStore getMyStoreUseCase;
  final GetMyProducts getMyProductsUseCase;

  MyStoreCubit({
    required this.getMyStoreUseCase,
    required this.getMyProductsUseCase,
  }) : super(const MyStoreLoading());

  Future<void> loadMyStore() async {
    emit(const MyStoreLoading());

    final storeResult = await getMyStoreUseCase(const NoParams());
    final productsResult = await getMyProductsUseCase(const NoParams());

    switch (storeResult) {
      case Success():
        switch (productsResult) {
          case Success():
            emit(
              MyStoreLoaded(
                store: storeResult.data,
                products: productsResult.data,
              ),
            );
          case Error(:final failure):
            emit(MyStoreError(failure.message));
        }
      case Error(:final failure):
        emit(MyStoreError(failure.message));
    }
  }
}
