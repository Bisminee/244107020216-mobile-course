import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Use case dengan aturan bisnis: judul tidak boleh kosong.
/// Validasi seperti ini alasan mengapa use case layak ada, bukan
/// sekadar meneruskan parameter ke repository.
class AddNote {
  const AddNote(this._repository);
  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call({
    required String title,
    String body = '',
  }) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return Future.value((
        note: null,
        failure: const LocalFailure('Judul catatan tidak boleh kosong.'),
      ));
    }
    return _repository.addNote(title: trimmed, body: body.trim());
  }
}
