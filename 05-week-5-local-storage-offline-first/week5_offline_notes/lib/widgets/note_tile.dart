import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/local/note.dart';
import '../data/providers.dart';

// Widget baris catatan; menampilkan badge "belum tersinkron" bila dirty.
class NoteTile extends ConsumerWidget {
  const NoteTile({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: note.dirty
          ? const Tooltip(
              message: 'Belum tersinkron',
              child: Icon(Icons.cloud_off, color: Colors.orange),
            )
          : const Tooltip(
              message: 'Tersinkron',
              child: Icon(Icons.cloud_done, color: Colors.green),
            ),
      title: Text(
        note.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        note.body.isEmpty ? '(tanpa isi)' : note.body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Hapus',
        onPressed: note.id == null
            ? null
            : () => ref.read(notesProvider.notifier).delete(note.id!),
      ),
      onTap: note.id == null ? null : () => context.push('/note/${note.id}'),
    );
  }
}
