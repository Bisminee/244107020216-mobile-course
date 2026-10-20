// Entity murni fitur pengumuman.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.cachedAt,
  });

  final int id;
  final String title;
  final String body;
  final DateTime cachedAt;
}
