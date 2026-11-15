import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../data/datasources/notes_database.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/search_notes.dart';
import '../../domain/usecases/sync_notes.dart';

// ===== Data layer: satu-satunya tempat instantiate implementasi =====
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDatabase);
});

// ===== Domain layer: use case menerima abstraksi, bukan implementasi =====
final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final addNoteProvider = Provider<AddNote>((ref) {
  return AddNote(ref.watch(noteRepositoryProvider));
});

final deleteNoteProvider = Provider<DeleteNote>((ref) {
  return DeleteNote(ref.watch(noteRepositoryProvider));
});

final syncNotesProvider = Provider<SyncNotes>((ref) {
  return SyncNotes(ref.watch(noteRepositoryProvider));
});

final searchNotesProvider = Provider<SearchNotes>((ref) => const SearchNotes());

// ===== Presentation layer: state untuk UI =====

/// Mengubah Failure menjadi exception pembungkus agar UI hanya
/// membaca pesan ramah pengguna.
Never _throwFailure(Failure failure) => throw FailureException(failure);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final result = await ref.watch(getNotesProvider).call();
    if (result.failure != null) _throwFailure(result.failure!);
    return result.notes;
  }

  Future<List<Note>> _reload() async {
    final result = await ref.read(getNotesProvider).call();
    if (result.failure != null) _throwFailure(result.failure!);
    return result.notes;
  }

  Future<void> add({required String title, String body = ''}) async {
    final result =
        await ref.read(addNoteProvider).call(title: title, body: body);
    if (result.failure != null) {
      state = AsyncError(FailureException(result.failure!), StackTrace.current);
      return;
    }
    state = AsyncData(await _reload());
  }

  Future<void> remove(int id) async {
    final result = await ref.read(deleteNoteProvider).call(id);
    if (result.failure != null) {
      state = AsyncError(FailureException(result.failure!), StackTrace.current);
      return;
    }
    state = AsyncData(await _reload());
  }

  Future<int> sync() async {
    final result = await ref.read(syncNotesProvider).call();
    if (result.failure != null) {
      state = AsyncError(FailureException(result.failure!), StackTrace.current);
      return 0;
    }
    state = AsyncData(await _reload());
    return result.synced;
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

/// Query pencarian (state UI).
final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;

  void clear() => state = '';
}

/// Daftar catatan yang sudah difilter. Diturunkan dari notesProvider,
/// sehingga tidak ada query database ulang saat pengguna mengetik.
final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final notesAsync = ref.watch(notesProvider);
  final query = ref.watch(searchQueryProvider);
  final search = ref.watch(searchNotesProvider);
  return notesAsync.whenData(
    (notes) => search(notes: notes, query: query),
  );
});

/// Jumlah catatan yang belum tersinkron (badge antrean).
final dirtyCountProvider = FutureProvider<int>((ref) async {
  ref.watch(notesProvider);
  final result = await ref.watch(noteRepositoryProvider).countDirty();
  if (result.failure != null) _throwFailure(result.failure!);
  return result.count;
});

/// Detail catatan dibaca langsung dari repository (bukan dari state list).
final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) async {
  final result = await ref.watch(noteRepositoryProvider).fetchNote(id);
  if (result.failure != null) _throwFailure(result.failure!);
  return result.note;
});
