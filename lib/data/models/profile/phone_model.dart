import 'package:incasa_app/domain/entities/profile/phone.dart';

/// Model do recurso `phones` (incasa-api.yaml).
class PhoneModel extends Phone {
  const PhoneModel({
    required super.id,
    required super.userId,
    required super.countryCode,
    required super.number,
    required super.createdAt,
    required super.updatedAt,
    super.areaCode,
    super.fullNumber,
    super.hasWhatsapp = false,
    super.isPrimary = false,
    super.isVerified = false,
    super.isActive = true,
  });

  factory PhoneModel.fromJson(Map<String, dynamic> json) {
    return PhoneModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      countryCode: json['country_code'] as String,
      areaCode: json['area_code'] as String?,
      number: json['number'] as String,
      fullNumber: json['full_number'] as String?,
      hasWhatsapp: json['has_whatsapp'] as bool? ?? false,
      isPrimary: json['is_primary'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Payload de criação (POST /phones), conforme `PhoneInsert`.
  /// Não envia `full_number` (GENERATED) nem timestamps/flags de servidor.
  Map<String, dynamic> toInsert() {
    return {
      'user_id': userId,
      'country_code': countryCode,
      if (areaCode != null) 'area_code': areaCode,
      'number': number,
      'is_primary': isPrimary,
      'has_whatsapp': hasWhatsapp,
    };
  }

  /// Payload de atualização (PATCH /phones), conforme `PhoneUpdate`.
  Map<String, dynamic> toUpdate() {
    return {
      'is_primary': isPrimary,
      'has_whatsapp': hasWhatsapp,
      'is_active': isActive,
    };
  }

  factory PhoneModel.fromEntity(Phone phone) {
    return PhoneModel(
      id: phone.id,
      userId: phone.userId,
      countryCode: phone.countryCode,
      areaCode: phone.areaCode,
      number: phone.number,
      fullNumber: phone.fullNumber,
      hasWhatsapp: phone.hasWhatsapp,
      isPrimary: phone.isPrimary,
      isVerified: phone.isVerified,
      isActive: phone.isActive,
      createdAt: phone.createdAt,
      updatedAt: phone.updatedAt,
    );
  }
}
