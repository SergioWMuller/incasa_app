final class MyStoreState {}

final class LoadingMyStoreState extends MyStoreState {}

final class LoadedMyStoreState extends MyStoreState {
  LoadedMyStoreState();
}

final class ErrorMyStoreState extends MyStoreState {
  final String errorMessage;
  ErrorMyStoreState({required this.errorMessage});
}
