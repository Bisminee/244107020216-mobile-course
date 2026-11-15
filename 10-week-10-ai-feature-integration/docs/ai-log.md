# AI Log - Integrasi Fitur AI (Minggu 10)

## 1. Prompt Sistem (system prompt)

```
Kamu asisten kampus yang ramah. Jawab dalam Bahasa Indonesia, maksimal 3 kalimat,
tanpa data pribadi. Jika tidak tahu, katakan tidak tahu dan sarankan menghubungi
admin kampus.
```

Dikirim sebagai `systemInstruction` ke Gemini, terpisah dari pertanyaan pengguna.

## 2. Prompt Pengguna (user prompt)

```
Apa itu KRS?
```

Tidak ada NIK, alamat, nomor HP, atau token yang dikirim. Batas panjang 500 karakter
divalidasi di use case sebelum request.

## 3. Output Awal AI (ringkas)

AI mengusulkan `AiService` dengan `http` dan:

```dart
final url = '$_apiUrl?key=$apiKey';   // API key di QUERY URL
```

Masalah yang ditemukan saat verifikasi:
1. **API key di query URL** berisiko tercatat di log server/proxy/history.
2. Tidak ada pemetaan error (semua error jadi `Exception` mentah).
3. Tidak ada fallback UI (aplikasi bisa error tanpa pesan jelas).
4. Key disimpan lewat parameter biasa, tidak jelas apakah aman.

## 4. Keputusan & Perbaikan Manual

| Usulan AI | Keputusan | Alasan |
|---|---|---|
| API key di query `?key=` | **Tolak** | Ganti ke header `x-goog-api-key` agar tidak muncul di URL/log |
| Menyimpan key di variabel/SharedPreferences | **Tolak** | Pakai `flutter_secure_storage` (Keystore/Keychain) |
| `Exception` mentah | **Tolak** | Petakan ke `Failure` + pesan ramah pengguna |
| Tanpa fallback | **Tolak** | Tambah banner error + tombol "Coba lagi" + banner "API key belum diatur" |
| Model `gemini-pro` | **Sesuaikan** | Pakai `gemini-2.0-flash` (konstanta mudah diganti) |
| Validasi input | **Terima + tambah** | Use case menolak pertanyaan kosong / > 500 karakter |
| Streaming SSE | **Tolak** | Kompleksitas parser tidak sepadan untuk satu halaman |

## 5. Arsitektur Akhir

```
presentation  assistant_page.dart, assistant_providers.dart
      |
      v
domain        ChatMessage, AssistantRepository (kontrak), AskAssistant (validasi)
      ^
      |
data          AssistantApi (Gemini), AssistantKeyStore (secure), AssistantRepositoryImpl
```

- Tidak ada API key di source code.
- Key tidak pernah ditampilkan ulang (write-only).
- `domain` bebas Flutter/Dio/secure storage.

## 6. Tabel Risiko + Mitigasi

| Risiko | Mitigasi |
|---|---|
| Bocor data pengguna | System prompt melarang data pribadi + UI mengingatkan; tidak kirim NIK/alamat/HP |
| API key bocor | Disimpan di `flutter_secure_storage`, dikirim lewat header, tidak ditampilkan/log |
| Biaya melonjak | `maxOutputTokens: 256`, input maks 500 karakter, satu request per kirim (`isSending` guard) |
| API error / down | `Failure` + banner error + tombol Coba lagi |
| Respons tidak relevan | System prompt membatasi jawaban; user bisa mengulang pertanyaan |

## 7. Bukti Mesin
```
flutter analyze                          -> No issues found
dart format --set-exit-if-changed lib test -> 0 file berubah
flutter test                             -> 29 test lulus (termasuk validasi + retry)
```
