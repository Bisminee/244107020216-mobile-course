import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:campus_notify/routes.dart';

// Token store palsu: tidak menyentuh Keystore/Keychain (tanpa plugin).
class FakeTokenStore extends TokenStore {
  String? _access;
  String? _refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    _access = access;
    _refresh = refresh;
  }

  @override
  Future<void> saveAccess(String access) async {
    _access = access;
  }

  @override
  Future<String?> readAccess() async => _access;

  @override
  Future<String?> readRefresh() async => _refresh;

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}

void main() {
  test('routeFromMessage menangani route kosong dan tanpa slash', () {
    expect(routeFromMessage({}), AppRoutes.home);
    expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
  });

  test('data payload membawa id pengumuman', () {
    const data = {'route': '/pengumuman/3', 'id': '3'};
    expect(data['id'], '3');
    expect(routeFromMessage(data), '/pengumuman/3');
  });

  test('token selalu ditampilkan terpotong (tidak pernah penuh)', () {
    expect(maskToken('pendek'), '***');
    expect(maskToken('abcdefghijklmnopqrstuvwxyz'), 'abcdefghijkl...');
  });

  test('login menolak email tanpa @ dan sandi < 6 karakter', () async {
    final auth = AuthRepository();
    await expectLater(
      auth.login(email: 'salah', password: '123456'),
      throwsException,
    );
    await expectLater(
      auth.login(email: 'a@b.com', password: '123'),
      throwsException,
    );
  });

  test('login sukses mengembalikan access + refresh token', () async {
    final auth = AuthRepository();
    final session = await auth.login(
      email: 'mahasiswa@polinema.ac.id',
      password: '123456',
    );
    expect(session.access, contains('mock-access'));
    expect(session.refresh, contains('mock-refresh'));
  });

  test('refresh gagal -> sesi dibersihkan (paksa login ulang)', () async {
    final auth = AuthRepository();
    await expectLater(auth.refresh(''), throwsException);
  });

  test('authStateProvider true setelah login, false setelah logout', () async {
    final container = ProviderContainer(
      overrides: [tokenStoreProvider.overrideWithValue(FakeTokenStore())],
    );
    addTearDown(container.dispose);

    expect(await container.read(authStateProvider.future), isFalse);

    await container
        .read(authStateProvider.notifier)
        .login('mahasiswa@polinema.ac.id', '123456');
    expect(container.read(authStateProvider).value, isTrue);

    await container.read(authStateProvider.notifier).logout();
    expect(await container.read(authStateProvider.future), isFalse);
  });

  test('token tersimpan di store setelah login', () async {
    final store = FakeTokenStore();
    final auth = AuthRepository();
    final session =
        await auth.login(email: 'a@b.com', password: '123456');
    await store.save(access: session.access, refresh: session.refresh);

    expect(await store.readAccess(), contains('mock-access'));
    expect(await store.readRefresh(), contains('mock-refresh'));

    await store.clear();
    expect(await store.readAccess(), isNull);
  });
}
