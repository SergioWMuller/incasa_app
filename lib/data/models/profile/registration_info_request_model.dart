/// Request da RPC `get_registration_info` (`POST /rest/v1/rpc/...`).
///
/// A RPC não recebe parâmetros: a identidade vem do JWT (`app_user_id()`),
/// nunca de um `user_id` enviado pelo cliente.
class RegistrationInfoRequestModel {
  const RegistrationInfoRequestModel();

  /// Corpo enviado ao PostgREST (vazio).
  Map<String, dynamic> toSupabase() => const {};
}
