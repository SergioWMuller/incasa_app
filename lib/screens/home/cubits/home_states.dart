abstract class HomeStates {}

class InitialHomeState extends HomeStates {}

class LoadingHomeState extends HomeStates {}

class LoadedHomeState extends HomeStates {
  final List<String> listExample;
  LoadedHomeState({required this.listExample});
}

class ErrorHomeState extends HomeStates {
  final String errorMessage;
  ErrorHomeState({required this.errorMessage});
}
