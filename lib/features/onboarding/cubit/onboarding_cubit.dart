import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:incasa_app/data/datasources/local/auth_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/user_supabase_data_source.dart';
import 'package:incasa_app/data/models/profile/user_model.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final UserSupabaseDataSource userSupabaseDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final User firebaseUser;
  final PageController pageController;

  OnboardingCubit({
    required this.userSupabaseDataSource,
    required this.authLocalDataSource,
    required this.firebaseUser,
  }) : pageController = PageController(),
       super(
         OnboardingState(
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
            cpf: userData['cpf'] as String?,
          ),
        );
      }
    } catch (e) {
      // Ignora erros ao carregar dados - apenas não atualiza o estado
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  /// Avança para a próxima etapa
  void nextStep() {
    switch (state.currentStep) {
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
      case OnboardingStep.emailVerification:
        // Primeira etapa - não faz nada
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

            // Atualiza no Supabase primeiro
            await _updatePhoneInSupabase(
              updatedUser.phoneNumber!,
              verified: true,
              isWhatsApp: state.isPhoneWhatsApp,
            );

            // Depois atualiza no SharedPreferences
            await _updatePhoneInSharedPreferences(
              updatedUser.phoneNumber!,
              verified: true,
              isWhatsApp: state.isPhoneWhatsApp,
            );

            emit(
              state.copyWith(
                isLoading: false,
                phoneVerified: true,
                phoneNumber: updatedUser.phoneNumber,
              ),
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
                'Verificação por SMS indisponível. Você pode pular esta etapa.';
          } else if (e.message?.contains('not allowed') == true) {
            errorMsg =
                'Verificação por SMS não configurada. Você pode pular esta etapa.';
          } else {
            errorMsg = 'Erro ao enviar SMS. Você pode pular esta etapa.';
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

      // 1. Primeiro atualiza no Supabase (phone_verified = true)
      await _updatePhoneInSupabase(
        updatedUser.phoneNumber!,
        verified: true,
        isWhatsApp: state.isPhoneWhatsApp,
      );

      // 2. Depois atualiza no SharedPreferences
      await _updatePhoneInSharedPreferences(
        updatedUser.phoneNumber!,
        verified: true,
        isWhatsApp: state.isPhoneWhatsApp,
      );

      emit(
        state.copyWith(
          isLoading: false,
          phoneVerified: true,
          phoneNumber: updatedUser.phoneNumber,
          errorMessage: null,
        ),
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

  /// Salva telefone sem verificação (modo padrão)
  Future<void> savePhoneWithoutVerification(String phoneNumber) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final formattedPhone = '+55$phoneNumber';

      // Salva no Supabase com phoneVerified = false
      await _updatePhoneInSupabase(
        formattedPhone,
        verified: false,
        isWhatsApp: state.isPhoneWhatsApp,
      );

      // Salva no SharedPreferences
      await _updatePhoneInSharedPreferences(
        formattedPhone,
        verified: false,
        isWhatsApp: state.isPhoneWhatsApp,
      );

      emit(
        state.copyWith(
          isLoading: false,
          phoneNumber: formattedPhone,
          phoneVerified: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao salvar telefone: $e',
        ),
      );
    }
  }

  /// Atualiza dados do telefone no Supabase
  Future<void> _updatePhoneInSupabase(
    String phoneNumber, {
    required bool verified,
    bool isWhatsApp = false,
  }) async {
    final existingUser = await userSupabaseDataSource.getUserByUid(
      firebaseUser.uid,
    );

    if (existingUser != null) {
      final updatedUser = UserModel(
        uid: existingUser.uid,
        email: existingUser.email,
        fullName: existingUser.fullName,
        displayName: existingUser.displayName,
        photoUrl: existingUser.photoUrl,
        phoneNumber: phoneNumber,
        phoneVerified: verified,
        isPhoneWhatsApp: isWhatsApp,
        emailVerified: existingUser.emailVerified,
        cpf: existingUser.cpf,
        createdAt: existingUser.createdAt,
        lastSignInTime: DateTime.now(),
      );

      await userSupabaseDataSource.updateUser(firebaseUser.uid, updatedUser);
    }
  }

  /// Atualiza dados do telefone no SharedPreferences
  Future<void> _updatePhoneInSharedPreferences(
    String phoneNumber, {
    required bool verified,
    bool isWhatsApp = false,
  }) async {
    try {
      final userData = await authLocalDataSource.getUserData();

      if (userData != null) {
        userData['phoneNumber'] = phoneNumber;
        userData['phoneVerified'] = verified;
        userData['isPhoneWhatsApp'] = isWhatsApp;

        await authLocalDataSource.saveUserData(userData);
      }
    } catch (e) {
      // Falha silenciosa - não bloqueia o fluxo
    }
  }

  /// Salva o CPF no Supabase
  Future<void> saveCpf(String cpf) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null, cpf: cpf));

      // Busca usuário atual do Supabase
      final existingUser = await userSupabaseDataSource.getUserByUid(
        firebaseUser.uid,
      );

      if (existingUser != null) {
        // Atualiza com o CPF
        final updatedUser = UserModel(
          uid: existingUser.uid,
          email: existingUser.email,
          fullName: existingUser.fullName,
          displayName: existingUser.displayName,
          photoUrl: existingUser.photoUrl,
          phoneNumber: state.phoneNumber ?? existingUser.phoneNumber,
          emailVerified: state.emailVerified,
          phoneVerified: state.phoneVerified,
          isPhoneWhatsApp:
              state.isPhoneWhatsApp || existingUser.isPhoneWhatsApp,
          cpf: cpf,
          createdAt: existingUser.createdAt,
          lastSignInTime: DateTime.now(),
        );

        await userSupabaseDataSource.updateUser(firebaseUser.uid, updatedUser);

        emit(state.copyWith(isLoading: false, errorMessage: null));
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Usuário não encontrado no banco de dados.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao salvar CPF: $e',
        ),
      );
    }
  }
}
