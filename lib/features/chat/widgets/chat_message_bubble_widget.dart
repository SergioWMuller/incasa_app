import 'package:flutter/material.dart';
import 'package:incasa_app/domain/entities/design/chat_message.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';

/// Bolha de mensagem (recebida à esquerda, enviada à direita)
class ChatMessageBubbleWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubbleWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMine = message.isMine;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: NeumorphicSurface(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        depth: 3,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMine ? 16 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 16),
        ),
        color: isMine ? theme.colorScheme.primaryContainer : null,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isMine
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
