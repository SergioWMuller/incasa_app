import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MarketplaceState {}

class InitialMarketplaceState extends MarketplaceState {}

class MarketplaceCubit extends Cubit<MarketplaceState> {
  MarketplaceCubit() : super(InitialMarketplaceState());

  void loadMarketplaceItems() {
    // Lógica para carregar os itens da vitrine
  }
}
