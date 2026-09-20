import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  group('Comment Model', () {
    test('fromJson handles missing fields gracefully (null-safe)', () {
      // JSON tanpa field yang lengkap untuk menguji safety fallback
      final json = <String, dynamic>{
        'postId': 1,
        // 'id': hilang
        // 'name': hilang
        // 'email': hilang
        // 'body': hilang
      };

      // Konversi JSON menjadi objek Comment
      final comment = Comment.fromJson(json);

      // Verifikasi bahwa data yang hilang digantikan dengan nilai default
      expect(comment.postId, 1);
      expect(comment.id, 0);
      expect(comment.name, 'No Name');
      expect(comment.email, 'No Email');
      expect(comment.body, 'No Body');
    });

    test('fromJson edge case: explicit null values instead of missing fields', () {
      // JSON dengan key tersedia namun memiliki nilai eksplisit null
      final json = <String, dynamic>{
        'postId': null,
        'id': null,
        'name': null,
        'email': null,
        'body': null,
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 0);
      expect(comment.id, 0);
      expect(comment.name, 'No Name');
      expect(comment.email, 'No Email');
      expect(comment.body, 'No Body');
    });
  });
}
