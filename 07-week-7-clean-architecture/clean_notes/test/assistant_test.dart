import 'package:clean_notes/core/failures.dart';
import 'package:clean_notes/features/assistant/domain/entities/chat_message.dart';
import 'package:clean_notes/features/assistant/domain/repositories/assistant_repository.dart';
import 'package:clean_notes/features/assistant/domain/usecases/ask_assistant.dart';
import 'package:clean_notes/features/assistant/presentation/providers/assistant_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAssistantRepository implements AssistantRepository {
  _FakeAssistantRepository({this.answer, this.failure});

  final String? answer;
  final Failure? failure;

  @override
  Future<({String? answer, Failure? failure})> ask(String question) async =>
      (answer: answer, failure: failure);

  @override
  Future<bool> hasApiKey() async => true;

  @override
  Future<void> saveApiKey(String key) async {}

  @override
  Future<void> clearApiKey() async {}
}

void main() {
  group('AskAssistant (validasi domain)', () {
    final repo = _FakeAssistantRepository(answer: 'Halo!');
    final useCase = AskAssistant(repo);

    test('menolak pertanyaan kosong tanpa memanggil repository', () async {
      final result = await useCase('   ');
      expect(result.failure, isA<LocalFailure>());
      expect(result.answer, isNull);
    });

    test('menolak pertanyaan lebih dari 500 karakter', () async {
      final result = await useCase('a' * 501);
      expect(result.failure, isA<LocalFailure>());
      expect(result.failure!.message, contains('500'));
    });

    test('meneruskan pertanyaan valid', () async {
      final result = await useCase('  Apa itu KRS?  ');
      expect(result.failure, isNull);
      expect(result.answer, 'Halo!');
    });
  });

  group('ChatNotifier', () {
    test('menambah pesan user + balasan asisten saat sukses', () async {
      final container = ProviderContainer(
        overrides: [
          assistantRepositoryProvider.overrideWithValue(
            _FakeAssistantRepository(answer: 'KRS adalah Kartu Rencana Studi.'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(chatProvider.notifier).ask('Apa itu KRS?');
      final state = container.read(chatProvider);

      expect(state.messages.length, 2);
      expect(state.messages.first.role, ChatRole.user);
      expect(state.messages.first.text, 'Apa itu KRS?');
      expect(state.messages.last.role, ChatRole.assistant);
      expect(state.messages.last.text, contains('Kartu Rencana Studi'));
      expect(state.error, isNull);
      expect(state.isSending, isFalse);
    });

    test('menyimpan error + pertanyaan terakhir untuk retry', () async {
      final container = ProviderContainer(
        overrides: [
          assistantRepositoryProvider.overrideWithValue(
            _FakeAssistantRepository(
              failure: const NetworkFailure('Layanan AI sibuk.'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(chatProvider.notifier).ask('Halo');
      final state = container.read(chatProvider);

      // Pesan user tetap tampil, error disimpan terpisah.
      expect(state.messages.length, 1);
      expect(state.error, 'Layanan AI sibuk.');
      expect(state.lastQuestion, 'Halo');
      expect(state.isSending, isFalse);
    });

    test('retry tidak menduplikasi pesan user (temuan review)', () async {
      final container = ProviderContainer(
        overrides: [
          assistantRepositoryProvider.overrideWithValue(
            _FakeAssistantRepository(
              failure: const NetworkFailure('Layanan AI sibuk.'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(chatProvider.notifier).ask('Halo');
      expect(container.read(chatProvider).messages.length, 1);

      await container.read(chatProvider.notifier).retry();

      final state = container.read(chatProvider);
      expect(state.messages.length, 1);
      expect(state.error, 'Layanan AI sibuk.');
    });
  });
}
