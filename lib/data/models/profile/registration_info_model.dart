import 'package:incasa_app/data/models/profile/registration_phone_model.dart';
import 'package:incasa_app/domain/entities/profile/registration_info.dart';

/// Response da RPC `get_registration_info` (incasa-api.yaml).
///
/// ```json
/// {
///   "email": "maria@gmail.com",
///   "phone": {
///     "country_code": "55", "area_code": "41", "number": "998123489",
///     "full_number": "5541998123489", "has_whatsapp": true, "is_verified": false
///   },
///   "cpf": "123.***.**9-12"
/// }
/// ```
class RegistrationInfoModel extends RegistrationInfo {
  const RegistrationInfoModel({super.email, super.phone, super.cpf});

  factory RegistrationInfoModel.fromSupabase(Map<String, dynamic> json) {
    final phone = json['phone'];
    return RegistrationInfoModel(
      email: json['email'] as String?,
      phone: phone is Map
          ? RegistrationPhoneModel.fromSupabase(
              Map<String, dynamic>.from(phone),
            )
          : null,
      cpf: json['cpf'] as String?,
    );
  }
}
