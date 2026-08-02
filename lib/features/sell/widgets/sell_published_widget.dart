import 'package:flutter/material.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/sell/cubit/sell_cubit.dart';

/// Confirmação de anúncio publicado
class SellPublishedWidget extends StatelessWidget {
  const SellPublishedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Anúncio publicado!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seus vizinhos já podem ver o que você faz.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => sl<SellCubit>().reset(),
              child: const Text('Criar novo anúncio'),
            ),
          ],
        ),
      ),
    );
  }
}
