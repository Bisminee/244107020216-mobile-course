import 'dart:io';

import 'package:clean_notes/core/failures.dart';
import 'package:clean_notes/features/announcements/domain/entities/announcement.dart';
import 'package:clean_notes/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:clean_notes/features/announcements/presentation/pages/announcements_page.dart';
import 'package:clean_notes/features/announcements/presentation/providers/announcements_providers.dart';
import 'package:clean_notes/features/notes/domain/entities/note.dart';
import 'package:clean_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:clean_notes/features/notes/presentation/pages/note_detail_page.dart';
import 'package:clean_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:clean_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:clean_notes/features/settings/domain/entities/app_preferences.dart';
import 'package:clean_notes/features/settings/domain/repositories/preferences_repository.dart';
import 'package:clean_notes/features/settings/presentation/pages/settings_page.dart';
import 'package:clean_notes/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Generator screenshot "after refactor" (tanpa emulator).
// Jalankan: $env:GEN_SCREENSHOTS=1; flutter test --update-goldens test/screenshots_test.dart
final bool _generate = Platform.environment['GEN_SCREENSHOTS'] == '1';

class _FakeNoteRepository implements NoteRepository {
  _FakeNoteRepository({this.items = const []});

  final List<Note> items;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async =>
      (notes: items, failure: null);

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
  }) async =>
      (note: null, failure: null);

  @override
  Future<({bool deleted, Failure? failure})> deleteNote(int id) async =>
      (deleted: true, failure: null);

  @override
  Future<({int count, Failure? failure})> countDirty() async =>
      (count: items.where((n) => n.dirty).length, failure: null);

  @override
  Future<({bool synced, Failure? failure})> markAllSynced() async =>
      (synced: true, failure: null);
}

class _FakePreferencesRepository implements PreferencesRepository {
  @override
  Future<({AppPreferences preferences, Failure? failure})> readPreferences() async =>
      (
        preferences: const AppPreferences(
          darkMode: true,
          lastOpenedAt: null,
        ),
        failure: null,
      );

  @override
  Future<({bool saved, Failure? failure})> saveDarkMode(bool value) async =>
      (saved: true, failure: null);

  @override
  Future<({bool saved, Failure? failure})> markOpenedNow() async =>
      (saved: true, failure: null);
}

class _FakeAnnouncementRepository implements AnnouncementRepository {
  @override
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements() async => (
            announcements: [
              Announcement(
                id: 1,
                title: 'Jadwal kuliah berubah',
                body: 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
                cachedAt: DateTime(2026, 9, 27, 8, 30),
              ),
            ],
            failure: null,
          );

  @override
  Future<({int count, Failure? failure})> countCached() async =>
      (count: 1, failure: null);
}

final _notes = [
  Note(
    id: 3,
    title: 'Belanja mingguan',
    body: 'Beras, telur, sayur',
    updatedAt: DateTime(2026, 9, 27, 9, 30),
    dirty: true,
  ),
  Note(
    id: 2,
    title: 'Tugas praktikum minggu 7',
    body: 'Clean Architecture + dependency rule',
    updatedAt: DateTime(2026, 9, 26, 20, 15),
    dirty: true,
  ),
  Note(
    id: 1,
    title: 'Catatan lama',
    body: 'Sudah tersinkron ke server',
    updatedAt: DateTime(2026, 9, 25, 8),
  ),
];

Future<void> _capture(WidgetTester tester, Widget app, String fileName) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../screenshots/$fileName'),
  );
}

Widget _app(ProviderContainer container, Widget home) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: home,
    ),
  );
}

void main() {
  testWidgets('after - daftar catatan', (tester) async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider
            .overrideWithValue(_FakeNoteRepository(items: _notes)),
      ],
    );
    addTearDown(container.dispose);
    await _capture(tester, _app(container, const NotesPage()), 'after_notes.png');
  }, skip: !_generate);

  testWidgets('after - daftar kosong', (tester) async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(_FakeNoteRepository()),
      ],
    );
    addTearDown(container.dispose);
    await _capture(
      tester,
      _app(container, const NotesPage()),
      'after_notes_empty.png',
    );
  }, skip: !_generate);

  testWidgets('after - detail catatan', (tester) async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider
            .overrideWithValue(_FakeNoteRepository(items: _notes)),
      ],
    );
    addTearDown(container.dispose);
    await _capture(
      tester,
      _app(container, const NoteDetailPage(id: 3)),
      'after_note_detail.png',
    );
  }, skip: !_generate);

  testWidgets('after - pengumuman (cache-first)', (tester) async {
    final container = ProviderContainer(
      overrides: [
        announcementRepositoryProvider
            .overrideWithValue(_FakeAnnouncementRepository()),
      ],
    );
    addTearDown(container.dispose);
    await _capture(
      tester,
      _app(container, const AnnouncementsPage()),
      'after_announcements.png',
    );
  }, skip: !_generate);

  testWidgets('after - pengaturan (mode gelap)', (tester) async {
    final container = ProviderContainer(
      overrides: [
        preferencesRepositoryProvider
            .overrideWithValue(_FakePreferencesRepository()),
      ],
    );
    addTearDown(container.dispose);
    await _capture(
      tester,
      _app(container, const SettingsPage()),
      'after_settings.png',
    );
  }, skip: !_generate);
}
