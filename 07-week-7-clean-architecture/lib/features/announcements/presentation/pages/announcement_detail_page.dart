/// Announcement detail page — pure presentation, consumes announcementDetailProvider.
/// No direct repository, Dio, or data layer imports.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/announcements_providers.dart';

class AnnouncementDetailPage extends ConsumerWidget {
  const AnnouncementDetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(announcementDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengumuman')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                const Text('Gagal memuat detail', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(err.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(announcementDetailProvider(id)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (announcement) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (announcement.imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        announcement.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    announcement.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Diperbarui: ${_formatDate(announcement.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    announcement.body,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}