# Tujuan
- Menjelaskan prinsip declarative UI dan hubungan antara widget, konfigurasi, serta state.
- Menggunakan StatelessWidget, StatefulWidget, Container, Row, Column, dan Expanded.
- Membedakan komponen Material 3 dan Cupertino untuk kebutuhan platform yang berbeda.
- Membangun layout responsif untuk ukuran layar mobile dan tablet.
- Menerapkan theme, dark mode, styling, dan aksesibilitas dasar.

# Fitur Utama
- row
- column
- MaterialApp
- Responsive Layout
- Theme

# Tech Stack
- Flutter

# Cara Menjalankan

1. Pastikan Flutter sudah terinstall.
2. Clone repository ini.
3. Masuk ke folder project.
`cd nama-project`
4. Jalankan perintah berikut untuk mengambil dependency:
`flutter pub get`
5. Jalankan aplikasi:
`flutter run`

# Hasil
- Dapat menjelaskan prinsip Declarative UI dan hubungan antara widget, konfigurasim serta state
- Bisa menggunakan StatelessWidget, StatefulWidget, COntainer, Row, Column, dan Expanded
- Bisa membedakan komponen material3 dan Cupertino
- Bisa membangun layout responsive
- Bisa menerapkan dark mode, styling, dan aksesibilitas dasar

# Refleksi
- imperative lebih berfokus pada langkah atau proses bagaimana UI diubah, sedangkan declarative lebih berfokus pada seperti apa UI yang diinginkan berdasarkan kondisi atau state yang ada

- `Expanded` membantu ketika ingin membagi ruang yang tersedia pada `Row` atau `Column` secara fleksibel, tetapi bisa menghasilkan layout error ketika digunakan pada parent yang tidak memiliki batas ukuran yang jelas atau constraint yang sesuai

- breakpoint memengaruhi bagaimana layout menyesuaikan ukuran layar, misalnya pada layar kecil menggunakan satu kolom dan pada layar lebih besar menggunakan dua kolom, sedangkan theme memengaruhi tampilan seperti warna dan dark mode sehingga tampilan dapat menyesuaikan kebutuhan dan kondisi pengguna

- rekomendasi dari AI perlu diverifikasi dengan mencoba menjalankan kode dan melihat hasilnya secara langsung, terutama memastikan tidak terjadi error atau overflow, serta memastikan hasilnya sesuai dengan kebutuhan dan memahami kode yang diberikan sebelum digunakan



# Screenshot
Kode Warm Up 

<img src="screenshots/kode-warmup1.png" width="350">
<img src="screenshots/kode-warmup2.png" width="350">

Hasil Warm Up

<img src="screenshots/warmup.png" width="350">

## Eksperimen Warm Up
<img src="screenshots/hapus-expanded.png" width="350">
tidak bisa dijalankan dan tidak ada peringatan overflow


Ganti mainAxisSize

<img src="screenshots/main-axis-max.png" width="200">

Kode penambahan baris baru

<img src="screenshots/kode-email.png" width="350">

Hasil penambahan baris baru

<img src="screenshots/hasil-kode-email.png" width="350">

## Praktikum: dashboard responsif

Kode Dashboard Responsive

<img src="screenshots/kode-dashboard-responsive1.png" width="400">
<img src="screenshots/kode-dashboard-responsive2.png" width="400">
<img src="screenshots/kode-dashboard-responsive3.png" width="400">

Hasil Kode

<img src="screenshots/hasil-kode-responsive.png" width="200">

ubah breakpoint

<img src="screenshots/breakpoint-change1.png" width="400">
<img src="screenshots/breakpoint-change2.png" width="400">
tidak ada perubahan di perubahan angka break point, hanya berubah di angka antara 300 - 400


Ukuran layar berbeda

Samsung S8+ Ultra

<img src="screenshots/tampilan-samsung-s8+-ultra.png" width="400">
Samsung Z Fold

<img src="screenshots/tampilan-samsung-z-fold.png" width="400">

Semantics

<img src="screenshots/semantics.png" width="400">

# Tugas dan AI design exploration

<img src="screenshots/AI1.png" width="400">
<img src="screenshots/AI2.png" width="400">
<img src="screenshots/AI3.png" width="400">
<img src="screenshots/AI4.png" width="400">
<img src="screenshots/AI5.png" width="400">
<img src="screenshots/AI6.png" width="400">
<img src="screenshots/AI7.png" width="400">

# Kode AI

<img src="screenshots/kode_AI1.png" width="400">
<img src="screenshots/kode_AI2.png" width="400">


Hasil kode AI
<img src="screenshots/Hasil_kode_AI.png" width="400">

kalau diihat dari hasilnya tampilan menjadi lebih responsive, lalu tidak butuh 2 import package

<img src="screenshots/hasil_analyze.png" width="400">

# Testing dasar

<img src="screenshots/hasil_flutter_test.png" width="600">
