import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/notes_database.dart';
import '../models/note_model.dart';

/// Implementasi kontrak NoteRepository memakai SQLite.
/// Tepatnya kelas ini yang boleh tahu soal database.
class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDatabase;

  final Future<Database> Function() _openDb;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      final db = await _openDb();
      final rows = await db.query('notes', orderBy: 'updated_at DESC');
      final notes =
          rows.map((row) => NoteModel.fromMap(row).toEntity()).toList();
      return (notes: notes, failure: null);
    } catch (e) {
      return (
        notes: const <Note>[],
        failure: LocalFailure('Gagal membaca catatan: $e'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> fetchNote(int id) async {
    try {
      final db = await _openDb();
      final rows = await db.query('notes', where: 'id = ?', whereArgs: [id]);
      if (rows.isEmpty) {
        return (note: null, failure: null);
      }
      return (note: NoteModel.fromMap(rows.first).toEntity(), failure: null);
    } catch (e) {
      return (note: null, failure: LocalFailure('Gagal memuat catatan: $e'));
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    try {
      final db = await _openDb();
      final now = DateTime.now();
      final model = NoteModel(
        title: title,
        body: body,
        updatedAt: now,
        dirty: true,
      );
      final id = await db.insert('notes', model.toMap());
      return (note: model.copyWith(id: id), failure: null);
    } catch (e) {
      return (note: null, failure: LocalFailure('Gagal menyimpan catatan: $e'));
    }
  }

  @override
  Future<({bool deleted, Failure? failure})> deleteNote(int id) async {
    try {
      final db = await _openDb();
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
      return (deleted: true, failure: null);
    } catch (e) {
      return (deleted: false, failure: LocalFailure('Gagal menghapus: $e'));
    }
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    try {
      final db = await _openDb();
      final rows =
          await db.rawQuery('SELECT COUNT(*) AS c FROM notes WHERE dirty = 1');
      return (count: (rows.first['c'] as num?)?.toInt() ?? 0, failure: null);
    } catch (e) {
      return (count: 0, failure: LocalFailure('Gagal menghitung antrean: $e'));
    }
  }

  @override
  Future<({bool synced, Failure? failure})> markAllSynced() async {
    try {
      final db = await _openDb();
      await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
      return (synced: true, failure: null);
    } catch (e) {
      return (synced: false, failure: LocalFailure('Gagal sinkronisasi: $e'));
    }
  }
}
