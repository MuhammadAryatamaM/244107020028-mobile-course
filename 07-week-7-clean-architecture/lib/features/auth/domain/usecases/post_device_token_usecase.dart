/// Use case for sending device FCM token to backend.
/// Called from [LoginUseCase] and [PushService] (on token refresh).
///
/// Idempotent: safe to call multiple times with same token.
import '../../repositories/i_auth_repository.dart';
import '../../../../core/failures.dart';

class PostDeviceTokenUseCase {
  const PostDeviceTokenUseCase(this._authRepository);
  final IAuthRepository _authRepository;

  Future<({bool success, Failure? failure})> call(String token) async {
    if (token.isEmpty) {
      return (success: false, failure: ValidationFailure('FCM token kosong'));
    }

    final result = await _authRepository.postDeviceToken(token);

    if (result.failure != null) {
      return (success: false, failure: result.failure);
    }

    return (success: result.success, failure: null);
  }
}