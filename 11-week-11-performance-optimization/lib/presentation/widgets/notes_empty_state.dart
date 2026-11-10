import 'package:flutter/material.dart';

class NotesEmptyState extends StatelessWidget {
  final String query;

  const NotesEmptyState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isNotEmpty) {
      return Center(
        key: const Key('search_empty_state'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada note dengan judul "$query"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }
    return const Center(child: Text('No notes yet.'));
  }
}
