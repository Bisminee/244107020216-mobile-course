import 'dart:io';

import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/main.dart';
import 'package:campus_notify/pages/announcement_page.dart';
import 'package:campus_notify/pages/home_page.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Generator screenshot berbasis widget test (tanpa emulator).
// Jalankan: $env:GEN_SCREENSHOTS=1; flutter test --update-goldens test/screenshots_test.dart
final bool _generate = Platform.environment['GEN_SCREENSHOTS'] == '1';

class FakeTokenStore extends TokenStore {
  FakeTokenStore({this.access});
  String? access;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
  }

  @override
  Future<void> saveAccess(String value) async => access = value;

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => access == null ? null : 'refresh';

  @override
  Future<void> clear() async => access = null;
}

Future<void> _capture(
  WidgetTester tester,
  Widget app,
  String fileName,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../screenshots/$fileName'),
  );
}

Widget _app(ProviderContainer container, Widget home) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: home,
    ),
  );
}

void main() {
  testWidgets('screenshot guard route (belum login -> /login)', (tester) async {
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(FakeTokenStore()),
        enablePushProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../screenshots/guard_route.png'),
    );
  }, skip: !_generate);

  testWidgets('screenshot beranda', (tester) async {
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider
            .overrideWithValue(FakeTokenStore(access: 'mock-access')),
        enablePushProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);
    await _capture(tester, _app(container, const HomePage()), 'home.png');
  }, skip: !_generate);

  testWidgets('screenshot beranda dengan token terpotong', (tester) async {
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider
            .overrideWithValue(FakeTokenStore(access: 'mock-access')),
        enablePushProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(debugInfoProvider.notifier)
        .setFcmToken('eXaMpLeFcmToken-1234567890abcdefghijklmnop');

    await _capture(
      tester,
      _app(container, const HomePage()),
      'home_token.png',
    );
  }, skip: !_generate);

  testWidgets('screenshot halaman pengumuman (deep link)', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await _capture(
      tester,
      _app(container, const AnnouncementPage(id: '3')),
      'announcement.png',
    );
  }, skip: !_generate);
}
