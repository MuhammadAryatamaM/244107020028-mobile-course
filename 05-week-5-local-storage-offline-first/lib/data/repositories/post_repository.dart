import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/db.dart';
import '../local/post.dart';
import '../network_provider.dart';

final postRepositoryProvider = Provider((ref) => PostRepository(ref));

final postsProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final repo = ref.watch(postRepositoryProvider);
  return repo.loadPostsCacheFirst();
});

class PostRepository {
  PostRepository(this.ref, {Future<Database> Function()? openDb})
    : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;
  final Ref ref;

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'cached_at DESC');
    return rows.map((row) {
      final payload =
          jsonDecode(row['payload'] as String) as Map<String, dynamic>;
      return Post.fromJson(payload);
    }).toList();
  }

  Future<void> refreshPostsInBackground() async {
    final isOffline = ref.read(forceOfflineProvider);
    if (isOffline) {
      return; // Skip background fetch jika offline
    }

    try {
      final response = await Dio().get(
        'https://jsonplaceholder.typicode.com/posts',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final db = await _openDb();

        await db.transaction((txn) async {
          await txn.delete('cached_posts');

          for (var item in data.take(15)) {
            await txn.insert('cached_posts', {
              'id': item['id'],
              'payload': jsonEncode(item),
              'cached_at': DateTime.now().toIso8601String(),
            });
          }
        });

        ref.invalidate(postsProvider);
      }
    } catch (e) {
      // log background fetch error
    }
  }

  Future<List<Post>> loadPostsCacheFirst() async {
    final cached = await readCachedPosts(); // dari tabel cached_posts
    // 1. Segera kembalikan cache agar UI tidak blank saat offline.
    // 2. Di background: fetch Dio -> simpan ke cached_posts -> invalidate provider.
    refreshPostsInBackground();
    return cached;
  }
}
