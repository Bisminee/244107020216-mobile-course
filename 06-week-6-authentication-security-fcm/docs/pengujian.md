# Catatan Pengujian - Campus Notify

## Hasil Verifikasi Otomatis
- `flutter analyze` → **No issues found**
- `flutter test` → **8 test lulus** (`auth_push_test.dart`)
- 4 test screenshot (`screenshots_test.dart`) di-skip otomatis di `flutter test` biasa;
  dijalankan manual dengan `$env:GEN_SCREENSHOTS=1; flutter test --update-goldens test/screenshots_test.dart`

Test yang lulus:
1. `routeFromMessage` menangani route kosong dan tanpa slash
2. data payload membawa id pengumuman
3. token selalu ditampilkan terpotong (tidak pernah penuh)
4. login menolak email tanpa @ dan sandi < 6 karakter
5. login sukses mengembalikan access + refresh token
6. refresh gagal → sesi dibersihkan (paksa login ulang)
7. `authStateProvider` true setelah login, false setelah logout
8. token tersimpan di store setelah login

Tidak ada Firebase maupun secure storage sungguhan di dalam test:
`FakeTokenStore` di-override lewat `tokenStoreProvider`.

## Matriks Pengujian Tiga App State (WAJIB diisi setelah uji di perangkat)
| State | Yang diharapkan | Cara uji | Hasil |
|---|---|---|---|
| Foreground | Banner lokal muncul, klik masuk ke `/pengumuman/3` | Aplikasi terbuka, kirim dari Firebase Console | |
| Background | Banner sistem muncul, klik masuk ke rute yang benar | Tekan Home, kirim, klik banner | |
| Terminated | Aplikasi terbuka ke rute yang benar via `getInitialMessage` | Swipe-close aplikasi, kirim, klik banner | |

## Yang Masih Perlu Diuji di Perangkat (tidak bisa otomatis)
1. Izin notifikasi muncul saat pertama kali login (Android 13+).
2. Token FCM terisi di kartu **Debug push** (bukan "Belum tersedia").
3. `onRegistered` mengirim token baru setelah **clear data / reinstall**.
4. Notifikasi dari Firebase Console sampai pada ketiga state.
5. Klik notifikasi membuka `/pengumuman/3` (deep link).
6. 401 memicu refresh sekali lalu retry (uji dengan backend yang mengembalikan 401;
   di codelab ini backend masih mock).

## Struktur Folder
```
lib/
├── main.dart
├── router.dart            (GoRouter + guard route)
├── routes.dart            (konstanta rute + routeFromMessage)
├── data/
│   ├── api_client.dart
│   ├── api_errors.dart
│   ├── auth_repository.dart
│   └── token_store.dart
├── providers/
│   └── auth_provider.dart
├── messaging/
│   └── push_service.dart
└── pages/
    ├── announcement_page.dart
    ├── home_page.dart
    └── login_page.dart
```
