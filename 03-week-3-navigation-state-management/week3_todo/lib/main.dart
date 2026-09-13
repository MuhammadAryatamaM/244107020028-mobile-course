import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:week3_todo/pages/main_page.dart';
import 'package:week3_todo/pages/todo_page.dart';
import 'package:week3_todo/pages/product_page.dart';
import 'package:week3_todo/pages/stats_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    routerConfig: _router,
    title: 'Week 3 - ToDo',
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomePage(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const TodoPage()),
        GoRoute(path: '/stats', builder: (context, state) => const StatsPage()),
        GoRoute(
          path: '/product',
          builder: (context, state) => const ProductPage(),
        ),
      ],
    ),
  ],
);
