import 'package:incasa_app/domain/entities/profile/user.dart';

/// Model do recurso `users` (incasa-api.yaml).
///
/// Conversões:
/// - [fromSupabase]/[toSupabase]: REST do Supabase (snake_case).
/// - [fromJson]/[toJson]: cache local (SharedPreferences) e snapshots avulsos.
/// - [fromEntity]: ponte a partir da entidade de domínio.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.createdAt,
    required super.updatedAt,
    super.displayName,
    super.photoUrl,
    super.sellerRating = 0.0,
    super.cpfHmac,
    super.cpfEncrypted,
    super.cpfDisplay,
  });

  static DateTime _parseDateTime(dynamic value, DateTime fallback) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  static double _parseRating(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ========================================
  // SUPABASE
  // ========================================

  /// Converte uma linha REST da tabela `users` em [UserModel].
  factory UserModel.fromSupabase(Map<String, dynamic> map) {
    final now = DateTime.now();
    final createdAt = _parseDateTime(map['created_at'], now);
    final updatedAt = _parseDateTime(map['updated_at'], createdAt);

    return UserModel(
      id: (map['id'] ?? '') as String,
      fullName: (map['full_name'] ?? map['display_name'] ?? '') as String,
      displayName: map['display_name'] as String?,
      photoUrl: map['photo_url'] as String?,
      sellerRating: _parseRating(map['seller_rating']),
      cpfHmac: map['cpf_hmac'] as String?,
      cpfEncrypted: map['cpf_encrypted'] as String?,
      cpfDisplay: map['cpf_display'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Payload de atualização (PATCH /users). Conforme `UserUpdate`,
  /// apenas `display_name` e `photo_url` são editáveis pelo app.
  /// `full_name`, `seller_rating` e CPF não são enviados daqui.
  Map<String, dynamic> toSupabase() {
    return {
      'display_name': displayName,
      'photo_url': photoUrl,
    };
  }

  // ========================================
  // JSON (cache local / snapshots)
  // ========================================

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final createdAt = _parseDateTime(json['created_at'] ?? json['createdAt'], now);
    final updatedAt = _parseDateTime(
      json['updated_at'] ?? json['updatedAt'],
      createdAt,
    );

    final displayName =
        (json['display_name'] ?? json['displayName']) as String?;

    return UserModel(
      id: (json['id'] ?? json['uid'] ?? '') as String,
      fullName:
          (json['full_name'] ?? json['fullName'] ?? displayName ?? '') as String,
      displayName: displayName,
      photoUrl: (json['photo_url'] ?? json['photoUrl'] ?? json['photoURL'])
          as String?,
      sellerRating: _parseRating(json['seller_rating'] ?? json['sellerRating']),
      cpfHmac: (json['cpf_hmac'] ?? json['cpfHmac']) as String?,
      cpfEncrypted: (json['cpf_encrypted'] ?? json['cpfEncrypted']) as String?,
      cpfDisplay: (json['cpf_display'] ?? json['cpfDisplay']) as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'display_name': displayName,
      'photo_url': photoUrl,
      'seller_rating': sellerRating,
      'cpf_hmac': cpfHmac,
      'cpf_encrypted': cpfEncrypted,
      'cpf_display': cpfDisplay,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ========================================
  // ENTITY
  // ========================================

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      fullName: user.fullName,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      sellerRating: user.sellerRating,
      cpfHmac: user.cpfHmac,
      cpfEncrypted: user.cpfEncrypted,
      cpfDisplay: user.cpfDisplay,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
