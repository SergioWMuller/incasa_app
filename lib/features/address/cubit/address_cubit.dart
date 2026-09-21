import 'dart:developer';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/core/constants/br_states_constants.dart';
import 'package:incasa_app/domain/repositories/profile/address_repository.dart';
import 'address_state.dart';
import 'package:incasa_app/domain/entities/profile/address.dart';

class AddressCubit extends Cubit<AddressState> {
  final GeolocatorPlatform _geolocator;
  final Dio _dio;
  final AddressRepository _repository;
  final SharedPreferences _prefs;

  AddressCubit(this._dio, this._geolocator, this._repository, this._prefs)
    : super(const AddressState());

  /// Inicializa o cubit carregando dados do SharedPreferences e endereços do DB
  /// Deve ser chamado explicitamente ao criar o cubit
  Future<void> initialize() async {
    log('🔵 ========== ADDRESS CUBIT INITIALIZE ==========');
    try {
      // Busca dados do usuário do SharedPreferences
      final userDataJson = _prefs.getString('userGoogleAccount');
      log('📦 userDataJson: ${userDataJson != null ? "existe" : "null"}');

      if (userDataJson == null) {
        log('❌ Usuário não autenticado');
        emit(
          state.copyWith(
            status: AddressStatus.error,
            errorMessage: 'Usuário não autenticado',
          ),
        );
        return;
      }

      final userData = json.decode(userDataJson) as Map<String, dynamic>;

      // A tabela `address` referencia `users.id` (UUID interno), não o UID do
      // Firebase. O UUID é salvo em `id` pelo AuthCubit após resolver o
      // usuário no Supabase; cai para o UID do Firebase só se ainda não
      // resolvido (ex.: falha transitória de rede no login).
      final String userId = (userData['id'] as String?) ?? userData['uid'] as String;
      log('🔑 userId: $userId');

      emit(state.copyWith(userId: userId));
      log('📋 Chamando initializeAddressList...');
      await initializeAddressList(userId);

      // Recalcula isPrimary/canChangePrimary com a lista já carregada: se for
      // o primeiro endereço do usuário, o switch deve vir ativado e travado.
      // Não usa resetForm() aqui porque ele também reseta `status` para
      // `initial` — este método é compartilhado com AddressListView, que
      // depende do `status` (success/error) já setado por initializeAddressList
      // para sair do loading quando a lista está vazia.
      final isFirstAddress = state.addresses.isEmpty;
      emit(
        state.copyWith(
          isPrimary: isFirstAddress,
          canChangePrimary: !isFirstAddress,
        ),
      );
      log('✅ Initialize completo');
    } catch (e, stackTrace) {
      log('❌ Erro ao inicializar: $e');
      log('Stack: $stackTrace');
      emit(
        state.copyWith(
          status: AddressStatus.error,
          errorMessage: 'Erro ao inicializar: $e',
        ),
      );
    }
  }

  // ========================================
  // MÉTODOS PARA FORMULÁRIO (criar/editar endereço)
  // ========================================

  void setIsPrimary(bool value) {
    // Só permite mudar se canChangePrimary for true
    if (state.canChangePrimary) {
      emit(state.copyWith(isPrimary: value));
    }
  }

  /// Define se o usuário pode mudar o isPrimary
  /// Chamado ao inicializar a tela baseado se é o primeiro endereço
  void setCanChangePrimary(bool canChange) {
    emit(
      state.copyWith(
        canChangePrimary: canChange,
        isPrimary: canChange
            ? state.isPrimary
            : true, // Se não pode mudar, força true
      ),
    );
  }

  void setAddressType(AddressType value) {
    emit(state.copyWith(addressType: value));
  }

  void setLabel(String? value) {
    emit(state.copyWith(label: value));
  }

  void setZipCode(String value) {
    emit(state.copyWith(zipCode: value));
    onCepChanged(value);
  }

  void setStreet(String value) {
    emit(state.copyWith(street: value));
  }

  void setNumber(String value) {
    emit(state.copyWith(number: value));
  }

  void setComplement(String value) {
    emit(state.copyWith(complement: value));
  }

  void setNeighborhood(String value) {
    emit(state.copyWith(neighborhood: value));
  }

  void setCity(String value) {
    emit(state.copyWith(city: value));
  }

  void setState(String value) {
    emit(state.copyWith(state: value));
  }

  void setCountryCode(String value) {
    emit(state.copyWith(countryCode: value));
  }

  /// Inicializa o formulário de endereço com um userId específico
  /// Chamado ao abrir a tela de criar/editar endereço
  /// Exemplo de uso:
  /// ```dart
  /// final userAddressCount = await addressRepository.getUserAddressCount(userId);
  /// cubit.setCanChangePrimary(userAddressCount > 0);
  /// ```
  Future<void> initializeForm(String userId) async {
    // TODO: Quando o AddressRepository estiver implementado, buscar quantos endereços o usuário tem
    // Por enquanto, assume que pode mudar (comportamento padrão)
    // final count = await addressRepository.getUserAddressCount(userId);
    // setCanChangePrimary(count > 0);

    emit(state.copyWith(userId: userId));
  }

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
      // final position = Position(
      //   latitude: 27.521875114763805,
      //   longitude: -80.80562359073323,
      //   timestamp: DateTime.now(),
      //   accuracy: 1.0,
      //   altitude: 0.0,
      //   heading: 0.0,
      //   speed: 0.0,
      //   speedAccuracy: 1.0,
      //   headingAccuracy: 0.0,
      //   altitudeAccuracy: 0.0,
      // );
      final position = await _geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 3. Converte em endereço
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      log(placemarks[0].toString());
      if (placemarks.isEmpty) {
        throw Exception('Não foi possível obter o endereço');
      }

      final placemark = placemarks.first;
      final nowKey = DateTime.now().millisecondsSinceEpoch;

      // Converte nome do estado (ex: "Paraná") para sigla (ex: "PR")
      final stateUf =
          BrStates.nameToUf(placemark.administrativeArea) ??
          placemark.administrativeArea ??
          '';

      emit(
        state.copyWith(
          status: AddressStatus.success,
          street: placemark.thoroughfare ?? '', // logradouro
          number: placemark.subThoroughfare, // número
          neighborhood: placemark.subLocality ?? '', // bairro
          city: placemark.subAdministrativeArea ?? '', // cidade
          state: stateUf, // estado convertido para sigla
          countryCode: placemark.isoCountryCode, // código do país
          zipCode: placemark.postalCode ?? '', // CEP
          latitude: position.latitude,
          longitude: position.longitude,
          clearError: true,
          autoCompleteKey: nowKey,
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
        // Preserva status anterior (formulário continua editável)
        // Apenas mostra erro, não trava a UI em estado de erro
        emit(
          state.copyWith(
            status: state.addresses.isNotEmpty
                ? AddressStatus.success
                : AddressStatus.initial,
            errorMessage: 'CEP inválido',
          ),
        );
        return;
      }

      // Tenta ViaCEP primeiro
      try {
        await _searchViaCep(cleanCep, autoComplete: true);
        return;
      } catch (e) {
        // Fallback para BrasilAPI
        await _searchBrasilApi(cleanCep, autoComplete: true);
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
  Future<void> _searchViaCep(String cep, {bool autoComplete = false}) async {
    final response = await _dio.get('https://viacep.com.br/ws/$cep/json/');

    if (response.data['erro'] == true) {
      throw Exception('CEP não encontrado');
    }

    emit(
      state.copyWith(
        status: AddressStatus.success,
        zipCode: response.data['cep'],
        street: response.data['logradouro'] ?? '',
        neighborhood: response.data['bairro'] ?? '',
        city: response.data['localidade'] ?? '',
        state: response.data['uf'] ?? '',
        countryCode: 'BR', // CEP é exclusivo do Brasil
        clearError: true,
        autoCompleteKey: autoComplete
            ? DateTime.now().millisecondsSinceEpoch
            : state.autoCompleteKey,
      ),
    );
  }

  /// BrasilAPI - Fallback
  Future<void> _searchBrasilApi(String cep, {bool autoComplete = false}) async {
    final response = await _dio.get('https://brasilapi.com.br/api/cep/v2/$cep');

    emit(
      state.copyWith(
        status: AddressStatus.success,
        zipCode: response.data['cep'],
        street: response.data['street'] ?? '',
        neighborhood: response.data['neighborhood'] ?? '',
        city: response.data['city'] ?? '',
        state: response.data['state'] ?? '',
        countryCode: 'BR', // CEP é exclusivo do Brasil
        clearError: true,
        autoCompleteKey: autoComplete
            ? DateTime.now().millisecondsSinceEpoch
            : state.autoCompleteKey,
      ),
    );
  }

  /// Verifica permissão de localização
  Future<bool> _checkPermission() async {
    bool serviceEnabled = await _geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
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
    String? addressId,
    String? userId,
    bool? isPrimary,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? stateUf,
    String? countryCode,
    String? zipCode,
    AddressType? addressType,
    String? label,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    emit(
      state.copyWith(
        addressId: addressId,
        userId: userId,
        isPrimary: isPrimary,
        street: street,
        number: number,
        complement: complement,
        neighborhood: neighborhood,
        city: city,
        state: stateUf,
        countryCode: countryCode,
        zipCode: zipCode,
        addressType: addressType,
        label: label,
        latitude: latitude,
        longitude: longitude,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }

  /// Métodos individuais para atualizar cada campo
  void updateZipCode(String value) {
    emit(state.copyWith(zipCode: value));
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

  void updateCountryCode(String value) {
    emit(state.copyWith(countryCode: value));
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
    // Preserva success se houver endereços carregados, senão volta para initial
    emit(
      state.copyWith(
        status: state.addresses.isNotEmpty
            ? AddressStatus.success
            : AddressStatus.initial,
        clearError: true,
      ),
    );
  }

  /// Reseta o formulário para estado inicial
  void resetState() {
    emit(const AddressState());
  }

  /// Limpa apenas os campos do formulário, mantendo userId e lista de endereços
  /// Útil ao navegar para criar um novo endereço quando o cubit persiste entre telas
  void resetForm() {
    // Se não há endereços cadastrados, o primeiro deve ser principal automaticamente
    final isFirstAddress = state.addresses.isEmpty;

    emit(
      state.copyWith(
        addressId: null,
        isPrimary: isFirstAddress, // true se for o primeiro endereço
        street: null,
        number: null,
        complement: null,
        neighborhood: null,
        city: null,
        state: null,
        countryCode: null,
        zipCode: null,
        addressType: AddressType.home,
        label: null,
        latitude: null,
        longitude: null,
        createdAt: null,
        updatedAt: null,
        enableValidation: false,
        autoCompleteKey: 0,
        canChangePrimary:
            !isFirstAddress, // false se for o primeiro (não pode desmarcar)
        status: AddressStatus.initial,
        clearError: true,
      ),
    );
  }

  /// Carrega um endereço existente no formulário para edição
  void loadAddress(Address address) {
    emit(
      state.copyWith(
        addressId: address.addressId,
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
        enableValidation: false,
        autoCompleteKey: DateTime.now().millisecondsSinceEpoch,
        canChangePrimary: true,
        status: AddressStatus.initial,
        clearError: true,
      ),
    );
  }

  /// Valida se todos os campos obrigatórios estão preenchidos
  bool canSave() {
    return state.userId != null &&
        state.street != null &&
        state.street!.isNotEmpty &&
        state.city != null &&
        state.city!.isNotEmpty &&
        state.state != null &&
        state.state!.isNotEmpty &&
        state.zipCode != null &&
        state.zipCode!.isNotEmpty;
  }

  /// Salva endereço no Supabase (CREATE se addressId for null, UPDATE se não for)
  Future<bool> saveAddress() async {
    log('🟢 ========== SAVE ADDRESS ==========');
    log('📋 Dados do state:');
    log('   - addressId: ${state.addressId}');
    log('   - userId: ${state.userId}');
    log('   - isPrimary: ${state.isPrimary}');
    log('   - street: ${state.street}');
    log('   - number: ${state.number}');
    log('   - city: ${state.city}');
    log('   - state: ${state.state}');
    log('   - zipCode: ${state.zipCode}');
    log('   - addressType: ${state.addressType}');

    // Validação básica
    if (!canSave()) {
      log('❌ Validação falhou: campos obrigatórios não preenchidos');
      emit(
        state.copyWith(
          status: AddressStatus.error,
          errorMessage: 'Preencha todos os campos obrigatórios',
        ),
      );
      return false;
    }

    emit(state.copyWith(status: AddressStatus.loading, clearError: true));

    try {
      // Cria entidade Address a partir do state
      final address = Address(
        addressId: state.addressId,
        userId: state.userId!,
        isPrimary: state.isPrimary,
        street: state.street!,
        number: state.number,
        complement: state.complement,
        neighborhood: state.neighborhood,
        city: state.city!,
        state: state.state!,
        countryCode: state.countryCode ?? 'BR', // Padrão Brasil se não tiver
        zipCode: state.zipCode,
        addressType: state.addressType,
        label: state.label,
        latitude: state.latitude,
        longitude: state.longitude,
        createdAt: state.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      log('📤 Chamando repository.saveAddress...');

      // Chama repository (detecta automaticamente CREATE vs UPDATE)
      final result = await _repository.saveAddress(address);

      return switch (result) {
        Success(:final data) => () async {
          log('✅ Sucesso! addressId: ${data.addressId}');
          log('🟢 ==========================================');
          emit(
            state.copyWith(
              status: AddressStatus.success,
              addressId: data.addressId,
              clearError: true,
            ),
          );

          // Recarrega a lista de endereços após salvar para sincronizar com a API
          await refresh();

          return true;
        }(),
        Error(:final failure) => () {
          log('🔴 ========== ERRO NO REPOSITORY ==========');
          log('🔴 Mensagem: ${failure.message}');
          log('🔴 Tipo: ${failure.runtimeType}');
          log('🔴 ==========================================');
          emit(
            state.copyWith(
              status: AddressStatus.error,
              errorMessage: 'Erro ao salvar endereço: ${failure.message}',
            ),
          );
          return false;
        }(),
      };
    } catch (e, stackTrace) {
      log('🔴 ========== EXCEPTION CAPTURADA ==========');
      log('🔴 Exception: $e');
      log('🔴 Tipo: ${e.runtimeType}');
      log('🔴 StackTrace:');
      log(stackTrace.toString());
      log('🔴 ==========================================');
      emit(
        state.copyWith(
          status: AddressStatus.error,
          errorMessage: 'Erro inesperado ao salvar: $e',
        ),
      );
      return false;
    }
  }

  // ========================================
  // MÉTODOS PARA LISTA DE ENDEREÇOS
  // ========================================

  /// Inicializa a lista de endereços (carrega apenas se ainda não carregou)
  Future<void> initializeAddressList(String userId) async {
    // Só carrega se não estiver carregando e não tiver endereços ainda
    if (state.isLoading ||
        (state.addresses.isNotEmpty && state.userId == userId)) {
      return;
    }
    await loadAddresses(userId);
  }

  /// Carrega os endereços do usuário
  Future<void> loadAddresses(String userId) async {
    log('🔵 ========== LOAD ADDRESSES ==========');
    log('👤 userId: $userId');

    emit(
      state.copyWith(
        status: AddressStatus.loading,
        userId: userId,
        clearError: true,
      ),
    );

    log('📡 Chamando repository.getUserAddresses...');
    final result = await _repository.getUserAddresses(userId);

    switch (result) {
      case Success(:final data):
        log('✅ Sucesso! ${data.length} endereços encontrados');

        // Encontra qual endereço é o principal no DB
        String? primaryAddressId;
        if (data.isNotEmpty) {
          // Procura endereço com isPrimary=true
          final primaryIndex = data.indexWhere((addr) => addr.isPrimary);
          if (primaryIndex != -1) {
            primaryAddressId = data[primaryIndex].addressId;
            log('🏠 Endereço principal encontrado: $primaryAddressId');
          } else {
            // Se nenhum for principal, usa o primeiro
            primaryAddressId = data.first.addressId;
            log(
              '🏠 Nenhum principal definido, usando primeiro: $primaryAddressId',
            );
          }
        } else {
          log('📭 Lista de endereços vazia');
        }

        emit(
          state.copyWith(
            status: AddressStatus.success,
            addresses: data,
            originalPrimaryAddressId: primaryAddressId,
            clearTemporaryPrimary:
                true, // Limpa qualquer temporário ao recarregar
            clearError: true,
          ),
        );
        log('✅ Initialize completo');
        log('🔵 ==========================================');
      case Error(:final failure):
        log('❌ Erro: ${failure.message}');
        log('🔵 ==========================================');
        emit(
          state.copyWith(
            status: AddressStatus.error,
            errorMessage: failure.message,
          ),
        );
    }
  }

  /// Recarrega a lista de endereços (usado após criar/editar/deletar)
  Future<void> refresh() async {
    if (state.userId != null) {
      await loadAddresses(state.userId!);
    }
  }

  /// Deleta um endereço
  Future<bool> deleteAddress(String addressId) async {
    final result = await _repository.deleteAddress(addressId);

    return switch (result) {
      Success() => () async {
        // Recarrega a lista após deletar — aguarda para não deixar `status`/
        // `addresses` desatualizados se o chamador prosseguir imediatamente
        // (ex.: abrir o formulário de novo endereço logo em seguida).
        await refresh();
        return true;
      }(),
      Error(:final failure) => () {
        emit(
          state.copyWith(
            status: AddressStatus.error,
            errorMessage: 'Erro ao deletar endereço: ${failure.message}',
          ),
        );
        return false;
      }(),
    };
  }

  // ========================================
  // MÉTODOS PARA CONTROLE DE ENDEREÇO PRINCIPAL (DRAFT STATE)
  // ========================================

  /// Marca um endereço como principal LOCALMENTE (não salva no DB ainda)
  /// Usado quando o usuário toca em um switch
  void setTemporaryPrimaryAddress(String addressId) {
    // Se tocar no switch que já está marcado como principal, não faz nada
    if (state.currentPrimaryAddressId == addressId) {
      return;
    }

    // Marca localmente o novo endereço como principal
    emit(state.copyWith(temporaryPrimaryAddressId: addressId));
  }

  /// Salva as mudanças do endereço principal no banco de dados
  /// Chamado quando o usuário clica no FAB "Salvar Alterações"
  Future<bool> savePrimaryChanges() async {
    if (!state.hasPendingPrimaryChanges ||
        state.temporaryPrimaryAddressId == null) {
      return false;
    }

    try {
      emit(state.copyWith(status: AddressStatus.loading, clearError: true));

      final newPrimaryId = state.temporaryPrimaryAddressId!;

      // Encontra o endereço que será o novo principal
      final targetAddress = state.addresses.firstWhere(
        (addr) => addr.addressId == newPrimaryId,
      );

      // Marca o endereço como principal
      final updatedAddress = Address(
        addressId: targetAddress.addressId,
        userId: targetAddress.userId,
        isPrimary: true, // Marca como principal
        street: targetAddress.street,
        number: targetAddress.number,
        complement: targetAddress.complement,
        neighborhood: targetAddress.neighborhood,
        city: targetAddress.city,
        state: targetAddress.state,
        countryCode: targetAddress.countryCode,
        zipCode: targetAddress.zipCode,
        addressType: targetAddress.addressType,
        label: targetAddress.label,
        latitude: targetAddress.latitude,
        longitude: targetAddress.longitude,
        createdAt: targetAddress.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await _repository.saveAddress(updatedAddress);

      return switch (result) {
        Success() => () async {
          // Desmarca outros endereços como principal
          await _demoteOtherPrimaryAddresses(newPrimaryId);

          // Limpa o estado temporário e marca como sucesso
          // (refresh() dentro de _demoteOtherPrimaryAddresses já emite success,
          // mas emitimos explicitamente para clareza)
          emit(
            state.copyWith(
              status: AddressStatus.success,
              clearTemporaryPrimary: true,
              clearError: true,
            ),
          );

          return true;
        }(),
        Error(:final failure) => () {
          emit(
            state.copyWith(
              status: AddressStatus.error,
              errorMessage:
                  'Erro ao salvar endereço principal: ${failure.message}',
            ),
          );
          return false;
        }(),
      };
    } catch (e) {
      emit(
        state.copyWith(
          status: AddressStatus.error,
          errorMessage: 'Erro ao salvar: $e',
        ),
      );
      return false;
    }
  }

  /// Cancela as mudanças temporárias (volta ao estado original do DB)
  void cancelPrimaryChanges() {
    emit(state.copyWith(clearTemporaryPrimary: true));
  }

  /// Marca um endereço como principal imediatamente no banco de dados.
  /// Essa ação salva o novo endereço principal e desmarca automaticamente
  /// o endereço anterior.
  Future<bool> setPrimaryAddress(String addressId) async {
    if (state.currentPrimaryAddressId == addressId) {
      return true;
    }

    try {
      emit(state.copyWith(status: AddressStatus.loading, clearError: true));

      final targetAddress = state.addresses.firstWhere(
        (addr) => addr.addressId == addressId,
      );

      final updatedAddress = Address(
        addressId: targetAddress.addressId,
        userId: targetAddress.userId,
        isPrimary: true,
        street: targetAddress.street,
        number: targetAddress.number,
        complement: targetAddress.complement,
        neighborhood: targetAddress.neighborhood,
        city: targetAddress.city,
        state: targetAddress.state,
        countryCode: targetAddress.countryCode,
        zipCode: targetAddress.zipCode,
        addressType: targetAddress.addressType,
        label: targetAddress.label,
        latitude: targetAddress.latitude,
        longitude: targetAddress.longitude,
        createdAt: targetAddress.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await _repository.saveAddress(updatedAddress);

      return switch (result) {
        Success() => () async {
          await _demoteOtherPrimaryAddresses(addressId);
          emit(
            state.copyWith(
              status: AddressStatus.success,
              clearTemporaryPrimary: true,
              clearError: true,
            ),
          );
          return true;
        }(),
        Error(:final failure) => () {
          emit(
            state.copyWith(
              status: AddressStatus.error,
              errorMessage:
                  'Erro ao alterar endereço principal: ${failure.message}',
            ),
          );
          return false;
        }(),
      };
    } catch (e) {
      emit(
        state.copyWith(
          status: AddressStatus.error,
          errorMessage: 'Erro ao alterar endereço principal: $e',
        ),
      );
      return false;
    }
  }

  /// Desmarca todos os outros endereços como principal
  /// Executado em background após marcar um novo endereço como principal
  Future<void> _demoteOtherPrimaryAddresses(String newPrimaryId) async {
    try {
      // Encontra endereços que são principais mas não são o novo principal
      final otherPrimaryAddresses = state.addresses.where((addr) {
        return addr.isPrimary && addr.addressId != newPrimaryId;
      }).toList();

      // Desmarca cada um
      for (final address in otherPrimaryAddresses) {
        final demotedAddress = Address(
          addressId: address.addressId,
          userId: address.userId,
          isPrimary: false, // Desmarca
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
          updatedAt: DateTime.now(),
        );

        await _repository.saveAddress(demotedAddress);
      }

      // Recarrega a lista para refletir mudanças
      await refresh();
    } catch (e) {
      log('⚠️ Erro ao desmarcar outros endereços principais: $e');
      // Não emite erro pois a operação principal já foi bem-sucedida
      // Apenas recarrega a lista
      await refresh();
    }
  }
}
