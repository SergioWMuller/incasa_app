import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projeto_incasa_app/data/models/auth_result_google.dart';
import 'package:projeto_incasa_app/data/supabase_service.dart';

class AuthService {
  Future<AuthResult> signInWithGoogleAndSaveToSupabase() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
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
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return AuthResult(
          userCredential: null,
          supabaseSaved: false,
          message: 'Erro ao autenticar com o Google.',
        );
      }

      // Verifica se o usuário já existe no Supabase
      final existingUser = await SupabaseService.client
          .from('users')
          .select('id')
          .eq('uid_google', firebaseUser.uid)
          .maybeSingle();

      bool supabaseSaved = false;
      if (existingUser == null) {
        try {
          await SupabaseService.client.from('users').insert({
            'uid_google': firebaseUser.uid,
            'display_name': firebaseUser.displayName ?? '',
            'email': firebaseUser.email ?? '',
            'photo_url': firebaseUser.photoURL ?? '',
            'email_verified': firebaseUser.emailVerified,
            'phone_number': firebaseUser.phoneNumber,
            'isAnonymous': firebaseUser.isAnonymous,
          });
          supabaseSaved = true;
        } catch (e) {
          supabaseSaved = false;
        }
      } else {
        supabaseSaved = true;
      }

      return AuthResult(
        userCredential: userCredential,
        supabaseSaved: supabaseSaved,
        message: supabaseSaved
            ? 'Login e salvamento no Supabase concluídos.'
            : 'Login feito, mas falha ao salvar no Supabase.',
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
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }
}
