# AI Challenge - Perbandingan Storage Lokal

## Prompt yang Digunakan
    Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
    Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
    untuk dua kebutuhan ini. Requirements:
    - Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
      type-safety, ukuran boilerplate, dan kemudahan testing.
    - Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
      beserta alasannya dalam 1 tabel.
    - Tunjukkan skema tabel/kotak untuk 1000+ catatan.
    Jelaskan trade-off setiap pilihan.

## Tabel Perbandingan Final

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
|---|---|---|---|---|
| Kompleksitas query | Tidak ada (key-value) | Rendah (box + index sederhana) | Sedang-tinggi (SQL bebas) | Tinggi (SQL type-safe, generated) |
| Kebutuhan relasi | Tidak mendukung | Terbatas (manual) | Ya (JOIN, foreign key) | Ya (JOIN, foreign key, migration) |
| Reaktivitas (stream) | Tidak | Ya (`box.watch`) | Tidak (harus invalidate manual) | Ya (`watch()` query) |
| Type-safety | Lemah (bool/int/string saja) | Sedang (adapter manual) | Lemah (Map<String, Object?>) | Kuat (code generation) |
| Ukuran boilerplate | Sangat rendah | Rendah | Sedang (SQL + mapping manual) | Tinggi (build_runner + schema) |
| Kemudahan testing | Mudah (`setMockInitialValues`) | Mudah (in-memory box) | Sedang (fake db / in-memory) | Sedang (in-memory + generated) |
| Cocok untuk | Preferensi kecil | Cache objek sederhana | Data relasional terstruktur | Aplikasi besar, query kompleks |

## Rekomendasi Final

| Kebutuhan | Pilihan | Alasan |
|---|---|---|
| Preferensi tema (dark mode) + waktu terakhir dibuka | **SharedPreferences** | Hanya nilai primitif kecil (bool/string), tidak perlu query maupun relasi. Paling ringan dan paling mudah diuji. |
| CRUD catatan (1000+ baris) | **sqflite (SQLite)** | Butuh query terurut (`ORDER BY updated_at`), filter `dirty = 1`, dan update massal (`markAllSynced`). SQLite juga mendukung transaksi batch untuk cache posts. |

**Keputusan:** kombinasi **SharedPreferences + sqflite**, sesuai codelab. Drift ditolak karena boilerplate `build_runner` tidak sebanding untuk kebutuhan query sesederhana ini, dan Hive ditolak karena data catatan bersifat relasional/terstruktur (butuh order, filter, dan update massal) sehingga SQL lebih tepat.

## Skema untuk 1000+ Catatan

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);

-- Index agar daftar (ORDER BY updated_at DESC) dan antrean sync tetap cepat
-- meski data ribuan baris.
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty);

CREATE TABLE cached_posts(
  id INTEGER PRIMARY KEY,
  payload TEXT NOT NULL,
  cached_at TEXT NOT NULL
);
```

Catatan penting untuk skala 1000+ baris:
- Jangan memuat seluruh tabel ke memori untuk halaman list; gunakan `LIMIT`/`OFFSET` atau `WHERE updated_at < ?` (keyset pagination).
- Update massal sinkronisasi pakai satu statement `UPDATE notes SET dirty = 0 WHERE dirty = 1`, bukan per baris.
- Cache posts ditulis dengan `batch()` agar satu transaksi, bukan insert satu-satu.

## Temuan Verifikasi (AI Verification Checklist)
- AI **tidak** menaruh daftar catatan di SharedPreferences (benar). Jika ada yang menyarankan itu, ditolak karena Serialisasi JSON di key-value membuat query, update parsial, dan sinkronisasi rapuh.
- Skema yang dipakai mendukung antrean sync lewat kolom `dirty` + `updated_at`, bukan CRUD polos.
- Klaim "real-time" hanya valid untuk Hive/Drift (stream). sqflite tidak punya stream otomatis, sehingga UI harus memakai `ref.invalidate` setelah mutasi — itu sebabnya provider Riverpod dipakai.
- Estimasi boilerplate: `flutter pub add sqflite path` langsung jalan tanpa code generation, sementara Drift butuh `build_runner` + file generated (terbukti saat instalasi).
- Keputusan final diverifikasi dengan `flutter analyze` (tanpa issue) dan `flutter test` (semua lulus).
