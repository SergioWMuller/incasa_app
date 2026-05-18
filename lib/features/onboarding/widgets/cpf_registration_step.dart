import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/address/cubit/address_cubit.dart';
import 'package:incasa_app/features/address/view/address_view.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_state.dart';

class CpfRegistrationStep extends StatefulWidget {
  const CpfRegistrationStep({super.key});

  @override
  State<CpfRegistrationStep> createState() => _CpfRegistrationStepState();
}

class _CpfRegistrationStepState extends State<CpfRegistrationStep> {
  final _cpfController = TextEditingController();

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  String _formatCpf(String text) {
    // Remove tudo que não é número
    final numbers = text.replaceAll(RegExp(r'[^\d]'), '');

    // Aplica a máscara XXX.XXX.XXX-XX
    if (numbers.length <= 3) {
      return numbers;
    } else if (numbers.length <= 6) {
      return '${numbers.substring(0, 3)}.${numbers.substring(3)}';
    } else if (numbers.length <= 9) {
      return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6)}';
    } else {
      return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6, 9)}-${numbers.substring(9, numbers.length > 11 ? 11 : numbers.length)}';
    }
  }

  bool _isValidCpf(String cpf) {
    final numbers = cpf.replaceAll(RegExp(r'[^\d]'), '');
    return numbers.length == 11;
  }

  void _saveCpf(BuildContext context) {
    final cpf = _cpfController.text.trim();

    if (!_isValidCpf(cpf)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Digite um CPF válido')));
      return;
    }

    // Remove a formatação antes de salvar
    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    context.read<OnboardingCubit>().saveCpf(cleanCpf);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        // Se o CPF foi salvo com sucesso, navega para cadastro de endereço
        if (state.cpf != null &&
            !state.isLoading &&
            state.errorMessage == null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => sl<AddressCubit>()..initialize(),
                child: const AddressView(),
              ),
            ),
          ).then((addressSaved) {
            // Após retornar da tela de endereço, fecha o onboarding
            if (context.mounted) {
              Navigator.of(context).pop(addressSaved ?? true);
            }
          });
        }
      },
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                // Ícone
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.badge_outlined,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Título
                Center(
                  child: Text(
                    'Complete seu Cadastro',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Descrição
                Center(
                  child: Text(
                    'Para finalizar, precisamos do seu CPF para\ngarantir a segurança das suas transações',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),

                // Campo de CPF
                TextField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'CPF',
                    hintText: '000.000.000-00',
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final formatted = _formatCpf(newValue.text);
                      return TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }),
                  ],
                ),

                // Mensagem informativa
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Seus dados estão protegidos e seguros',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

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

                const Spacer(),

                // Botão de ação
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : () => _saveCpf(context),
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
                        : const Text(
                            'Finalizar',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                // Botão de pular
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: state.isLoading
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Pular por Agora'),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
