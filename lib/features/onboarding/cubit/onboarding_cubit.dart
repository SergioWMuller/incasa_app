import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:incasa_app/data/datasources/local/auth_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/phone_supabase_data_source.dart';
import 'package:incasa_app/data/datasources/remote/user_supabase_data_source.dart';
import 'package:incasa_app/data/models/profile/phone_model.dart';
import 'onboarding_state.dart';

/// Cubit do onboarding (4 etapas):
/// 0. **Boas-vindas** — tela de transição, sem dado nenhum envolvido.
/// 1. **E-mail** — já persistido em `providers` no login (Edge Function); aqui é
///    só confirmação visual via Firebase.
/// 2. **Telefone** — gravado na tabela `phones` (`PhoneSupabaseDataSource`).
/// 3. **CPF** — gravado via RPC `set_user_cpf` (só `cpf_hmac`/`cpf_encrypted`).
class OnboardingCubit extends Cubit<OnboardingState> {
  final UserSupabaseDataSource userSupabaseDataSource;
  final PhoneSupabaseDataSource phoneDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final User firebaseUser;
  final PageController pageController;

  OnboardingCubit({
    required this.userSupabaseDataSource,
    required this.phoneDataSource,
    required this.authLocalDataSource,
    required this.firebaseUser,
  }) : pageController = PageController(initialPage: OnboardingStep.welcome.index),
       super(
         OnboardingState(
           currentStep: OnboardingStep.welcome,
           email: firebaseUser.email,
           emailVerified: firebaseUser.emailVerified,
         ),
       ) {
    _loadUserData();
  }

  /// Carrega dados do usuário do SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final userData = await authLocalDataSource.getUserData();

      if (userData != null) {
        emit(
          state.copyWith(
            phoneNumber: userData['phoneNumber'] as String?,
            phoneVerified: userData['phoneVerified'] as bool? ?? false,
            phoneSaved: userData['phoneNumber'] != null,
            // Não guardamos o CPF (PII) localmente — apenas a flag de concluído.
            cpfSaved: userData['cpfSaved'] as bool? ?? false,
          ),
        );
      }
    } catch (e) {
      // Ignora erros ao carregar dados - apenas não atualiza o estado
      log('Erro ao carregar dados do usuário: $e');
    }
  }

  /// Avança para a próxima etapa
  void nextStep() {
    switch (state.currentStep) {
      case OnboardingStep.welcome:
        emit(
          state.copyWith(
            currentStep: OnboardingStep.emailVerification,
            errorMessage: null,
          ),
        );
        _animateToCurrentStep();
        break;
      case OnboardingStep.emailVerification:
        emit(
          state.copyWith(
            currentStep: OnboardingStep.phoneVerification,
            errorMessage: null,
          ),
        );
        _animateToCurrentStep();
        break;
      case OnboardingStep.phoneVerification:
        emit(
          state.copyWith(
            currentStep: OnboardingStep.cpfRegistration,
            errorMessage: null,
          ),
        );
        _animateToCurrentStep();
        break;
      case OnboardingStep.cpfRegistration:
        // Última etapa - não faz nada aqui
        break;
    }
  }

  /// Volta para a etapa anterior
  void previousStep() {
    switch (state.currentStep) {
      case OnboardingStep.welcome:
        // Primeira etapa - não faz nada
        break;
      case OnboardingStep.emailVerification:
        emit(
          state.copyWith(
            currentStep: OnboardingStep.welcome,
            errorMessage: null,
          ),
        );
        _animateToCurrentStep();
        break;
      case OnboardingStep.phoneVerification:
        emit(
          state.copyWith(
            currentStep: OnboardingStep.emailVerification,
            errorMessage: null,
          ),
        );
        _animateToCurrentStep();
        break;
      case OnboardingStep.cpfRegistration:
        emit(
          state.copyWith(
            currentStep: OnboardingStep.phoneVerification,
            errorMessage: null,
          ),
        );
        _animateToCurrentStep();
        break;
    }
  }

  /// Vai para uma etapa específica
  void goToStep(OnboardingStep step) {
    emit(state.copyWith(currentStep: step, errorMessage: null));
    _animateToCurrentStep();
  }

  /// Anima o PageController para a etapa atual
  void _animateToCurrentStep() {
    final index = OnboardingStep.values.indexOf(state.currentStep);
    if (pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }

  /// Envia código de verificação para o email
  Future<void> sendEmailVerification() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      await firebaseUser.sendEmailVerification();

      emit(state.copyWith(isLoading: false, errorMessage: null));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao enviar email de verificação: $e',
        ),
      );
    }
  }

  /// Verifica se o email foi verificado
  Future<void> checkEmailVerification() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      await firebaseUser.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser?.emailVerified == true) {
        emit(
          state.copyWith(
            isLoading: false,
            emailVerified: true,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage:
                'Email ainda não verificado. Verifique sua caixa de entrada.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao verificar email: $e',
        ),
      );
    }
  }

  /// Envia código de verificação SMS para o telefone
  Future<void> sendPhoneVerification(String phoneNumber) async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          errorMessage: null,
          phoneNumber: phoneNumber,
        ),
      );

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+55$phoneNumber', // Adiciona DDI do Brasil
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verificação (raro, acontece só em alguns dispositivos Android)
          try {
            await firebaseUser.linkWithCredential(credential);
            final updatedUser = FirebaseAuth.instance.currentUser!;

            await _persistPhone(
              updatedUser.phoneNumber!,
              verified: true,
            );
          } catch (e) {
            emit(
              state.copyWith(
                isLoading: false,
                errorMessage: 'Erro na verificação automática: $e',
              ),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMsg = 'Erro ao enviar SMS';

          if (e.code == 'invalid-phone-number') {
            errorMsg = 'Número de telefone inválido';
          } else if (e.code == 'too-many-requests') {
            errorMsg = 'Muitas tentativas. Tente novamente mais tarde.';
          } else if (e.code == 'quota-exceeded') {
            errorMsg = 'Cota de SMS excedida. Contate o suporte.';
          } else if (e.message?.contains('BILLING_NOT_ENABLED') == true) {
            errorMsg =
                'Verificação por SMS indisponível no momento. Tente novamente mais tarde.';
          } else if (e.message?.contains('not allowed') == true) {
            errorMsg =
                'Verificação por SMS não configurada. Tente outro método.';
          } else {
            errorMsg = 'Erro ao enviar SMS. Tente novamente.';
          }

          emit(state.copyWith(isLoading: false, errorMessage: errorMsg));
        },
        codeSent: (String verificationId, int? resendToken) {
          // Código enviado com sucesso - salva verificationId
          emit(
            state.copyWith(
              isLoading: false,
              verificationId: verificationId,
              errorMessage: null,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout - pode atualizar UI se necessário
          emit(state.copyWith(verificationId: verificationId));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage:
              'Erro ao enviar código SMS. Você pode pular esta etapa.',
        ),
      );
    }
  }

  /// Verifica o código SMS e vincula telefone à conta Google
  Future<void> verifyPhoneCode(String code) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      if (state.verificationId == null) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Erro: código de verificação não encontrado',
          ),
        );
        return;
      }

      // Cria credential com o código SMS
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: code,
      );

      // Vincula o telefone à conta Google existente (não faz login)
      final userCredential = await firebaseUser.linkWithCredential(credential);
      final updatedUser = userCredential.user!;

      await _persistPhone(
        updatedUser.phoneNumber!,
        verified: true,
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Código inválido';

      if (e.code == 'invalid-verification-code') {
        errorMsg = 'Código inválido. Verifique e tente novamente.';
      } else if (e.code == 'session-expired') {
        errorMsg = 'Código expirado. Solicite um novo código.';
      } else if (e.code == 'credential-already-in-use') {
        errorMsg = 'Este número já está vinculado a outra conta.';
      } else if (e.code == 'provider-already-linked') {
        errorMsg = 'Você já tem um telefone vinculado. Remova-o primeiro.';
      }

      emit(state.copyWith(isLoading: false, errorMessage: errorMsg));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao verificar código: $e',
        ),
      );
    }
  }

  /// Alterna o estado do isPhoneWhatsApp
  void toggleIsPhoneWhatsApp() {
    emit(state.copyWith(isPhoneWhatsApp: !state.isPhoneWhatsApp));
  }

  /// Limpa o flag de telefone salvo após navegação
  void clearPhoneSaved() {
    emit(state.copyWith(phoneSaved: false));
  }

  /// Limpa o flag de CPF salvo após navegação
  void clearCpfSaved() {
    emit(state.copyWith(cpfSaved: false));
  }

  /// Salva telefone sem verificação (modo padrão)
  Future<void> savePhoneWithoutVerification(String phoneNumber) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      await _persistPhone(phoneNumber, verified: false);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao salvar telefone: $e',
        ),
      );
    }
  }

  /// Fluxo único de persistência do telefone:
  /// 1) grava em `phones` (fonte de verdade) -> 2) cache local -> 3) sucesso.
  Future<void> _persistPhone(
    String phoneNumber, {
    required bool verified,
  }) async {
    final userId = await _resolveSupabaseUserId();
    final isWhatsApp = state.isPhoneWhatsApp;
    final parts = _splitBrazilianPhone(phoneNumber);

    // id/timestamps são ignorados por toInsert() (gerados pelo banco).
    final phone = PhoneModel(
      id: '',
      userId: userId,
      countryCode: parts.countryCode,
      areaCode: parts.areaCode,
      number: parts.number,
      isPrimary: true,
      hasWhatsapp: isWhatsApp,
      isVerified: verified,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final saved = await phoneDataSource.createPhone(phone);

    await _cachePhoneLocally(saved);

    emit(
      state.copyWith(
        isLoading: false,
        phoneNumber: saved.fullNumber ?? saved.number,
        phoneVerified: verified,
        isPhoneWhatsApp: isWhatsApp,
        phoneSaved: true,
        errorMessage: null,
      ),
    );
  }

  /// Quebra um número brasileiro em `country_code` / `area_code` / `number`
  /// para a tabela `phones`. Aceita entrada com ou sem DDI (`+55`).
  ({String countryCode, String? areaCode, String number}) _splitBrazilianPhone(
    String raw,
  ) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');

    // Remove o DDI 55 se vier incluso (ex.: +5511999998888).
    if (digits.length > 11 && digits.startsWith('55')) {
      digits = digits.substring(2);
    }

    // DDD (2) + número (8 ou 9 dígitos).
    if (digits.length >= 10) {
      return (
        countryCode: '55',
        areaCode: digits.substring(0, 2),
        number: digits.substring(2),
      );
    }

    return (countryCode: '55', areaCode: null, number: digits);
  }

  bool _isUuid(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(value);
  }

  /// Resolve o UUID (PK) do usuário no Supabase sem fallback por email.
  Future<String> _resolveSupabaseUserId() async {
    final userData = await authLocalDataSource.getUserData();
    final localId = userData?['id']?.toString();

    if (localId != null && _isUuid(localId)) {
      return localId;
    }

    if (_isUuid(firebaseUser.uid)) {
      return firebaseUser.uid;
    }

    throw Exception(
      'ID UUID do usuário não encontrado localmente. Faça login novamente para sincronizar o usuário com o Supabase.',
    );
  }

  /// Guarda no cache local apenas o necessário para reidratar a UI do
  /// onboarding (telefone formatado + flag WhatsApp). A fonte de verdade é a
  /// tabela `phones`.
  Future<void> _cachePhoneLocally(PhoneModel phone) async {
    final userData =
        await authLocalDataSource.getUserData() ?? <String, dynamic>{};

    userData['phoneNumber'] = phone.fullNumber ?? phone.number;
    userData['isPhoneWhatsApp'] = phone.hasWhatsapp;

    await authLocalDataSource.saveUserData(userData);
  }

  /// Marca o CPF como concluído localmente — **sem** guardar o CPF (PII).
  Future<void> _markCpfSavedLocally() async {
    final userData =
        await authLocalDataSource.getUserData() ?? <String, dynamic>{};
    userData['cpfSaved'] = true;
    await authLocalDataSource.saveUserData(userData);
  }

  /// Salva o CPF via RPC `set_user_cpf` (grava `cpf_hmac`/`cpf_encrypted`).
  Future<void> saveCpf(String cpf) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null, cpf: cpf));

      await userSupabaseDataSource.setUserCpf(cpf);

      await _markCpfSavedLocally();

      emit(state.copyWith(isLoading: false, errorMessage: null, cpfSaved: true));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao salvar CPF: $e',
        ),
      );
    }
  }

  /// Busca o CPF já cadastrado (campo `cpf_display`, gravado por
  /// `set_user_cpf` no momento do cadastro — 2 primeiros + 2 últimos
  /// dígitos). Usado pela tela "Configurações > Cadastro" para mostrar o
  /// status sem nunca decifrar/reexpor o CPF completo. Falha silenciosa: sem
  /// CPF/erro de rede, a tela só mostra "não cadastrado" em vez de travar.
  Future<void> loadCpfMasked() async {
    try {
      final user = await userSupabaseDataSource.getUserById(firebaseUser.uid);
      emit(state.copyWith(cpfMasked: user?.cpfDisplay));
    } catch (e) {
      log('Erro ao carregar CPF mascarado: $e');
    }
  }

  /// Busca o telefone principal já cadastrado (número + WhatsApp) direto da
  /// tabela `phones`. Usado pela tela "Configurações > Cadastro" — diferente
  /// do CPF, o telefone não é PII criptografada, então o número completo pode
  /// ser mostrado. Falha silenciosa: sem telefone/erro de rede, a tela só
  /// mostra o campo vazio em vez de travar.
  Future<void> loadPhoneStatus() async {
    try {
      final phones = await phoneDataSource.getPhones();
      if (phones.isEmpty) return;

      final primary = phones.firstWhere(
        (p) => p.isPrimary,
        orElse: () => phones.first,
      );

      emit(
        state.copyWith(
          phoneNumber: primary.fullNumber ?? primary.number,
          phoneVerified: primary.isVerified,
          isPhoneWhatsApp: primary.hasWhatsapp,
        ),
      );
    } catch (e) {
      log('Erro ao carregar telefone: $e');
    }
  }
}
