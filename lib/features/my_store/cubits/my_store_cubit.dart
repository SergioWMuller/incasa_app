import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_incasa_app/data/repositories/product_repository.dart';
import 'package:projeto_incasa_app/features/my_store/states/my_store_state.dart';

class MyStoreCubit extends Cubit<MyStoreState> {
  MyStoreCubit() : super(LoadingMyStoreState());

  Future<void> loadMyStore() async {
    emit(LoadingMyStoreState());
    try {
      final products = await ProductRepository().getAll();
      emit(LoadedMyStoreState(products));
    } catch (e) {
      emit(ErrorMyStoreState(errorMessage: e.toString()));
    }
  }

  Future<void> updateAvailability(int productId, bool isAvailable,
      {bool refresh = true}) async {
    try {
      await ProductRepository().updateAvailability(productId, isAvailable);
      if (refresh) loadMyStore();
    } catch (e) {
      emit(ErrorMyStoreState(errorMessage: e.toString()));
    }
  }
}
