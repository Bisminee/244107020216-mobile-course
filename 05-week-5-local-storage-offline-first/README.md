# Tujuan
- menjelaskan perbedaan penyimpanan key-value, relasional, dan NoSQL di perangkat;
- menyimpan preferensi sederhana (tema, terakhir dibuka) dengan SharedPreferences;
- menerapkan CRUD catatan dengan SQLite (sqflite) melalui repository lokal;
- menerapkan pola offline-first: cache-first read, dirty flag, dan antrean sinkronisasi;
- menampilkan state loading, error, empty, dan success untuk data lokal dengan Riverpod;
- menguji repository lokal dengan repository palsu (tanpa database sungguhan).


# Fitur Utama
### Jenis Penyimpanan Lokal
HTTP adalah protokol request–response: client mengirim request (method + URL + header + body), server membalas dengan status code + body. REST memetakan operasi ke resource melalui URL dan method HTTP.

|Kebutuhan     |Pilihan                 |Contoh             |
|--------------|------------------------|-------------------|
|Pengaturan kecil key-value|`SharedPreferences`|tema gelap/terang, bahasa, waktu terakhir dibuka|
|Data terstruktur relasional   |`SQLite via sqflite`|catatan, tugas, transaksi|
|NoSQL ringan embedded|`Hive`|cache objek, kotak (box) sederhana|
|Relasional reaktif & type-safe|`Drift`|aplikasi besar dengan query kompleks + stream
|

Codelab ini memakai SharedPreferences + SQLite (sqflite): kombinasi paling umum di industri untuk aplikasi offline notes. Tabel perbandingan Hive vs Drift wajib Anda isi pada AI Challenge sebagai bukti pengambilan keputusan.


### Offline-first, bukan offline-only
Offline-first berarti aplikasi **selalu bisa dibaca dan ditulis** meski tanpa internet, lalu **disinkronkan** saat koneksi kembali. Tiga mekanisme intinya:

- **Cache-first read**: tampilkan data lokal seketika, lalu refresh dari jaringan di background dan simpan hasilnya.
- **Dirty flag**: setiap perubahan lokal yang belum terkirim ditandai (`dirty = 1`) agar bisa di-sync belakangan.
- **Antrean sinkronisasi**: operasi tertunda diproses berurutan saat online; konflik diselesaikan dengan aturan eksplisit (misalnya last-write-wins berdasarkan `updated_at`).
```
UI (ConsumerWidget) --watch--> Provider (AsyncValue)
Provider --panggil--> LocalRepository --CRUD--> SQLite
LocalRepository --sync--> Remote (simulasi) --sukses--> dirty = 0
Cache: baca lokal dulu, refresh background, simpan
```
### Repository untuk data lokal
Aturan arsitektur yang sama seperti Minggu 4 tetap berlaku, hanya sumber datanya berubah:

- **UI tidak boleh memanggil SQLite/SharedPreferences secara langsung**. UI hanya membaca provider.
- **Repository lokal** adalah satu-satunya pintu ke database dan preferensi. Ia mengubah exception platform menjadi kegagalan bermakna bagi UI.
- **Provider Riverpod** mengekspos AsyncValue (loading/error/data) dan fungsi invalidate untuk refresh.
