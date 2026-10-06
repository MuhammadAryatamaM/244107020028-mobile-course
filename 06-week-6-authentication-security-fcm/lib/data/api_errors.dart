import 'package:dio/dio.dart';

abstract class ApiErrorMapper {
  /// Mengubah `DioException` atau `Object` error umum menjadi pesan teks yang ramah pengguna.
  static String toUserMessage(Object error) {
    if (error is! DioException) {
      return 'Terjadi kesalahan tidak terduga. Silakan coba lagi.';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi waktu habis. Silakan periksa jaringan Anda dan coba lagi.';

      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet. Pastikan perangkat Anda terhubung ke jaringan.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        // Jika backend mengirim pesan error kustom (misal: {"message": "Email sudah terdaftar"})
        if (responseData is Map<String, dynamic> &&
            responseData['message'] is String &&
            (responseData['message'] as String).isNotEmpty) {
          return responseData['message'];
        }

        // Pemetaan standar berdasarkan HTTP Status Code
        switch (statusCode) {
          case 400:
            return 'Permintaan tidak valid. Mohon periksa kembali data Anda.';
          case 401:
            return 'Sesi Anda telah berakhir. Silakan login kembali.';
          case 403:
            return 'Anda tidak memiliki akses untuk melakukan tindakan ini.';
          case 404:
            return 'Data atau layanan yang diminta tidak ditemukan.';
          case 422:
            return 'Data yang dimasukkan tidak valid atau belum lengkap.';
          case 500:
          case 502:
          case 503:
            return 'Terjadi gangguan pada server. Silakan coba beberapa saat lagi.';
          default:
            return 'Terjadi kesalahan pada server (Kode: $statusCode).';
        }

      case DioExceptionType.cancel:
        return 'Permintaan ke server dibatalkan.';

      default:
        return 'Gagal terhubung ke server. Silakan periksa koneksi internet Anda.';
    }
  }
}
