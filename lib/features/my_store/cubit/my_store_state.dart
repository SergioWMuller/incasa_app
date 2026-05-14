import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/my_store/store.dart';

enum MyStoreStatus { inicial, loading, loaded, error }

class MyStoreState extends Equatable {
  final MyStoreStatus status;
  final Store? store;
  final List<Product>? products;
  final String? errorMessage;
  final bool isAddingProduct;

  const MyStoreState({
    this.status = MyStoreStatus.inicial,
    this.store,
    this.products,
    this.errorMessage,
    this.isAddingProduct = false,
  });

  @override
  List<Object?> get props => [
    status,
    store,
    products,
    errorMessage,
    isAddingProduct,
  ];

  MyStoreState copyWith({
    MyStoreStatus? status,
    Store? store,
    List<Product>? products,
    String? errorMessage,
    bool clearError = false,
    bool? isAddingProduct,
  }) {
    return MyStoreState(
      status: status ?? this.status,
      store: store ?? this.store,
      products: products ?? this.products,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAddingProduct: isAddingProduct ?? this.isAddingProduct,
    );
  }
}
