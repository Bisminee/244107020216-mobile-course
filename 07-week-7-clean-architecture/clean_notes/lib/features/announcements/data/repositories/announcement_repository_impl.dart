import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcements_api.dart';
import '../datasources/announcements_database.dart';
import '../models/announcement_model.dart';

/// Implementasi kontrak AnnouncementRepository: cache-first read.
/// Tepatnya kelas ini yang boleh tahu soal HTTP dan SQLite.
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl(
    this._api, {
    Future<Database> Function()? openDb,
    this.forceOffline = false,
  }) : _openDb = openDb ?? openAnnouncementsDatabase;

  final AnnouncementApi _api;
  final Future<Database> Function() _openDb;

  /// Simulasi offline deterministik.
  final bool forceOffline;

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements() async {
    try {
      final cached = await _readCache();
      if (!forceOffline) {
        // Refresh di background, tidak memblokir UI (cache-first).
        unawaitedRefresh();
      }
      return (announcements: cached, failure: null);
    } catch (e) {
      return (
        announcements: const <Announcement>[],
        failure: LocalFailure('Gagal memuat pengumuman: $e'),
      );
    }
  }

  @override
  Future<({int count, Failure? failure})> countCached() async {
    try {
      final db = await _openDb();
      final rows = await db
          .rawQuery('SELECT COUNT(*) AS c FROM cached_announcements');
      return (count: (rows.first['c'] as num?)?.toInt() ?? 0, failure: null);
    } catch (e) {
      return (count: 0, failure: LocalFailure('Gagal menghitung cache: $e'));
    }
  }

  Future<List<Announcement>> _readCache() async {
    final db = await _openDb();
    final rows = await db.query('cached_announcements', orderBy: 'id ASC');
    return rows.map((row) {
      final cachedAt = DateTime.tryParse(row['cached_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final decoded = jsonDecode(row['payload'] as String? ?? '{}');
      return AnnouncementModel.fromJson(
        decoded is Map<String, dynamic> ? decoded : <String, dynamic>{},
        cachedAt: cachedAt,
      ).toEntity();
    }).toList();
  }

  /// Refresh cache dari jaringan. Kegagalan diabaikan: cache lama tetap tampil.
  Future<void> unawaitedRefresh() async {
    try {
      final data = await _api.fetchPosts();
      final db = await _openDb();
      final batch = db.batch();
      batch.delete('cached_announcements');
      final now = DateTime.now().toIso8601String();
      for (final item in data.take(20)) {
        final model = AnnouncementModel.fromJson(item, cachedAt: DateTime.now());
        batch.insert('cached_announcements', {
          'id': model.id,
          'payload': jsonEncode(model.toJson()),
          'cached_at': now,
        });
      }
      await batch.commit(noResult: true);
    } catch (_) {
      // Offline: biarkan cache lama.
    }
  }
}
