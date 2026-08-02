import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/widgets/design/design_avatar_widget.dart';
import 'package:incasa_app/features/chat/cubit/chat_cubit.dart';
import 'package:incasa_app/features/chat/cubit/chat_state.dart';
import 'package:incasa_app/features/chat/view/chat_conversation_view.dart';

/// View do Chat (tab) — lista de conversas mock; a tela 05 do handoff
/// é a conversa aberta (ChatConversationView)
class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ChatCubit, ChatState>(
        bloc: sl<ChatCubit>(),
        builder: (context, state) {
          return switch (state.status) {
            ChatStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            ChatStatus.error => Center(
              child: Text(state.errorMessage ?? 'Erro ao carregar'),
            ),
            ChatStatus.loaded => ListView.separated(
              itemCount: state.threads.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final thread = state.threads[index];
                return ListTile(
                  leading: DesignAvatarWidget(name: thread.sellerName, size: 44),
                  title: Text(thread.sellerName),
                  subtitle: Text(
                    thread.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    thread.timeLabel,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  onTap: () {
                    sl<ChatCubit>().openThread(thread.id);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChatConversationView(),
                      ),
                    );
                  },
                );
              },
            ),
          };
        },
      ),
    );
  }
}
