import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';

import 'api_client.dart';
import 'models/post.dart';
import 'repositories/post_repository.dart';
import 'models/comment.dart';
import 'repositories/comment_repository.dart';
import 'paged_posts.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    // Exception dari repository otomatis menjadi AsyncError.
    // Inilah ekuivalen deklaratif dari AsyncValue.guard di versi lama.
    final repository = ref.watch(postRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(postRepositoryProvider);
      state = AsyncData(await repository.fetchPosts());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final postListProvider = AsyncNotifierProvider<PostListNotifier, List<Post>>(
  PostListNotifier.new,
  // Nonaktifkan retry otomatis Riverpod 3 agar error langsung
  // final dan mudah diuji (tanpa ini, future provider di-test
  // akan me-retry dan menggantung).
  retry: (retryCount, error) => null,
);

/// Provider untuk mengambil single post.
/// Memeriksa terlebih dahulu apakah post sudah ada di state list (cache).
/// Jika belum ada, baru fetch lewat repository.
final singlePostProvider = FutureProvider.family<Post, int>((ref, id) async {
  // Coba cari di postListProvider (mode non-paged)
  final postList = ref.read(postListProvider).value;
  if (postList != null) {
    for (final p in postList) {
      if (p.id == id) return p;
    }
  }

  // Coba cari di pagedPostsProvider (mode paged)
  final pagedState = ref.read(pagedPostsProvider);
  for (final p in pagedState.items) {
    if (p.id == id) return p;
  }

  // Jika tidak ditemukan di memori, ambil dari repository
  return ref.watch(postRepositoryProvider).fetchPost(id);
});

/// Provider menggunakan AsyncNotifier untuk menerima argumen [postId].
/// Mengelola state komentar berdasarkan postId yang diberikan (via parameter constructor Riverpod 3).
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  final int postId;
  CommentListNotifier(this.postId);

  @override
  Future<List<Comment>> build() async {
    // Exception dari repository otomatis menjadi AsyncError (ditangani Riverpod).
    // Nantinya di UI bisa ditangkap dan ditampilkan menggunakan fungsi
    // [friendlyErrorMessage] yang sudah menangani timeout, connection error, 404, dan 500.
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(postId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      // Menangkap error jika refresh gagal dan update state
      state = AsyncError(e, st);
    }
  }
}

final commentListProvider =
    AsyncNotifierProvider.family<CommentListNotifier, List<Comment>, int>(
      CommentListNotifier.new,
      retry: (retryCount, error) =>
          null, // non-retryable for straightforward testing
    );

/// Helper khusus testing (letakkan di providers.dart): membaca state
/// pertama yang bukan loading lewat listener + completer, sehingga
/// test tidak menunggu retry dan tidak melakukan HTTP sungguhan.
Future<List<Post>> readPostsOnce(ProviderContainer container) {
  final completer = Completer<List<Post>>();
  final sub = container.listen<AsyncValue<List<Post>>>(postListProvider, (
    previous,
    next,
  ) {
    if (next.isLoading || completer.isCompleted) return;
    next.whenData(completer.complete);
    if (next.hasError) {
      completer.completeError(
        next.error ?? StateError('unknown error'),
        next.stackTrace ?? StackTrace.empty,
      );
    }
  }, fireImmediately: true);
  return completer.future.whenComplete(sub.close);
}

Future<Object?> readPostsErrorOnce(ProviderContainer container) {
  final completer = Completer<Object?>();
  final sub = container.listen<AsyncValue<List<Post>>>(postListProvider, (
    previous,
    next,
  ) {
    if (next.isLoading || completer.isCompleted) return;
    completer.complete(next.error);
  }, fireImmediately: true);
  return completer.future.whenComplete(sub.close);
}
