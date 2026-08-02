import 'package:incasa_app/domain/entities/profile/provider.dart';

/// Model do recurso `providers` (incasa-api.yaml). Somente leitura via REST.
class ProviderModel extends Provider {
  const ProviderModel({
    required super.id,
    required super.userId,
    required super.provider,
    required super.providerUid,
    super.email,
    super.isPrimary = false,
    super.isVerified = false,
    super.createdAt,
    super.lastLoginAt,
  });

  static DateTime? _tryParseDate(dynamic value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      provider: json['provider'] as String,
      providerUid: json['provider_uid'] as String? ?? '',
      email: json['email'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: _tryParseDate(json['created_at']),
      lastLoginAt: _tryParseDate(json['last_login_at']),
    );
  }

  factory ProviderModel.fromEntity(Provider provider) {
    return ProviderModel(
      id: provider.id,
      userId: provider.userId,
      provider: provider.provider,
      providerUid: provider.providerUid,
      email: provider.email,
      isPrimary: provider.isPrimary,
      isVerified: provider.isVerified,
      createdAt: provider.createdAt,
      lastLoginAt: provider.lastLoginAt,
    );
  }
}
