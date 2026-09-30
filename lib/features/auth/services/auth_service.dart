import 'dart:developer';
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
        '899647823112-0mhvssudvtf92vja0j2i2b0jld7g1nf8.apps.googleusercontent.com',
  );

  // DioClient apontando para a base de Edge Functions configurada no .env
  final DioClient _dioClient = DioClient(
    baseUrl: SupabaseConstants.supabaseFunctionsUrl,
  );

  User? get currentUser => _firebaseAuth.currentUser;

  Future<AuthResult> signInWithGoogle() async {
    try {
      log('🔵 [AUTH] ========== INICIANDO LOGIN GOOGLE ==========');

      // PASSO 1: Abrir dialog do Google
      log('🔵 [AUTH] Passo 1: Abrindo Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        log('🟠 [AUTH] Passo 1 CANCELADO: Usuário cancelou login');
        return AuthResult(
          userCredential: null,
          supabaseSaved: false,
          message: 'Login cancelado pelo usuário.',
        );
      }
      log('✅ [AUTH] Passo 1 OK: ${googleUser.email}');

      // PASSO 2: Obter tokens do Google
      log('🔵 [AUTH] Passo 2: Obtendo tokens do Google...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;
      log('✅ [AUTH] Passo 2 OK');

      if (idToken == null) {
        log('🔴 [AUTH] idToken é null — verifique o serverClientId');
        return AuthResult(
          userCredential: null,
          supabaseSaved: false,
          message:
              'Não foi possível obter o idToken do Google. Verifique o serverClientId.',
        );
      }

      // PASSO 3: Sign-in com Firebase
      log('🔵 [AUTH] Passo 3: Autenticando no Firebase...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        log('🔴 [AUTH] Passo 3 ERRO: Firebase user é null');
        return AuthResult(
          userCredential: null,
          supabaseSaved: false,
          message: 'Erro ao autenticar com o Google.',
        );
      }
      log('✅ [AUTH] Passo 3 OK');

      // PASSO 4: Pegar Firebase idToken (assinado pelo Firebase, não pelo Google)
      log('🔵 [AUTH] Passo 4: Obtendo Firebase idToken...');
      final firebaseIdToken = await firebaseUser.getIdToken();
      if (firebaseIdToken == null) {
        log('🔴 [AUTH] Passo 4 ERRO: Firebase idToken é null');
        return AuthResult(
          userCredential: null,
          supabaseSaved: false,
          message: 'Erro ao obter token do Firebase.',
        );
      }
      log('✅ [AUTH] Passo 4 OK: Firebase idToken obtido');

      // PASSO 5: Chamar Edge Function
      log('🔵 [AUTH] Passo 5: Chamando Edge Function...');
      bool supabaseSaved = true;
      String authMessage = 'Login realizado com sucesso!';
      Map<String, dynamic> edgeResult = {};

      try {
        edgeResult = await _callAuthEdgeFunction(
          firebaseIdToken: firebaseIdToken,
        );
        log('✅ [AUTH] Passo 5 OK: Edge Function respondeu');
        log('   - user_id: ${edgeResult['user_id']}');
        log('   - is_new_user: ${edgeResult['is_new_user']}');
        log('   - is_new_provider: ${edgeResult['is_new_provider']}');
      } catch (e) {
        supabaseSaved = false;
        authMessage =
            'Login realizado, mas erro ao sincronizar com Supabase: $e';
        log('⚠️ [AUTH] Passo 5 com falha não bloqueante (${e.runtimeType})');
      }

      // JWT do Supabase emitido pela Edge Function (quando já implementado no
      // backend) — ver ai/supabase-estado-atual.md §4/§7.
      final supabaseAccessToken = _extractSupabaseToken(edgeResult);

      log('🟢 [AUTH] ========== LOGIN GOOGLE SUCESSO! ==========');
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
      log('🔴 [AUTH] ========== LOGIN GOOGLE ERRO! ==========');
      log('🔴 [AUTH] Tipo: ${e.runtimeType}');
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
      log('⚠️ [AUTH] Falha ao renovar JWT do Supabase (${e.runtimeType})');
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
      log('🟡 [EDGE] Chamando Edge Function...');

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

      log('🟡 [EDGE] Status: ${response.statusCode}');

      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception('A Edge Function recusou a autenticação.');
      }

      return data;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      log('🔴 [EDGE] Falha HTTP (${statusCode ?? 'sem resposta'})');
      throw Exception(
        'Erro ao comunicar com a Edge Function (${statusCode ?? 'sem resposta'}).',
      );
    } catch (e) {
      log('🔴 [EDGE] Erro (${e.runtimeType})');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
