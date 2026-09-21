import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

// Repository komentar memakai Dio yang sama (dioProvider dari providers.dart),
// sehingga base URL dan timeout tetap terpusat di satu tempat.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

// postId yang sedang dipilih; bisa diubah dari UI.
final selectedPostIdProvider = Provider<int>((ref) => 1);

// AsyncNotifier: exception yang dilempar dari build() otomatis ditangkap
// Riverpod dan menjadi AsyncError, tanpa try/catch di widget.
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  @override
  Future<List<Comment>> build() {
    final repository = ref.watch(commentRepositoryProvider);
    final postId = ref.watch(selectedPostIdProvider);
    return repository.fetchComments(postId);
  }

  // Refresh manual: state diubah manual sehingga try/catch eksplisit
  // tetap dibutuhkan agar error menjadi state, bukan dilempar ke luar.
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      final postId = ref.read(selectedPostIdProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final commentListProvider =
    AsyncNotifierProvider<CommentListNotifier, List<Comment>>(
  CommentListNotifier.new,
  // Nonaktifkan retry otomatis Riverpod 3 agar error langsung final
  // dan mudah diuji.
  retry: (retryCount, error) => null,
);

// Menerjemahkan DioException teknis menjadi pesan yang ramah pengguna.
String friendlyCommentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa internet Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Komentar tidak ditemukan (404).';
        if (code == 500) {
          return 'Server sedang bermasalah (500). Coba lagi nanti.';
        }
        return 'Server bermasalah ($code). Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  return 'Terjadi kesalahan tak terduga: $error';
}
