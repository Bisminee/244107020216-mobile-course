import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format.dart';
import '../../../../core/widgets/status_views.dart';
import '../providers/announcements_providers.dart';

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);
    final forceOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman (cache-first)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: () => ref.invalidate(announcementsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Force offline'),
            subtitle: const Text(
                'Aktif: hanya cache lokal yang dibaca, tanpa request jaringan'),
            value: forceOffline,
            onChanged: (_) => ref.read(forceOfflineProvider.notifier).toggle(),
          ),
          const Divider(height: 1),
          Expanded(
            child: announcementsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  ErrorView(message: '$error', onRetry: () => ref.invalidate(announcementsProvider)),
              data: (announcements) => announcements.isEmpty
                  ? const EmptyView(
                      message: 'Cache kosong. Matikan force offline lalu muat ulang.',
                    )
                  : ListView.builder(
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        final item = announcements[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text('${item.id}')),
                          title: Text(item.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            'Dicache: ${formatDateTime(item.cachedAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
