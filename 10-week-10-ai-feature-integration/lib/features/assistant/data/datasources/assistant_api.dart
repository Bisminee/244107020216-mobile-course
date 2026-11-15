import 'package:dio/dio.dart';

import 'assistant_key_store.dart';

/// Dilempar bila API key belum diatur, agar repository bisa memetakan
/// ke pesan yang ramah pengguna.
class MissingApiKeyException implements Exception {
  const MissingApiKeyException();
}

/// Data source HTTP ke Google Gemini.
/// API key dikirim lewat header `x-goog-api-key`, BUKAN query URL,
/// supaya tidak tercatat di log server/proxy.
class AssistantApi {
  AssistantApi({Dio? dio, required this.keyStore})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://generativelanguage.googleapis.com',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Content-Type': 'application/json'},
            ),
          );

  final Dio _dio;
  final AssistantKeyStore keyStore;

  /// Bisa diganti sesuai model yang tersedia di akunmu.
  static const model = 'gemini-2.0-flash';

  /// System prompt: membatasi persona, bahasa, panjang, dan privasi.
  static const systemPrompt =
      'Kamu asisten kampus yang ramah. Jawab dalam Bahasa Indonesia, '
      'maksimal 3 kalimat, tanpa data pribadi. Jika tidak tahu, katakan '
      'tidak tahu dan sarankan menghubungi admin kampus.';

  Future<String> ask(String question) async {
    final key = await keyStore.read();
    if (key == null || key.trim().isEmpty) {
      throw const MissingApiKeyException();
    }

    final response = await _dio.post(
      '/v1beta/models/$model:generateContent',
      options: Options(headers: {'x-goog-api-key': key}),
      data: {
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': question},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 256},
      },
    );

    final data = response.data;
    final candidates = data is Map<String, dynamic> ? data['candidates'] : null;
    if (candidates is List && candidates.isNotEmpty) {
      final content = candidates.first['content'];
      final parts = content is Map ? content['parts'] : null;
      if (parts is List && parts.isNotEmpty) {
        final text = parts.first['text'];
        if (text is String && text.trim().isNotEmpty) return text.trim();
      }
    }
    throw FormatException('Respons AI tidak berisi teks.');
  }
}
