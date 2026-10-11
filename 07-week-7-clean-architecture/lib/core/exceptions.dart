/// Custom exceptions that carry Failure for proper error handling.
import 'failures.dart';

/// Base exception that wraps a [Failure] for UI display.
class FailureException implements Exception {
  const FailureException(this.failure);
  final Failure failure;

  @override
  String toString() => failure.message;
}

/// Exception for network failures.
class NetworkException extends FailureException {
  const NetworkException(NetworkFailure failure) : super(failure);
}

/// Exception for auth failures.
class AuthException extends FailureException {
  const AuthException(AuthFailure failure) : super(failure);
}

/// Exception for validation failures.
class ValidationException extends FailureException {
  const ValidationException(ValidationFailure failure) : super(failure);
}

/// Exception for not found failures.
class NotFoundException extends FailureException {
  const NotFoundException(NotFoundFailure failure) : super(failure);
}

/// Exception for server failures.
class ServerException extends FailureException {
  const ServerException(ServerFailure failure) : super(failure);
}

/// Exception for local/storage failures.
class LocalException extends FailureException {
  const LocalException(LocalFailure failure) : super(failure);
}

/// Exception for unknown failures.
class UnknownException extends FailureException {
  const UnknownException(UnknownFailure failure) : super(failure);
}

/// Convert [Failure] to appropriate [FailureException].
FailureException failureToException(Failure failure) {
  return switch (failure) {
    NetworkFailure() => NetworkException(failure),
    AuthFailure() => AuthException(failure),
    ValidationFailure() => ValidationException(failure),
    NotFoundFailure() => NotFoundException(failure),
    ServerFailure() => ServerException(failure),
    LocalFailure() => LocalException(failure),
    UnknownFailure() => UnknownException(failure),
    // Sealed class covers all subtypes
  };
}