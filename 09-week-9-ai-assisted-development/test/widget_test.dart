import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/domain/note.dart';
import 'package:week5_offline_notes/domain/note_repository_interface.dart';
import 'package:week5_offline_notes/domain/search_notes_use_case.dart';
import 'package:week5_offline_notes/presentation/notes_providers.dart';
import 'package:week5_offline_notes/pages/notes_page.dart';

class FakeNoteRepository implements NoteRepositoryInterface {
  FakeNoteRepository({this.items = const [], this.throwError = false});

  final List<Note> items;
  final bool throwError;

  @override
  Future<List<Note>> fetchNotes() {
    if (throwError) return Future.error(Exception('db locked (simulasi)'));
    return Future.value(items);
  }

  @override
  Future<List<Note>> searchNotes(String query) {
    if (throwError) return Future.error(Exception('db locked (simulasi)'));
    final q = query.toLowerCase();
    return Future.value(
      items.where((n) => n.title.toLowerCase().contains(q)).toList(),
    );
  }

  @override
  Future<int> countDirty() => Future.value(items.where((n) => n.dirty).length);

  @override
  Future<Note> addNote({required String title, String body = ''}) {
    throw UnimplementedError();
  }

  @override
  Future<Note?> getNote(int id) => Future.value(null);

  @override
  Future<void> deleteNote(int id) => Future.value();

  @override
  Future<void> markAllSynced() => Future.value();
}

void main() {
  group('Domain: filterNotesByTitle (Pure Function)', () {
    final sampleNotes = [
      Note(title: 'Belanja Sayur', updatedAt: DateTime(2026)),
      Note(title: 'Kuliah Mobile', updatedAt: DateTime(2026)),
      Note(title: 'Beli Buku Flutter', updatedAt: DateTime(2026)),
    ];

    test('mengembalikan semua list jika query kosong atau whitespace', () {
      expect(filterNotesByTitle(sampleNotes, ''), sampleNotes);
      expect(filterNotesByTitle(sampleNotes, '   '), sampleNotes);
    });

    test('memfilter judul secara case-insensitive', () {
      final result = filterNotesByTitle(sampleNotes, 'bel');
      expect(result.length, 2);
      expect(
        result.map((n) => n.title),
        containsAll(['Belanja Sayur', 'Beli Buku Flutter']),
      );
    });

    test('mengembalikan list kosong jika tidak ada judul yang cocok', () {
      final result = filterNotesByTitle(sampleNotes, 'Dart backend');
      expect(result, isEmpty);
    });
  });

  group('Domain: SearchNotesUseCase', () {
    test('memanggil fetchNotes saat query kosong', () async {
      final repo = FakeNoteRepository(
        items: [Note(title: 'A', updatedAt: DateTime.now())],
      );
      final useCase = SearchNotesUseCase(repo);
      final result = await useCase.execute('');
      expect(result.length, 1);
    });

    test('memanggil searchNotes saat query diisi', () async {
      final repo = FakeNoteRepository(
        items: [
          Note(title: 'Catatan Kuliah', updatedAt: DateTime.now()),
          Note(title: 'Catatan Pribadi', updatedAt: DateTime.now()),
          Note(title: 'Tugas', updatedAt: DateTime.now()),
        ],
      );
      final useCase = SearchNotesUseCase(repo);
      final result = await useCase.execute('kuliah');
      expect(result.length, 1);
      expect(result.first.title, 'Catatan Kuliah');
    });
  });

  group('Model Note', () {
    test('fromMap aman terhadap field yang hilang', () {
      final note = Note.fromMap({'title': 'Belanja'});
      expect(note.title, 'Belanja');
      expect(note.body, '');
      expect(note.dirty, isFalse);
    });

    test('flag dirty bertahan pada serialisasi', () {
      final note = Note(
        title: 'a',
        updatedAt: DateTime(2026, 9, 18),
        dirty: true,
      );
      final restored = Note.fromMap(note.toMap());
      expect(restored.dirty, isTrue);
    });
  });

  group('Riverpod Providers & Integration', () {
    test('provider sukses dengan repository palsu', () async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(
              items: [Note(title: 'Tes', updatedAt: DateTime.now())],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notes = await container.read(searchNotesProvider.future);
      expect(notes.length, 1);
      expect(notes.first.title, 'Tes');
    });

    test('provider error dengan repository palsu', () async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(throwError: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final values = <AsyncValue<List<Note>>>[];
      container.listen(searchNotesProvider, (previous, next) {
        values.add(next);
      });

      await Future.delayed(const Duration(milliseconds: 100));
      expect(values.last.error, isA<Exception>());
    });

    test('searchNotesProvider memfilter berdasarkan query state', () async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(
              items: [
                Note(title: 'Belanja', updatedAt: DateTime.now()),
                Note(title: 'Meeting', updatedAt: DateTime.now()),
                Note(title: 'Belajar Flutter', updatedAt: DateTime.now()),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).update('bel');
      await Future.delayed(const Duration(milliseconds: 500));

      final notes = await container.read(searchNotesProvider.future);
      expect(notes.length, 2);
      expect(
        notes.map((n) => n.title),
        containsAll(['Belanja', 'Belajar Flutter']),
      );
    });
  });

  testWidgets('NotesPage: empty state muncul ketika search tidak cocok', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(
            items: [Note(title: 'Belanja', updatedAt: DateTime.now())],
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

    await tester.enterText(find.byType(TextField), 'xyz tidak ada');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('search_empty_state')), findsOneWidget);
    expect(
      find.text('Tidak ada note dengan judul "xyz tidak ada"'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.search_off), findsOneWidget);
  });
}
