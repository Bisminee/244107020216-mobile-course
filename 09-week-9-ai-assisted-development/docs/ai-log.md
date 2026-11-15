# AI Log - Fitur Pencarian Catatan (Minggu 9)

## 1. Prompt (formula 5 slot)

```
Peran: senior Flutter developer
Konteks: project clean_notes, feature-first (presentation -> domain <- data),
  Riverpod, SQLite, file use case: lib/features/notes/domain/usecases/get_notes.dart
  Entity: lib/features/notes/domain/entities/note.dart
Tugas: tambah pencarian judul catatan + empty state
Batas: jangan ubah arsitektur, jangan panggil SQLite dari widget, maks 80 baris
Output: kode + 3 test case + cara uji
```

Konteks yang ditempel: struktur folder `features/notes/{domain,data,presentation}`, isi `Note` entity, dan kontrak `NoteRepository`. Tidak ada token/API key yang ditempel.

## 2. Output Awal AI (ringkas)

AI mengusulkan:

```dart
// di dalam widget (SALAH: logika di presentation)
final filtered = notes.where((n) => n.title.contains(_query)).toList();
...
TextField(onChanged: (v) => setState(() => _query = v)),
```

Masalah pada output awal:
1. Filter case-sensitive (`contains` tanpa normalisasi).
2. Tidak ada `trim`, sehingga spasi di tepi membuat hasil kosong.
3. Logika filter berada di widget (melanggar dependency rule).
4. Tidak ada empty state khusus.

## 3. Verifikasi 6 Langkah

| Langkah | Hasil |
|---|---|
| Baca tiap baris | Ditemukan 4 masalah di atas |
| Cek import | Usulan awal meletakkan filter di presentation; melanggar aturan |
| Cek API | `String.contains` ada; tidak ada method fiktif |
| `flutter analyze` | Setelah refactor: **No issues found** |
| Test sukses + gagal | `test/search_filter_test.dart` (5 test) + widget test (2 test) |
| Uji manual | Query kosong, cocok, tidak cocok (empty state) — lihat screenshot |

### Bug/halusinasi yang dibuktikan
**Klaim AI:** `notes.where((n) => n.title.contains(query))` sudah cukup.

**Bukti salah:** menulis test:
```dart
final notes = [Note(title: 'Belanja mingguan', ...)];
expect(filterNotes(notes, 'belanja'), hasLength(2));
```
Dengan implementasi awal (case-sensitive), `'Belanja mingguan'.contains('belanja')` = `false`, sehingga hasil = 0 (test merah). Perbaikan: `title.toLowerCase().contains(query.trim().toLowerCase())`. Test yang sama menjadi hijau.

## 4. Refactor ke Layer yang Benar

| Sebelum (AI) | Sesudah (final) |
|---|---|
| Filter di `build()` widget | `domain/usecases/search_notes.dart` (`filterNotes` murni + `SearchNotes`) |
| `setState` query | `searchQueryProvider` (Riverpod) |
| List dihitung ulang di widget | `filteredNotesProvider` turunan dari `notesProvider` |
| Tanpa empty state | `EmptyView` dengan pesan query |

Kode AI 1 file > 80 baris dipecah menjadi: 1 fungsi murni + 1 use case + 1 provider turunan.

## 5. Tabel Terima / Tolak

| Saran AI | Keputusan | Alasan |
|---|---|---|
| Filter di widget dengan `contains` | **Tolak + tulis manual** | Melanggar dependency rule, case-sensitive |
| `setState` untuk query | **Tolak** | State harus di Riverpod agar bisa dipakai ulang/diuji |
| Empty state | **Terima + refactor** | Kebutuhan UX nyata, dipindah ke `EmptyView` |
| `trim()` input | **Terima** | Mencegah hasil kosong karena spasi tak sengaja |

## 6. Bukti Mesin
```
flutter analyze                          -> No issues found
dart format --set-exit-if-changed lib test -> 0 file berubah
flutter test                             -> 29 test lulus (7 test terkait search)
```
