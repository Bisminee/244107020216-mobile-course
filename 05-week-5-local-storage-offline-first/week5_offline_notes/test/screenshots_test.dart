import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/prefs.dart';
import 'package:week5_offline_notes/data/providers.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/pages/note_detail_page.dart';
import 'package:week5_offline_notes/pages/notes_page.dart';
import 'package:week5_offline_notes/pages/settings_page.dart';

// Generator screenshot berbasis widget test (tidak butuh emulator).
// Jalankan: $env:GEN_SCREENSHOTS=1; flutter test --update-goldens test/screenshots_test.dart
// Test ini di-skip pada `flutter test` biasa supaya tidak menulis file terus-menerus.
final bool _generate = Platform.environment['GEN_SCREENSHOTS'] == '1';

class FakePrefsRepository extends PrefsRepository {
  FakePrefsRepository({this.darkMode = false, this.lastOpened});

  final bool darkMode;
  final String? lastOpened;

  @override
  Future<bool> getDarkMode() async => darkMode;

  @override
  Future<void> setDarkMode(bool value) async {}

  @override
  Future<String?> getLastOpened() async => lastOpened;
}

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({this.items = const [], this.throwError = false})
      : super(openDb: () => throw UnimplementedError());

  final List<Note> items;
  final bool throwError;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) throw Exception('db locked (simulasi)');
    return items;
  }

  @override
  Future<Note?> fetchNote(int id) async {
    for (final note in items) {
      if (note.id == id) return note;
    }
    return null;
  }

  @override
  Future<int> countDirty() =>
      Future.value(items.where((n) => n.dirty).length);
}

final _notes = [
  Note(
    id: 3,
    title: 'Belanja mingguan',
    body: 'Beras, telur, sayur',
    updatedAt: DateTime(2026, 9, 18, 9, 30),
    dirty: true,
  ),
  Note(
    id: 2,
    title: 'Tugas praktikum minggu 5',
    body: 'Offline-first + dirty flag',
    updatedAt: DateTime(2026, 9, 17, 20, 15),
    dirty: true,
  ),
  Note(
    id: 1,
    title: 'Catatan lama',
    body: 'Sudah tersinkron ke server',
    updatedAt: DateTime(2026, 9, 16, 8, 0),
  ),
];

Future<void> _capture(
  WidgetTester tester,
  Widget page,
  String fileName, {
  List<dynamic> overrides = const [],
  bool dark = false,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        home: page,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../screenshots/$fileName'),
  );
}

void main() {
  testWidgets('screenshot daftar catatan', (tester) async {
    await _capture(
      tester,
      const NotesPage(),
      'notes_list.png',
      overrides: [
        noteRepositoryProvider
            .overrideWithValue(FakeNoteRepository(items: _notes)),
        prefsRepositoryProvider
            .overrideWithValue(FakePrefsRepository()),
      ],
    );
  }, skip: !_generate);

  testWidgets('screenshot daftar kosong', (tester) async {
    await _capture(
      tester,
      const NotesPage(),
      'notes_empty.png',
      overrides: [
        noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
        prefsRepositoryProvider.overrideWithValue(FakePrefsRepository()),
      ],
    );
  }, skip: !_generate);

  testWidgets('screenshot error state', (tester) async {
    await _capture(
      tester,
      const NotesPage(),
      'notes_error.png',
      overrides: [
        noteRepositoryProvider
            .overrideWithValue(FakeNoteRepository(throwError: true)),
        prefsRepositoryProvider.overrideWithValue(FakePrefsRepository()),
      ],
    );
  }, skip: !_generate);

  testWidgets('screenshot detail catatan', (tester) async {
    await _capture(
      tester,
      const NoteDetailPage(id: 3),
      'note_detail.png',
      overrides: [
        noteRepositoryProvider
            .overrideWithValue(FakeNoteRepository(items: _notes)),
      ],
    );
  }, skip: !_generate);

  testWidgets('screenshot pengaturan (mode gelap)', (tester) async {
    await _capture(
      tester,
      const SettingsPage(),
      'settings_dark.png',
      dark: true,
      overrides: [
        prefsRepositoryProvider.overrideWithValue(
          FakePrefsRepository(darkMode: true, lastOpened: '2026-09-18 09:12'),
        ),
      ],
    );
  }, skip: !_generate);
}
