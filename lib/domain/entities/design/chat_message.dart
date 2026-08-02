import 'package:equatable/equatable.dart';

/// Mensagem da conversa (tela 05 do design handoff).
class ChatMessage extends Equatable {
  final String id;
  final String text;
  final bool isMine;

  const ChatMessage({required this.id, required this.text, required this.isMine});

  @override
  List<Object?> get props => [id, text, isMine];
}
