import 'package:dio/dio.dart';

import 'api_errors.dart';

class AuthSession {
  const AuthSession({required this.access, required this.refresh});
  final String access;
  final String refresh;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      access: json['access'] ?? json['access_token'] ?? '',
      refresh: json['refresh'] ?? json['refresh_token'] ?? '',
    );
  }
}

class AuthRepository {
  final Dio? _dio;

  // Dio dibuat opsional agar tetap mendukung mode simulasi/mock
  AuthRepository([this._dio]);

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    // Mode simulasi/mock (jika Dio tidak diinjeksikan)
    if (_dio == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!email.contains('@') || password.length < 6) {
        throw 'Email atau kata sandi tidak valid';
      }
      return AuthSession(
        access: 'mock-access-for-$email',
        refresh: 'mock-refresh-for-$email',
      );
    }

    // Mode nyata (menggunakan Dio & API backend)
    try {
      final res = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      return AuthSession.fromJson(res.data);
    } catch (e) {
      throw ApiErrorMapper.toUserMessage(e);
    }
  }

  Future<String> refresh(String refreshToken) async {
    if (_dio == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (refreshToken.isEmpty) throw 'Refresh token hilang';
      return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
    }

    try {
      final res = await _dio.post('/refresh', data: {'refresh': refreshToken});
      return res.data['access'] ?? res.data['access_token'];
    } catch (e) {
      throw ApiErrorMapper.toUserMessage(e);
    }
  }

  /// Fungsi untuk mengirim token FCM perangkat ke backend
  Future<void> postDeviceToken(String token) async {
    if (_dio == null) return; // Mode mock: lewati request

    try {
      await _dio.post('/devices', data: {'token': token});
    } catch (e) {
      throw ApiErrorMapper.toUserMessage(e);
    }
  }
}
