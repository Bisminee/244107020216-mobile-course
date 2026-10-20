import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Database khusus fitur pengumuman (terpisah dari fitur notes).
Future<Database> openAnnouncementsDatabase() async {
  final dir = await getDatabasesPath();
  return openDatabase(
    p.join(dir, 'clean_announcements.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE cached_announcements(
          id INTEGER PRIMARY KEY,
          payload TEXT NOT NULL,
          cached_at TEXT NOT NULL
        )
      ''');
    },
  );
}
