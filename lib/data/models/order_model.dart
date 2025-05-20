class OrderModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final String productServiceId;
  final int quantity;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final String status;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.productServiceId,
    required this.quantity,
    required this.orderDate,
    required this.deliveryDate,
    required this.status,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      buyerId: map['buyer_id'],
      sellerId: map['seller_id'],
      productServiceId: map['product_service_id'],
      quantity: map['quantity'],
      orderDate: DateTime.parse(map['order_date']),
      deliveryDate: DateTime.parse(map['delivery_date']),
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'product_service_id': productServiceId,
      'quantity': quantity,
      'order_date': orderDate.toIso8601String(),
      'delivery_date': deliveryDate.toIso8601String(),
      'status': status,
    };
  }
}
