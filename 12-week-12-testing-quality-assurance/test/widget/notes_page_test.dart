import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/domain/note.dart';
import 'package:week5_offline_notes/domain/note_repository_interface.dart';
import 'package:week5_offline_notes/pages/notes_page.dart';
import 'package:week5_offline_notes/presentation/widgets/notes_app_bar.dart';
import 'package:week5_offline_notes/presentation/widgets/notes_empty_state.dart';
import 'package:week5_offline_notes/presentation/widgets/notes_search_bar.dart';
import 'package:week5_offline_notes/widgets/note_tile.dart';

class FakeNoteRepository implements NoteRepositoryInterface {
  FakeNoteRepository({this.items = const [], this.throwError = false});

  final List<Note> items;
  final bool throwError;

  @override
  Future<List<Note>> fetchNotes() {
    if (throwError) {
      return Future.error(Exception('Database error'));
    }
    return Future.value(items);
  }

  @override
  Future<List<Note>> searchNotes(String query) {
    if (throwError) {
      return Future.error(Exception('Database search error'));
    }
    final q = query.toLowerCase();
    return Future.value(
      items.where((n) => n.title.toLowerCase().contains(q)).toList(),
    );
  }

  @override
  Future<int> countDirty() => Future.value(items.where((n) => n.dirty).length);

  @override
  Future<Note> addNote({required String title, String body = ''}) {
    final note = Note(
      id: items.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    items.add(note);
    return Future.value(note);
  }

  @override
  Future<Note?> getNote(int id) {
    final match = items.where((n) => n.id == id);
    return Future.value(match.isNotEmpty ? match.first : null);
  }

  @override
  Future<void> deleteNote(int id) {
    items.removeWhere((n) => n.id == id);
    return Future.value();
  }

  @override
  Future<void> markAllSynced() => Future.value();
}

void main() {
  group('Widget Test: Notes Page UI & Interaksi', () {
    testWidgets('Tampilan awal me-render App Bar, Search Bar, dan FAB', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(
              items: [
                Note(id: 1, title: 'Catatan Awal', updatedAt: DateTime.now()),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: NotesPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NotesAppBar), findsOneWidget);
      expect(find.byType(NotesSearchBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Catatan Awal'), findsOneWidget);
    });

    testWidgets('Empty State muncul ketika belum ada catatan sama sekali', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(items: []),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: NotesPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NotesEmptyState), findsOneWidget);
      expect(find.text('No notes yet.'), findsOneWidget);
    });

    testWidgets(
      'Search Empty State muncul saat query tidak menghasilkan kecocokan',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            noteRepositoryProvider.overrideWithValue(
              FakeNoteRepository(
                items: [
                  Note(
                    id: 1,
                    title: 'Belanja Sayur',
                    updatedAt: DateTime.now(),
                  ),
                ],
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: NotesPage()),
          ),
        );
        await tester.pumpAndSettle();

        // Masukkan query pencarian yang tidak ada di daftar
        await tester.enterText(find.byType(TextField), 'Kriptografi');
        await tester.pump(const Duration(milliseconds: 500)); // Debounce delay
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('search_empty_state')), findsOneWidget);
        expect(
          find.text('Tidak ada note dengan judul "Kriptografi"'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.search_off), findsOneWidget);

        // Tekan tombol clear (X) pada search bar
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pumpAndSettle();

        // Daftar kembali menampilkan catatan semula
        expect(find.text('Belanja Sayur'), findsOneWidget);
      },
    );

    testWidgets('Menambah catatan baru berhasil memicu update pada UI', (
      tester,
    ) async {
      final fakeRepo = FakeNoteRepository(items: []);
      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(fakeRepo)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: NotesPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No notes yet.'), findsOneWidget);

      // Tekan tombol FAB Add
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verifikasi item baru bertambah di tampilan
      expect(find.byType(NoteTile), findsOneWidget);
      expect(fakeRepo.items.length, 1);
    });
  });
}
