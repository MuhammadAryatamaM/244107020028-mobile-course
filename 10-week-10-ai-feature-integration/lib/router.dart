import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/home_page.dart';
import 'pages/note_detail_page.dart';
import 'pages/settings_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return NoteDetailPage(noteId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
