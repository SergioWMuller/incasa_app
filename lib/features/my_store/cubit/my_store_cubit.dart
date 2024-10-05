import 'package:flutter_bloc/flutter_bloc.dart';

import 'my_store_state.dart';

class MyStoreCubit extends Cubit<MyStoreState> {
  MyStoreCubit() : super(LoadingMyStoreState());

  void loadMyStore() {
    try {
      emit(LoadedMyStoreState());
    } catch (e) {
      emit(
        ErrorMyStoreState(
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
