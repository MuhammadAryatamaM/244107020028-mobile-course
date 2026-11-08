import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/network_provider.dart';
import '../../data/sync.dart';
import '../notes_providers.dart';

class NotesAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const NotesAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(forceOfflineProvider);
    final dirtyCountAsync = ref.watch(dirtyCountProvider);

    return AppBar(
      title: const Text('Offline Notes'),
      actions: [
        Row(
          children: [
            const Text('Offline', style: TextStyle(fontSize: 12)),
            Switch(
              value: isOffline,
              onChanged: (val) {
                ref.read(forceOfflineProvider.notifier).setOffline(val);
              },
            ),
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () async {
                try {
                  final syncService = ref.read(syncServiceProvider);
                  await syncService.syncNotes();
                  ref.invalidate(searchNotesProvider);
                  ref.invalidate(dirtyCountProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sync successful!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
                  }
                }
              },
            ),
            if (dirtyCountAsync.hasValue && dirtyCountAsync.value! > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${dirtyCountAsync.value}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
