# Praktikum 2 - Tandai Tiga Pelanggaran Klasik (hasil grep asli)

Semua output di bawah adalah hasil menjalankan pencarian sungguhan di repo,
bukan contoh karangan.

> Catatan: pola `rg` di codelab memakai path `lib/pages` dan `lib/providers`.
> Project Minggu 5 (`week5_offline_notes`) menaruh provider di `lib/data/providers.dart`,
> jadi path-nya disesuaikan agar hasil grep tidak kosong karena salah path.

## BEFORE — `week5_offline_notes` (Minggu 5)

### (1) Widget yang menyentuh jaringan / database langsung
```
Dio\(|http\.|openDatabase|SharedPreferences\.getInstance|FlutterSecureStorage
lib/pages lib/widgets
```
**NOL HASIL** — sudah tidak ada widget yang memanggil API/db langsung.

### (2) Logika bisnis di dalam `build()`
```
DateFormat|jsonDecode|\.toIso8601String
lib/pages lib/widgets
```
**NOL HASIL** — tidak ada parsing/formatting di dalam widget.

### (3) Instansiasi manual (DI bocor)
```
Repository\(|Dio\(BaseOptions
lib/pages lib/data
```
**4 TEMUAN:**
```
providers.dart:9:  Provider<PrefsRepository>((ref) => PrefsRepository());
providers.dart:38: Provider<NoteRepository>((ref) => NoteRepository());
note_repository.dart:10: NoteRepository({Future<Database> Function()? openDb})
auth_repository.dart:11: class AuthRepository {
```
Analisis temuan:
- `providers.dart:9` & `:38` — instantiate repository **di dalam provider**. Ini sebenarnya sudah pola DI yang benar (composition root), jadi bukan pelanggaran fatal; tetapi memuat file `data/` langsung ke folder state membuat satu file provider jadi "god" dan mencampur beberapa fitur.
- `note_repository.dart:10` — **interface dan implementasi dalam satu kelas** (`NoteRepository` sekaligus kontrak sekaligus implementasi SQLite). Ini pelanggaran nyata: domain tidak bisa menguji tanpa SQLite, dan satu sumber kebenaran tercampur.
- `auth_repository.dart:11` — pola yang sama di project Minggu 6.

## BEFORE — `campus_notify` (Minggu 6)

### (1) & (2) → **NOL HASIL** (sama seperti di atas)
### (3) → **1 TEMUAN**
```
auth_provider.dart:10: Provider<AuthRepository>((ref) => AuthRepository());
```

## Temuan tambahan di luar grep (hasil baca kode)
| Pelanggaran | Lokasi | Bukti |
|---|---|---|
| Entity tercampur mapping | `week5/lib/data/local/note.dart` | `Map<String, Object?> toMap()` + `factory Note.fromMap()` ada di class entity yang sama |
| Exception mentah, bukan `Failure` | `week6/lib/data/auth_repository.dart` | `throw Exception('Email atau kata sandi tidak valid')` |
| Tidak ada tipe `Failure` sama sekali | Minggu 5 & 6 | Tidak ada `core/failures.dart`; kegagalan hanya berupa exception |
| Kontrak & implementasi tercampur | `NoteRepository`, `AuthRepository` | Tidak ada interface terpisah di domain |

## AFTER — `clean_notes` (Minggu 7, hasil refactor)

### (1) Presentation steril dari data mentah
```
Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode
lib/features/*/presentation
```
**NOL HASIL** ✅

### (2) Domain steril dari framework & package
```
import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase
lib/features/*/domain
```
**NOL HASIL** ✅

### (3) Static analysis + test
```
flutter analyze  -> No issues found
flutter test     -> All tests passed (13 test)
```

## Pemetaan temuan -> perbaikan
| Temuan (before) | Perbaikan (after) |
|---|---|
| `Note` punya `toMap`/`fromMap` | Entity `Note` (domain) bebas mapping; mapping pindah ke `NoteModel` (data) |
| `NoteRepository` = kontrak + impl | `NoteRepository` (abstract, domain) + `NoteRepositoryImpl` (data) |
| `throw Exception` mentah | `core/failures.dart`: `sealed class Failure` + `LocalFailure`/`NetworkFailure`/`AuthFailure`; UI menerima `message` saja |
| Tidak ada Failure | `FailureException` sebagai pembungkus agar provider bisa melempar tanpa bocor exception mentah ke UI |
| 1 file provider untuk semua fitur | Provider dipecah per fitur: `notes_providers.dart`, `announcements_providers.dart`, `settings_providers.dart` |
| `Provider<X>(() => X())` di file state | Instantiate implementasi dipindah ke file data/repository; provider hanya meng wiring abstraksi (`Provider<NoteRepository>`) |

## Snapshot sebelum refactor
Kode "before" sudah ter-commit di repository sebagai project `week5_offline_notes`
(folder `05-week-5-local-storage-offline-first/`), sehingga refactor bisa
dibandingkan dan di-rollback. Project `clean_notes` di folder
`07-week-7-clean-architecture/` adalah hasil refactor-nya.
