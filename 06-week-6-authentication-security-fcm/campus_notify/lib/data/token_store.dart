import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Seluruh token hanya keluar-masuk lewat kelas ini.
// flutter_secure_storage memakai Keystore (Android) / Keychain (iOS),
// jadi token TIDAK pernah disimpan di SharedPreferences.
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<void> saveAccess(String access) =>
      _storage.write(key: _accessKey, value: access);

  Future<String?> readAccess() => _storage.read(key: _accessKey);
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  Future<void> clear() => _storage.deleteAll();
}

/// Memotong token agar aman ditampilkan di layar debug / screenshot.
/// Jangan pernah menampilkan token penuh.
String maskToken(String token) {
  if (token.length <= 12) return '***';
  return '${token.substring(0, 12)}...';
}
