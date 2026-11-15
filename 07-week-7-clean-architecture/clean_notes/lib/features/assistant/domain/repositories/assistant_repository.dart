import '../../../../core/failures.dart';

/// Kontrak repository Asisten AI.
abstract class AssistantRepository {
  /// Kirim pertanyaan ke layanan AI. Kegagalan dikembalikan sebagai Failure.
  Future<({String? answer, Failure? failure})> ask(String question);

  Future<bool> hasApiKey();
  Future<void> saveApiKey(String key);
  Future<void> clearApiKey();
}
