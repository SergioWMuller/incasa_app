import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/data/datasources/local/design_mock_data_source.dart';
import 'package:incasa_app/domain/entities/design/chat_message.dart';
import 'package:incasa_app/features/chat/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final DesignMockDataSource mockDataSource;

  ChatCubit({required this.mockDataSource}) : super(const ChatState());

  /// Carrega a lista de conversas mock
  void loadThreads() {
    emit(
      ChatState(
        status: ChatStatus.loaded,
        threads: mockDataSource.getChatThreads(),
      ),
    );
  }

  /// Abre uma conversa: carrega mensagens e o combinado fixado
  void openThread(String threadId) {
    final thread = state.threads.isEmpty
        ? mockDataSource.getChatThreads().first
        : state.threads.firstWhere(
            (t) => t.id == threadId,
            orElse: () => state.threads.first,
          );

    emit(
      state.copyWith(
        status: ChatStatus.loaded,
        threads: state.threads.isEmpty
            ? mockDataSource.getChatThreads()
            : state.threads,
        openThread: thread,
        messages: mockDataSource.getMessages(threadId),
        agreement: mockDataSource.getAgreement(threadId),
      ),
    );
  }

  /// Envia uma mensagem na conversa aberta (só local, mock)
  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final message = ChatMessage(
      id: 'local-${state.messages.length + 1}',
      text: trimmed,
      isMine: true,
    );
    emit(state.copyWith(messages: [...state.messages, message]));
  }
}
