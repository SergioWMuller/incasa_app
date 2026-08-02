import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/design/home_product.dart';
import 'package:incasa_app/domain/entities/design/pix_charge.dart';

enum PixStatus { aguardandoPagamento, pago }

class PixState extends Equatable {
  final PixStatus status;
  final HomeProduct? product;
  final PixCharge? charge;
  final int remainingSeconds;
  final bool codeCopied;

  const PixState({
    this.status = PixStatus.aguardandoPagamento,
    this.product,
    this.charge,
    this.remainingSeconds = 0,
    this.codeCopied = false,
  });

  @override
  List<Object?> get props => [
    status,
    product,
    charge,
    remainingSeconds,
    codeCopied,
  ];

  PixState copyWith({
    PixStatus? status,
    HomeProduct? product,
    PixCharge? charge,
    int? remainingSeconds,
    bool? codeCopied,
  }) {
    return PixState(
      status: status ?? this.status,
      product: product ?? this.product,
      charge: charge ?? this.charge,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      codeCopied: codeCopied ?? this.codeCopied,
    );
  }
}
