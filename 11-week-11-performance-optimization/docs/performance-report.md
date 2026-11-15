# Performance Report - Minggu 11

## Ringkasan
Optimasi difokuskan pada **mengurangi rebuild yang tidak perlu** dan **menghindari optimasi placebo**. Project: `clean_notes` (`07-week-7-clean-architecture/clean_notes`).

## Baseline Metrics (perlu perangkat)
Profiling memerlukan `flutter run --profile` di emulator/perangkat fisik. Isi tabel ini setelah profiling:

| Metrik | Before | After |
|---|---|---|
| Rata-rata frame time (ms) | _(isi)_ | _(isi)_ |
| Jumlah frame merah (>32 ms) | _(isi)_ | _(isi)_ |
| Jumlah frame kuning (16–32 ms) | _(isi)_ | _(isi)_ |
| Heap usage setelah 5x navigasi (MB) | _(isi)_ | _(isi)_ |

Langkah profiling:
1. `cd 07-week-7-clean-architecture/clean_notes`
2. `flutter run --profile`
3. Buka DevTools -> tab Performance -> Record.
4. Skenario: buka daftar -> scroll cepat -> buka detail -> kembali -> cari `belanja` -> hapus pencarian -> sync.
5. Stop -> simpan screenshot Flame Chart sebagai `screenshots/before-profile.png`.
6. Terapkan optimasi (sudah ada di branch `perf/optimizations`), ulangi -> `screenshots/after-profile.png`.
7. Tab Memory: ambil Heap Snapshot sebelum/sesudah navigasi 5x, bandingkan objek yang menumpuk (controller/listener/stream).

## Optimasi yang Diterapkan
| # | Optimasi | Alasan | Verifikasi |
|---|---|---|---|
| 1 | `_DirtyBanner` jadi `ConsumerWidget` + `dirtyCountProvider.select((v) => v.value ?? 0)` | Perubahan badge tidak perlu merender ulang seluruh halaman; `select` mencegah rebuild saat `AsyncValue` berganti status tetapi angkanya sama | kode + `perf_select_test.dart` |
| 2 | `select` untuk nilai turunan sempit (contoh `query.isEmpty`) | Listener hanya dipanggil saat nilai yang dipakai berubah | Test: 4 ketikan -> 1 notifikasi (vs 4 tanpa select) |
| 3 | `const` pada widget/ikon/padding statis | Rebuild lebih murah; instance dapat dipakai ulang | `flutter analyze` |
| 4 | Semua daftar memakai `ListView.builder` | Hanya item terlihat yang dibangun (lazy) | kode |
| 5 | Cache-first repository `announcements` (stale-while-revalidate) | Mengurangi request berulang; tetap tampil saat offline | kode Minggu 7 |

## Optimasi yang Ditolak (dengan alasan)
| Optimasi | Alasan ditolak |
|---|---|
| `RepaintBoundary` di sekitar `ListView` | `Viewport` sudah punya repaint boundary; tidak ada bukti frame time turun (placebo) — wrapper dihapus di `7f3dd29` |
| Pagination daftar catatan | Data lokal SQLite jumlah kecil + `ListView.builder` sudah lazy; pagination menambah kompleksitas tanpa manfaat terukur |
| Debounce input pencarian | Filter in-memory (tanpa DB/network); debounce hanya menambah delay |

## Hasil Verifikasi
```
flutter analyze                          -> No issues found
dart format --set-exit-if-changed lib test -> 0 file berubah
flutter test                             -> 29 test lulus
test/perf_select_test.dart               -> 4 notifikasi -> 1 notifikasi dengan select
```

## Trade-off
- `select` menambah satu konsep di kode, tetapi menghilangkan rebuild yang tidak perlu dan mudah diuji.
- Menolak `RepaintBoundary`/pagination menjaga kode tetap sederhana; optimasi hanya diterapkan bila ada bukti.
- Optimasi premature (mis. pagination untuk 20 catatan lokal) dihindari karena menambah state dan risiko bug tanpa manfaat terukur.

## Kesimpulan
Dampak terbesar datang dari **mempersempit cakupan rebuild** (`select` + ekstraksi widget), bukan dari menambah wrapper rendering. Verifikasi dilakukan dengan test notifikasi provider; profiling Flame Chart tetap perlu dijalankan di perangkat untuk mengisi tabel baseline/after.
