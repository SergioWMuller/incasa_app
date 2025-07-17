import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/repositories/product_repository.dart';
import '../states/my_store_state.dart';

class MyStoreCubit extends Cubit<MyStoreState> {
  MyStoreCubit() : super(LoadingMyStoreState());

  Future<void> loadMyStore() async {
    emit(LoadingMyStoreState());
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(ErrorMyStoreState(errorMessage: 'Usuário não autenticado.'));
        return;
      }
      final products = await ProductRepository().getAll();
      final myProducts = products
          .where((p) => p['user_id'] == userId && p['type'] == 'product')
          .toList();
      emit(LoadedMyStoreState(myProducts));
    } catch (e) {
      emit(
        ErrorMyStoreState(
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
