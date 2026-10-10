/// Data transfer object for AuthSession — extends domain entity with JSON mapping.
/// Only place where JSON parsing/serialization lives.
import '../../../../auth/domain/entities/auth_session.dart';

class AuthSessionDto extends AuthSession {
  const AuthSessionDto({
    required super.accessToken,
    required super.refreshToken,
  });

  /// Create from backend JSON response.
  /// Handles multiple possible key names (access/access_token, refresh/refresh_token).
  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(
      accessToken: json['access'] ?? json['access_token'] ?? '',
      refreshToken: json['refresh'] ?? json['refresh_token'] ?? '',
    );
  }

  /// Convert to JSON for request body (if needed).
  Map<String, dynamic> toJson() => {
        'access': accessToken,
        'refresh': refreshToken,
      };

  /// Convert to domain entity (pure, no framework deps).
  AuthSession toEntity() => AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
}