import 'package:flutter/material.dart';

// Halaman tujuan deep link dari notifikasi (data.route = /pengumuman/:id).
class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengumuman #$id')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jadwal kuliah berubah',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Kategori: Akademik',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'Kelas Pemrograman Mobile pindah ke Ruang A2 mulai pekan ini, '
              'jam 13.00. Harap menyesuaikan jadwal masing-masing.',
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Dibuka dari deep link FCM'),
                subtitle: Text('/pengumuman/$id'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
