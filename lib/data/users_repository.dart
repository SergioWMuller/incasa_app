import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class UsersRepository {
  final SupabaseClient client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await client.from('users').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final response = await client.from('users').select().eq('id', id).single();
    return response;
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String passwordHash,
    String? phone,
  }) async {
    await client.from('users').insert({
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'phone': phone,
    });
  }

  Future<void> updateUser(
    String id, {
    String? name,
    String? email,
    String? passwordHash,
    String? phone,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (passwordHash != null) data['password_hash'] = passwordHash;
    if (phone != null) data['phone'] = phone;
    await client.from('users').update(data).eq('id', id);
  }

  Future<void> deleteUser(String id) async {
    await client.from('users').delete().eq('id', id);
  }
}
