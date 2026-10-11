import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'routes.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/announcements/presentation/pages/announcement_list_page.dart';
import 'features/announcements/presentation/pages/announcement_detail_page.dart';
import 'features/notifications/presentation/providers/push_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: ValueNotifier(authState),
    redirect: (context, state) {
      final loggedIn = authState.value ?? false;
      final goingLogin = state.matchedLocation == AppRoutes.login;

      if (!loggedIn && !goingLogin) return AppRoutes.login;
      if (loggedIn && goingLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const AnnouncementListPage(),
      ),
      GoRoute(
        path: AppRoutes.announcementDetailPath,
        builder: (context, state) =>
            AnnouncementDetailPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future<void> navigateFromNotif(String route) async {
        if (route == AppRoutes.home || route.isEmpty) return;

        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            ref.read(routerProvider).push(route);
          }
        });
      }

      // Initialize push notifications via IPushService (not concrete class)
      final pushService = ref.read(pushServiceProvider);
      await pushService.initialize(
        onToken: (token) async {
          // Post FCM token to backend via use case
          try {
            await ref.read(postDeviceTokenUseCaseProvider)(token);
          } catch (_) {
            // Silent fail - token will be retried on next login
          }
        },
        onMessage: navigateFromNotif,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Campus Notify',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      routerConfig: router,
    );
  }
}
