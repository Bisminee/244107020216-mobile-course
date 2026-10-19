import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

// Dio yang sudah dilengkapi interceptor refresh 401.
final apiDioProvider = Provider<Dio>((ref) => buildApiClient(
      ref.watch(tokenStoreProvider),
      ref.watch(authRepositoryProvider),
    ));

// State login. build() membaca token dari secure storage,
// sehingga status login bertahan setelah aplikasi ditutup.
class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    ref.invalidateSelf();
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
  retry: (retryCount, error) => null,
);

/// Info debug untuk halaman Home. Token FCM selalu ditampilkan terpotong
/// (memakai `maskToken`) supaya tidak pernah muncul penuh di screenshot/log.
class DebugInfo {
  const DebugInfo({this.fcmToken, this.lastRefresh});

  final String? fcmToken;
  final DateTime? lastRefresh;
}

class DebugInfoNotifier extends Notifier<DebugInfo> {
  @override
  DebugInfo build() => const DebugInfo();

  void setFcmToken(String token) {
    state = DebugInfo(fcmToken: token, lastRefresh: DateTime.now());
  }
}

final debugInfoProvider =
    NotifierProvider<DebugInfoNotifier, DebugInfo>(DebugInfoNotifier.new);

/// Flag agar halaman Home bisa dimuat di test tanpa menyentuh API Firebase.
final enablePushProvider = Provider<bool>((ref) => true);
