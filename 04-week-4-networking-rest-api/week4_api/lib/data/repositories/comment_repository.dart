import 'package:dio/dio.dart';
import '../models/comment.dart';

// Repository: satu-satunya pintu ke API komentar.
// UI tidak boleh memanggil Dio secara langsung, cukup lewat provider.
class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  // Ambil komentar berdasarkan postId dari GET /comments?postId={id}.
  // receiveTimeout 10 detik dipasang eksplisit (selain default di api_client).
  // Exception dibiarkan naik agar provider mengubahnya menjadi AsyncError.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
      options: Options(receiveTimeout: const Duration(seconds: 10)),
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
