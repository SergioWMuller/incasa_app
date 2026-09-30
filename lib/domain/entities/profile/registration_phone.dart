import 'package:equatable/equatable.dart';

/// Telefone principal do usuário na tela "Dados da Conta".
///
/// Vem completo (não mascarado) da RPC `get_registration_info` — é dado do
/// próprio usuário, já legível por ele via RLS em `phones`.
class RegistrationPhone extends Equatable {
  final String countryCode;
  final String? areaCode;
  final String number;

  /// `country_code || area_code || number` (coluna GENERATED no banco).
  final String? fullNumber;
  final bool hasWhatsapp;
  final bool isVerified;

  const RegistrationPhone({
    required this.countryCode,
    required this.number,
    this.areaCode,
    this.fullNumber,
    this.hasWhatsapp = false,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
    countryCode,
    areaCode,
    number,
    fullNumber,
    hasWhatsapp,
    isVerified,
  ];
}
