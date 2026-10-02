import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repositories/note_repository.dart';
import 'repositories/post_repository.dart';
import 'network_provider.dart';
import 'local/post.dart';

// ATURAN KONFLIK
//
// 1. NOTES (tulisan user)
//    - Strategy: Last-Write-Wins (LWW) dengan dirty flag
//    - Setiap catatan baru/updated ditandai dirty = 1
//    - syncNotes() mengirim semua catatan dirty ke server
//    - Setelah server respond 2xx, dirty flag di-clear (markAllSynced)
//    - Jika server mengembalikan konflik (409), versi server menang
//      (client-side changes di-overwrite oleh server)
//
// 2. POSTS (data bacaan)
//    - Strategy: Cache-First dengan background refresh
//    - Cache lama tetap ditampilkan selama fetch baru berlangsung
//    - Jika fetch gagal (offline/error), cache lama tetap dipakai
//    - Tidak ada konflik karena posts adalah read-only dari user
//
// 3. FORCE OFFLINE MODE
//    - Saat aktif, syncNotes() throw exception
//    - Saat aktif, refreshPostsInBackground() di-skip
//    - User tetap bisa membaca cache dan membuat catatan baru

final syncServiceProvider = Provider((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  return SyncService(repo, ref);
});

class SyncService {
  final NoteRepository repo;
  final Ref ref;

  SyncService(this.repo, this.ref);

  Future<int> syncNotes() async {
    final isOffline = ref.read(forceOfflineProvider);
    if (isOffline) {
      // Simulate that sync fails when offline
      throw Exception('Force Offline is ON. Cannot sync.');
    }

    final dirtyCount = await repo.countDirty();
    if (dirtyCount == 0) return 0;

    // Simulasi upload: pada project nyata, kirim tiap catatan dirty
    // ke REST API di sini, lalu tandai bersih bila server menjawab 2xx.
    await Future.delayed(const Duration(seconds: 1));
    await repo.markAllSynced();

    return dirtyCount;
  }
}

final postsSyncServiceProvider = Provider((ref) {
  final repo = ref.watch(postRepositoryProvider);
  return PostsSyncService(repo, ref);
});

final postsProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final service = ref.watch(postsSyncServiceProvider);
  return service.loadPostsCacheFirst();
});

class PostsSyncService {
  final PostRepository repo;
  final Ref ref;

  PostsSyncService(this.repo, this.ref);

  /// 1. Segera kembalikan cache agar UI tidak blank saat offline.
  /// 2. Di background: fetch Dio -> simpan ke cached_posts -> invalidate provider.
  Future<List<Post>> loadPostsCacheFirst() async {
    final cached = await repo.readCachedPosts();
    refreshPostsInBackground();
    return cached;
  }

  Future<void> refreshPostsInBackground() async {
    final isOffline = ref.read(forceOfflineProvider);
    if (isOffline) return; // Skip background fetch jika offline

    try {
      final response = await Dio().get(
        'https://jsonplaceholder.typicode.com/posts',
      );
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> data = List.from(response.data);
        await repo.replaceCachedPosts(data.take(15).toList());
        ref.invalidate(postsProvider);
      }
    } catch (e) {
      // log background fetch error
    }
  }
}
