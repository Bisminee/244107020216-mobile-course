import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

/// Use case hapus:/rules bisnis "tidak boleh menghapus id yang tidak ada".
class DeleteNote {
  const DeleteNote(this._repository);
  final NoteRepository _repository;

  Future<({bool deleted, Failure? failure})> call(int id) {
    if (id <= 0) {
      return Future.value((
        deleted: false,
        failure: const LocalFailure('Id catatan tidak valid.'),
      ));
    }
    return _repository.deleteNote(id);
  }
}
