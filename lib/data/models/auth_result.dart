import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  final UserCredential? userCredential;
  final bool supabaseSaved;
  final String message;

  AuthResult({
    required this.userCredential,
    required this.supabaseSaved,
    required this.message,
  });
}
