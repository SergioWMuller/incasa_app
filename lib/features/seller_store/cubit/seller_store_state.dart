import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/design/seller_store_info.dart';

enum SellerStoreStatus { loading, loaded, error }

class SellerStoreState extends Equatable {
  final SellerStoreStatus status;
  final SellerStoreInfo? store;
  final bool isFollowing;
  final String? errorMessage;

  const SellerStoreState({
    this.status = SellerStoreStatus.loading,
    this.store,
    this.isFollowing = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, store, isFollowing, errorMessage];

  SellerStoreState copyWith({
    SellerStoreStatus? status,
    SellerStoreInfo? store,
    bool? isFollowing,
    String? errorMessage,
  }) {
    return SellerStoreState(
      status: status ?? this.status,
      store: store ?? this.store,
      isFollowing: isFollowing ?? this.isFollowing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
