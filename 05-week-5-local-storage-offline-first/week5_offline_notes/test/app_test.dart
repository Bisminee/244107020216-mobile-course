import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/prefs.dart';
import 'package:week5_offline_notes/data/providers.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/main.dart';

// Smoke test: memastikan aplikasi (main.dart + GoRouter) dapat dirender.
class _FakePrefs extends PrefsRepository {
  @override
  Future<bool> getDarkMode() async => false;

  @override
  Future<String?> getLastOpened() async => null;

  @override
  Future<void> markOpenedNow() async {}
}

class _FakeNotes extends NoteRepository {
  _FakeNotes() : super(openDb: () => throw UnimplementedError());

  @override
  Future<List<Note>> fetchNotes() async => [];

  @override
  Future<int> countDirty() async => 0;
}

void main() {
  testWidgets('aplikasi dapat dirender dan menampilkan halaman catatan',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsRepositoryProvider.overrideWithValue(_FakePrefs()),
          noteRepositoryProvider.overrideWithValue(_FakeNotes()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Catatan Offline'), findsOneWidget);
    expect(find.text('Belum ada catatan. Tambahkan lewat tombol +.'),
        findsOneWidget);
  });
}
