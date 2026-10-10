/// Announcement list page — pure presentation, consumes announcementsProvider.
/// No direct repository, Dio, or data layer imports.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/announcements_providers.dart';
import '../../../../routes.dart';

class AnnouncementListPage extends ConsumerStatefulWidget {
  const AnnouncementListPage({super.key});

  @override
  ConsumerState<AnnouncementListPage> createState() => _AnnouncementListPageState();
}

class _AnnouncementListPageState extends ConsumerState<AnnouncementListPage> {
  String _fcmToken = 'Memuat token...';

  @override
  void initState() {
    super.initState();
    _setupFcm();
  }

  Future<void> _setupFcm() async {
    // Get FCM token from notifications feature
    final token = await ref.read(fcmTokenProvider.future);
    if (mounted) {
      setState(() {
        _fcmToken = token ?? 'Tidak tersedia';
      });
    }

    // Post token to backend if available (non-blocking)
    if (token != null && token != 'fcm-not-supported-on-desktop') {
      try {
        await ref.read(postDeviceTokenUseCaseProvider)(token);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal kirim FCM token: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  String _formatToken(String token) {
    if (token.length > 12) {
      return '${token.substring(0, 12)}...';
    }
    return token;
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(announcementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman Kampus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            tooltip: 'Logout',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(announcementsProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: announcementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat pengumuman',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(announcementsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (announcements) {
          if (announcements.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.announcement_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Belum ada pengumuman'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(announcementsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final a = announcements[index];
                return Card(
                  child: ListTile(
                    leading: a.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              a.imageUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 40),
                            ),
                          )
                        : const Icon(Icons.announcement, size: 40, color: Colors.indigo),
                    title: Text(
                      a.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          a.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(a.updatedAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.announcementDetail(a.id)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}