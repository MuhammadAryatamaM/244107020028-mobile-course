import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _fcmToken = 'Memuat token...';

  @override
  void initState() {
    super.initState();
    _setupFcm();
  }

  Future<void> _setupFcm() async {
    await initFcmToken(
      onToken: (token) async {
        if (mounted) {
          setState(() {
            _fcmToken = token;
          });
        }
      },
    );
  }

  String _formatToken(String token) {
    if (token.length > 12) {
      return '${token.substring(0, 12)}...';
    }
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Selamat Datang di Halaman Utama!'),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Debug FCM Token:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_formatToken(_fcmToken)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              // Gunakan helper statis AppRoutes.announcementDetail('101')
              onPressed: () => context.go(AppRoutes.announcementDetail('101')),
              child: const Text('Buka Pengumuman #101'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
