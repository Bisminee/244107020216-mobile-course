// Entity preferensi aplikasi (murni, tanpa Flutter).
class AppPreferences {
  const AppPreferences({
    this.darkMode = false,
    this.lastOpenedAt,
  });

  final bool darkMode;
  final DateTime? lastOpenedAt;

  AppPreferences copyWith({bool? darkMode, DateTime? lastOpenedAt}) {
    return AppPreferences(
      darkMode: darkMode ?? this.darkMode,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }
}
