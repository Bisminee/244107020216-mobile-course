import '../../../../core/failures.dart';
import '../entities/note.dart';

/// Kontrak (interface) repository yang dibutuhkan domain.
/// Hanya deklarasi, tanpa implementasi dan tanpa Flutter/Dio/SQLite.
abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();

  Future<({Note? note, Failure? failure})> fetchNote(int id);

  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  });

  Future<({bool deleted, Failure? failure})> deleteNote(int id);

  Future<({int count, Failure? failure})> countDirty();

  Future<({bool synced, Failure? failure})> markAllSynced();
}
