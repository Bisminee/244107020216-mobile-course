import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../data/repositories/preferences_repository_impl.dart';
import '../../domain/entities/app_preferences.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../domain/usecases/toggle_dark_mode.dart';

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepositoryImpl();
});

final toggleDarkModeProvider = Provider<ToggleDarkMode>((ref) {
  return ToggleDarkMode(ref.watch(preferencesRepositoryProvider));
});

final preferencesProvider = FutureProvider<AppPreferences>((ref) async {
  final result = await ref.watch(preferencesRepositoryProvider).readPreferences();
  if (result.failure != null) throw FailureException(result.failure!);
  return result.preferences;
});

/// Notifikasi ke seluruh app saat tema berubah.
final darkModeProvider = NotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class DarkModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Baca nilai awal dari repository, lalu biarkan state yang di-toggle.
    final prefs = ref.watch(preferencesProvider);
    return prefs.value?.darkMode ?? false;
  }

  Future<void> toggle() async {
    final result = await ref
        .read(toggleDarkModeProvider)
        .call(currentValue: state);
    if (result.failure != null) return;
    state = result.preferences.darkMode;
    ref.invalidate(preferencesProvider);
  }
}
