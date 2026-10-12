import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local/note.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';

// ---- Preferensi (SharedPreferences) ----

final prefsRepositoryProvider =
    Provider<PrefsRepository>((ref) => PrefsRepository());

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
  // Nonaktifkan retry otomatis agar error langsung final dan mudah diuji.
  retry: (retryCount, error) => null,
);

final lastOpenedProvider = FutureProvider<String?>((ref) {
  return ref.watch(prefsRepositoryProvider).getLastOpened();
});

// ---- Catatan (SQLite) ----

final noteRepositoryProvider =
    Provider<NoteRepository>((ref) => NoteRepository());

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() {
    final repository = ref.watch(noteRepositoryProvider);
    return repository.fetchNotes();
  }

  Future<void> add({required String title, String body = ''}) async {
    final repository = ref.read(noteRepositoryProvider);
    await repository.addNote(title: title, body: body);
    state = await AsyncValue.guard(repository.fetchNotes);
  }

  Future<void> delete(int id) async {
    final repository = ref.read(noteRepositoryProvider);
    await repository.deleteNote(id);
    state = await AsyncValue.guard(repository.fetchNotes);
  }

  Future<void> refresh() async {
    final repository = ref.read(noteRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(repository.fetchNotes);
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

// Jumlah catatan yang belum tersinkron (badge dirty).
class DirtyCountNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() {
    // Ikut ter-update setiap daftar catatan berubah.
    ref.watch(notesProvider);
    return ref.watch(noteRepositoryProvider).countDirty();
  }
}

final dirtyCountProvider = AsyncNotifierProvider<DirtyCountNotifier, int>(
  DirtyCountNotifier.new,
  retry: (retryCount, error) => null,
);

// Detail catatan untuk route /note/:id; dibaca dari repository lokal,
// bukan dari state halaman list.
final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) {
  return ref.watch(noteRepositoryProvider).fetchNote(id);
});
