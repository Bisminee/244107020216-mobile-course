import 'package:clean_notes/core/failures.dart';
import 'package:clean_notes/features/notes/domain/entities/note.dart';
import 'package:clean_notes/features/notes/domain/usecases/add_note.dart';
import 'package:clean_notes/features/notes/domain/usecases/delete_note.dart';
import 'package:clean_notes/features/notes/domain/usecases/sync_notes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'get_notes_test.dart';

void main() {
  group('AddNote', () {
    test('menolak judul kosong tanpa memanggil repository', () async {
      var called = false;
      final repo = _SpyNoteRepository(onAdd: () => called = true);

      final result = await AddNote(repo).call(title: '   ');

      expect(result.failure, isA<LocalFailure>());
      expect(result.failure!.message, contains('tidak boleh kosong'));
      expect(result.note, isNull);
      expect(called, isFalse);
    });

    test('memotong spasi lalu meneruskan ke repository', () async {
      final repo = FakeNoteRepository();

      final result = await AddNote(repo).call(title: '  Catatan  ', body: ' isi ');

      expect(result.failure, isNull);
      expect(result.note!.title, 'Catatan');
      expect(result.note!.body, 'isi');
    });
  });

  group('DeleteNote', () {
    test('menolak id tidak valid', () async {
      final result = await DeleteNote(FakeNoteRepository()).call(0);
      expect(result.failure, isA<LocalFailure>());
      expect(result.deleted, isFalse);
    });
  });

  group('SyncNotes', () {
    test('tidak melakukan apa-apa bila tidak ada catatan dirty', () async {
      final repo = FakeNoteRepository(items: [
        Note(title: 'A', updatedAt: DateTime(2026, 9, 27)),
      ]);

      final result = await SyncNotes(repo).call();

      expect(result.failure, isNull);
      expect(result.synced, 0);
    });

    test('melaporkan jumlah catatan yang tersinkron', () async {
      final repo = FakeNoteRepository(items: [
        Note(title: 'A', updatedAt: DateTime(2026, 9, 27), dirty: true),
        Note(title: 'B', updatedAt: DateTime(2026, 9, 27), dirty: true),
        Note(title: 'C', updatedAt: DateTime(2026, 9, 27)),
      ]);

      final result = await SyncNotes(repo).call();

      expect(result.failure, isNull);
      expect(result.synced, 2);
    });

    test('meneruskan failure dari repository', () async {
      final result = await SyncNotes(FakeNoteRepository(fail: true)).call();
      expect(result.failure, isA<LocalFailure>());
      expect(result.synced, 0);
    });
  });
}

/// Repository yang melacak apakah addNote dipanggil.
class _SpyNoteRepository extends FakeNoteRepository {
  _SpyNoteRepository({required this.onAdd});

  final void Function() onAdd;

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    onAdd();
    return super.addNote(title: title, body: body);
  }
}
