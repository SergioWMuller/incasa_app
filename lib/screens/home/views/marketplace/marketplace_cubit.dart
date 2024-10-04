import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MarketplaceState {}

class InitialMarketplaceState extends MarketplaceState {}

class MarketplaceCubit extends Cubit<MarketplaceState> {
  MarketplaceCubit() : super(InitialMarketplaceState());

  void loadMarketplaceItems() {}
}

class LoadingHomeState extends MarketplaceState {}

class LoadedHomeState extends MarketplaceState {
  final List<String> listExample;
  LoadedHomeState({required this.listExample});
}

class ErrorHomeState extends MarketplaceState {
  final String errorMessage;
  ErrorHomeState({required this.errorMessage});
}
