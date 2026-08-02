import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:incasa_app/core/constants/supabase_constants.dart';
import 'package:incasa_app/core/network/dio_client.dart';
import 'package:incasa_app/data/models/auth_result.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // ⚠️ serverClientId = Web Client ID do Firebase (não o Android)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '289817032686-cakro7a1lgfqo6depe2500h5bdnejo71.apps.googleusercontent.com',
  );

  // DioClient apontando para a base de Edge Functions configurada no .env
  final DioClient _dioClient = DioClient(
    baseUrl: SupabaseConstants.supabaseFunctionsUrl,
  );

  User? get currentUser => _firebaseAuth.currentUser;

  Future<AuthResult> signInWithGoogle() async {
    try {
      print('🔵 [AUTH] ========== INICIANDO LOGIN GOOGLE ==========');

      // PASSO 1: Abrir dialog do Google
      print('🔵 [AUTH] Passo 1: Abrindo Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('🟠 [AUTH] Passo 1 CANCELADO: Usuário cancelou login');
        return AuthResult(
          userCredential: null,
          supabaseSaved: false,
          message: 'Login cancelado pelo usuário.',
        );
      }
      print('✅ [AUTH] Passo 1 OK: ${googleUser.email}');

      // PASSO 2: Obter tokens do Google
      print('🔵 [AUTH] Passo 2: Obtendo tokens do Google...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;
      print('✅ [AUTH] Passo 2 OK');
      print(
        '   - idToken: ${idToken != null ? '${idToken.substring(0, 20)}...' : 'NULL ⚠️'}',
      );
      print('   - accessToken: ${googleAuth.accessToken?.substring(0, 20)}...');

      if (idToken == null) {
        print('🔴 [AUTH] idToken é null — verifique o serverClientId');
        return AuthResult(
          userCredential: null,
          supabaseSaved: false,
          message:
              'Não foi possível obter o idToken do Google. Verifique o serverClientId.',
        );
      }

      // PASSO 3: Sign-in com Firebase
      print('🔵 [AUTH] Passo 3: Autenticando no Firebase...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        print('🔴 [AUTH] Passo 3 ERRO: Firebase user é null');
        return AuthResult(
          userCredential: null,
          supabaseSaved: false,
          message: 'Erro ao autenticar com o Google.',
        );
      }
      print('✅ [AUTH] Passo 3 OK');
      print('   - Firebase UID: ${firebaseUser.uid}');
      print('   - Email: ${firebaseUser.email}');
      print('   - Display Name: ${firebaseUser.displayName}');

      // PASSO 4: Pegar Firebase idToken (assinado pelo Firebase, não pelo Google)
      print('🔵 [AUTH] Passo 4: Obtendo Firebase idToken...');
      final firebaseIdToken = await firebaseUser.getIdToken();
      if (firebaseIdToken == null) {
        print('🔴 [AUTH] Passo 4 ERRO: Firebase idToken é null');
        return AuthResult(
          userCredential: null,
          supabaseSaved: false,
          message: 'Erro ao obter token do Firebase.',
        );
      }
      print('✅ [AUTH] Passo 4 OK: Firebase idToken obtido');

      // PASSO 5: Chamar Edge Function
      print('🔵 [AUTH] Passo 5: Chamando Edge Function...');
      bool supabaseSaved = true;
      String authMessage = 'Login realizado com sucesso!';
      Map<String, dynamic> edgeResult = {};

      try {
        edgeResult = await _callAuthEdgeFunction(
          firebaseIdToken: firebaseIdToken,
        );
        print('✅ [AUTH] Passo 5 OK: Edge Function respondeu');
        print('   - user_id: ${edgeResult['user_id']}');
        print('   - is_new_user: ${edgeResult['is_new_user']}');
        print('   - is_new_provider: ${edgeResult['is_new_provider']}');
      } catch (e) {
        supabaseSaved = false;
        authMessage =
            'Login realizado, mas erro ao sincronizar com Supabase: $e';
        print('⚠️ [AUTH] Passo 5 com falha não bloqueante: $e');
      }

      // JWT do Supabase emitido pela Edge Function (quando já implementado no
      // backend) — ver ai/supabase-estado-atual.md §4/§7.
      final supabaseAccessToken = _extractSupabaseToken(edgeResult);

      print('🟢 [AUTH] ========== LOGIN GOOGLE SUCESSO! ==========');
      return AuthResult(
        userCredential: userCredential,
        supabaseSaved: supabaseSaved,
        message: authMessage,
        userId: edgeResult['user_id'] as String?,
        isNewUser: edgeResult['is_new_user'] as bool? ?? false,
        isNewProvider: edgeResult['is_new_provider'] as bool? ?? false,
        supabaseAccessToken: supabaseAccessToken,
      );
    } catch (e) {
      print('🔴 [AUTH] ========== LOGIN GOOGLE ERRO! ==========');
      print('🔴 [AUTH] Erro: $e');
      print('🔴 [AUTH] Tipo: ${e.runtimeType}');
      return AuthResult(
        userCredential: null,
        supabaseSaved: false,
        message: 'Erro inesperado: $e',
      );
    }
  }

  /// Reobtém o JWT do Supabase a partir da sessão atual do Firebase.
  ///
  /// Usado no bootstrap (app reaberto): o Firebase restaura a sessão, mas o JWT
  /// do Supabase precisa ser renovado chamando a Edge Function novamente
  /// (idempotente — atualiza `last_login_at`). Retorna `null` se não houver
  /// usuário, se a Edge falhar ou enquanto o backend ainda não emitir o JWT.
  Future<String?> refreshSupabaseAccessToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    try {
      final idToken = await user.getIdToken();
      if (idToken == null) return null;
      final edgeResult = await _callAuthEdgeFunction(firebaseIdToken: idToken);
      return _extractSupabaseToken(edgeResult);
    } catch (e) {
      print('⚠️ [AUTH] Falha ao renovar JWT do Supabase: $e');
      return null;
    }
  }

  /// Extrai o JWT do Supabase do retorno da Edge Function. Aceita alguns nomes
  /// de campo possíveis para não acoplar a um contrato ainda em definição.
  String? _extractSupabaseToken(Map<String, dynamic> edgeResult) {
    return (edgeResult['supabase_access_token'] ??
            edgeResult['access_token'] ??
            edgeResult['supabase_jwt'] ??
            edgeResult['token'])
        as String?;
  }

  // ── Chama a Edge Function auth-firebase ────────────────────
  Future<Map<String, dynamic>> _callAuthEdgeFunction({
    required String firebaseIdToken,
  }) async {
    try {
      print('🟡 [EDGE] Chamando Edge Function...');

      final anonKey = SupabaseConstants.supabaseAnonKey;
      if (anonKey.isEmpty) {
        throw Exception(
          'SUPABASE_ANON_KEY não configurada no .env. Não é possível chamar a Edge Function.',
        );
      }

      final response = await _dioClient.post(
        '/functions/v1/auth-firebase',
        data: {'id_token': firebaseIdToken},
        options: Options(
          headers: {
            'apikey': anonKey,
            'Authorization': 'Bearer $firebaseIdToken',
          },
        ),
      );

      print('🟡 [EDGE] Status: ${response.statusCode}');
      print('🟡 [EDGE] Body: ${response.data}');

      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception('Edge Function falhou: ${data['error']}');
      }

      return data;
    } on DioException catch (e) {
      print(
        '🔴 [EDGE] DioException: ${e.response?.statusCode} — ${e.response?.data}',
      );
      throw Exception(
        'Erro na Edge Function: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      print('🔴 [EDGE] Erro: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
