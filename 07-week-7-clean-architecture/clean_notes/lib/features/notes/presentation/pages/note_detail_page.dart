import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format.dart';
import '../../../../core/widgets/status_views.dart';
import '../providers/notes_providers.dart';

/// Halaman detail catatan (route /notes/:id).
class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            ErrorView(message: '$error', onRetry: () => ref.invalidate(noteDetailProvider(id))),
        data: (note) {
          if (note == null) {
            return const EmptyView(message: 'Catatan tidak ditemukan.');
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.title,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      note.dirty ? Icons.cloud_off : Icons.cloud_done,
                      size: 16,
                      color: note.dirty ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      note.dirty ? 'Belum tersinkron' : 'Tersinkron',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Diperbarui: ${formatDateTime(note.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Text(note.body.isEmpty ? '(tanpa isi)' : note.body),
              ],
            ),
          );
        },
      ),
    );
  }
}
