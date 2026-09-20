import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model data statistik sederhana yang ditampilkan di halaman.
class Stat {
  const Stat(this.label, this.value);

  final String label;
  final int value;
}

// Notifier asinkron untuk mengambil data statistik.
// Parameter delay dan failureRate dibuat agar bisa diatur dari test,
// sehingga unit test tidak bergantung pada keacakan (random).
class StatsNotifier extends AsyncNotifier<List<Stat>> {
  StatsNotifier({
    this.delay = const Duration(seconds: 2),
    this.failureRate = 0.3,
    Random? random,
  }) : _random = random ?? Random();

  // Lama simulasi proses pengambilan data dari server.
  final Duration delay;

  // Peluang gagal (0.0 = selalu berhasil, 1.0 = selalu gagal).
  final double failureRate;

  final Random _random;

  // build() dipanggil otomatis oleh Riverpod saat provider pertama dibaca.
  // Return-nya otomatis dibungkus AsyncValue (loading -> data/error).
  @override
  Future<List<Stat>> build() => _fetch();

  // Simulasi pengambilan data: menunggu delay, lalu kadang gagal.
  Future<List<Stat>> _fetch() async {
    await Future.delayed(delay);
    if (_random.nextDouble() < failureRate) {
      throw Exception('Gagal terhubung ke server');
    }
    return const [
      Stat('Pengguna Aktif', 120),
      Stat('Tugas Selesai', 87),
      Stat('Tugas Tertunda', 13),
    ];
  }

  // Muat ulang data: set state ke loading lalu ambil ulang.
  // AsyncValue.guard menangkap exception dan mengubahnya jadi AsyncError,
  // sehingga tidak perlu try/catch manual.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

// Satu-satunya provider yang dipakai halaman StatsPage.
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<Stat>>(
  StatsNotifier.new,
);
