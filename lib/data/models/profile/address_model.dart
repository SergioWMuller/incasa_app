import 'package:incasa_app/domain/entities/profile/address.dart';

class AddressModel extends Address {
  const AddressModel({
    super.addressId,
    required super.userId,
    super.isPrimary = false,
    required super.street,
    super.number,
    super.complement,
    super.neighborhood,
    required super.city,
    required super.state,
    super.countryCode,
    super.zipCode,
    required super.addressType,
    super.label,
    super.latitude,
    super.longitude,
    super.createdAt,
    super.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressId: json['address_id'] as String?,
      userId: json['user_id'] as String,
      isPrimary: json['is_primary'] ?? false,
      street: json['street'] as String,
      number: json['number'] as String?,
      complement: json['complement'] as String?,
      neighborhood: json['neighborhood'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      countryCode: json['country_code'] as String?,
      zipCode: json['zip_code'] as String?,
      addressType: AddressType.values.firstWhere(
        (e) => e.name == (json['address_type'] as String),
        orElse: () => AddressType.other,
      ),
      label: json['label'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'is_primary': isPrimary,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'country_code': countryCode,
      'zip_code': zipCode,
      'address_type': addressType.name,
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
    };

    // Só inclui address_id se existir (UPDATE)
    if (addressId != null) {
      json['address_id'] = addressId;
    }

    // Só inclui timestamps se existirem
    if (createdAt != null) {
      json['created_at'] = createdAt!.toIso8601String();
    }
    if (updatedAt != null) {
      json['updated_at'] = updatedAt!.toIso8601String();
    }

    return json;
  }

  factory AddressModel.fromEntity(Address address) {
    return AddressModel(
      addressId: address.addressId,
      userId: address.userId,
      isPrimary: address.isPrimary,
      street: address.street,
      number: address.number,
      complement: address.complement,
      neighborhood: address.neighborhood,
      city: address.city,
      state: address.state,
      countryCode: address.countryCode,
      zipCode: address.zipCode,
      addressType: address.addressType,
      label: address.label,
      latitude: address.latitude,
      longitude: address.longitude,
      createdAt: address.createdAt,
      updatedAt: address.updatedAt,
    );
  }
}
