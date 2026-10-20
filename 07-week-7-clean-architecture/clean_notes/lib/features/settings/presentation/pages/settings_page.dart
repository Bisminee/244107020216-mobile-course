import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format.dart';
import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(preferencesProvider);
    final darkMode = ref.watch(darkModeProvider);
    final preferences = preferencesAsync.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode gelap'),
            subtitle: const Text('Disimpan dengan SharedPreferences'),
            secondary: Icon(darkMode ? Icons.dark_mode : Icons.light_mode),
            value: darkMode,
            onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Terakhir dibuka'),
            subtitle: Text(
              preferences?.lastOpenedAt == null
                  ? 'Belum pernah dibuka'
                  : formatDateTime(preferences!.lastOpenedAt!),
            ),
          ),
        ],
      ),
    );
  }
}
