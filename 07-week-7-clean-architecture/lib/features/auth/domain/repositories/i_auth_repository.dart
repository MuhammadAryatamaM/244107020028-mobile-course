/// Authentication repository contract — pure domain interface.
/// Implementations live in data layer (e.g., [AuthRepositoryImpl]).
///
/// All methods return a record `({T data, Failure? failure})` to make
/// success/failure explicit without throwing exceptions across layers.
import '../../entities/auth_session.dart';
import '../../../core/failures.dart';

abstract class IAuthRepository {
  /// Authenticate user with email & password.
  /// On success: saves tokens via [ITokenStore] (handled by use case).
  /// Returns [AuthSession] on success, [Failure] on error.
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  });

  /// Refresh access token using refresh token.
  /// Returns new access token string on success.
  Future<({String? accessToken, Failure? failure})> refreshToken(String refreshToken);

  /// Send device FCM token to backend for push notifications.
  /// Called after login and on token refresh.
  Future<({bool success, Failure? failure})> postDeviceToken(String token);

  /// Logout — clear local tokens (delegates to [ITokenStore]).
  /// Typically handled by use case / notifier, not directly here.
  Future<void> logout();
}