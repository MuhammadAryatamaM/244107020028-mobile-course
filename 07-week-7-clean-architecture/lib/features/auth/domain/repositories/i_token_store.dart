/// Secure token storage contract — pure domain interface.
/// Implementation wraps [FlutterSecureStorage] in data layer.
import '../../../core/failures.dart';

abstract class ITokenStore {
  /// Save both access and refresh tokens.
  /// Throws [LocalFailure] on storage error (handled by caller).
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  });

  /// Read access token. Returns null if not found.
  Future<String?> readAccessToken();

  /// Read refresh token. Returns null if not found.
  Future<String?> readRefreshToken();

  /// Clear all stored tokens (logout).
  Future<void> clear();

  /// Check if any token exists (for quick auth state check).
  Future<bool> hasToken() async {
    final access = await readAccessToken();
    return access != null;
  }
}