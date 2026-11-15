import 'package:clean_notes/core/failures.dart';
import 'package:clean_notes/features/notes/domain/entities/note.dart';
import 'package:clean_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:clean_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:clean_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNoteRepository implements NoteRepository {
  _FakeNoteRepository(this.items);

  final List<Note> items;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async =>
      (notes: items, failure: null);

  @override
  Future<({Note? note, Failure? failure})> fetchNote(int id) async =>
      (note: null, failure: null);

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async =>
      (note: null, failure: null);

  @override
  Future<({bool deleted, Failure? failure})> deleteNote(int id) async =>
      (deleted: true, failure: null);

  @override
  Future<({int count, Failure? failure})> countDirty() async =>
      (count: 0, failure: null);

  @override
  Future<({bool synced, Failure? failure})> markAllSynced() async =>
      (synced: true, failure: null);
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          _FakeNoteRepository([
            Note(
              id: 1,
              title: 'Belanja mingguan',
              updatedAt: DateTime(2026, 9, 27),
            ),
            Note(
              id: 2,
              title: 'Tugas kampus',
              updatedAt: DateTime(2026, 9, 26),
            ),
          ]),
        ),
      ],
      child: const MaterialApp(home: NotesPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('search menampilkan hasil yang cocok', (tester) async {
    await _pump(tester);

    expect(find.text('Belanja mingguan'), findsOneWidget);
    expect(find.text('Tugas kampus'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'belanja');
    await tester.pumpAndSettle();

    expect(find.text('Belanja mingguan'), findsOneWidget);
    expect(find.text('Tugas kampus'), findsNothing);
  });

  testWidgets('search tanpa hasil menampilkan empty state', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'zzz-tak-ada');
    await tester.pumpAndSettle();

    expect(
      find.text('Tidak ada catatan yang cocok dengan "zzz-tak-ada".'),
      findsOneWidget,
    );
  });
}
