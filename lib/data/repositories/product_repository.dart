import 'package:projeto_incasa_app/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';

class ProductRepository {
  final SupabaseClient client = SupabaseService.client;

  Future<List<ProductModel>> getAll() async {
    final response = await client.from('products_services').select();
    return List<Map<String, dynamic>>.from(response)
        .map((map) => ProductModel.fromMap(map))
        .toList();
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final response =
        await client.from('products_services').select().eq('id', id).single();
    return response;
  }

  Future<void> create({
    required String userId,
    required String type,
    required String name,
    required String description,
    required num price,
    int? stock,
    int? leadTimeDays,
    num? discount,
    String? promoCode,
    String? category,
    required bool isAvailable,
  }) async {
    await client.from('products_services').insert({
      'user_id': userId,
      'type': type,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'lead_time_days': leadTimeDays,
      'discount': discount,
      'promo_code': promoCode,
      'category': category,
      'is_available': isAvailable,
    });
  }

  Future<void> update(
    String id, {
    String? name,
    String? description,
    num? price,
    int? stock,
    int? leadTimeDays,
    bool? isAvailable,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (stock != null) data['stock'] = stock;
    if (leadTimeDays != null) data['lead_time_days'] = leadTimeDays;
    if (isAvailable != null) data['is_available'] = isAvailable;
    await client.from('products_services').update(data).eq('id', id);
  }

  Future<void> delete(String id) async {
    await client.from('products_services').delete().eq('id', id);
  }

  Future<void> updateAvailability(int productId, bool isAvailable) async {
    await client
        .from('products_services')
        .update({'is_available': isAvailable}).eq('id', productId);
  }
}
