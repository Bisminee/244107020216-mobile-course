# AI Challenge - PushService

## Prompt yang Digunakan
    Aplikasi Flutter Campus Notification App.
    Stack: firebase_messaging, flutter_local_notifications,
    flutter_secure_storage, go_router, Riverpod.
    Buatkan PushService dengan:
    - requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
    - onMessage (tampilkan local notification manual)
    - onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
    - subscribe/unsubscribe topic pengumuman-kampus
    - background handler top-level dengan @pragma('vm:entry-point')
    Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
    dan bagian yang tidak boleh mengakses BuildContext.

## Hasil dan Perbaikan Manual
File hasil: `lib/messaging/push_service.dart`.

| Bagian | Isi | Perbaikan / catatan |
|---|---|---|
| Background handler | `firebaseMessagingBackgroundHandler` top-level + `@pragma('vm:entry-point')` | Sesuai; hanya `debugPrint`, tidak menyentuh `BuildContext`/Riverpod |
| Permission | `requestNotificationPermission()` | Android 13+ dan iOS sama-sama memanggil `requestPermission()`; bedanya iOS butuh APNs key di console |
| Local notification | `initLocalNotifications()` | Signature API berubah di v22: `initialize({settings: ...})` dan `show({id: ...})` — kode menyesuaikan versi terpasang |
| Token lifecycle | `initTokenLifecycle()` | **Perbaikan penting**: `getToken()`/`onTokenRefresh` sudah deprecated di firebase_messaging 17. Diganti `register()` + `onRegistered` (dan `onUnregistered`) agar `flutter analyze` bersih |
| Kirim token ke backend | `_sendTokenToBackend()` → `POST /devices` | Dibungkus try/catch karena backend kampus belum ada; token juga tidak pernah di-log penuh |
| Foreground | `listenForeground()` | Banner manual via `flutter_local_notifications` (sistem tidak menampilkannya otomatis) |
| Background klik | `onMessageOpenedApp` | `go(routeFromMessage(message.data))` |
| Terminated | `handleTerminated()` | `getInitialMessage()` + `pendingDeepLink` |
| Topic | `subscribeAnnouncementTopic()` | Topik `pengumuman-kampus` (broadcast), bukan token personal |

## AI Verification Checklist (temuan)
- [x] Background handler berupa fungsi top-level dengan `@pragma('vm:entry-point')` — bukan method kelas.
- [x] `register()` + `onRegistered` benar-benar mengirim token baru ke backend (`POST /devices`), bukan hanya dicetak ke log.
- [x] Foreground memakai local notification manual.
- [x] Klik dari ketiga state diarahkan ke `data.route` melalui `routeFromMessage()` (fungsi murni, ada unit test-nya).
- [x] Token tidak di-hardcode dan selalu ditampilkan terpotong (`maskToken`, `maskForLog`).
- [x] `flutter analyze` tanpa issue dan `flutter test` lulus.

## Keputusan Teknis Sendiri
1. **`routeFromMessage()` diekstrak sebagai fungsi murni** di `lib/routes.dart` supaya bisa diunit-test tanpa Firebase (refactoring challenge no. 2).
2. **Rute dipusatkan di `AppRoutes`** supaya deep link FCM dan GoRouter memakai konstanta yang sama (refactoring challenge no. 1).
3. **Pemetaan error Dio dipisah** ke `lib/data/api_errors.dart` supaya UI hanya menerima pesan (refactoring challenge no. 3).
4. **Adaptasi versi**: mengikuti API terbaru `firebase_messaging` 17 dan `flutter_local_notifications` 22 walaupun codelab masih memakai API lama — ini keputusan sadar agar kode bersih dari API deprecated.
