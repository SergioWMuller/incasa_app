import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_state.dart';

class RegistrationView extends StatelessWidget {
  const RegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dados da Conta')),
      body: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          final email = state.email ?? 'usuario@email.com';

          final phoneNumber = state.phoneNumber;
          final hasPhone = phoneNumber != null && phoneNumber.isNotEmpty;

          final cpf = state.cpfMasked;
          final hasCpf = cpf != null && cpf.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                'Essas informações identificam sua conta na Incasa.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              _AccountInfoCard(
                icon: Icons.email_outlined,
                label: 'E-mail',
                value: email,
                badges: [
                  state.emailVerified
                      ? const _StatusBadge.verified('Verificado')
                      : const _StatusBadge.pending('Não verificado'),
                ],
              ),
              const SizedBox(height: 12),

              _AccountInfoCard(
                icon: Icons.phone_outlined,
                label: 'Telefone',
                value: hasPhone ? phoneNumber : 'Não cadastrado',
                badges: [
                  if (hasPhone && state.phoneVerified)
                    const _StatusBadge.verified('Verificado'),
                  if (hasPhone && state.isPhoneWhatsApp)
                    const _StatusBadge.info(
                      'WhatsApp',
                      icon: Icons.chat_bubble_outline,
                    ),
                  if (!hasPhone) const _StatusBadge.pending('Não cadastrado'),
                ],
              ),
              const SizedBox(height: 12),

              _AccountInfoCard(
                icon: Icons.badge_outlined,
                label: 'CPF',
                value: hasCpf ? cpf : 'Não cadastrado',
                badges: [
                  if (hasCpf)
                    const _StatusBadge.verified('Cadastrado')
                  else
                    const _StatusBadge.pending('Não cadastrado'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Widget> badges;

  const _AccountInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.badges = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (badges.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: badges),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _BadgeKind { verified, pending, info }

class _StatusBadge extends StatelessWidget {
  final _BadgeKind kind;
  final String label;
  final IconData icon;

  const _StatusBadge.verified(this.label)
    : kind = _BadgeKind.verified,
      icon = Icons.check_circle_outline;

  const _StatusBadge.pending(this.label)
    : kind = _BadgeKind.pending,
      icon = Icons.radio_button_unchecked;

  const _StatusBadge.info(this.label, {this.icon = Icons.info_outline})
    : kind = _BadgeKind.info;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color background;
    final Color foreground;
    switch (kind) {
      case _BadgeKind.verified:
        background = colorScheme.tertiaryContainer;
        foreground = colorScheme.onTertiaryContainer;
        break;
      case _BadgeKind.pending:
        background = colorScheme.surfaceContainerHighest;
        foreground = colorScheme.onSurfaceVariant;
        break;
      case _BadgeKind.info:
        background = colorScheme.secondaryContainer;
        foreground = colorScheme.onSecondaryContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
