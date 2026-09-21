import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/comment_providers.dart';

class CommentPage extends ConsumerWidget {
  const CommentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentListProvider);
    final postId = ref.watch(selectedPostIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Komentar post $postId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(commentListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: commentsAsync.when(
        // State 1: loading.
        loading: () => const Center(child: CircularProgressIndicator()),
        // State 2: error + pesan ramah + tombol retry.
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(friendlyCommentErrorMessage(err),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(commentListProvider),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        // State 3: empty.
        data: (comments) {
          if (comments.isEmpty) {
            return const Center(child: Text('Belum ada komentar.'));
          }
          // State 4: success.
          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return ListTile(
                leading: CircleAvatar(child: Text(comment.id.toString())),
                title: Text(comment.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${comment.email}\n${comment.body}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
