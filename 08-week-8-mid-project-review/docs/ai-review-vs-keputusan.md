# AI Review vs Keputusan Final (Minggu 8)

## Prompt yang Digunakan
```
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

## Tabel Usulan AI vs Keputusan

| # | Level | Temuan AI | Terbukti? (bukti) | Keputusan | Alasan |
|---|---|---|---|---|---|
| 1 | blocker | `TextEditingController` di dialog tidak di-dispose -> bocor | Ya — grep `TextEditingController` di `notes_page.dart`, tidak ada `dispose` untuk controller dialog | **Diterima + diperbaiki** | Listener controller tetap hidup setelah dialog ditutup; `whenComplete(... dispose)` dipakai |
| 2 | blocker | `retry()` menduplikasi pesan user | Ya — `retry()` memanggil `ask()` yang selalu menambah pesan user; test baru membuktikan `messages.length` jadi 2 | **Diterima + diperbaiki** | Dipisah `_send(q, appendUser: false)` + test `retry tidak menduplikasi pesan user` |
| 3 | saran | `RepaintBoundary` di sekitar `ListView` meningkatkan performa | **Tidak** — `Scrollable`/`Viewport` sudah membuat repaint boundary; tidak ada bukti frame time turun | **Ditolak** (wrapper dihapus) | Menambah layer tanpa dampak terukur = placebo |
| 4 | saran | Debounce input pencarian | Tidak relevan — filter berjalan in-memory (tanpa DB/network) | **Ditolak** | Debounce hanya menambah delay UX |
| 5 | saran | Tambah streaming SSE untuk chat | Tidak wajib — fitur satu halaman, non-streaming + indikator loading cukup | **Ditolak** | Kompleksitas parser SSE tidak sepadan untuk codelab |
| 6 | saran | Pagination daftar catatan | Tidak perlu — data SQLite lokal, jumlah kecil | **Ditolak** | Kompleksitas tanpa manfaat terukur |

## Verifikasi yang Dijalankan
```
flutter analyze                         -> No issues found
dart format --set-exit-if-changed lib test -> 0 file berubah
flutter test                            -> 29 test lulus
grep "TextEditingController" notes_page.dart -> 2 deklarasi, 2 dispose
```

## Catatan
Dua temuan AI (blocker) terbukti benar lewat kode + test, satu temuan (RepaintBoundary) terbukti **salah/placebo** dan ditolak dengan alasan. Inilah alasan review AI tidak boleh diterima mentah: AI bisa benar pada kebocoran resource, tetapi juga bisa menyarankan optimasi yang tidak berdampak.
