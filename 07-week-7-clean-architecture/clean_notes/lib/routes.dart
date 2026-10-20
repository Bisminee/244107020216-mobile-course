// Konstanta rute terpusat (satu sumber kebenaran untuk GoRouter).
class AppRoutes {
  static const home = '/';
  static const settings = '/settings';
  static const announcements = '/announcements';
  static const notePattern = '/notes/:id';

  static String note(int id) => '/notes/$id';
}
