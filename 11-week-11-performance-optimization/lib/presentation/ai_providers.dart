import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/ai_service_interface.dart';
import '../data/ai/gemini_ai_service.dart';

final aiServiceProvider = Provider<AiServiceInterface>((ref) {
  return GeminiAiService();
});

final apiKeyProvider = FutureProvider<String?>((ref) async {
  final aiService = ref.watch(aiServiceProvider);
  return aiService.getApiKey();
});
