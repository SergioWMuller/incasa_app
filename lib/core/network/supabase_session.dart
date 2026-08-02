import 'dart:convert';

/// Mantém o **JWT do Supabase** usado para autenticar as chamadas REST/RPC como
/// o próprio usuário (`role = authenticated`, `sub = UID do Firebase`).
///
/// O token é emitido pela Edge Function `auth-firebase` (campo `access_token`)
/// e consumido pelo callback `accessToken` do `Supabase.initialize`.
///
/// Como o JWT expira em ~1h, esta classe guarda também o `exp` e renova o token
/// sob demanda (via [registerRefresher]) quando ele está vencido ou perto de
/// vencer — assim sessões longas não tomam 401.
class SupabaseSession {
  SupabaseSession._();

  static final SupabaseSession instance = SupabaseSession._();

  /// Margem de segurança antes do `exp` para considerar o token "vencido".
  static const Duration _expiryGuard = Duration(seconds: 60);

  String? _accessToken;
  DateTime? _expiresAt;

  /// Renovador registrado pela camada de auth (re-chama a Edge Function).
  Future<String?> Function()? _refresher;

  /// Dedupe de renovações concorrentes (várias requisições ao mesmo tempo).
  Future<String?>? _inFlight;

  String? get accessToken => _accessToken;

  bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  bool get _isFresh {
    if (!hasToken) return false;
    if (_expiresAt == null) return true; // sem exp legível: assume válido
    return _expiresAt!.isAfter(DateTime.now().add(_expiryGuard));
  }

  /// Define o token atual e extrai o `exp` do próprio JWT.
  void setToken(String? token) {
    if (token == null || token.isEmpty) {
      _accessToken = null;
      _expiresAt = null;
      return;
    }
    _accessToken = token;
    _expiresAt = _readExpiry(token);
  }

  void clear() {
    _accessToken = null;
    _expiresAt = null;
    _inFlight = null;
  }

  /// Registra a função que reobtém um JWT novo (ex.: `AuthService`).
  void registerRefresher(Future<String?> Function() refresher) {
    _refresher = refresher;
  }

  /// Retorna um token válido para a próxima chamada, renovando se necessário.
  /// Usado pelo callback `accessToken` do cliente Supabase.
  Future<String?> validToken() async {
    if (_isFresh) return _accessToken;
    if (_refresher == null) return _accessToken;

    // Coalesce renovações simultâneas em uma única chamada à Edge.
    _inFlight ??= _runRefresh();
    try {
      return await _inFlight;
    } finally {
      _inFlight = null;
    }
  }

  Future<String?> _runRefresh() async {
    try {
      setToken(await _refresher!.call());
    } catch (_) {
      // Mantém o token atual (pode ainda servir) — falha silenciosa.
    }
    return _accessToken;
  }

  /// Lê o claim `exp` (segundos desde epoch) do payload do JWT.
  static DateTime? _readExpiry(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      payload = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
      final map = json.decode(utf8.decode(base64.decode(payload)));
      final exp = map['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
