import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_state.dart';

class PhoneVerificationStep extends StatefulWidget {
  const PhoneVerificationStep({super.key});

  @override
  State<PhoneVerificationStep> createState() => _PhoneVerificationStepState();
}

class _PhoneVerificationStepState extends State<PhoneVerificationStep> {
  static const _resendSeconds = 60;

  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  Timer? _resendTimer;
  int _secondsLeft = 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  void _sendCode(BuildContext context, {bool resend = false}) {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um número de telefone válido')),
      );
      return;
    }

    _codeController.clear();
    context.read<OnboardingCubit>().sendPhoneVerification(
      phone,
      resend: resend,
    );
  }

  void _verifyCode(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o código de 6 dígitos')),
      );
      return;
    }

    context.read<OnboardingCubit>().verifyPhoneCode(code);
  }

  void _changeNumber(BuildContext context) {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = 0);
    _codeController.clear();
    context.read<OnboardingCubit>().changePhoneNumber();
  }

  String _formattedPhone() {
    final d = _phoneController.text.trim();
    if (d.length < 10) return d;
    final ddd = d.substring(0, 2);
    final rest = d.substring(2);
    final split = rest.length - 4;
    return '($ddd) ${rest.substring(0, split)}-${rest.substring(split)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) =>
          previous.phoneCodeSent != current.phoneCodeSent ||
          previous.verificationId != current.verificationId ||
          previous.phoneSaved != current.phoneSaved,
      listener: (context, state) {
        // Novo SMS enviado (envio inicial ou reenvio): reinicia o cronômetro.
        if (state.phoneCodeSent && !state.phoneSaved) _startResendTimer();
        if (state.currentStep == OnboardingStep.phoneVerification &&
            state.phoneSaved) {
          // Pequeno delay para mostrar feedback visual
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              final cubit = context.read<OnboardingCubit>();
              cubit.clearPhoneSaved();
              cubit.nextStep();
            }
          });
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),

                  // Ícone
                  Center(
                    child: NeumorphicSurface(
                      constraints: const BoxConstraints.tightFor(
                        width: 80,
                        height: 80,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      child: Icon(
                        Icons.phone_android,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Título
                  Center(
                    child: Text(
                      'Seu Telefone\ncom WhatsApp',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descrição
                  Center(
                    child: Text(
                      state.phoneCodeSent
                          ? 'Enviamos um código de 6 dígitos por SMS para\n${_formattedPhone()}'
                          : "Informe seu número de telefone celular !\n(o mesmo utilizado no WhatsApp)",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (!state.phoneCodeSent) ...[
                    // Campo de telefone
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Telefone Celular',
                        hintText: '(11) 99999-9999',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Switch WhatsApp
                    NeumorphicSurface(
                      borderRadius: BorderRadius.circular(16),
                      child: SwitchListTile(
                        title: const Text('Este número é WhatsApp?'),
                        subtitle: Text(
                          'Confirme que este número é o seu número usado no WhatsApp',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: state.isPhoneWhatsApp,
                        onChanged: (value) {
                          context
                              .read<OnboardingCubit>()
                              .toggleIsPhoneWhatsApp();
                        },
                        secondary: Icon(
                          Icons.message,
                          color: state.isPhoneWhatsApp
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Campo do código SMS
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, letterSpacing: 8),
                      decoration: InputDecoration(
                        labelText: 'Código SMS',
                        hintText: '000000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onChanged: (value) {
                        if (value.length == 6 && !state.isLoading) {
                          _verifyCode(context);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: state.isLoading
                              ? null
                              : () => _changeNumber(context),
                          child: const Text('Alterar número'),
                        ),
                        TextButton(
                          onPressed: state.isLoading || _secondsLeft > 0
                              ? null
                              : () => _sendCode(context, resend: true),
                          child: Text(
                            _secondsLeft > 0
                                ? 'Reenviar em ${_secondsLeft}s'
                                : 'Reenviar código',
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Mensagem de erro
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => state.phoneCodeSent
                                ? _verifyCode(context)
                                : _sendCode(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              state.phoneCodeSent
                                  ? 'Verificar e Continuar'
                                  : 'Enviar código por SMS',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
