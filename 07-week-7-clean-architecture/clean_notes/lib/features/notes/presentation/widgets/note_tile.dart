import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/format.dart';
import '../../../../routes.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

/// Widget baris catatan. Tidak tahu apa-apa soal SQLite maupun mapping.
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatRelative(note.updatedAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus',
            onPressed: note.id == null
                ? null
                : () => ref.read(notesProvider.notifier).remove(note.id!),
          ),
        ],
      ),
      onTap: note.id == null ? null : () => context.push(AppRoutes.note(note.id!)),
    );
  }
}
