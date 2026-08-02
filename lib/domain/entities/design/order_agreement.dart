import 'package:equatable/equatable.dart';

/// "Combinado" fixado no topo do chat (tela 05 do design handoff).
class OrderAgreement extends Equatable {
  final String productName;
  final double price;
  final bool paid;
  final String placeLabel;
  final String timeLabel;

  const OrderAgreement({
    required this.productName,
    required this.price,
    required this.paid,
    required this.placeLabel,
    required this.timeLabel,
  });

  @override
  List<Object?> get props => [productName, price, paid, placeLabel, timeLabel];

  OrderAgreement copyWith({
    String? productName,
    double? price,
    bool? paid,
    String? placeLabel,
    String? timeLabel,
  }) {
    return OrderAgreement(
      productName: productName ?? this.productName,
      price: price ?? this.price,
      paid: paid ?? this.paid,
      placeLabel: placeLabel ?? this.placeLabel,
      timeLabel: timeLabel ?? this.timeLabel,
    );
  }
}
