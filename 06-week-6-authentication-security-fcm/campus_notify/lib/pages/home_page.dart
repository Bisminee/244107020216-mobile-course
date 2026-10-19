import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/token_store.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPush());
  }

  Future<void> _initPush() async {
    if (!ref.read(enablePushProvider)) return;
    try {
      await ref.read(pushServiceProvider).initAfterLogin(
            go: (route) {
              if (mounted) context.go(route);
            },
          );
    } catch (e) {
      // Tanpa konfigurasi Firebase, push dilewati; login & deep link tetap jalan.
      debugPrint('Push init dilewati: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final debug = ref.watch(debugInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Jadwal kuliah berubah'),
              subtitle: const Text(
                  'Kelas Mobile pindah ke Ruang A2 jam 13.00'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.announcement('3')),
            ),
          ),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.bug_report),
                  title: Text('Debug push (token selalu dipotong)'),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Token FCM'),
                  subtitle: Text(
                    debug.fcmToken == null
                        ? 'Belum tersedia (Firebase belum dikonfigurasi)'
                        : maskToken(debug.fcmToken!),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Refresh terakhir'),
                  subtitle: Text(debug.lastRefresh?.toString() ?? '-'),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Topik langganan'),
                  subtitle: const Text(PushService.topic),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Notifikasi gabungan notification + data: klik dari '
              'foreground/background/terminated akan membuka /pengumuman/:id.',
            ),
          ),
        ],
      ),
    );
  }
}
