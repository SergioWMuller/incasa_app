import 'package:equatable/equatable.dart';

/// Conversa da lista do tab Chat (design handoff).
class ChatThread extends Equatable {
  final String id;
  final String sellerId;
  final String sellerName;
  final String lastMessage;
  final String timeLabel;
  final bool isOnline;

  const ChatThread({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.lastMessage,
    required this.timeLabel,
    required this.isOnline,
  });

  @override
  List<Object?> get props => [
    id,
    sellerId,
    sellerName,
    lastMessage,
    timeLabel,
    isOnline,
  ];
}
