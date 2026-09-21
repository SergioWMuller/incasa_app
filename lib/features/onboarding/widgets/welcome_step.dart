import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:incasa_app/features/onboarding/utils/onboarding_spacing.dart';

/// Etapa 1 do onboarding: tela de transição, sem nenhum dado envolvido.
/// Avança só quando o usuário toca em "Continuar".
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(context.onboardingPadding),
      child: Column(
        children: [
          const Spacer(),

          // Ícone com entrada animada (scale + easeOutBack)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Container(
              width: context.onboardingIconDiameter * 1.2,
              height: context.onboardingIconDiameter * 1.2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.primaryColor, theme.colorScheme.tertiary],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.waving_hand_rounded,
                size: context.onboardingIconDiameter * 0.6,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: context.onboardingSpacingLarge),

          // Título e descrição com fade-in + slide sutil
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 12),
                child: child,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Perfeito!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.onboardingSpacingMedium),
                Text(
                  'Agora vamos informar só mais alguns\ndetalhes para completar seu cadastro.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.read<OnboardingCubit>().nextStep(),
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
              child: Text('Continuar', style: theme.textTheme.labelLarge),
            ),
          ),
          SizedBox(height: context.onboardingSpacingLarge),
        ],
      ),
    );
  }
}
