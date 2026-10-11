/// Notifications feature presentation providers — wiring DI for push service.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_notify/features/notifications/data/services/push_service_impl.dart';
import 'package:campus_notify/features/notifications/domain/services/i_push_service.dart';
import 'package:campus_notify/features/auth/presentation/providers/auth_providers.dart';

/// Callback class for push initialization
class PushInitCallbacks {
  const PushInitCallbacks({
    required this.onToken,
    required this.onMessage,
  });

  final Future<void> Function(String token) onToken;
  final Future<void> Function(String route) onMessage;
}

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
/// Usage: ref.read(pushInitProvider(PushInitCallbacks(onToken: ..., onMessage: ...)))
final pushInitProvider = Provider<PushInitCallbacks>((ref) {
  throw UnimplementedError('Use pushInitProvider.overrideWithValue() in main.dart');
});