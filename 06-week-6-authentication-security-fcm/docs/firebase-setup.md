# Langkah Setup Firebase (FCM) - Campus Notify

Package name / applicationId project ini: **`com.example.campus_notify`**

> Semua langkah di bawah dilakukan di browser + terminal, **tidak bisa
> diotomatiskan** karena butuh login akun Google/Firebase milikmu.

## 1. Buat project Firebase
1. Buka [Firebase Console](https://console.firebase.google.com/).
2. Klik **Add project** → beri nama, mis. `campus-notify`.
3. Google Analytics boleh dimatikan (tidak dipakai di codelab ini).
4. Tunggu sampai project selesai dibuat.

## 2. Daftarkan aplikasi Android
1. Di halaman project, klik ikon **Android**.
2. **Android package name** = `com.example.campus_notify` (harus sama persis).
3. Nickname bebas, mis. `Campus Notify Android`. SHA-1 tidak wajib untuk FCM.
4. Klik **Register app**.
5. **Download `google-services.json`**.
6. Pindahkan file itu ke: `campus_notify/android/app/google-services.json`

> File ini **jangan di-commit** ke repository publik (isinya API key project).
> Tambahkan ke `.gitignore` bila perlu.

## 3. Aktifkan plugin google-services di Gradle

`android/settings.gradle.kts` — tambahkan di dalam blok `plugins { ... }`:
```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```

`android/app/build.gradle.kts` — tambahkan di dalam blok `plugins { ... }`:
```kotlin
id("com.google.gms.google-services")
```

## 4. (Android 13+) Izin notifikasi
`android/app/src/main/AndroidManifest.xml` sudah berisi:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```
Izin ini diminta saat runtime oleh `requestNotificationPermission()`.

## 5. (iOS, opsional)
1. Tambahkan aplikasi iOS di Firebase Console (butuh bundle ID).
2. Unduh `GoogleService-Info.plist` → `ios/Runner/`.
3. Upload **APNs Authentication Key** di Firebase Console → Project Settings →
   Cloud Messaging, lalu aktifkan capability **Push Notifications** di Xcode.

## 6. Jalankan aplikasi di perangkat
```bash
cd campus_notify
flutter pub get
flutter run            # gunakan perangkat fisik (lebih andal untuk FCM)
```
Setelah login, halaman **Beranda** akan:
1. meminta izin notifikasi,
2. mendaftarkan token (`register()` + `onRegistered`),
3. mengirim token ke `POST /devices` (di codelab ini masih simulasi),
4. subscribe topik `pengumuman-kampus`.

Cek token di kartu **Debug push** pada halaman Beranda (selalu terpotong).

## 7. Kirim notifikasi uji dari Firebase Console
1. Firebase Console → **Messaging** → **Create campaign** → **Notifications**.
2. Isi **Notification title** dan **Notification text**:
   - Title: `Jadwal kuliah berubah`
   - Body: `Kelas Mobile pindah ke Ruang A2 jam 13.00`
3. **Advanced options → Custom data** (agar deep link bekerja):
   - Key: `route` → Value: `/pengumuman/3`
   - Key: `id` → Value: `3`
4. **Target** → pilih aplikasi Android Anda (atau topik `pengumuman-kampus`).
5. **Send**.
6. Uji pada tiga state: **foreground** (aplikasi terbuka), **background**
   (tekan Home), dan **terminated** (swipe-close aplikasi). Klik banner →
   aplikasi harus membuka `/pengumuman/3`.

## 8. (Alternatif) Kirim lewat FCM HTTP v1
```json
{
  "message": {
    "topic": "pengumuman-kampus",
    "notification": {
      "title": "Jadwal kuliah berubah",
      "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
    },
    "data": {
      "route": "/pengumuman/3",
      "id": "3"
    }
  }
}
```

## Troubleshooting
| Gejala | Penyebab | Solusi |
|---|---|---|
| Token null | Emulator tanpa Google Play Services | Pakai emulator ber-ikon Play Store atau HP fisik |
| Banner tidak muncul saat foreground | Mengandalkan banner otomatis sistem | Sudah ditangani: `flutter_local_notifications` di `onMessage` |
| Klik notifikasi (terminated) tidak navigasi | `getInitialMessage()` tidak dipanggil | Sudah ditangani `handleTerminated()` |
| `MissingPluginException` | Hot reload setelah tambah plugin | Hentikan aplikasi lalu `flutter run` ulang |
| Build gagal soal desugaring | `flutter_local_notifications` butuh desugaring | Sudah ditambahkan di `app/build.gradle.kts` |
| Notifikasi iOS tidak muncul | Belum ada APNs key | Konfigurasi APNs + aktifkan Push di Xcode |
