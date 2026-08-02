import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/widgets/design/design_avatar_widget.dart';
import 'package:incasa_app/features/chat/cubit/chat_cubit.dart';
import 'package:incasa_app/features/chat/cubit/chat_state.dart';
import 'package:incasa_app/features/chat/widgets/chat_agreement_widget.dart';
import 'package:incasa_app/features/chat/widgets/chat_input_bar_widget.dart';
import 'package:incasa_app/features/chat/widgets/chat_message_bubble_widget.dart';

/// Conversa + combinado fixado — tela 05 do design_handoff_incasa
class ChatConversationView extends StatelessWidget {
  const ChatConversationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ChatCubit, ChatState>(
      bloc: sl<ChatCubit>(),
      builder: (context, state) {
        final thread = state.openThread;

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: [
                DesignAvatarWidget(name: thread?.sellerName ?? '?', size: 36),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread?.sellerName ?? '',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (thread != null)
                      Text(
                        thread.isOnline ? '● online' : 'offline',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: thread.isOnline
                              ? Colors.green
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              if (state.agreement != null)
                ChatAgreementWidget(agreement: state.agreement!),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) =>
                      ChatMessageBubbleWidget(message: state.messages[index]),
                ),
              ),
              const ChatInputBarWidget(),
            ],
          ),
        );
      },
    );
  }
}
