import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/widgets/design/design_avatar_widget.dart';
import 'package:incasa_app/core/widgets/design/design_format.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/domain/entities/design/home_product.dart';
import 'package:incasa_app/features/chat/cubit/chat_cubit.dart';
import 'package:incasa_app/features/chat/view/chat_conversation_view.dart';
import 'package:incasa_app/features/checkout/cubit/pix_cubit.dart';
import 'package:incasa_app/features/checkout/cubit/pix_state.dart';

/// Bottom sheet de pagamento Pix — tela 04 do design_handoff_incasa
class PixSheetWidget extends StatelessWidget {
  const PixSheetWidget({super.key});

  /// Abre o sheet com um PixCubit próprio (factory) já iniciado
  static Future<void> show(BuildContext context, HomeProduct product) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => sl<PixCubit>()..start(product),
        child: const PixSheetWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<PixCubit, PixState>(
      listenWhen: (previous, current) =>
          previous.status != current.status && current.status == PixStatus.pago,
      listener: (context, state) {
        // "Já paguei" → fecha o sheet e abre o chat com o combinado pago
        final navigator = Navigator.of(context);
        navigator.pop();
        sl<ChatCubit>().openThread('thread-bel');
        navigator.push(
          MaterialPageRoute(builder: (_) => const ChatConversationView()),
        );
      },
      builder: (context, state) {
        final product = state.product;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pague com Pix',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Escaneie ou copie o código · expira em '
                  '${DesignFormat.countdown(state.remainingSeconds)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                // QR code placeholder
                NeumorphicSurface(
                  constraints: const BoxConstraints.tightFor(
                    width: 150,
                    height: 150,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Icon(
                    Icons.qr_code_2,
                    size: 120,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                // Código copia-e-cola
                NeumorphicSurface(
                  onTap: () => context.read<PixCubit>().copyCode(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.charge?.code ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        Icon(
                          state.codeCopied ? Icons.check : Icons.copy,
                          size: 18,
                          color: state.codeCopied
                              ? Colors.green
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (product != null)
                  Row(
                    children: [
                      DesignAvatarWidget(name: product.sellerName, size: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              product.sellerName,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DesignFormat.price(product.price),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                // Banner do combinado
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Retirada combinada: hoje até 18h',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.read<PixCubit>().confirmPaid(),
                    child: const Text('Já paguei'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
