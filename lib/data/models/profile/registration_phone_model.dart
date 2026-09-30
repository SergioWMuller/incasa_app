import 'package:incasa_app/domain/entities/profile/registration_phone.dart';

/// Model do objeto `phone` da resposta de `get_registration_info`.
class RegistrationPhoneModel extends RegistrationPhone {
  const RegistrationPhoneModel({
    required super.countryCode,
    required super.number,
    super.areaCode,
    super.fullNumber,
    super.hasWhatsapp,
    super.isVerified,
  });

  factory RegistrationPhoneModel.fromSupabase(Map<String, dynamic> json) {
    return RegistrationPhoneModel(
      countryCode: json['country_code'] as String,
      areaCode: json['area_code'] as String?,
      number: json['number'] as String,
      fullNumber: json['full_number'] as String?,
      hasWhatsapp: json['has_whatsapp'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}
