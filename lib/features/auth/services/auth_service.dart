import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:incasa_app/data/models/auth_result.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<AuthResult> signInWithGoogle() async {
    try {
      print('🔵 AuthService: Iniciando Google Sign In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('⚠️ AuthService: Login cancelado pelo usuário');
        return AuthResult(
          userCredential: null,
          supabaseSaved: false,
          message: 'Login cancelado pelo usuário.',
        );
      }

      print('🔵 AuthService: Usuário Google selecionado: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('🔵 AuthService: Obtendo credential do Firebase...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔵 AuthService: Fazendo login no Firebase...');
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        print('❌ AuthService: Erro - usuário Firebase é null');
        return AuthResult(
          userCredential: null,
          supabaseSaved: false,
          message: 'Erro ao autenticar com o Google.',
        );
      }

      print(
        '✅ AuthService: Login Firebase bem-sucedido: ${firebaseUser.email}',
      );
      return AuthResult(
        userCredential: userCredential,
        supabaseSaved: true,
        message: 'Login realizado com sucesso!',
      );
    } catch (e) {
      print('💥 AuthService: Erro durante login: $e');
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
