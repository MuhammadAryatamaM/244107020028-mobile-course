/// Secure token storage implementation using FlutterSecureStorage.
/// Implements [ITokenStore] domain interface.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/failures.dart';
import '../../../domain/repositories/i_token_store.dart';

class TokenStoreImpl implements ITokenStore {
  TokenStoreImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _storage.write(key: _accessKey, value: accessToken);
      await _storage.write(key: _refreshKey, value: refreshToken);
    } catch (e) {
      throw LocalFailure('Gagal menyimpan token ke secure storage: $e');
    }
  }

  @override
  Future<String?> readAccessToken() async {
    try {
      return await _storage.read(key: _accessKey);
    } catch (e) {
      throw LocalFailure('Gagal membaca access token: $e');
    }
  }

  @override
  Future<String?> readRefreshToken() async {
    try {
      return await _storage.read(key: _refreshKey);
    } catch (e) {
      throw LocalFailure('Gagal membaca refresh token: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw LocalFailure('Gagal menghapus token: $e');
    }
  }
}