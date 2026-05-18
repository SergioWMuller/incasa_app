import 'package:equatable/equatable.dart';

enum AddressType { home, work, billing, shipping, other }

extension AddressTypeExtension on AddressType {
  String get displayName {
    switch (this) {
      case AddressType.home:
        return 'Residencial';
      case AddressType.work:
        return 'Trabalho';
      case AddressType.billing:
        return 'Cobrança';
      case AddressType.shipping:
        return 'Entrega';
      case AddressType.other:
        return 'Outro';
    }
  }
}

class Address extends Equatable {
  final String? addressId;
  final String userId;
  final bool isPrimary;
  final String street;
  final String? number;
  final String? complement;
  final String? neighborhood;
  final String city;
  final String state;
  final String? countryCode;
  final String? zipCode;
  final AddressType addressType;
  final String? label;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Address({
    this.addressId,
    required this.userId,
    this.isPrimary = false,
    required this.street,
    this.number,
    this.complement,
    this.neighborhood,
    required this.city,
    required this.state,
    this.countryCode,
    this.zipCode,
    required this.addressType,
    this.label,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    addressId,
    userId,
    isPrimary,
    street,
    number,
    complement,
    neighborhood,
    city,
    state,
    countryCode,
    zipCode,
    addressType,
    label,
    latitude,
    longitude,
    createdAt,
    updatedAt,
  ];
}
