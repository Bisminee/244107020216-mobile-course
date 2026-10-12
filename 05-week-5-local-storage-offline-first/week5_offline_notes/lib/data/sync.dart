import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local/db.dart';
import 'providers.dart';
import 'repositories/note_repository.dart';

// ---- Simulasi offline deterministik ----
// Toggle ini membuat demo/testing tidak bergantung kondisi Wi-Fi kelas.

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

// ---- Cache-first read untuk data API ----
// Alur: tampilkan cache lokal seketika, refresh dari jaringan di background,
// simpan hasilnya untuk kunjungan berikutnya.

final postsDioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  ),
);

class CachedPost {
  const CachedPost({
    required this.id,
    required this.title,
    required this.cachedAt,
  });

  final int id;
  final String title;
  final DateTime cachedAt;
}

class PostsCacheNotifier extends AsyncNotifier<List<CachedPost>> {
  @override
  Future<List<CachedPost>> build() async {
    final offline = ref.watch(forceOfflineProvider);
    final cached = await _readCache();
    if (!offline) {
      // Refresh di background tanpa memblokir UI (cache-first).
      unawaited(_refreshInBackground());
    }
    return cached;
  }

  Future<List<CachedPost>> _readCache() async {
    final db = await openNotesDb();
    final rows =
        await db.query('cached_posts', orderBy: 'id ASC', limit: 20);
    return rows
        .map((row) => CachedPost(
              id: (row['id'] as num?)?.toInt() ?? 0,
              title: row['payload'] as String? ?? '',
              cachedAt:
                  DateTime.tryParse(row['cached_at'] as String? ?? '') ??
                      DateTime.fromMillisecondsSinceEpoch(0),
            ))
        .toList();
  }

  Future<void> _refreshInBackground() async {
    try {
      final dio = ref.read(postsDioProvider);
      final response = await dio.get<List>('/posts');
      final data = (response.data ?? [])
          .whereType<Map<String, dynamic>>()
          .take(20)
          .toList();
      final db = await openNotesDb();
      final batch = db.batch();
      batch.delete('cached_posts');
      for (final item in data) {
        batch.insert('cached_posts', {
          'id': (item['id'] as num?)?.toInt() ?? 0,
          'payload': item['title'] as String? ?? '',
          'cached_at': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit(noResult: true);
      state = AsyncData(await _readCache());
    } catch (_) {
      // Gagal refresh tidak masalah: cache lama tetap tampil.
    }
  }
}

final postsCacheProvider =
    AsyncNotifierProvider<PostsCacheNotifier, List<CachedPost>>(
  PostsCacheNotifier.new,
  retry: (retryCount, error) => null,
);

// ---- Sinkronisasi catatan kotor (dirty) ----
// Codelab ini belum punya backend tulis, jadi "server" disimulasikan delay.
// Yang dinilai adalah mekanismenya: dirty = 1 -> upload -> markAllSynced.

Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  await Future.delayed(const Duration(seconds: 1)); // simulasi upload
  await repo.markAllSynced();
  return dirtyCount;
}

class SyncNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() => ref.watch(noteRepositoryProvider).countDirty();

  // Jalankan sinkronisasi lalu perbarui daftar catatan + badge dirty.
  Future<int> syncNow() async {
    final repository = ref.read(noteRepositoryProvider);
    state = const AsyncLoading();
    final synced = await syncNotes(repository);
    ref.invalidate(notesProvider);
    state = AsyncData(await repository.countDirty());
    return synced;
  }
}

final syncProvider = AsyncNotifierProvider<SyncNotifier, int>(
  SyncNotifier.new,
  retry: (retryCount, error) => null,
);
