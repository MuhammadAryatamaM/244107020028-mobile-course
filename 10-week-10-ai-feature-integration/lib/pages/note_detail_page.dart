import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../presentation/ai_providers.dart';

final noteDetailProvider = FutureProvider.family.autoDispose<Note?, int>((
  ref,
  id,
) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getNote(id);
});

class NoteDetailPage extends ConsumerStatefulWidget {
  final int noteId;
  const NoteDetailPage({super.key, required this.noteId});

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  String? _summary;
  bool _isLoading = false;
  String? _error;

  Future<void> _summarize(String title, String body) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _summary = null;
    });
    try {
      final result = await ref
          .read(aiServiceProvider)
          .summarizeNote(title: title, body: body);
      setState(() => _summary = result);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteAsync = ref.watch(noteDetailProvider(widget.noteId));

    return Scaffold(
      appBar: AppBar(title: const Text('Note Detail')),
      body: noteAsync.when(
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Note not found.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Updated: ${note.updatedAt.toLocal()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                if (note.dirty)
                  Chip(
                    label: const Text('Not synced'),
                    avatar: const Icon(Icons.cloud_upload_outlined, size: 16),
                    backgroundColor: Colors.orange.shade100,
                  ),
                const Divider(height: 32),
                Text(
                  note.body.isEmpty ? '(empty body)' : note.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // ── AI Summarize Button ──
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _summarize(note.title, note.body),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _isLoading ? 'Meringkas…' : 'Ringkas dengan AI',
                    ),
                  ),
                ),

                // ── Error ──
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── AI Summary Result ──
                if (_summary != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer
                          .withAlpha(180),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Ringkasan AI',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _summary!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
