abstract class AiServiceInterface {
  Future<String> summarizeNote({required String title, required String body});

  Future<void> saveApiKey(String key);
  Future<String?> getApiKey();
}
