class ProductServiceModel {
  final String id;
  final String userId;
  final String productOrService;
  final String name;
  final String description;
  final num price;
  final int? stock;
  final int? leadTimeDays;
  final bool isAvailable;
  final DateTime createdAt;

  ProductServiceModel({
    required this.id,
    required this.userId,
    required this.productOrService,
    required this.name,
    required this.description,
    required this.price,
    this.stock,
    this.leadTimeDays,
    required this.isAvailable,
    required this.createdAt,
  });

  factory ProductServiceModel.fromMap(Map<String, dynamic> map) {
    return ProductServiceModel(
      id: map['id'],
      userId: map['user_id'],
      productOrService: map['product_or_service'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      stock: map['stock'],
      leadTimeDays: map['lead_time_days'],
      isAvailable: map['is_available'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_or_service': productOrService,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'lead_time_days': leadTimeDays,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
