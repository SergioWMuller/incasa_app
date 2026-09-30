import 'package:flutter/material.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/features/chat/cubit/chat_cubit.dart';

/// Barra de digitação da conversa (tela 05 do handoff).
/// Stateful apenas pelo TextEditingController (plumbing de UI);
/// as mensagens vivem no ChatState.
class ChatInputBarWidget extends StatefulWidget {
  const ChatInputBarWidget({super.key});

  @override
  State<ChatInputBarWidget> createState() => _ChatInputBarWidgetState();
}

class _ChatInputBarWidgetState extends State<ChatInputBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    sl<ChatCubit>().sendMessage(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: NeumorphicSurface(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Mensagem…',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              icon: const Icon(Icons.arrow_upward),
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}
