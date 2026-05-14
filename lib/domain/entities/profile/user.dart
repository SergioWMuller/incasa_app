import 'package:equatable/equatable.dart';

/// Entity User (Perfil do usuário)
/// Reflete o schema real do Supabase
class User extends Equatable {
  // IDENTIFICAÇÃO
  final String uid; // UID do usuário (Firebase/Google)
  final String? email;
  final String? displayName;
  final String? fullName;
  final String? phoneNumber;
  final String? photoUrl;
  final String? cpf;

  // TIMESTAMPS
  final DateTime createdAt; // creation_time
  final DateTime? lastSignInTime;

  // VENDEDOR
  final double sellerRating; // seller_rating (default 0.00)
  final bool isSeller; // is_seller (default false)

  // ENDEREÇO DE ENTREGA PADRÃO
  final String? defaultShippingStreet;
  final String? defaultShippingNumber;
  final String? defaultShippingComplement;
  final String? defaultShippingNeighborhood;
  final String? defaultShippingCity;
  final String? defaultShippingState;
  final String? defaultShippingZipCode;

  // VERIFICAÇÕES
  final bool emailVerified; // email_verified (default false)
  final bool phoneVerified; // phone_verified (default false)
  final bool isPhoneWhatsApp; // is_phone_whatsapp (default false)

  const User({
    // Obrigatórios
    required this.uid,
    required this.createdAt,
    this.email,
    this.fullName,
    this.displayName,
    this.photoUrl,
    // Contato
    this.phoneNumber,
    this.cpf,
    // Timestamps
    this.lastSignInTime,
    // Vendedor
    this.sellerRating = 0.0,
    this.isSeller = false,
    // Endereço
    this.defaultShippingStreet,
    this.defaultShippingNumber,
    this.defaultShippingComplement,
    this.defaultShippingNeighborhood,
    this.defaultShippingCity,
    this.defaultShippingState,
    this.defaultShippingZipCode,
    // Verificações
    this.emailVerified = false,
    this.phoneVerified = false,
    this.isPhoneWhatsApp = false,
  });

  @override
  List<Object?> get props => [
    uid,
    email,
    fullName,
    displayName,
    photoUrl,
    phoneNumber,
    cpf,
    createdAt,
    lastSignInTime,
    sellerRating,
    isSeller,
    defaultShippingStreet,
    defaultShippingNumber,
    defaultShippingComplement,
    defaultShippingNeighborhood,
    defaultShippingCity,
    defaultShippingState,
    defaultShippingZipCode,
    emailVerified,
    phoneVerified,
    isPhoneWhatsApp,
  ];
}
