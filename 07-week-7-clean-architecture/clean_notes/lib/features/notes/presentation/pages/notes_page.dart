import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/status_views.dart';
import '../../../../routes.dart';
import '../providers/notes_providers.dart';
import '../widgets/note_tile.dart';

/// Halaman catatan. Tidak ada SQL, tidak ada Dio, tidak ada parsing JSON.
/// Pencarian hanya mengubah state query; filter judul dijalankan use case domain.
class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(filteredNotesProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan (Clean Architecture)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Asisten AI',
            onPressed: () => context.push(AppRoutes.assistant),
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Sinkronkan',
            onPressed: () async {
              final synced = await ref.read(notesProvider.notifier).sync();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    synced == 0
                        ? 'Tidak ada catatan yang perlu disinkronkan.'
                        : '$synced catatan tersinkron.',
                  ),
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
          const _DirtyBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).setQuery(value),
              decoration: InputDecoration(
                hintText: 'Cari judul catatan...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Hapus pencarian',
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).clear();
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorView(
                message: '$error',
                onRetry: () => ref.invalidate(notesProvider),
              ),
              data: (notes) {
                if (notes.isEmpty) {
                  return EmptyView(
                    message: query.isEmpty
                        ? 'Belum ada catatan. Tambahkan lewat tombol +.'
                        : 'Tidak ada catatan yang cocok dengan "$query".',
                  );
                }
                return RepaintBoundary(
                  child: ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) =>
                        NoteTile(note: notes[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
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
              ref
                  .read(notesProvider.notifier)
                  .add(title: titleController.text, body: bodyController.text);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    ).whenComplete(() {
      // Perbaikan review: controller tidak boleh bocor setelah dialog ditutup.
      titleController.dispose();
      bodyController.dispose();
    });
  }
}

class _DirtyBanner extends ConsumerWidget {
  const _DirtyBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Optimasi: select() membuat banner hanya rebuild saat NILAI count
    // berubah, bukan setiap kali AsyncValue berganti loading/data.
    final count = ref.watch(dirtyCountProvider.select((v) => v.value ?? 0));
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
          pending
              ? '$count catatan belum tersinkron'
              : 'Semua catatan tersinkron',
        ),
      ),
    );
  }
}
