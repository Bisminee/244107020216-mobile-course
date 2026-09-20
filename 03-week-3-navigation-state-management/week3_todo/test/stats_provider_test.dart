import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  group('StatsNotifier', () {
    // failureRate: 0 memastikan selamanya berhasil (deterministik).
    test('mengembalikan 3 statistik saat berhasil', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(delay: Duration.zero, failureRate: 0),
          ),
        ],
      );
      addTearDown(container.dispose);

      final stats = await container.read(statsProvider.future);

      expect(stats.length, 3);
      expect(stats.first.label, 'Pengguna Aktif');
      expect(stats.first.value, 120);
    });

    // failureRate: 1 memastikan selamanya gagal (deterministik).
    test('menghasilkan error saat gagal', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(delay: Duration.zero, failureRate: 1),
          ),
        ],
      );
      addTearDown(container.dispose);

      // listen agar provider mulai dijalankan.
      container.listen(statsProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final value = container.read(statsProvider);
      expect(value.hasError, isTrue);
      expect(value.error, isA<Exception>());
    });

    // Setelah gagal, refresh() harus mengubah state kembali.
    test('refresh mengeksekusi ulang provider', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(delay: Duration.zero, failureRate: 0),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(statsProvider.future);

      await container.read(statsProvider.notifier).refresh();

      final stats = await container.read(statsProvider.future);
      expect(stats.length, 3);
    });
  });
}
