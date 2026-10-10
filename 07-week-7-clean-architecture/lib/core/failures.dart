/// Domain-level failures — pure Dart, no framework dependencies.
///
/// Used as the error channel across all layers:
/// - Data layer returns `Failure` in record `({T data, Failure? failure})`
/// - Domain/use cases propagate `Failure` upward
/// - Presentation maps `Failure.message` to user-facing SnackBar/Dialog
sealed class Failure {
  const Failure(this.message);
  final String message;
}

/// Failures originating from local sources (storage, cache, parsing, etc.)
class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

/// Failures originating from network / remote API calls
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure for authentication/authorization issues (401, 403, token expired)
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Failure for validation errors (400, 422)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure for not found (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Failure for server errors (5xx)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Unknown / unexpected failure
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}