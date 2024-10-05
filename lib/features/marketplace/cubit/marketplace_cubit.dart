import 'package:flutter_bloc/flutter_bloc.dart';

import 'marketplace_state.dart';

class MarketplaceCubit extends Cubit<MarketplaceState> {
  MarketplaceCubit() : super(LoadingMarketplaceState());

  void loadMarketplace() {
    try {
      emit(LoadedMarketplaceState());
    } catch (e) {
      emit(
        ErrorMarketplaceState(
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
