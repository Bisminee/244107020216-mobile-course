import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';

// ConsumerWidget: widget yang bisa membaca provider lewat parameter ref.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch: build ulang otomatis setiap state provider berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      // .when menangani ketiga kondisi AsyncValue sekaligus.
      body: statsAsync.when(
        // State 1: loading -> spinner.
        loading: () => const Center(child: CircularProgressIndicator()),
        // State 2: error -> pesan + tombol retry.
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat: $err'),
              const SizedBox(height: 12),
              // ref.invalidate menjalankan ulang provider dari awal.
              FilledButton(
                onPressed: () => ref.invalidate(statsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        // State 3: success -> daftar 3 item.
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(stats[index].label),
            trailing: Text('${stats[index].value}'),
          ),
        ),
      ),
    );
  }
}
