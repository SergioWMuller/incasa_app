import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  final UserCredential? userCredential;
  final bool supabaseSaved;
  final String message;
  final String? userId;
  final bool isNewUser;
  final bool isNewProvider;

  /// JWT do Supabase emitido pela Edge Function `auth-firebase` (quando
  /// disponível). Usado como `accessToken` do cliente Supabase.
  final String? supabaseAccessToken;

  AuthResult({
    required this.userCredential,
    required this.supabaseSaved,
    required this.message,
    this.userId,
    this.isNewUser = false,
    this.isNewProvider = false,
    this.supabaseAccessToken,
  });
}
