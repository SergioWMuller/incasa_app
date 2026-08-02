import 'package:equatable/equatable.dart';

/// Entity Phone.
///
/// Reflete o recurso `phones` exposto pela API (incasa-api.yaml).
/// `fullNumber` é coluna GENERATED no banco (country_code + area_code + number)
/// e nunca deve ser enviada em writes.
class Phone extends Equatable {
  final String id;
  final String userId;
  final String countryCode;
  final String? areaCode;
  final String number;
  final String? fullNumber;
  final bool hasWhatsapp;
  final bool isPrimary;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Phone({
    required this.id,
    required this.userId,
    required this.countryCode,
    required this.number,
    required this.createdAt,
    required this.updatedAt,
    this.areaCode,
    this.fullNumber,
    this.hasWhatsapp = false,
    this.isPrimary = false,
    this.isVerified = false,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    countryCode,
    areaCode,
    number,
    fullNumber,
    hasWhatsapp,
    isPrimary,
    isVerified,
    isActive,
    createdAt,
    updatedAt,
  ];
}
