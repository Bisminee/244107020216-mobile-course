import 'package:clean_notes/core/failures.dart';
import 'package:clean_notes/features/notes/domain/entities/note.dart';
import 'package:clean_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:clean_notes/features/notes/domain/usecases/get_notes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repository palsu: mengimplementasikan kontrak domain, tanpa SQLite.
class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.items = const [], this.fail = false});

  final List<Note> items;
  final bool fail;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('db locked (simulasi)'),
      );
    }
    return (notes: items, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> fetchNote(int id) async {
    for (final note in items) {
      if (note.id == id) return (note: note, failure: null);
    }
    return (note: null, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    if (fail) {
      return (note: null, failure: const LocalFailure('gagal simpan'));
    }
    final note = Note(
      id: items.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime(2026, 9, 27),
      dirty: true,
    );
    return (note: note, failure: null);
  }

  @override
  Future<({bool deleted, Failure? failure})> deleteNote(int id) async {
    if (fail) return (deleted: false, failure: const LocalFailure('gagal hapus'));
    return (deleted: true, failure: null);
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    if (fail) return (count: 0, failure: const LocalFailure('gagal hitung'));
    return (count: items.where((n) => n.dirty).length, failure: null);
  }

  @override
  Future<({bool synced, Failure? failure})> markAllSynced() async {
    if (fail) return (synced: false, failure: const LocalFailure('gagal sync'));
    return (synced: true, failure: null);
  }
}

void main() {
  test('GetNotes meneruskan daftar dari repository', () async {
    final repo = FakeNoteRepository(items: [
      Note(title: 'A', updatedAt: DateTime(2026, 9, 27)),
    ]);
    final result = await GetNotes(repo).call();
    expect(result.failure, isNull);
    expect(result.notes.length, 1);
    expect(result.notes.first.title, 'A');
  });

  test('GetNotes meneruskan failure tanpa melempar', () async {
    final repo = FakeNoteRepository(fail: true);
    final result = await GetNotes(repo).call();
    expect(result.failure, isA<LocalFailure>());
    expect(result.notes, isEmpty);
  });
}
