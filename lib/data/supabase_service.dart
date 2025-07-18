import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://icakickytxkswwgaaxzm.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImljYWtpY2t5dHhrc3d3Z2FheHptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2ODM5NjEsImV4cCI6MjA2MzI1OTk2MX0.9K2E4gHAUBpzaKouoJxMp4Vnu0nAu5zxnirOldxskFo';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
