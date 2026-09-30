import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/profile/registration_phone.dart';

/// Entity dos dados cadastrais da tela "Dados da Conta".
///
/// Reflete o retorno da RPC `get_registration_info` (incasa-api.yaml):
/// - [email] e [phone] vêm **completos** (dados do próprio usuário);
/// - [cpf] vem **sempre mascarado pelo banco** (ex.: `123.***.**9-12`) — o CPF
///   em texto puro nunca sai do Postgres.
///
/// Cada campo é `null` quando o usuário ainda não o cadastrou.
class RegistrationInfo extends Equatable {
  final String? email;
  final RegistrationPhone? phone;
  final String? cpf;

  const RegistrationInfo({this.email, this.phone, this.cpf});

  @override
  List<Object?> get props => [email, phone, cpf];
}
