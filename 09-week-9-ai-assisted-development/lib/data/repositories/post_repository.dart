import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/db.dart';
import '../local/post.dart';

final postRepositoryProvider = Provider((ref) => PostRepository());

/// CRUD-only untuk tabel cached_posts.
/// Logika cache-first dan background refresh ada di [PostsSyncService].
class PostRepository {
  Future<List<Post>> readCachedPosts() async {
    final db = await openNotesDb();
    final rows = await db.query('cached_posts', orderBy: 'cached_at DESC');
    return rows.map((row) {
      final payload =
          jsonDecode(row['payload'] as String) as Map<String, dynamic>;
      return Post.fromJson(payload);
    }).toList();
  }

  Future<void> replaceCachedPosts(List<Map<String, dynamic>> items) async {
    final db = await openNotesDb();
    await db.transaction((txn) async {
      await txn.delete('cached_posts');
      for (var item in items) {
        await txn.insert('cached_posts', {
          'id': item['id'],
          'payload': jsonEncode(item),
          'cached_at': DateTime.now().toIso8601String(),
        });
      }
    });
  }
}
