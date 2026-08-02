import 'package:flutter/material.dart';
import 'package:incasa_app/core/widgets/design/design_format.dart';
import 'package:incasa_app/domain/entities/design/order_agreement.dart';

/// Bloco do "combinado" fixado no topo da conversa (tela 05 do handoff)
class ChatAgreementWidget extends StatelessWidget {
  final OrderAgreement agreement;

  const ChatAgreementWidget({super.key, required this.agreement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${agreement.productName} · '
                  '${DesignFormat.price(agreement.price)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              if (agreement.paid)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pago ✓',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'LOCAL · ${agreement.placeLabel}     ${agreement.timeLabel}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Ver combinado / alterar'),
          ),
        ],
      ),
    );
  }
}
