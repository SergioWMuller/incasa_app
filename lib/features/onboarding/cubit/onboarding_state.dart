import 'package:equatable/equatable.dart';

enum OnboardingStep { emailVerification, phoneVerification, cpfRegistration }

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
  ];
}
