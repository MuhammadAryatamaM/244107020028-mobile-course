/// Secure token storage contract — pure domain interface.
/// Implementation wraps [FlutterSecureStorage] in data layer.
import 'package:campus_notify/core/failures.dart';

abstract class ITokenStore {
  /// Save both access and refresh tokens.
  /// Returns [Failure] on storage error.
  Future<Failure?> save({
    required String accessToken,
    required String refreshToken,
  });

  /// Read access token. Returns null if not found.
  /// Returns [Failure] on storage error.
  Future<({String? token, Failure? failure})> readAccessToken();

  /// Read refresh token. Returns null if not found.
  /// Returns [Failure] on storage error.
  Future<({String? token, Failure? failure})> readRefreshToken();

  /// Clear all stored tokens (logout).
  /// Returns [Failure] on storage error.
  Future<Failure?> clear();

  /// Check if any token exists (for quick auth state check).
  Future<({bool hasToken, Failure? failure})> hasToken() async {
    final result = await readAccessToken();
    return (hasToken: result.token != null, failure: result.failure);
  }
}