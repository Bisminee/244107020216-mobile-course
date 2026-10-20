import '../../../../core/failures.dart';
import '../entities/app_preferences.dart';
import '../repositories/preferences_repository.dart';

/// Use case: aktifkan/nonaktifkan mode gelap.
class ToggleDarkMode {
  const ToggleDarkMode(this._repository);
  final PreferencesRepository _repository;

  Future<({AppPreferences preferences, Failure? failure})> call({
    required bool currentValue,
  }) async {
    final next = !currentValue;
    final saved = await _repository.saveDarkMode(next);
    if (saved.failure != null) {
      return (preferences: const AppPreferences(), failure: saved.failure);
    }
    return (preferences: AppPreferences(darkMode: next), failure: null);
  }
}
