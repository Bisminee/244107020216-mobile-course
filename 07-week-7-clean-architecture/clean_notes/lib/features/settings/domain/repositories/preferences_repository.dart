import '../../../../core/failures.dart';
import '../entities/app_preferences.dart';

/// Kontrak repository preferensi.
abstract class PreferencesRepository {
  Future<({AppPreferences preferences, Failure? failure})> readPreferences();

  Future<({bool saved, Failure? failure})> saveDarkMode(bool value);

  Future<({bool saved, Failure? failure})> markOpenedNow();
}
