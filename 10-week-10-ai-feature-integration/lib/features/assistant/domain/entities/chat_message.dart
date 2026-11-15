enum ChatRole { user, assistant }

/// Entity pesan chat. Murni: tidak tahu Dio/secure storage.
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    required this.createdAt,
  });

  final ChatRole role;
  final String text;
  final DateTime createdAt;
}
