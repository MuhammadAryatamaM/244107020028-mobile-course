import 'package:dio/dio.dart';
import '../models/comment.dart';

class CommentRepository {
  final Dio _dio;

  CommentRepository(this._dio);

  /// Fetch comments berdasarkan [postId].
  /// Menggunakan Dio dengan timeout tambahan jika diperlukan (contoh 10 detik).
  Future<List<Comment>> fetchComments(int postId) async {
    // Meminta list komentar dari JSONPlaceholder dengan query param postId
    final response = await _dio.get(
      '/comments',
      queryParameters: {'postId': postId},
      // Menetapkan timeout spesifik 10 detik untuk request ini
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Parsing data ke List<Map<String, dynamic>>
    final data = response.data as List;
    
    // Mapping setiap data JSON menjadi objek Comment secara null-safe
    return data.map((json) => Comment.fromJson(json as Map<String, dynamic>)).toList();
  }
}
