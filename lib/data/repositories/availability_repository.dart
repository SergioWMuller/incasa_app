import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';

class WeeklyAvailabilityRepository {
  final SupabaseClient client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await client.from('weekly_availability').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final response =
        await client.from('weekly_availability').select().eq('id', id).single();
    return response;
  }

  Future<void> create({
    required String productServiceId,
    required int weekday,
    required String startTime,
    required String endTime,
  }) async {
    await client.from('weekly_availability').insert({
      'product_service_id': productServiceId,
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
    });
  }

  Future<void> update(
    String id, {
    int? weekday,
    String? startTime,
    String? endTime,
  }) async {
    final data = <String, dynamic>{};
    if (weekday != null) data['weekday'] = weekday;
    if (startTime != null) data['start_time'] = startTime;
    if (endTime != null) data['end_time'] = endTime;
    await client.from('weekly_availability').update(data).eq('id', id);
  }

  Future<void> delete(String id) async {
    await client.from('weekly_availability').delete().eq('id', id);
  }
}
