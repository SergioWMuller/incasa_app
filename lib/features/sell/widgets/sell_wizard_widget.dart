import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/sell/cubit/sell_cubit.dart';
import 'package:incasa_app/features/sell/cubit/sell_state.dart';
import 'package:incasa_app/features/sell/widgets/sell_published_widget.dart';
import 'package:incasa_app/features/sell/widgets/sell_step_four_widget.dart';
import 'package:incasa_app/features/sell/widgets/sell_step_one_widget.dart';
import 'package:incasa_app/features/sell/widgets/sell_step_three_widget.dart';
import 'package:incasa_app/features/sell/widgets/sell_step_two_widget.dart';

/// Wizard de anúncio (tela 03 do design_handoff_incasa), sem Scaffold próprio
/// para poder ser embutido em qualquer lugar (hoje: 3ª tab do Minha Loja).
///
/// Solicita as mesmas informações e validações da tela "Adicionar Produto",
/// distribuídas em 4 passos, e publica criando o produto de verdade.
class SellWizardWidget extends StatefulWidget {
  const SellWizardWidget({super.key});

  @override
  State<SellWizardWidget> createState() => _SellWizardWidgetState();
}

class _SellWizardWidgetState extends State<SellWizardWidget> {
  final _formKeyStepOne = GlobalKey<FormState>();
  final _formKeyStepTwo = GlobalKey<FormState>();

  bool _validateCurrentStep(int step) {
    switch (step) {
      case 1:
        return _formKeyStepOne.currentState?.validate() ?? true;
      case 2:
        return _formKeyStepTwo.currentState?.validate() ?? true;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SellCubit, SellState>(
      bloc: sl<SellCubit>(),
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${state.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      child: BlocBuilder<SellCubit, SellState>(
        bloc: sl<SellCubit>(),
        builder: (context, state) {
          if (state.published) {
            return const SellPublishedWidget();
          }

          return Column(
            children: [
              // Header do wizard: voltar + título + "passo X de 4"
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: state.currentStep > 1
                          ? () => sl<SellCubit>().previousStep()
                          : null,
                    ),
                    Text(
                      'Anunciar',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'passo ${state.currentStep} de ${SellState.totalSteps}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 6,
                  ),
                ),
              ),
              Expanded(
                child: switch (state.currentStep) {
                  1 => SellStepOneWidget(
                    state: state,
                    formKey: _formKeyStepOne,
                  ),
                  2 => SellStepTwoWidget(
                    state: state,
                    formKey: _formKeyStepTwo,
                  ),
                  3 => SellStepThreeWidget(state: state),
                  _ => SellStepFourWidget(state: state),
                },
              ),
              // Botão fixo Continuar / Publicar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state.isPublishing
                          ? null
                          : () {
                              if (!_validateCurrentStep(state.currentStep)) {
                                return;
                              }
                              if (state.currentStep < SellState.totalSteps) {
                                sl<SellCubit>().nextStep();
                              } else {
                                sl<SellCubit>().publish();
                              }
                            },
                      child: state.isPublishing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              state.currentStep < SellState.totalSteps
                                  ? 'Continuar →'
                                  : 'Publicar anúncio',
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
