import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MyStoreState {}

class InitialMyStoreState extends MyStoreState {}

class SalesCubit extends Cubit<MyStoreState> {
  SalesCubit() : super(InitialMyStoreState());

  void loadMinhaLojaItems() {
    // Lógica para carregar os itens da loja
  }
}
