/// Announcement repository implementation.
/// Implements [IAnnouncementRepository] using Dio for HTTP.
import 'package:dio/dio.dart';

import '../../../../core/failures.dart';
import '../../../domain/entities/announcement.dart';
import '../../../domain/repositories/i_announcement_repository.dart';
import '../models/announcement_dto.dart';

class AnnouncementRepositoryImpl implements IAnnouncementRepository {
  AnnouncementRepositoryImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

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
            return const ValidationFailure('Permintaan tidak valid.');
          case 401:
            return const AuthFailure('Sesi berakhir. Silakan login ulang.');
          case 403:
            return const AuthFailure('Akses ditolak.');
          case 404:
            return const NotFoundFailure('Pengumuman tidak ditemukan.');
          case 422:
            return const ValidationFailure('Data tidak valid.');
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
  Future<({List<Announcement> announcements, Failure? failure})> fetchAnnouncements() async {
    try {
      final res = await _dio.get('/announcements');
      final data = res.data;

      List<Announcement> announcements;
      if (data is List) {
        announcements = data
            .whereType<Map<String, dynamic>>()
            .map(AnnouncementDto.fromJson)
            .map((dto) => dto.toEntity())
            .toList();
      } else if (data is Map && data['data'] is List) {
        announcements = (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(AnnouncementDto.fromJson)
            .map((dto) => dto.toEntity())
            .toList();
      } else {
        announcements = const <Announcement>[];
      }

      return (announcements: announcements, failure: null);
    } on DioException catch (e) {
      return (announcements: const <Announcement>[], failure: _mapDioError(e));
    } catch (e) {
      return (announcements: const <Announcement>[], failure: UnknownFailure('Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<({Announcement? announcement, Failure? failure})> fetchAnnouncementDetail(String id) async {
    try {
      final res = await _dio.get('/announcements/$id');
      final dto = AnnouncementDto.fromJson(res.data);
      return (announcement: dto.toEntity(), failure: null);
    } on DioException catch (e) {
      return (announcement: null, failure: _mapDioError(e));
    } catch (e) {
      return (announcement: null, failure: UnknownFailure('Terjadi kesalahan: $e'));
    }
  }
}