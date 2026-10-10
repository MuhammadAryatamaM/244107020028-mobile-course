/// Pure domain entity for authenticated session.
/// No JSON parsing, no framework imports, no mapping logic.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  /// Convenience getter for Authorization header
  String get authorizationHeader => 'Bearer $accessToken';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSession &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken;

  @override
  int get hashCode => accessToken.hashCode ^ refreshToken.hashCode;

  @override
  String toString() => 'AuthSession(access: ${accessToken.substring(0, 10)}..., refresh: ${refreshToken.substring(0, 10)}...)';
}