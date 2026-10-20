import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

/// Use case sinkronisasi: menghitung catatan dirty lalu menandainya bersih.
/// Di aplikasi nyata, di sinilah catatan dikirim ke server; pada codelab
/// ini server disimulasikan.
class SyncNotes {
  const SyncNotes(this._repository);
  final NoteRepository _repository;

  Future<({int synced, Failure? failure})> call() async {
    final dirty = await _repository.countDirty();
    if (dirty.failure != null) {
      return (synced: 0, failure: dirty.failure);
    }
    if (dirty.count == 0) {
      return (synced: 0, failure: null);
    }
    final result = await _repository.markAllSynced();
    if (result.failure != null) {
      return (synced: 0, failure: result.failure);
    }
    return (synced: dirty.count, failure: null);
  }
}
