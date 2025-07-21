import 'package:projeto_incasa_app/data/models/product_model.dart';

abstract class MyStoreState {}

class LoadingMyStoreState extends MyStoreState {}

class LoadedMyStoreState extends MyStoreState {
  final List<ProductModel> products;
  LoadedMyStoreState(this.products);
}

class ErrorMyStoreState extends MyStoreState {
  final String errorMessage;
  ErrorMyStoreState({required this.errorMessage});
}
