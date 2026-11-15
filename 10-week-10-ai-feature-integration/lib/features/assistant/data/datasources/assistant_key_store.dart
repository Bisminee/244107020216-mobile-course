import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// API key AI hanya disimpan di secure storage (Keystore/Keychain),
/// tidak pernah di source code, SharedPreferences, atau log.
class AssistantKeyStore {
  AssistantKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'ai_api_key';

  Future<String?> read() => _storage.read(key: _key);

  Future<void> save(String value) => _storage.write(key: _key, value: value);

  Future<void> clear() => _storage.delete(key: _key);
}
