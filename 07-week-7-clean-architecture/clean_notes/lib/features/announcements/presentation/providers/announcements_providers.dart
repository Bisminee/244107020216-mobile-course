import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../data/datasources/announcements_api.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';

// ===== Data layer =====
final announcementApiProvider = Provider<AnnouncementApi>((ref) {
  return AnnouncementApi();
});

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(
    ref.watch(announcementApiProvider),
    forceOffline: ref.watch(forceOfflineProvider),
  );
});

// ===== Domain layer =====
final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

/// Toggle simulasi offline (tidak bergantung kondisi Wi-Fi kelas).
final forceOfflineProvider = NotifierProvider<ForceOfflineNotifier, bool>(
  ForceOfflineNotifier.new,
);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

// ===== Presentation layer =====
final announcementsProvider =
    FutureProvider<List<Announcement>>((ref) async {
  final result = await ref.watch(getAnnouncementsProvider).call();
  if (result.failure != null) {
    throw FailureException(result.failure!);
  }
  return result.announcements;
});
