# Catatan Pengujian - Minggu 7 (Clean Architecture)

## Hasil Verifikasi
- `flutter analyze` → **No issues found**
- `flutter test` → **13 test lulus**

| Test | Isi |
|---|---|
| `get_notes_test.dart` | `GetNotes` meneruskan daftar; `GetNotes` meneruskan failure tanpa melempar |
| `notes_usecases_test.dart` | `AddNote` menolak judul kosong tanpa memanggil repository; `AddNote` memotong spasi; `DeleteNote` menolak id invalid; `SyncNotes` no-op saat tidak ada dirty; `SyncNotes` melaporkan jumlah tersinkron; `SyncNotes` meneruskan failure |
| `format_and_model_test.dart` | `formatDateTime`, `formatRelative`; `NoteModel.fromMap` aman null; flag dirty bertahan; `toEntity` melepas tipe model |
| `screenshots_test.dart` | 5 generator screenshot (di-skip di `flutter test` biasa) |

Uji domain memakai `FakeNoteRepository` (implementasi interface) — **tanpa SQLite, tanpa Dio, tanpa jaringan**.

## Bukti Perilaku Identik (before/after)
| Fitur | Sebelum (Minggu 5) | Sesudah (Minggu 7) |
|---|---|---|
| Daftar catatan | `before_notes.png` | `after_notes.png` |
| Daftar kosong | `before_notes_empty.png` | `after_notes_empty.png` |
| Error state | `before_notes_error.png` | (tetap sama, error kini lewat `Failure` + `FailureException`) |
| Detail catatan | `before_note_detail.png` | `after_note_detail.png` |
| Pengaturan | `before_settings.png` | `after_settings.png` |
| Pengumuman (cache-first) | (belum ada di Minggu 5 sebagai fitur) | `after_announcements.png` |

Screenshot "before" diambil dari project `week5_offline_notes` (folder `05-week-5-local-storage-offline-first/screenshots`), "after" digenerate dari `clean_notes` dengan golden test sehingga bisa dibandingkan langsung.

## Uji Manual yang Tetap Perlu Dijalankan (butuh perangkat)
1. Tambah catatan → catatan muncul, badge dirty naik.
2. Hapus catatan → catatan hilang.
3. Tekan sinkronkan → badge dirty kembali 0.
4. Buka detail catatan → judul/isi/waktu tampil benar.
5. Toggle mode gelap → tema berubah dan bertahan setelah app ditutup.
6. Buka Pengumuman → cache tampil; matikan internet → cache tetap tampil (force offline).

## Struktur Folder Akhir
```
lib/
├── core/
│   ├── failures.dart
│   ├── format.dart
│   └── widgets/status_views.dart
├── features/
│   ├── notes/
│   │   ├── domain/
│   │   │   ├── entities/note.dart
│   │   │   ├── repositories/note_repository.dart      # interface
│   │   │   └── usecases/{get_notes,add_note,delete_note,sync_notes}.dart
│   │   ├── data/
│   │   │   ├── models/note_model.dart
│   │   │   ├── datasources/notes_database.dart
│   │   │   └── repositories/note_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/notes_providers.dart
│   │       ├── pages/{notes_page,note_detail_page}.dart
│   │       └── widgets/note_tile.dart
│   ├── announcements/
│   │   ├── domain/{entities,repositories,usecases}
│   │   ├── data/{models,datasources,repositories}
│   │   └── presentation/{providers,pages}
│   └── settings/
│       ├── domain/{entities,repositories,usecases}
│       ├── data/repositories
│       └── presentation/{providers,pages}
├── routes.dart
└── main.dart
```
