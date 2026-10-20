# AI Challenge - Clean Architecture Feature-First

## Prompt yang Digunakan
    Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
    Kondisi kini: folder lib/{data, providers, pages, messaging},
    repository tercampur dengan implementasi, widget memanggil Dio langsung.
    Tugas:
    1. Usulkan struktur feature-first Clean Architecture
       (presentation/domain/data) untuk fitur auth + announcements.
    2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
    3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
       dan kapan use case benar-benar dibutuhkan vs repository langsung.
    4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
    Jelaskan trade-off setiap keputusan.

## Tabel Usulan AI vs Keputusan Final

| File lama (Minggu 5/6) | Usulan AI | Keputusan saya | Alasan |
|---|---|---|---|
| `lib/data/local/note.dart` | Pisah jadi entity + model | **Diterima** → `domain/entities/note.dart` (murni) + `data/models/note_model.dart` (mapping) | Entity tanpa `toMap/fromMap` supaya logika bisnis tidak bergantung format penyimpanan |
| `lib/data/local/db.dart` | Pindah ke `data/datasources/` | **Diterima** → `features/notes/data/datasources/notes_database.dart` | Pembuka DB hanya boleh diketahui data layer |
| `lib/data/repositories/note_repository.dart` | Pecah jadi interface (domain) + impl (data) | **Diterima** → `domain/repositories/note_repository.dart` (abstract) + `data/repositories/note_repository_impl.dart` | Kontrak dibutuhkan domain, implementasi hanya=data yang boleh tahu SQLite |
| `lib/data/providers.dart` | Pecah per fitur | **Diterima** → `features/notes/presentation/providers/notes_providers.dart` dan `features/settings/presentation/providers/settings_providers.dart` |satu fitur punya satu sumber state, tidak ada file "god" |
| `lib/pages/notes_page.dart` | Pindah ke `features/notes/presentation/pages/` | **Diterima** | Feature-first: fitur bisa dihapus tanpa menyentuh fitur lain |
| `lib/widgets/note_tile.dart` | Pindah ke `features/notes/presentation/widgets/` | **Diterima** | Widget ikut feature yang memiliki |
| `lib/data/sync.dart` | Pecah: use case sync di domain, logic cache di data | **Diterima sebagian** → `domain/usecases/sync_notes.dart` (aturan: hitung dirty lalu tandai bersih), logic cache tetap di `features/announcements/data/` | Use case hanya untuk *aturan bisnis*; detail teknis cache bukan urusan domain |
| `lib/data/api_client.dart` (Minggu 6) | Pisah interceptor Dio ke data layer | **Diterima** → Dio dibungkus `AnnouncementApi` di data layer | Widget/presentation tidak boleh menyentuh `Dio(` sama sekali |
| `lib/pages/cached_posts_page.dart` | Jadikan fitur `announcements` | **Diterima** → `features/announcements/` | Cache-first adalah fitur tersendiri, bukan utilitas |
| `lib/data/prefs.dart` | Pecah jadi entity + repository + use case | **Diterima sebagian** → entity `AppPreferences` + interface + impl, use case hanya `ToggleDarkMode` | Baca/tulis preferensi terlalu sederhana untuk.use case tersendiri |
| `lib/messaging/*` (Minggu 6) | Buat fitur `push` | **Ditolak (di luar scope)** | Praktikum ini merefactor fitur yang ada, tidak menambah fitur baru |
| — | Tambah `fpdart` untuk `Either<Failure, T>` | **Ditolak** | Pakai Dart *record* `({List<Note> notes, Failure? failure})`: pola kontrak sama, tanpa dependency baru |
| — | Tambah `get_it` untuk DI | **Ditolak** | Provider Riverpod sudah cukup dan konsisten dengan minggu 3–6 |

## Tanda over-engineering (yang saya tandai &BATALKAN)

1. **Use case untuk setiap CRUD satu-baris** — TIDAK saya buat semuanya.
   - `GetNotes` (entry point seragam) ✅
   - `AddNote` ✅ karena ada **aturan bisnis**: judul wajib tidak kosong (diuji di `notes_usecases_test.dart`).
   - `SyncNotes` ✅ karena ada **alur multi-langkah**: hitung dirty → upload → tandai bersih.
   - `DeleteNote` ✅ (aturan: id harus valid) — tetapi kalau CRUD ini nanti benar-benar tanpa aturan apa pun, cukup panggil repository langsung dari notifier.
2. **`Failure` per fitur** — tidak. Semua failure (Local/Network/Auth) diletakkan di `lib/core/failures.dart` karena lintas fitur.
3. **Base class/interface generik** untuk semua repository — tidak. Over-abstraction; yang penting kontrak spesifik per fitur.
4. **Mapper terpisah (mapper file, mapper extension)** — tidak. Mapping 1 file (`note_model.dart`) masih jelas;abstract mapper per field baru perlu kalau datanya banyak.

## Hasil Verifikasi (tiga grep sterilitas)

### 1. Presentation steril dari data mentah — NOL HASIL ✅
```
Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode
```
dijalankan pada `lib/features/*/presentation` → **0 hasil**.

### 2. Domain steril dari framework & package — NOL HASIL ✅
```
import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase
```
dijalankan pada `lib/features/*/domain` → **0 hasil**.

### 3. Static analysis + test
```
flutter analyze  -> No issues found
flutter test     -> All tests passed (13 test)
```

## Arah dependensi (yang harus bisa digambar saat demo)

```
presentation  (widget, page, notifier, provider wiring)
     |  bergantung ke
     v
domain        (entity, repository interface, use case, Failure)
     ^
     |  diimplementasikan oleh
     |
data          (model + mapping, repository impl, database/API, SharedPreferences)
```
`core` (Failure, format, status view) dipakai lintas fitur dan tidak boleh bergantung ke fitur tertentu.


