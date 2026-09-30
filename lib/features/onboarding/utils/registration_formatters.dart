import 'package:incasa_app/domain/entities/profile/registration_phone.dart';

/// Formata o telefone para exibição: `+55 (41) 99812-3489`.
///
/// Celular BR de 9 dígitos → `99812-3489`; de 8 → `9812-3489`. Fora do formato
/// esperado, cai no número completo com `+`.
String formatRegistrationPhone(RegistrationPhone phone) {
  final n = phone.number;
  final area = phone.areaCode;

  if (area == null || area.isEmpty || (n.length != 8 && n.length != 9)) {
    return '+${phone.fullNumber ?? '${phone.countryCode}${area ?? ''}$n'}';
  }

  final split = n.length - 4;
  return '+${phone.countryCode} ($area) ${n.substring(0, split)}-${n.substring(split)}';
}
