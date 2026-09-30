import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_state.dart';
import 'package:incasa_app/features/onboarding/utils/onboarding_spacing.dart';
import 'package:incasa_app/features/onboarding/widgets/welcome_step.dart';
import 'package:incasa_app/features/onboarding/widgets/email_verification_step.dart';
import 'package:incasa_app/features/onboarding/widgets/phone_verification_step.dart';
import 'package:incasa_app/features/onboarding/widgets/cpf_registration_step.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Indicador de progresso
            _ProgressIndicator(),

            // Conteúdo das etapas
            Expanded(
              child: PageView(
                controller: cubit.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  WelcomeStep(),
                  EmailVerificationStep(),
                  PhoneVerificationStep(),
                  CpfRegistrationStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final currentIndex = OnboardingStep.values.indexOf(state.currentStep);
        final totalSteps = OnboardingStep.values.length;

        return Container(
          padding: EdgeInsets.all(context.onboardingPadding),
          child: Column(
            children: [
              // Título e subtítulo
              Row(
                children: [
                  const Spacer(),
                  Text(
                    'Etapa ${currentIndex + 1} de $totalSteps',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.onboardingSpacingMedium),

              // Barra de progresso
              Row(
                children: List.generate(totalSteps, (index) {
                  final isCompleted = index < currentIndex;
                  final isCurrent = index == currentIndex;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        left: index == 0
                            ? 0
                            : context.onboardingSpacingSmall / 2,
                        right: index == totalSteps - 1
                            ? 0
                            : context.onboardingSpacingSmall / 2,
                      ),
                      height: context.onboardingIndicatorHeight,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? Theme.of(context).primaryColor
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          context.onboardingBorderRadius * 0.25,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
