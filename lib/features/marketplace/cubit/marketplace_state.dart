final class MarketplaceState {}

final class LoadingMarketplaceState extends MarketplaceState {}

final class LoadedMarketplaceState extends MarketplaceState {
  LoadedMarketplaceState();
}

final class ErrorMarketplaceState extends MarketplaceState {
  final String errorMessage;
  ErrorMarketplaceState({required this.errorMessage});
}
