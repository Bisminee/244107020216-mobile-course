import 'package:dio/dio.dart';
import 'auth_repository.dart';
import 'token_store.dart';

// Dio dengan refresh otomatis: saat menerima 401, interceptor mencoba
// menukar refresh token SATU kali, lalu mengulang request.
// Bila refresh ikut gagal, token dibersihkan sehingga user dipaksa login ulang.
Dio buildApiClient(TokenStore store, AuthRepository auth) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final refresh = await store.readRefresh();
          if (refresh == null) return handler.next(e);
          try {
            final renewed = await auth.refresh(refresh);
            await store.saveAccess(renewed);
            final retry = await dio.fetch(
              e.requestOptions..headers['Authorization'] = 'Bearer $renewed',
            );
            return handler.resolve(retry);
          } catch (_) {
            // Refresh ikut kedaluwarsa -> paksa login ulang.
            await store.clear();
          }
        }
        handler.next(e);
      },
    ),
  );

  return dio;
}
