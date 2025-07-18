final class MyStoreState {}

final class LoadingMyStoreState extends MyStoreState {}

final class LoadedMyStoreState extends MyStoreState {
  final List<Map<String, dynamic>> products;
  LoadedMyStoreState(this.products);
}

final class ErrorMyStoreState extends MyStoreState {
  final String errorMessage;
  ErrorMyStoreState({required this.errorMessage});
}
