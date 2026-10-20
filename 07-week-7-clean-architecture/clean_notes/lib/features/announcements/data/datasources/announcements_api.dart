import 'package:dio/dio.dart';

/// Data source HTTP fitur pengumuman. Tepatnya kelas ini yang tahu soal Dio.
class AnnouncementApi {
  AnnouncementApi({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://jsonplaceholder.typicode.com',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {'Accept': 'application/json'},
              ),
            );

  final Dio _dio;

  /// Ambil daftar mentah dari API. Mapping ke entity dilakukan di model.
  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final response = await _dio.get<List>('/posts');
    return (response.data ?? []).whereType<Map<String, dynamic>>().toList();
  }
}
