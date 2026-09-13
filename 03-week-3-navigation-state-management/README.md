# Tujuan
- menjelaskan konsep navigasi, route, dan perbedaan Navigator 1.0 dengan GoRouter;
- menerapkan navigasi multi-page dengan GoRouter, termasuk passing argument dan deep link sederhana;
- menjelaskan mengapa state management diperlukan dan cara kerja Riverpod (Provider, ConsumerWidget, Notifier);
- menggunakan AsyncValue untuk menangani state loading, error, dan success pada UI;
- membangun aplikasi ToDo dengan navigasi dan Riverpod, lalu memverifikasi hasilnya dengan widget test sederhana.


# Fitur Utama
### Navigation
mekanisme pindah layar. di flutter tiap layar adalah route yang ditumpuk di `Navigator`(stack). cara lama menggunakan `Navigator.push` dan `Navigator.pop` 

GoRouter adalah router deklaratif dengan konsep:

|Konsep         |Penjelasan                                         |
|---------------|---------------------------------------------------|
|GoRoute        |	Definisi path dan widget tujuan, misal /, /detail/:id.|
|context.go()   |	Pindah route (mengganti stack, cocok untuk redirect login).|
|context.push() |	Tumpuk route baru di atas stack (cocok untuk detail).|
|path parameter |	Nilai dinamis pada path, diakses lewat state.pathParameters.|
|extra          |	Mengirim objek antar route (gunakan hati-hati, tidak tersimpan saat proses restart web).|
|redirect       |	Guard navigasi terpusat, misal cek status login.|


### State Management dengan Riverpod
`setState` cukup untuk state lokal satu widget. Namun ketika state harus dibagi antar banyak halaman (misal daftar ToDo yang ditampilkan di Home dan diubah di halaman lain), memindahkan state ke atas widget tree membuat kode rumit (prop drilling). State management memindahkan state keluar dari widget sehingga:

UI dapat dibangun ulang dari state yang sama secara konsisten (UI deklaratif = f(state));
logika bisa diuji tanpa membangun UI;
state tetap hidup meski widget sudah tidak tampil.
Pada mata kuliah ini kita menggunakan Riverpod berbasis `Provider` yang bersifat compile-safe, tidak bergantung pada `BuildContext`, dan mudah diuji.

Konsep inti Riverpod:

|Konsep     |Penjelasan                                             |
|-----------|-------------------------------------------------------|
|ProviderScope|	Wadah global yang menyimpan semua provider, membungkus root aplikasi.|
|Provider|	Nilai read-only/immutable (misal konfigurasi, service).|
|Notifier + NotifierProvider|	State yang bisa berubah melalui method; UI memanggil method, bukan mengubah state langsung.|
|ConsumerWidget|	Widget yang bisa membaca provider lewat ref.|
|ref.watch vs ref.read| watch: build ulang saat state berubah (di dalam build). read: sekali baca (di callback/event).|

# Tech Stack
- Flutter
- Dart

# Cara Menjalankan
cara menjalankannya tergantung pada tujuan, jika tujuannya melakukan debug, lebih mudah menggunakan run debug karena adanya hot reload. jika tujuannya testing lebih baik langsung run flutternya

# Hasil
- Mengetahui Ekosistem mobile dan Flutter
- Mengetahui dasar Dart dan dasar dari framework Flutter
- Mengetahui cara Null Handling 
- Menyiapkan environment untuk git dan FLutter
- Mampu mengubah UI Default di Flutter
- Mampu menyiapkan repository untuk pertemuan 16 minggu
- Mampu mengerjakan mini assignment

# Refleksi
- native lebih cocok digunakan ketika memilki kebutuhan khusus untuk menghubungkan aplikasi dengan sistem operasi langsung, misal membutuhkan akses BLE

- Perubahan state berhubungan dengan widget tree dan UI deklaratif, dengan berubahnya state, maka susunan widget tree juga bisa berubah(terbentuk baru), dengan demikian UI deklaratifnya juga berubah

- commit kecil dengan pesan jelas bermanfaat bagi tim untuk memantau update yang diberikan anggota sehingga bisa melanjutkan pekerjaan yang ada, sedangkan untuk portofolio membantu untuk memperlihatkan kontribusi terhadap projek


# Screenshot
Praktikum 1

add go_router
<img src="screenshots/pub_add_go_router.png" width="350">

kode main
<img src="screenshots/kode_praktikum1_main.png" width="350">

kode home_page
<img src="screenshots/kode_praktikum1_home_page.png" width="350">

kode detail_page
<img src="screenshots/kode_praktikum1_detail_page.png" width="350">

hasil kode
<img src="screenshots/hasil_praktikum1.png" width="350">
