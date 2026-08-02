import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/address/cubit/address_cubit.dart';
import 'package:incasa_app/features/address/view/address_view.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_state.dart';
import 'package:incasa_app/features/onboarding/widgets/cpf_field.dart';

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

  void _saveCpf(BuildContext context) {
    final cpf = _cpfController.text.trim();

    if (!CpfValidator.isValid(cpf)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Digite um CPF válido')));
      return;
    }

    context.read<OnboardingCubit>().saveCpf(CpfValidator.strip(cpf));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.currentStep == OnboardingStep.cpfRegistration &&
            state.cpfSaved) {
          final cubit = context.read<OnboardingCubit>();
          cubit.clearCpfSaved();

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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

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
                CpfField(controller: _cpfController),

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

                const SizedBox(height: 32),

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

                // (Botão 'Pular por Agora' removido)
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
