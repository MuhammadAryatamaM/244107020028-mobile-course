/// Use case for user login.
/// Orchestrates: [IAuthRepository.login] → [ITokenStore.save] → [IPushService.postDeviceToken]
///
/// Returns [AuthSession] on success, [Failure] on any step failure.
import '../../entities/auth_session.dart';
import '../../repositories/i_auth_repository.dart';
import '../../repositories/i_token_store.dart';
import '../../../../notifications/domain/services/i_push_service.dart';
import '../../../../core/failures.dart';

class LoginUseCase {
  const LoginUseCase({
    required IAuthRepository authRepository,
    required ITokenStore tokenStore,
    required IPushService pushService,
  })  : _authRepository = authRepository,
        _tokenStore = tokenStore,
        _pushService = pushService;

  final IAuthRepository _authRepository;
  final ITokenStore _tokenStore;
  final IPushService _pushService;

  Future<({AuthSession? session, Failure? failure})> call({
    required String email,
    required String password,
  }) async {
    // 1. Call auth repository
    final loginResult = await _authRepository.login(
      email: email,
      password: password,
    );

    if (loginResult.failure != null) {
      return (session: null, failure: loginResult.failure);
    }

    final session = loginResult.session!;

    // 2. Save tokens locally
    try {
      await _tokenStore.save(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
    } catch (e) {
      return (
        session: null,
        failure: LocalFailure('Gagal menyimpan token: $e'),
      );
    }

    // 3. Post FCM token to backend (non-blocking: log error but don't fail login)
    try {
      final fcmToken = await _pushService.getToken();
      if (fcmToken != null) {
        await _pushService.postDeviceToken(fcmToken);
      }
    } catch (e) {
      // Log only, don't fail login
      // TODO: Add proper logging
    }

    return (session: session, failure: null);
  }
}