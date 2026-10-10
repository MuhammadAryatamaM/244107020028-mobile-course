/// Use case for refreshing access token.
/// Shared by [AuthNotifier] (manual refresh) and [ApiClient] interceptor (auto-refresh on 401).
///
/// Returns new access token on success, [Failure] on error.
import '../../repositories/i_auth_repository.dart';
import '../../repositories/i_token_store.dart';
import '../../../../core/failures.dart';

class RefreshTokenUseCase {
  const RefreshTokenUseCase({
    required IAuthRepository authRepository,
    required ITokenStore tokenStore,
  })  : _authRepository = authRepository,
        _tokenStore = tokenStore;

  final IAuthRepository _authRepository;
  final ITokenStore _tokenStore;

  Future<({String? accessToken, Failure? failure})> call() async {
    // 1. Read refresh token from secure storage
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return (
        accessToken: null,
        failure: AuthFailure('Refresh token tidak ditemukan. Silakan login ulang.'),
      );
    }

    // 2. Call repository to refresh
    final refreshResult = await _authRepository.refreshToken(refreshToken);

    if (refreshResult.failure != null) {
      // Refresh failed (e.g., refresh token expired) → clear storage
      await _tokenStore.clear();
      return (accessToken: null, failure: refreshResult.failure);
    }

    final newAccessToken = refreshResult.accessToken!;

    // 3. Save new access token (keep same refresh token)
    try {
      await _tokenStore.save(
        accessToken: newAccessToken,
        refreshToken: refreshToken,
      );
    } catch (e) {
      return (
        accessToken: null,
        failure: LocalFailure('Gagal menyimpan token baru: $e'),
      );
    }

    return (accessToken: newAccessToken, failure: null);
  }
}