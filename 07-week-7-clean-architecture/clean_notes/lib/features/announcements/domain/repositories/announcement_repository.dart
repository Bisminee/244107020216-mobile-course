import '../../../../core/failures.dart';
import '../entities/announcement.dart';

/// Kontrak repository fitur pengumuman.
abstract class AnnouncementRepository {
  /// Cache-first: baca cache lokal dulu, refresh jaringan di background.
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements();

  Future<({int count, Failure? failure})> countCached();
}
