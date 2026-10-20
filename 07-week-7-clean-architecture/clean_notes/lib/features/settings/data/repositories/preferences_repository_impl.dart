import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/app_preferences.dart';
import '../../domain/repositories/preferences_repository.dart';

/// Implementasi kontrak preferensi memakai SharedPreferences.
class PreferencesRepositoryImpl implements PreferencesRepository {
  PreferencesRepositoryImpl({this.preferences});

  static const _darkModeKey = 'dark_mode';
  static const _lastOpenedKey = 'last_opened_at';

  SharedPreferences? preferences;

  Future<SharedPreferences> _prefs() async {
    return preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<({AppPreferences preferences, Failure? failure})> readPreferences() async {
    try {
      final prefs = await _prefs();
      return (
        preferences: AppPreferences(
          darkMode: prefs.getBool(_darkModeKey) ?? false,
          lastOpenedAt: DateTime.tryParse(
            prefs.getString(_lastOpenedKey) ?? '',
          ),
        ),
        failure: null,
      );
    } catch (e) {
      return (
        preferences: const AppPreferences(),
        failure: LocalFailure('Gagal memuat preferensi: $e'),
      );
    }
  }

  @override
  Future<({bool saved, Failure? failure})> saveDarkMode(bool value) async {
    try {
      final prefs = await _prefs();
      await prefs.setBool(_darkModeKey, value);
      return (saved: true, failure: null);
    } catch (e) {
      return (saved: false, failure: LocalFailure('Gagal menyimpan tema: $e'));
    }
  }

  @override
  Future<({bool saved, Failure? failure})> markOpenedNow() async {
    try {
      final prefs = await _prefs();
      await prefs.setString(_lastOpenedKey, DateTime.now().toIso8601String());
      return (saved: true, failure: null);
    } catch (e) {
      return (saved: false, failure: LocalFailure('Gagal menyimpan waktu: $e'));
    }
  }
}
