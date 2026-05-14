import 'package:equatable/equatable.dart';

enum AddressStatus { initial, loading, success, error }

class AddressState extends Equatable {
  final AddressStatus status;
  final String? errorMessage;
  final String? cep;
  final String? street;
  final String? number;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final String? state;
  final double? latitude;
  final double? longitude;
  final bool enableValidation;

  const AddressState({
    this.status = AddressStatus.initial,
    this.errorMessage,
    this.cep,
    this.street,
    this.number,
    this.complement,
    this.neighborhood,
    this.city,
    this.state,
    this.latitude,
    this.longitude,
    this.enableValidation = false,
  });

  AddressState copyWith({
    AddressStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? cep,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
    bool? enableValidation,
  }) {
    return AddressState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      cep: cep ?? this.cep,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      enableValidation: enableValidation ?? this.enableValidation,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    cep,
    street,
    number,
    complement,
    neighborhood,
    city,
    state,
    latitude,
    longitude,
    enableValidation,
  ];

  // Helpers para facilitar checagem
  bool get isLoading => status == AddressStatus.loading;
  bool get isSuccess => status == AddressStatus.success;
  bool get isError => status == AddressStatus.error;
  bool get isInitial => status == AddressStatus.initial;
}
