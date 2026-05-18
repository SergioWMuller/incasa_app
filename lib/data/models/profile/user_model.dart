import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incasa_app/domain/entities/profile/user.dart';

class UserModel extends User {
  const UserModel({
    // Obrigatórios
    required super.uid,
    required super.createdAt,
    super.email,
    super.fullName,
    super.displayName,
    super.photoUrl,
    // Contato
    super.phoneNumber,
    super.cpf,
    // Timestamps
    super.lastSignInTime,
    // Verificações
    super.emailVerified = false,
    super.phoneVerified = false,
    super.isPhoneWhatsApp = false,
  });

  // ========================================
  // SUPABASE (MVP - USAR AGORA) ✅
  // ========================================

  /// Converte dados do Supabase para UserModel
  factory UserModel.fromSupabase(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      fullName: map['full_name'] as String?,
      displayName: map['display_name'] as String?,
      photoUrl: map['photo_url'] as String?,
      phoneNumber: map['phone_number'] as String?,
      cpf: map['cpf'] as String?,
      createdAt: DateTime.parse(map['creation_time'] as String),
      lastSignInTime: map['last_sign_in_time'] != null
          ? DateTime.parse(map['last_sign_in_time'] as String)
          : null,
      emailVerified: map['email_verified'] as bool? ?? false,
      phoneVerified: map['phone_verified'] as bool? ?? false,
      isPhoneWhatsApp: map['is_phone_whatsapp'] as bool? ?? false,
    );
  }

  /// Converte UserModel para Supabase
  Map<String, dynamic> toSupabase() {
    return {
      'uid': uid,
      'email': email,
      'full_name': fullName,
      'display_name': displayName,
      'photo_url': photoUrl,
      'phone_number': phoneNumber,
      'cpf': cpf,
      'creation_time': createdAt.toIso8601String(),
      if (lastSignInTime != null)
        'last_sign_in_time': lastSignInTime!.toIso8601String(),
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      'is_phone_whatsapp': isPhoneWhatsApp,
    };
  }

  // ========================================
  // FIREBASE (COMPATIBILIDADE) ✅
  // ========================================

  /// Converte DocumentSnapshot do Firestore para UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      fullName: data['name'] as String?,
      displayName: data['name'] as String?,
      photoUrl: data['avatarUrl'] as String?,
      phoneNumber: data['phone'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Converte UserModel para Map do Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': fullName ?? displayName,
      'email': email,
      'avatarUrl': photoUrl,
      'phone': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ========================================
  // LARAVEL API (FUTURO) 📦
  // ========================================

  /// Converte JSON da API Laravel para UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      cpf: json['cpf'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSignInTime: json['lastSignInTime'] != null
          ? DateTime.parse(json['lastSignInTime'] as String)
          : null,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      isPhoneWhatsApp: json['isPhoneWhatsApp'] as bool? ?? false,
    );
  }

  /// Converte UserModel para JSON para API Laravel
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'cpf': cpf,
      'createdAt': createdAt.toIso8601String(),
      if (lastSignInTime != null)
        'lastSignInTime': lastSignInTime!.toIso8601String(),
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'isPhoneWhatsApp': isPhoneWhatsApp,
    };
  }

  // ========================================
  // CONVERSÃO DE/PARA ENTITY
  // ========================================

  /// Converte Entity pura para Model
  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      fullName: user.fullName,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      phoneNumber: user.phoneNumber,
      cpf: user.cpf,
      createdAt: user.createdAt,
      lastSignInTime: user.lastSignInTime,
      emailVerified: user.emailVerified,
      phoneVerified: user.phoneVerified,
      isPhoneWhatsApp: user.isPhoneWhatsApp,
    );
  }
}
