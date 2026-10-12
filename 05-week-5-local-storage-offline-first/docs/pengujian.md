# Catatan Pengujian & Simulasi Offline

## Hasil Verifikasi
- `flutter analyze` -> No issues found
- `flutter test` -> 5 test lulus:
  1. `fromMap` aman terhadap field yang hilang
  2. flag `dirty` bertahan pada serialisasi
  3. provider sukses dengan repository palsu
  4. provider error dengan repository palsu
  5. `countDirty` menghitung catatan yang belum tersinkron

Tidak ada request HTTP maupun SQLite sungguhan di dalam test: repository
di-override memakai `FakeNoteRepository` (pola injeksi `openDb`).

## Simulasi Offline yang Deterministik
Selain mode pesawat sungguhan, aplikasi menyediakan toggle **Force offline**
di halaman *Posts (cache-first)* agar demo tidak bergantung kondisi Wi-Fi:

1. Matikan toggle Force offline, buka halaman *Posts (cache-first)*:
   data diambil dari jaringan lalu disimpan ke tabel `cached_posts`.
2. Nyalakan toggle Force offline lalu muat ulang (`invalidate`):
   halaman tetap menampilkan data cache tanpa request jaringan.
3. Catatan (halaman utama) tetap berfungsi penuh saat offline:
   tambah, baca, hapus, karena semuanya lokal di SQLite.
4. Tekan tombol sinkronkan di AppBar: badge "belum tersinkron" berubah.
   Simulasi upload memakai delay 1 detik, lalu `markAllSynced()` dipanggil.

## Aturan Konflik
Sinkronisasi memakai aturan **last-write-wins** berdasarkan `updated_at`.
Catatan yang lebih baru menimpa versi server saat konflik. Aturan ini dipilih
karena sederhana dan cukup untuk satu pengguna satu perangkat; untuk multi-user
diperlukan versi/vector clock.

## Struktur Folder
```
lib/
├── main.dart
├── data/
│   ├── local/
│   │   ├── db.dart
│   │   └── note.dart
│   ├── prefs.dart
│   ├── providers.dart
│   ├── sync.dart
│   └── repositories/
│       └── note_repository.dart
├── pages/
│   ├── cached_posts_page.dart
│   ├── note_detail_page.dart
│   ├── notes_page.dart
│   └── settings_page.dart
└── widgets/
    └── note_tile.dart
```
