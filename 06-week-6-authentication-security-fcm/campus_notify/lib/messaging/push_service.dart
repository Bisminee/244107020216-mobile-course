import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

/// Background handler WAJIB fungsi top-level (berjalan di isolate terpisah).
/// Jangan akses BuildContext / Riverpod di sini.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM background] id=${message.messageId}');
}

class PushService {
  PushService(this._ref);

  final Ref _ref;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const topic = 'pengumuman-kampus';

  /// Deep link yang tertunda dari klik banner foreground.
  String? pendingDeepLink;

  /// Dipanggil setelah user berhasil login.
  Future<void> initAfterLogin({
    required void Function(String route) go,
  }) async {
    registerBackgroundHandler();
    await requestNotificationPermission();
    await initLocalNotifications();
    await initTokenLifecycle();
    await subscribeAnnouncementTopic();
    listenForeground(go);
    await handleTerminated(go);
  }

  void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Android 13+ dan iOS wajib meminta izin runtime.
  Future<bool> requestNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        // Klik banner foreground -> teruskan payload ke router.
        pendingDeepLink = response.payload;
      },
    );
  }

  /// Token lifecycle.
  ///
  /// Catatan versi: pada `firebase_messaging` 17+, `getToken()` dan
  /// `onTokenRefresh` sudah deprecated. Penggantinya adalah `register()`
  /// + stream `onRegistered` (berisi Firebase Installation ID / target
  /// pengiriman langsung), dan `onUnregistered` untuk mencabut token di
  /// backend. Pola pengiriman ke backend tetap sama.
  Future<void> initTokenLifecycle() async {
    await FirebaseMessaging.instance.register();

    FirebaseMessaging.instance.onRegistered.listen((id) async {
      _ref.read(debugInfoProvider.notifier).setFcmToken(id);
      await _sendTokenToBackend(id);
    });

    FirebaseMessaging.instance.onUnregistered.listen((id) async {
      debugPrint('[FCM] token dicabut, hapus di backend: ${maskForLog(id)}');
    });
  }

  /// Simulasi pendaftaran token ke backend kampus.
  /// Endpoint nyata: POST /devices { fcm_token, platform }.
  Future<void> _sendTokenToBackend(String token) async {
    try {
      final dio = _ref.read(apiDioProvider);
      await dio.post('/devices', data: {
        'fcm_token': token,
        'platform': defaultTargetPlatform.name,
      });
    } catch (_) {
      // Backend kampus belum tersedia di codelab ini; kegagalan diabaikan.
      debugPrint('[FCM] gagal kirim token ke backend (simulasi)');
    }
  }

  Future<void> subscribeAnnouncementTopic() =>
      FirebaseMessaging.instance.subscribeToTopic(topic);

  Future<void> unsubscribeAnnouncementTopic() =>
      FirebaseMessaging.instance.unsubscribeFromTopic(topic);

  /// Foreground: sistem TIDAK menampilkan banner otomatis,
  /// jadi tampilkan manual lewat local notification.
  void listenForeground(void Function(String route) go) {
    FirebaseMessaging.onMessage.listen((message) async {
      final route = routeFromMessage(message.data);
      const androidDetails = AndroidNotificationDetails(
        'pengumuman',
        'Pengumuman Kampus',
        importance: Importance.high,
        priority: Priority.high,
      );
      await _local.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'Pengumuman',
        body: message.notification?.body ?? '',
        notificationDetails: const NotificationDetails(android: androidDetails),
        payload: route,
      );
    });

    // Background -> diklik.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      go(routeFromMessage(message.data));
    });
  }

  /// Terminated -> aplikasi dibuka dari notifikasi.
  Future<void> handleTerminated(void Function(String route) go) async {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) go(routeFromMessage(initial.data));
    if (pendingDeepLink != null) go(pendingDeepLink!);
    pendingDeepLink = null;
  }
}

/// Token di log juga selalu terpotong.
String maskForLog(String token) =>
    token.length <= 12 ? '***' : '${token.substring(0, 12)}...';

final pushServiceProvider = Provider<PushService>((ref) => PushService(ref));
