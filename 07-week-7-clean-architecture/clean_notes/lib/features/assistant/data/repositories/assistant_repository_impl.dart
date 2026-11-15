import 'package:dio/dio.dart';

import '../../../../core/failures.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../datasources/assistant_api.dart';
import '../datasources/assistant_key_store.dart';

/// Implementasi kontrak Asisten: memanggil API dan memetakan error teknis
/// menjadi Failure yang ramah pengguna.
class AssistantRepositoryImpl implements AssistantRepository {
  AssistantRepositoryImpl(this._api, this._keyStore);

  final AssistantApi _api;
  final AssistantKeyStore _keyStore;

  @override
  Future<({String? answer, Failure? failure})> ask(String question) async {
    try {
      final answer = await _api.ask(question);
      return (answer: answer, failure: null);
    } on MissingApiKeyException {
      return (
        answer: null,
        failure: const AuthFailure(
          'API key AI belum diatur. Buka menu "Atur API key" untuk menambahkan.',
        ),
      );
    } on DioException catch (e) {
      return (answer: null, failure: _mapDio(e));
    } on FormatException {
      return (
        answer: null,
        failure: const NetworkFailure(
          'Respons AI tidak dapat dibaca. Coba lagi.',
        ),
      );
    } catch (e) {
      return (
        answer: null,
        failure: NetworkFailure('Gagal memanggil layanan AI: $e'),
      );
    }
  }

  Failure _mapDio(DioException e) {
    final status = e.response?.statusCode;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          'Layanan AI terlalu lama merespons. Periksa koneksi lalu coba lagi.',
        );
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'Tidak dapat terhubung ke layanan AI. Periksa internet Anda.',
        );
      case DioExceptionType.badResponse:
        if (status == 400 || status == 401 || status == 403) {
          return const AuthFailure(
            'API key AI tidak valid atau tidak punya akses.',
          );
        }
        if (status == 429) {
          return const NetworkFailure(
            'Kuota AI habis atau terlalu banyak permintaan. Coba lagi nanti.',
          );
        }
        return NetworkFailure('Layanan AI bermasalah ($status). Coba lagi.');
      default:
        return const NetworkFailure('Terjadi kesalahan saat memanggil AI.');
    }
  }

  @override
  Future<bool> hasApiKey() async {
    final key = await _keyStore.read();
    return key != null && key.trim().isNotEmpty;
  }

  @override
  Future<void> saveApiKey(String key) => _keyStore.save(key.trim());

  @override
  Future<void> clearApiKey() => _keyStore.clear();
}
