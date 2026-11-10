import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/ai_service_interface.dart';

class GeminiAiService implements AiServiceInterface {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  static const String _storageKey = 'ai_api_key';

  GeminiAiService({FlutterSecureStorage? storage, Dio? dio})
    : _storage = storage ?? const FlutterSecureStorage(),
      _dio = dio ?? Dio();

  @override
  Future<String?> getApiKey() async {
    return _storage.read(key: _storageKey);
  }

  @override
  Future<void> saveApiKey(String key) async {
    await _storage.write(key: _storageKey, value: key.trim());
  }

  Future<List<String>> _fetchSupportedModels(String apiKey) async {
    try {
      final response = await _dio.get(
        'https://generativelanguage.googleapis.com/v1beta/models',
        options: Options(headers: {'x-goog-api-key': apiKey}),
      );
      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        final list = (data['models'] as List?) ?? [];
        return list
            .where((m) {
              final name = (m['name'] as String? ?? '').toLowerCase();
              final methods = m['supportedGenerationMethods'] as List?;
              final supportsGenerate =
                  methods?.contains('generateContent') ?? false;
              // Abaikan model khusus audio/tts/vision-only
              final isAudioOrSpecial =
                  name.contains('tts') ||
                  name.contains('audio') ||
                  name.contains('embedding') ||
                  name.contains('aqa');
              return supportsGenerate && !isAudioOrSpecial;
            })
            .map((m) => m['name'] as String)
            .toList()
          ..sort((a, b) {
            // Prioritaskan model standar stabil non-thinking
            final aLower = a.toLowerCase();
            final bLower = b.toLowerCase();
            int score(String name) {
              if (name.contains('gemini-1.5-flash-latest')) return 10;
              if (name.contains('gemini-1.5-flash')) return 9;
              if (name.contains('gemini-pro')) return 8;
              if (name.contains('flash')) return 5;
              if (name.contains('thinking')) return 1;
              return 3;
            }

            return score(bLower).compareTo(score(aLower));
          });
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<String> summarizeNote({
    required String title,
    required String body,
  }) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'API Key belum diatur. Silakan atur di halaman Pengaturan.',
      );
    }

    if (body.trim().isEmpty) {
      throw Exception(
        'Isi catatan masih kosong, tidak ada yang dapat diringkas.',
      );
    }

    final prompt =
        '''
Ringkas catatan berikut dalam Bahasa Indonesia.
Tuliskan HANYA hasil ringkasan akhirnya saja (maksimal 2-3 poin ringkas atau kalimat padat).
DILARANG menampilkan proses berpikir, analisis, peran, atau opsi-opsi alternatif. Langsung berikan ringkasannya.

Judul Catatan: $title
Isi Catatan: $body
''';

    // Ambil daftar model aktual yang aktif untuk API key ini
    final models = await _fetchSupportedModels(apiKey);

    final urlsToTry = <String>[];
    if (models.isNotEmpty) {
      for (final m in models) {
        urlsToTry.add(
          'https://generativelanguage.googleapis.com/v1beta/$m:generateContent',
        );
      }
    } else {
      urlsToTry.addAll([
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent',
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent',
      ]);
    }

    String lastErrorMessage = '';

    for (final url in urlsToTry) {
      try {
        final response = await _dio.post(
          url,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
          data: {
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                ],
              },
            ],
          },
        );

        if (response.statusCode == 200) {
          final data = response.data is String
              ? jsonDecode(response.data as String)
              : response.data;
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            final parts = content['parts'] as List;
            // Ambil part yang bukan thought/thinking
            String textResult = '';
            for (final p in parts) {
              if (p['thought'] == true) continue;
              if (p['text'] != null) {
                textResult += (p['text'] as String);
              }
            }
            if (textResult.isEmpty && parts.isNotEmpty) {
              textResult = parts.last['text'] as String? ?? '';
            }

            // Bersihkan sisa draft/checklist jika model masih menyelipkannya
            final lines = textResult.split('\n');
            final cleanLines = lines.where((line) {
              final trim = line.trim().toLowerCase();
              return !trim.startsWith('* role:') &&
                  !trim.startsWith('* task:') &&
                  !trim.startsWith('* constraint') &&
                  !trim.startsWith('* input:') &&
                  !trim.startsWith('* observation:') &&
                  !trim.startsWith('* summary idea:') &&
                  !trim.startsWith('* only the summary?') &&
                  !trim.startsWith('* max 2-3') &&
                  !trim.startsWith('* indonesian?') &&
                  !trim.startsWith('* no thinking');
            }).toList();

            return cleanLines.join('\n').trim();
          }
        }
      } on DioException catch (e) {
        final errorData = e.response?.data;
        String detailedMsg = '';
        if (errorData is Map && errorData['error'] != null) {
          detailedMsg = errorData['error']['message'] ?? '';
        } else {
          detailedMsg = e.message ?? 'Status ${e.response?.statusCode}';
        }

        if (e.response?.statusCode == 400 &&
            detailedMsg.contains('API key not valid')) {
          throw Exception(
            'API Key tidak valid. Silakan periksa kembali di Pengaturan.',
          );
        }

        lastErrorMessage = detailedMsg;
        // Lanjutkan mencoba model teks berikutnya jika model ini bermasalah
        continue;
      }
    }

    throw Exception('Koneksi AI gagal: $lastErrorMessage');
  }
}
