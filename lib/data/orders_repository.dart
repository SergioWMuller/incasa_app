import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class OrdersRepository {
  final SupabaseClient client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await client.from('orders').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getOrderById(String id) async {
    final response = await client.from('orders').select().eq('id', id).single();
    return response;
  }

  Future<void> createOrder({
    required String buyerId,
    required String sellerId,
    required String productServiceId,
    required int quantity,
    required String orderDate,
    required String deliveryDate,
    required String status,
  }) async {
    await client.from('orders').insert({
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'product_service_id': productServiceId,
      'quantity': quantity,
      'order_date': orderDate,
      'delivery_date': deliveryDate,
      'status': status,
    });
  }

  Future<void> updateOrder(
    String id, {
    int? quantity,
    String? deliveryDate,
    String? status,
  }) async {
    final data = <String, dynamic>{};
    if (quantity != null) data['quantity'] = quantity;
    if (deliveryDate != null) data['delivery_date'] = deliveryDate;
    if (status != null) data['status'] = status;
    await client.from('orders').update(data).eq('id', id);
  }

  Future<void> deleteOrder(String id) async {
    await client.from('orders').delete().eq('id', id);
  }
}
