import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/assistant_api.dart';
import '../../data/datasources/assistant_key_store.dart';
import '../../data/repositories/assistant_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../../domain/usecases/ask_assistant.dart';

// ===== Data layer =====
final assistantKeyStoreProvider = Provider<AssistantKeyStore>(
  (ref) => AssistantKeyStore(),
);

final assistantApiProvider = Provider<AssistantApi>((ref) {
  return AssistantApi(keyStore: ref.watch(assistantKeyStoreProvider));
});

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  return AssistantRepositoryImpl(
    ref.watch(assistantApiProvider),
    ref.watch(assistantKeyStoreProvider),
  );
});

// ===== Domain layer =====
final askAssistantProvider = Provider<AskAssistant>((ref) {
  return AskAssistant(ref.watch(assistantRepositoryProvider));
});

/// Status apakah API key sudah tersimpan (untuk banner pengaturan).
final hasApiKeyProvider = FutureProvider<bool>((ref) {
  return ref.watch(assistantRepositoryProvider).hasApiKey();
});

// ===== Presentation layer =====
class ChatState {
  const ChatState({
    this.messages = const [],
    this.isSending = false,
    this.error,
    this.lastQuestion,
  });

  final List<ChatMessage> messages;
  final bool isSending;
  final String? error;
  final String? lastQuestion;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? error,
    String? lastQuestion,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
      lastQuestion: lastQuestion ?? this.lastQuestion,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  Future<void> ask(String question) async {
    final q = question.trim();
    if (q.isEmpty || state.isSending) return;
    await _send(q, appendUser: true);
  }

  /// Coba lagi pertanyaan terakhir setelah error TANPA menduplikasi
  /// pesan user di list (temuan review).
  Future<void> retry() async {
    final q = state.lastQuestion;
    if (q == null || state.isSending) return;
    state = state.copyWith(clearError: true);
    await _send(q, appendUser: false);
  }

  Future<void> _send(String q, {required bool appendUser}) async {
    final messages = appendUser
        ? [
            ...state.messages,
            ChatMessage(
              role: ChatRole.user,
              text: q,
              createdAt: DateTime.now(),
            ),
          ]
        : state.messages;

    state = ChatState(messages: messages, isSending: true, lastQuestion: q);

    final result = await ref.read(askAssistantProvider).call(q);

    if (result.failure != null) {
      state = state.copyWith(isSending: false, error: result.failure!.message);
      return;
    }

    final reply = ChatMessage(
      role: ChatRole.assistant,
      text: result.answer ?? '',
      createdAt: DateTime.now(),
    );
    state = ChatState(
      messages: [...state.messages, reply],
      isSending: false,
      lastQuestion: q,
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
