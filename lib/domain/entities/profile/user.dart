import 'package:equatable/equatable.dart';

/// Entity User (perfil do usuário).
///
/// Reflete o recurso `users` exposto pela API (incasa-api.yaml).
/// E-mail, telefone e CPF em texto puro NÃO pertencem a este recurso:
/// - e-mail vive em `providers`;
/// - telefones vivem em `phones`;
/// - o CPF é gravado apenas como `cpf_hmac`/`cpf_encrypted` via RPC.
class User extends Equatable {
  final String id;
  final String fullName;
  final String? displayName;
  final String? photoUrl;

  /// Nota do vendedor (numeric(3,2) no banco). Gerenciado pelo servidor.
  final double sellerRating;

  /// PII do CPF — nunca expor no app, presente apenas para completude do recurso.
  final String? cpfHmac;
  final String? cpfEncrypted;

  /// Fragmento do CPF pronto para exibição (2 primeiros + 2 últimos dígitos,
  /// ex.: `12*.***.***-11`), gravado por `set_user_cpf` no momento do
  /// cadastro. Não é PII reversível — nunca reconstrói o CPF completo.
  final String? cpfDisplay;

  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.fullName,
    required this.createdAt,
    required this.updatedAt,
    this.displayName,
    this.photoUrl,
    this.sellerRating = 0.0,
    this.cpfHmac,
    this.cpfEncrypted,
    this.cpfDisplay,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    displayName,
    photoUrl,
    sellerRating,
    cpfHmac,
    cpfEncrypted,
    cpfDisplay,
    createdAt,
    updatedAt,
  ];
}
