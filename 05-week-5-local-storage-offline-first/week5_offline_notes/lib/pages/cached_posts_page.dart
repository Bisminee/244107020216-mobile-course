import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sync.dart';

class CachedPostsPage extends ConsumerWidget {
  const CachedPostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsCacheProvider);
    final forceOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (cache-first)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: () => ref.invalidate(postsCacheProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle simulasi offline agar demo tidak bergantung Wi-Fi.
          SwitchListTile(
            title: const Text('Force offline'),
            subtitle: const Text(
                'Aktif: hanya cache lokal yang dibaca, tanpa request jaringan'),
            value: forceOffline,
            onChanged: (_) => ref.read(forceOfflineProvider.notifier).toggle(),
          ),
          const Divider(height: 1),
          Expanded(
            child: postsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Gagal memuat: $err')),
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(
                    child: Text(
                      'Cache kosong. Matikan force offline lalu muat ulang.',
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${post.id}')),
                      title: Text(post.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        'Dicache: ${post.cachedAt.toLocal()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
