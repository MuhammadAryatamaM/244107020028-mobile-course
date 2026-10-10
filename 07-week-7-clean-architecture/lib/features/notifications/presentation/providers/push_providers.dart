/// Notifications feature presentation providers — wiring DI for push service.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/push_service_impl.dart';
import '../../../domain/services/i_push_service.dart';
import '../../../../auth/presentation/providers/auth_providers.dart'; // for authRepositoryProvider

/// Push service implementation (wraps Firebase Messaging)
final pushServiceProvider = Provider<IPushService>((ref) {
  // Inject AuthRepository to enable postDeviceToken from push service
  final authRepo = ref.watch(authRepositoryProvider);
  return PushServiceImpl(authRepository: authRepo);
});

/// FCM token provider — auto-fetches token on initialization
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(pushServiceProvider);
  return service.getToken();
});

/// Provider to trigger FCM initialization from main.dart
/// Usage: ref.read(pushInitProvider(onToken: ..., onMessage: ...))
final pushInitProvider = Provider.family<void, ({
  required Future<void> Function(String token) onToken,
  required Future<void> Function(String route) onMessage,
})>((ref, callbacks) {
  final service = ref.watch(pushServiceProvider);
  // Fire and forget - initialization happens in background
  service.initialize(
    onToken: callbacks.onToken,
    onMessage: callbacks.onMessage,
  );
});