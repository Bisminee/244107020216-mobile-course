# Performance Findings - Minggu 11

## Metode
- Profiling penuh (Flame Chart) memerlukan perangkat/emulator dengan `flutter run --profile`. Langkahnya ada di `performance-report.md`.
- Temuan kode di bawah diverifikasi dengan **membaca alur rebuild** dan **test notifikasi provider** (`test/perf_select_test.dart`), bukan klaim.

## Temuan

### 1. Rebuild seluruh halaman saat badge dirty berubah (CPU/build)
**Lokasi:** `notes_page.dart` — `NotesPage` melakukan `ref.watch(dirtyCountProvider)`.
**Dampak:** setiap perubahan jumlah dirty (setelah tambah/hapus/sync) merender ulang seluruh Scaffold + list + TextField, padahal hanya badge yang perlu berubah.
**Bukti:** derivasi provider — `dirtyCountProvider` bergantung pada `notesProvider`; setiap mutasi catatan memicu rebuild halaman.
**Perbaikan:** ekstrak `_DirtyBanner` menjadi `ConsumerWidget` dan pakai
`ref.watch(dirtyCountProvider.select((v) => v.value ?? 0))`.
**Hasil:** hanya banner yang rebuild, dan hanya ketika **angka** berubah (bukan saat `AsyncValue` loading/data).

### 2. Listener query terlalu luas (CPU/build)
**Lokasi:** state pencarian.
**Dampak:** jika widget mendengarkan seluruh string query, 4 ketikan = 4 notifikasi/rebuild, padahal yang dibutuhkan sering hanya boolean (mis. apakah query kosong untuk tombol clear).
**Bukti terukur (`test/perf_select_test.dart`):**
```
tanpa select : 4 perubahan query -> 4 notifikasi
dengan select(query.isEmpty) : 4 perubahan query -> 1 notifikasi
```
**Perbaikan:** gunakan `select` untuk nilai turunan yang sempit.

### 3. `RepaintBoundary` di sekitar `ListView` (placebo — ditolak)
**Lokasi:** sempat ditambahkan di `notes_page.dart` dan daftar pesan chat.
**Dampak:** `Scrollable`/`Viewport` sudah membuat repaint boundary sendiri; menambah wrapper hanya menambah layer.
**Bukti:** tidak ada penurunan frame time yang bisa diklaim tanpa profiling; review menandainya placebo.
**Keputusan:** wrapper **dihapus** (commit `7f3dd29`). Ini contoh optimasi yang harus ditolak bila tidak terbukti.

### 4. Pagination daftar catatan (tidak diterapkan)
**Alasan:** data berasal dari SQLite lokal dengan jumlah kecil dan sudah memakai `ListView.builder` (lazy). Pagination akan menambah kompleksitas state tanpa manfaat terukur. Pagination tetap relevan untuk daftar jaringan besar (lihat fitur `announcements` yang mengambil 20 item).

## Ringkasan Optimasi yang Diterapkan
| # | Optimasi | Status | Bukti |
|---|---|---|---|
| 1 | Ekstrak `_DirtyBanner` + `select` | Diterapkan | kode + test select |
| 2 | `select` untuk nilai turunan sempit | Diterapkan | `perf_select_test.dart` (4 -> 1 notifikasi) |
| 3 | `const` pada widget statis (`_EmptyChat`, ikon, padding) | Diterapkan | `flutter analyze` |
| 4 | `ListView.builder` untuk semua daftar | Sudah ada | kode |
| 5 | Cache-first repository (announcements) | Sudah ada (Minggu 7) | kode |
| 6 | `RepaintBoundary` di sekitar ListView | **Ditolak** | tidak terbukti (placebo) |
| 7 | Pagination daftar catatan | **Ditolak** | data lokal kecil |
