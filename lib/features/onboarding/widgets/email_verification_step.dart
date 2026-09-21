import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_state.dart';
import 'package:incasa_app/features/onboarding/utils/onboarding_spacing.dart';

/// Etapa 2: confirmação visual do e-mail (já vem preenchido/verificado pelo
/// Firebase — ver CLAUDE.md, "auto-populado do Firebase").
class EmailVerificationStep extends StatelessWidget {
  const EmailVerificationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.all(context.onboardingPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              // Ícone
              Center(
                child: Container(
                  width: context.onboardingIconDiameter,
                  height: context.onboardingIconDiameter,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    state.emailVerified
                        ? Icons.check_circle
                        : Icons.email_outlined,
                    size: context.onboardingIconDiameter * 0.5,
                    color: state.emailVerified
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: context.onboardingSpacingLarge),

              // Título
              Center(
                child: Text(
                  state.emailVerified
                      ? 'Email Já Verificado !'
                      : 'Verifique seu Email',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              if (state.email != null) ...[
                SizedBox(height: context.onboardingSpacingMedium),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.onboardingSpacingMedium,
                      vertical: context.onboardingSpacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        context.onboardingBorderRadius,
                      ),
                    ),
                    child: Text(
                      state.email!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],

              // Mensagem de erro
              if (state.errorMessage != null) ...[
                SizedBox(height: context.onboardingSpacingMedium),
                Container(
                  padding: EdgeInsets.all(context.onboardingSpacingSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(
                      context.onboardingBorderRadius * 0.75,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: context.onboardingSmallIconSize,
                      ),
                      SizedBox(width: context.onboardingSpacingSmall),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                            fontSize: context.onboardingMessageFontSize,
                          ),
                        ),
                      ),
                      SizedBox(width: context.onboardingSpacingMedium),
                    ],
                  ),
                ),
              ],
              // Descrição
              Center(
                child: Text(
                  state.emailVerified
                      ? 'Show, seu email foi\nverificado pela Google !'
                      : 'Enviamos um link de verificação para o\nemail abaixo',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),


              const Spacer(),

              // Botões de ação
              if (!state.emailVerified) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () => context
                              .read<OnboardingCubit>()
                              .checkEmailVerification(),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: context.onboardingButtonPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          context.onboardingBorderRadius,
                        ),
                      ),
                    ),
                    child: state.isLoading
                        ? SizedBox(
                            height: context.onboardingSpinnerSize,
                            width: context.onboardingSpinnerSize,
                            child: CircularProgressIndicator(
                              strokeWidth: context.onboardingSpinnerSize * 0.1,
                            ),
                          )
                        : Text(
                            'Já Verifiquei',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: state.isLoading
                        ? null
                        : () => context
                              .read<OnboardingCubit>()
                              .sendEmailVerification(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Reenviar Email',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.read<OnboardingCubit>().nextStep(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
