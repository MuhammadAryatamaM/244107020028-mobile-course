import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/note_repository.dart';
import '../presentation/notes_providers.dart';
import '../presentation/widgets/notes_app_bar.dart';
import '../presentation/widgets/notes_empty_state.dart';
import '../presentation/widgets/notes_search_bar.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(searchNotesProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: const NotesAppBar(),
      body: Column(
        children: [
          const NotesSearchBar(),
          Expanded(
            child: notesAsync.when(
              data: (notes) {
                if (notes.isEmpty) {
                  return NotesEmptyState(query: query);
                }
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteTile(
                      note: note,
                      onTap: () {
                        if (note.id != null) {
                          context.push('/note/${note.id}');
                        }
                      },
                      onLongPress: () async {
                        if (note.id != null) {
                          await ref
                              .read(noteRepositoryProvider)
                              .deleteNote(note.id!);
                          ref.invalidate(searchNotesProvider);
                          ref.invalidate(dirtyCountProvider);
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ref
              .read(noteRepositoryProvider)
              .addNote(
                title: 'New Note ${DateTime.now().second}',
                body: 'Note created at ${DateTime.now().toIso8601String()}',
              );
          ref.invalidate(searchNotesProvider);
          ref.invalidate(dirtyCountProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
