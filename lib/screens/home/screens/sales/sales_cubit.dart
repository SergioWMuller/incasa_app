import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MinhaLojaState {}

class InitialSalesState extends MinhaLojaState {}

class SalesCubit extends Cubit<MinhaLojaState> {
  SalesCubit() : super(InitialSalesState());

  void loadMinhaLojaItems() {
    // Lógica para carregar os itens da loja
  }
}
