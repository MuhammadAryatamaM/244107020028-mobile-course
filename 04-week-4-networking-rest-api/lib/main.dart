import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/paged_post_page.dart';
import 'pages/post_list_page.dart';
import 'pages/post_detail_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

// Setup rute aplikasi menggunakan GoRouter
final _router = GoRouter(
  initialLocation: '/paged',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const PostListPage()),
    GoRoute(path: '/paged', builder: (context, state) => const PagedPostPage()),
    GoRoute(
      path: '/post/:id',
      builder: (context, state) {
        final idParam = state.pathParameters['id'];
        final id = int.tryParse(idParam ?? '') ?? 0;
        return PostDetailPage(postId: id);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Week 4 - REST API',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      routerConfig: _router,
    );
  }
}
