import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/status_views.dart';
import '../../../../routes.dart';
import '../providers/notes_providers.dart';
import '../widgets/note_tile.dart';

/// Halaman catatan. Tidak ada SQL, tidak ada Dio, tidak ada parsing JSON.
/// Halaman ini hanya membaca state dari provider.
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyAsync = ref.watch(dirtyCountProvider);
    final dirtyCount = dirtyAsync.value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan (Clean Architecture)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Sinkronkan',
            onPressed: () async {
              final synced = await ref.read(notesProvider.notifier).sync();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(synced == 0
                      ? 'Tidak ada catatan yang perlu disinkronkan.'
                      : '$synced catatan tersinkron.'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_queue),
            tooltip: 'Pengumuman',
            onPressed: () => context.push(AppRoutes.announcements),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Pengaturan',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          _DirtyBanner(count: dirtyCount),
          Expanded(
            child: notesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorView(
                message: '$error',
                onRetry: () => ref.invalidate(notesProvider),
              ),
              data: (notes) => notes.isEmpty
                  ? const EmptyView(
                      message: 'Belum ada catatan. Tambahkan lewat tombol +.',
                    )
                  : ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) =>
                          NoteTile(note: notes[index]),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catatan baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Isi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(notesProvider.notifier).add(
                    title: titleController.text,
                    body: bodyController.text,
                  );
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _DirtyBanner extends StatelessWidget {
  const _DirtyBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final pending = count > 0;
    return Material(
      color: pending
          ? Colors.orange.withValues(alpha: 0.15)
          : Colors.green.withValues(alpha: 0.15),
      child: ListTile(
        dense: true,
        leading: Icon(
          pending ? Icons.pending_actions : Icons.check_circle,
          color: pending ? Colors.orange : Colors.green,
        ),
        title: Text(
          pending ? '$count catatan belum tersinkron' : 'Semua catatan tersinkron',
        ),
      ),
    );
  }
}
