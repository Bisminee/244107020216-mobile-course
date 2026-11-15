import '../../../../core/failures.dart';
import '../repositories/assistant_repository.dart';

/// Use case: validasi pertanyaan sebelum dikirim (aturan bisnis).
class AskAssistant {
  const AskAssistant(this._repository);
  final AssistantRepository _repository;

  static const maxLength = 500;

  Future<({String? answer, Failure? failure})> call(String question) {
    final q = question.trim();
    if (q.isEmpty) {
      return Future.value((
        answer: null,
        failure: const LocalFailure('Pertanyaan tidak boleh kosong.'),
      ));
    }
    if (q.length > maxLength) {
      return Future.value((
        answer: null,
        failure: const LocalFailure(
          'Pertanyaan terlalu panjang (maksimal $maxLength karakter).',
        ),
      ));
    }
    return _repository.ask(q);
  }
}
