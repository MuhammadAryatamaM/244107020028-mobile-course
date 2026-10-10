/// Authentication repository implementation.
/// Implements [IAuthRepository] using Dio for HTTP and [ITokenStore] for storage.
import 'package:dio/dio.dart';

import '../../../../core/failures.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/repositories/i_token_store.dart';
import '../models/auth_session_dto.dart';
import '../datasources/api_client.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl({
    required Dio dio,
    required ITokenStore tokenStore,
  })  : _dio = dio,
        _tokenStore = tokenStore;

  final Dio _dio;
  final ITokenStore _tokenStore;

  /// Map DioException to domain Failure.
  Failure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Koneksi waktu habis. Periksa jaringan Anda.');

      case DioExceptionType.connectionError:
        return const NetworkFailure('Tidak ada koneksi internet.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        // Backend custom error message
        if (responseData is Map<String, dynamic> &&
            responseData['message'] is String &&
            (responseData['message'] as String).isNotEmpty) {
          final msg = responseData['message'] as String;
          // Classify by status code
          switch (statusCode) {
            case 400:
            case 422:
              return ValidationFailure(msg);
            case 401:
            case 403:
              return AuthFailure(msg);
            case 404:
              return NotFoundFailure(msg);
            case 500:
            case 502:
            case 503:
              return ServerFailure(msg);
            default:
              return NetworkFailure(msg);
          }
        }

        // Standard HTTP status mapping
        switch (statusCode) {
          case 400:
            return const ValidationFailure('Permintaan tidak valid. Periksa data Anda.');
          case 401:
            return const AuthFailure('Sesi berakhir. Silakan login ulang.');
          case 403:
            return const AuthFailure('Akses ditolak.');
          case 404:
            return const NotFoundFailure('Layanan tidak ditemukan.');
          case 422:
            return const ValidationFailure('Data tidak valid atau belum lengkap.');
          case 500:
          case 502:
          case 503:
            return const ServerFailure('Gangguan server. Coba lagi nanti.');
          default:
            return NetworkFailure('Error server (kode: $statusCode)');
        }

      case DioExceptionType.cancel:
        return const NetworkFailure('Permintaan dibatalkan.');

      default:
        return const NetworkFailure('Gagal terhubung ke server. Periksa koneksi internet.');
    }
  }

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final dto = AuthSessionDto.fromJson(res.data);
      return (session: dto.toEntity(), failure: null);
    } on DioException catch (e) {
      return (session: null, failure: _mapDioError(e));
    } catch (e) {
      return (session: null, failure: UnknownFailure('Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<({String? accessToken, Failure? failure})> refreshToken(String refreshToken) async {
    try {
      final res = await _dio.post('/refresh', data: {'refresh': refreshToken});
      final newAccess = res.data['access'] ?? res.data['access_token'];
      if (newAccess == null) {
        return (accessToken: null, failure: const NetworkFailure('Token baru tidak diterima dari server.'));
      }
      return (accessToken: newAccess as String, failure: null);
    } on DioException catch (e) {
      return (accessToken: null, failure: _mapDioError(e));
    } catch (e) {
      return (accessToken: null, failure: UnknownFailure('Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<({bool success, Failure? failure})> postDeviceToken(String token) async {
    try {
      await _dio.post('/devices', data: {'token': token});
      return (success: true, failure: null);
    } on DioException catch (e) {
      return (success: false, failure: _mapDioError(e));
    } catch (e) {
      return (success: false, failure: UnknownFailure('Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStore.clear();
  }
}