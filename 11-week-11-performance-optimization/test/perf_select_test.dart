import 'package:clean_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bukti terukur bahwa `select` mengurangi rebuild:
/// listener hanya dipanggil ketika NILAI yang dipilih berubah,
/// bukan setiap kali provider sumber berubah.
void main() {
  test('select hanya memberi notifikasi saat nilai berubah', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var notifications = 0;
    final sub = container.listen(
      searchQueryProvider.select((query) => query.isEmpty),
      (previous, next) => notifications++,
    );
    addTearDown(sub.close);

    final notifier = container.read(searchQueryProvider.notifier);

    // '' -> true (awal, tanpa notifikasi karena listen belum fire)
    notifier.setQuery('b');
    // isEmpty: true -> false => notifikasi 1
    notifier.setQuery('be');
    notifier.setQuery('bel');
    notifier.setQuery('bela');
    // isEmpty tetap false => TIDAK ada notifikasi tambahan
    expect(notifications, 1);

    notifier.clear();
    // false -> true => notifikasi 2
    expect(notifications, 2);
  });

  test('tanpa select, setiap perubahan query memicu notifikasi', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var notifications = 0;
    final sub = container.listen(
      searchQueryProvider,
      (previous, next) => notifications++,
    );
    addTearDown(sub.close);

    final notifier = container.read(searchQueryProvider.notifier);
    notifier.setQuery('b');
    notifier.setQuery('be');
    notifier.setQuery('bel');
    notifier.setQuery('bela');

    // 4 notifikasi vs 1 notifikasi saat memakai select.
    expect(notifications, 4);
  });
}
