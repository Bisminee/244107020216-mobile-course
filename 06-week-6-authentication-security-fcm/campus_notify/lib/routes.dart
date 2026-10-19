// Semua string rute terpusat di sini agar deep link dari FCM dan GoRouter
// memakai konstanta yang sama (tidak ada magic string yang tersebar).
class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const announcementPattern = '/pengumuman/:id';

  static String announcement(String id) => '/pengumuman/$id';
}

/// Fungsi murni: mengubah data payload FCM menjadi route yang valid.
/// Dibuat terpisah agar bisa diunit-test tanpa Firebase.
String routeFromMessage(Map<String, dynamic> data) {
  final raw = (data['route'] as String? ?? '').trim();
  if (raw.isEmpty) return AppRoutes.home;
  return raw.startsWith('/') ? raw : '/$raw';
}
