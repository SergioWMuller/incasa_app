import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/my_store/store.dart';

sealed class MyStoreState extends Equatable {
  const MyStoreState();

  @override
  List<Object?> get props => [];
}

class MyStoreLoading extends MyStoreState {
  const MyStoreLoading();
}

class MyStoreLoaded extends MyStoreState {
  final Store store;
  final List<Product> products;

  const MyStoreLoaded({required this.store, required this.products});

  @override
  List<Object?> get props => [store, products];
}

class MyStoreError extends MyStoreState {
  final String message;

  const MyStoreError(this.message);

  @override
  List<Object?> get props => [message];
}
