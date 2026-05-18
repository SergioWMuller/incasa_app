import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/profile/address.dart';

enum AddressStatus { initial, loading, success, error }

class AddressState extends Equatable {
  // Status e erro
  final AddressStatus status;
  final String? errorMessage;

  // Lista de endereços (para tela de listagem)
  final List<Address> addresses;

  // Campos de um único endereço (para formulário)
  final String? addressId;
  final String? userId;
  final bool isPrimary;
  final String? street;
  final String? number;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? countryCode;
  final String? zipCode;
  final AddressType addressType;
  final String? label;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Controles do formulário
  final bool enableValidation;
  final int autoCompleteKey;
  final bool canChangePrimary;

  // Controle de mudanças temporárias do endereço principal (para switches na lista)
  // Permite que o usuário mude qual endereço é principal localmente antes de salvar
  final String?
  temporaryPrimaryAddressId; // Switch marcado localmente (antes de salvar)
  final String?
  originalPrimaryAddressId; // Endereço marcado como principal no DB

  const AddressState({
    this.status = AddressStatus.initial,
    this.errorMessage,
    this.addresses = const [],
    this.addressId,
    this.userId,
    this.isPrimary = false,
    this.street,
    this.number,
    this.complement,
    this.neighborhood,
    this.city,
    this.state,
    this.countryCode,
    this.zipCode,
    this.addressType = AddressType.home,
    this.label,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.enableValidation = false,
    this.autoCompleteKey = 0,
    this.canChangePrimary = true,
    this.temporaryPrimaryAddressId,
    this.originalPrimaryAddressId,
  });

  AddressState copyWith({
    AddressStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<Address>? addresses,
    String? addressId,
    String? userId,
    bool? isPrimary,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    String? countryCode,
    String? zipCode,
    AddressType? addressType,
    String? label,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? enableValidation,
    int? autoCompleteKey,
    bool? canChangePrimary,
    String? temporaryPrimaryAddressId,
    String? originalPrimaryAddressId,
    bool clearTemporaryPrimary = false,
  }) {
    return AddressState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      addresses: addresses ?? this.addresses,
      addressId: addressId ?? this.addressId,
      userId: userId ?? this.userId,
      isPrimary: isPrimary ?? this.isPrimary,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      countryCode: countryCode ?? this.countryCode,
      zipCode: zipCode ?? this.zipCode,
      addressType: addressType ?? this.addressType,
      label: label ?? this.label,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      enableValidation: enableValidation ?? this.enableValidation,
      autoCompleteKey: autoCompleteKey ?? this.autoCompleteKey,
      canChangePrimary: canChangePrimary ?? this.canChangePrimary,
      temporaryPrimaryAddressId: clearTemporaryPrimary
          ? null
          : (temporaryPrimaryAddressId ?? this.temporaryPrimaryAddressId),
      originalPrimaryAddressId:
          originalPrimaryAddressId ?? this.originalPrimaryAddressId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    addresses,
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
    enableValidation,
    autoCompleteKey,
    canChangePrimary,
    temporaryPrimaryAddressId,
    originalPrimaryAddressId,
  ];

  // Helpers para facilitar checagem
  bool get isLoading => status == AddressStatus.loading;
  bool get isSuccess => status == AddressStatus.success;
  bool get isError => status == AddressStatus.error;
  bool get isInitial => status == AddressStatus.initial;

  // Helpers para lista de endereços
  bool get hasAddresses => addresses.isNotEmpty;
  bool get isEmpty => addresses.isEmpty && isSuccess;

  // Helpers para controle de mudanças temporárias
  bool get hasPendingPrimaryChanges {
    // Tem mudanças se o temporário existe E é diferente do original
    return temporaryPrimaryAddressId != null &&
        temporaryPrimaryAddressId != originalPrimaryAddressId;
  }

  // Retorna qual endereço está marcado como principal (temporário ou original)
  String? get currentPrimaryAddressId {
    return temporaryPrimaryAddressId ?? originalPrimaryAddressId;
  }
}
