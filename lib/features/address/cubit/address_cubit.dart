import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final Dio _dio;

  AddressCubit(this._dio) : super(const AddressState());

  Future<void> useCurrentLocation() async {
    try {
      emit(state.copyWith(status: AddressStatus.loading, clearError: true));

      // 1. Verifica permissão
      final hasPermission = await _checkPermission();
      if (!hasPermission) {
        emit(
          state.copyWith(
            status: AddressStatus.error,
            errorMessage: 'Permissão de localização negada',
          ),
        );
        return;
      }

      // 2. Obtém localização
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Converte em endereço
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception('Não foi possível obter o endereço');
      }

      final placemark = placemarks.first;

      emit(
        state.copyWith(
          status: AddressStatus.success,
          street: placemark.street ?? '',
          neighborhood: placemark.subLocality ?? '',
          city: placemark.locality ?? '',
          state: placemark.administrativeArea ?? '',
          cep: placemark.postalCode ?? '',
          latitude: position.latitude,
          longitude: position.longitude,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AddressStatus.error,
          errorMessage: 'Erro ao obter localização: $e',
        ),
      );
    }
  }

  /// Busca endereço por CEP usando ViaCEP
  Future<void> searchByCep(String cep) async {
    try {
      emit(state.copyWith(status: AddressStatus.loading, clearError: true));

      // Remove formatação
      final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

      if (cleanCep.length != 8) {
        emit(
          state.copyWith(
            status: AddressStatus.error,
            errorMessage: 'CEP inválido',
          ),
        );
        return;
      }

      // Tenta ViaCEP primeiro
      try {
        await _searchViaCep(cleanCep);
        return;
      } catch (e) {
        // Fallback para BrasilAPI
        await _searchBrasilApi(cleanCep);
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AddressStatus.error,
          errorMessage: 'Erro ao buscar CEP: $e',
        ),
      );
    }
  }

  /// ViaCEP - Opção 1
  Future<void> _searchViaCep(String cep) async {
    final response = await _dio.get('https://viacep.com.br/ws/$cep/json/');

    if (response.data['erro'] == true) {
      throw Exception('CEP não encontrado');
    }

    emit(
      state.copyWith(
        status: AddressStatus.success,
        cep: response.data['cep'],
        street: response.data['logradouro'] ?? '',
        neighborhood: response.data['bairro'] ?? '',
        city: response.data['localidade'] ?? '',
        state: response.data['uf'] ?? '',
        clearError: true,
      ),
    );
  }

  /// BrasilAPI - Fallback
  Future<void> _searchBrasilApi(String cep) async {
    final response = await _dio.get('https://brasilapi.com.br/api/cep/v2/$cep');

    emit(
      state.copyWith(
        status: AddressStatus.success,
        cep: response.data['cep'],
        street: response.data['street'] ?? '',
        neighborhood: response.data['neighborhood'] ?? '',
        city: response.data['city'] ?? '',
        state: response.data['state'] ?? '',
        clearError: true,
      ),
    );
  }

  /// Verifica permissão de localização
  Future<bool> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Atualiza um campo específico
  void updateField({
    String? cep,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? stateUf,
  }) {
    emit(
      state.copyWith(
        cep: cep,
        street: street,
        number: number,
        complement: complement,
        neighborhood: neighborhood,
        city: city,
        state: stateUf,
      ),
    );
  }

  /// Métodos individuais para atualizar cada campo
  void updateCep(String value) {
    emit(state.copyWith(cep: value));
  }

  void updateStreet(String value) {
    emit(state.copyWith(street: value));
  }

  void updateNumber(String value) {
    emit(state.copyWith(number: value));
  }

  void updateComplement(String value) {
    emit(state.copyWith(complement: value));
  }

  void updateNeighborhood(String value) {
    emit(state.copyWith(neighborhood: value));
  }

  void updateCity(String value) {
    emit(state.copyWith(city: value));
  }

  void updateState(String value) {
    emit(state.copyWith(state: value));
  }

  /// Formata CEP (00000-000)
  String formatCep(String text) {
    final numbers = text.replaceAll(RegExp(r'[^\d]'), '');
    if (numbers.length <= 5) {
      return numbers;
    } else {
      return '${numbers.substring(0, 5)}-${numbers.substring(5, numbers.length > 8 ? 8 : numbers.length)}';
    }
  }

  /// Verifica se deve buscar CEP (quando atinge 8 dígitos)
  void onCepChanged(String cepText) {
    final cep = cepText.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length == 8) {
      searchByCep(cep);
    }
  }

  /// Ativa validação de formulário
  void enableFormValidation() {
    emit(state.copyWith(enableValidation: true));
  }

  /// Validações
  String? validateCep(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length != 8) {
      return 'CEP inválido';
    }
    return null;
  }

  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (value.length != 2) {
      return 'UF inválido';
    }
    return null;
  }

  /// Limpa mensagem de erro e reseta status
  void clearError() {
    emit(state.copyWith(status: AddressStatus.initial, clearError: true));
  }

  /// Reseta o formulário para estado inicial
  void resetState() {
    emit(const AddressState());
  }
}
