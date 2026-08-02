import 'package:equatable/equatable.dart';

/// Entity Provider (provedor de autenticação vinculado ao usuário).
///
/// Reflete o recurso `providers` exposto pela API (incasa-api.yaml).
/// Somente leitura via REST — inserção/atualização é feita pela Edge Function
/// `auth-firebase` com service_role.
class Provider extends Equatable {
  final String id;
  final String userId;

  /// Ex.: `google`, `apple`, `facebook`.
  final String provider;

  /// UID do Firebase (string, não UUID).
  final String providerUid;
  final String? email;
  final bool isPrimary;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const Provider({
    required this.id,
    required this.userId,
    required this.provider,
    required this.providerUid,
    this.email,
    this.isPrimary = false,
    this.isVerified = false,
    this.createdAt,
    this.lastLoginAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    provider,
    providerUid,
    email,
    isPrimary,
    isVerified,
    createdAt,
    lastLoginAt,
  ];
}
