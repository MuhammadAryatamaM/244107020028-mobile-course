/// Push notification service contract — pure domain interface.
/// Implementation wraps Firebase Messaging in data layer.
///
/// Used by [LoginUseCase] to send FCM token to backend after login.
import '../../../../core/failures.dart';

abstract class IPushService {
  /// Initialize FCM: request permission, get token, set up listeners.
  /// [onToken] called when token is available (initial + refresh).
  /// [onMessage] called when push notification is tapped/opened.
  Future<void> initialize({
    required Future<void> Function(String token) onToken,
    required Future<void> Function(String route) onMessage,
  });

  /// Get current FCM token (may trigger permission request).
  Future<String?> getToken();

  /// Send device token to backend via auth repository.
  /// Called by [PostDeviceTokenUseCase].
  Future<({bool success, Failure? failure})> postDeviceToken(String token);

  /// Subscribe to campus-wide topic.
  Future<void> subscribeToCampusTopic();

  /// Unsubscribe from campus-wide topic.
  Future<void> unsubscribeFromCampusTopic();
}