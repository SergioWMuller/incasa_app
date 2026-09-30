import 'package:equatable/equatable.dart';

enum OnboardingStep {
  welcome,
  emailVerification,
  phoneVerification,
  cpfRegistration,
}

class OnboardingState extends Equatable {
  final OnboardingStep currentStep;
  final bool isLoading;
  final String? errorMessage;
  final String? email;
  final String? phoneNumber;
  final String? cpf;
  final bool emailVerified;
  final bool phoneVerified;
  final bool isPhoneWhatsApp;
  final String? verificationId; // ID da verificação do Firebase Phone Auth
  final int? resendToken; // Permite reenviar o SMS sem novo reCAPTCHA
  final bool phoneCodeSent; // SMS enviado; aguardando o código do usuário
  final bool phoneSaved;
  final bool cpfSaved;

  /// CPF já mascarado (ex.: `12*.***.***-11`), buscado via RPC
  /// `get_user_cpf_masked`. `null` = ainda não carregado ou usuário sem CPF.
  final String? cpfMasked;

  const OnboardingState({
    this.currentStep = OnboardingStep.emailVerification,
    this.isLoading = false,
    this.errorMessage,
    this.email,
    this.phoneNumber,
    this.cpf,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.isPhoneWhatsApp = false,
    this.verificationId,
    this.resendToken,
    this.phoneCodeSent = false,
    this.phoneSaved = false,
    this.cpfSaved = false,
    this.cpfMasked,
  });

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    bool? isLoading,
    String? errorMessage,
    String? email,
    String? phoneNumber,
    String? cpf,
    bool? emailVerified,
    bool? phoneVerified,
    bool? isPhoneWhatsApp,
    String? verificationId,
    int? resendToken,
    bool? phoneCodeSent,
    bool? phoneSaved,
    bool? cpfSaved,
    String? cpfMasked,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      cpf: cpf ?? this.cpf,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      isPhoneWhatsApp: isPhoneWhatsApp ?? this.isPhoneWhatsApp,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      phoneCodeSent: phoneCodeSent ?? this.phoneCodeSent,
      phoneSaved: phoneSaved ?? this.phoneSaved,
      cpfSaved: cpfSaved ?? this.cpfSaved,
      cpfMasked: cpfMasked ?? this.cpfMasked,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    isLoading,
    errorMessage,
    email,
    phoneNumber,
    cpf,
    emailVerified,
    phoneVerified,
    isPhoneWhatsApp,
    verificationId,
    resendToken,
    phoneCodeSent,
    phoneSaved,
    cpfSaved,
    cpfMasked,
  ];
}
