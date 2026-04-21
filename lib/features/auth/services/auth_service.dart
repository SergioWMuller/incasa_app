import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:incasa_app/data/models/auth_result.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(
          userCredential: null,
          supabaseSaved: false,
          message: 'Login cancelado pelo usuário.',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return AuthResult(
          userCredential: null,
          supabaseSaved: false,
          message: 'Erro ao autenticar com o Google.',
        );
      }

      return AuthResult(
        userCredential: userCredential,
        supabaseSaved: true,
        message: 'Login realizado com sucesso!',
      );
    } catch (e) {
      return AuthResult(
        userCredential: null,
        supabaseSaved: false,
        message: 'Erro inesperado: $e',
      );
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
