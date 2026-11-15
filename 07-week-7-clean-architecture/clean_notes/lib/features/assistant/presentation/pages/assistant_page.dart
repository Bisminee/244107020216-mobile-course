import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/chat_message.dart';
import '../providers/assistant_providers.dart';

class AssistantPage extends ConsumerStatefulWidget {
  const AssistantPage({super.key});

  @override
  ConsumerState<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends ConsumerState<AssistantPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final hasKeyAsync = ref.watch(hasApiKeyProvider);
    final hasKey = hasKeyAsync.value ?? false;

    ref.listen(chatProvider, (previous, next) {
      if (next.messages.length != (previous?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asisten AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.key),
            tooltip: 'Atur API key',
            onPressed: _showKeyDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!hasKey) _KeyBanner(onOpenSettings: _showKeyDialog),
          if (chat.error != null)
            _ErrorBanner(
              message: chat.error!,
              onRetry: () => ref.read(chatProvider.notifier).retry(),
              onDismiss: () => ref.read(chatProvider.notifier).clearError(),
            ),
          Expanded(
            child: chat.messages.isEmpty
                ? const _EmptyChat()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: chat.messages.length,
                    itemBuilder: (context, index) =>
                        _Bubble(message: chat.messages[index]),
                  ),
          ),
          if (chat.isSending)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Asisten sedang menulis...'),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !chat.isSending,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: 'Tanyakan sesuatu tentang kampus...',
                        border: OutlineInputBorder(),
                        isDense: true,
                        counterText: '',
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send),
                    tooltip: 'Kirim',
                    onPressed: chat.isSending ? null : _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    ref.read(chatProvider.notifier).ask(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _showKeyDialog() async {
    final controller = TextEditingController();
    String? keyError;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Atur API key AI'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'API key hanya disimpan di secure storage (Keystore/Keychain). '
                'Jangan gunakan data pribadi di percakapan.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: 'API key (write-only)',
                  helperText: 'Key lama tidak pernah ditampilkan ulang.',
                  errorText: keyError,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(assistantRepositoryProvider).clearApiKey();
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
            FilledButton(
              onPressed: () async {
                final value = controller.text.trim();
                // Temuan review: tolak key yang terlalu pendek (kemungkinan typo).
                if (value.length < 20) {
                  setDialogState(
                    () => keyError =
                        'API key terlalu pendek (minimal 20 karakter).',
                  );
                  return;
                }
                await ref.read(assistantRepositoryProvider).saveApiKey(value);
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (saved == true) {
      ref.invalidate(hasApiKeyProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan API key disimpan.')),
        );
      }
    }
  }
}

class _KeyBanner extends StatelessWidget {
  const _KeyBanner({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.orange.withValues(alpha: 0.15),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.info_outline, color: Colors.orange),
        title: const Text('API key AI belum diatur'),
        subtitle: const Text(
          'Fitur AI membutuhkan API key. Tanpa key, permintaan akan gagal '
          'dengan pesan yang jelas (bukan crash).',
        ),
        trailing: TextButton(
          onPressed: onOpenSettings,
          child: const Text('Atur'),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onRetry,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Tutup',
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tanyakan seputar kampus, misalnya jadwal atau prosedur akademik.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Jangan kirim data pribadi (NIK, alamat, nomor HP).',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.text),
      ),
    );
  }
}
