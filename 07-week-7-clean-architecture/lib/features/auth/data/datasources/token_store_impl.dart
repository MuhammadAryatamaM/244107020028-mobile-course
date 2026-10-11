/// Secure token storage implementation using FlutterSecureStorage.
/// Implements [ITokenStore] domain interface.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/auth/domain/repositories/i_token_store.dart';

class TokenStoreImpl implements ITokenStore {
  TokenStoreImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  @override
  Future<Failure?> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _storage.write(key: _accessKey, value: accessToken);
      await _storage.write(key: _refreshKey, value: refreshToken);
      return null;
    } catch (e) {
      return LocalFailure('Gagal menyimpan token ke secure storage: $e');
    }
  }

  @override
  Future<({String? token, Failure? failure})> readAccessToken() async {
    try {
      final token = await _storage.read(key: _accessKey);
      return (token: token, failure: null);
    } catch (e) {
      return (token: null, failure: LocalFailure('Gagal membaca access token: $e'));
    }
  }

  @override
  Future<({String? token, Failure? failure})> readRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshKey);
      return (token: token, failure: null);
    } catch (e) {
      return (token: null, failure: LocalFailure('Gagal membaca refresh token: $e'));
    }
  }

  @override
  Future<Failure?> clear() async {
    try {
      await _storage.deleteAll();
      return null;
    } catch (e) {
      return LocalFailure('Gagal menghapus token: $e');
    }
  }

  @override
  Future<({bool hasToken, Failure? failure})> hasToken() async {
    final result = await readAccessToken();
    return (hasToken: result.token != null, failure: result.failure);
  }
}