import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/design/chat_message.dart';
import 'package:incasa_app/domain/entities/design/chat_thread.dart';
import 'package:incasa_app/domain/entities/design/order_agreement.dart';

enum ChatStatus { loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatThread> threads;
  final ChatThread? openThread;
  final List<ChatMessage> messages;
  final OrderAgreement? agreement;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.loading,
    this.threads = const [],
    this.openThread,
    this.messages = const [],
    this.agreement,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    status,
    threads,
    openThread,
    messages,
    agreement,
    errorMessage,
  ];

  ChatState copyWith({
    ChatStatus? status,
    List<ChatThread>? threads,
    ChatThread? openThread,
    List<ChatMessage>? messages,
    OrderAgreement? agreement,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      threads: threads ?? this.threads,
      openThread: openThread ?? this.openThread,
      messages: messages ?? this.messages,
      agreement: agreement ?? this.agreement,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
