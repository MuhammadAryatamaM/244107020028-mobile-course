import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/domain/note.dart';
import 'package:week5_offline_notes/domain/note_repository_interface.dart';
import 'package:week5_offline_notes/domain/search_notes_use_case.dart';
import 'package:week5_offline_notes/presentation/notes_providers.dart';

class FakeNoteRepository implements NoteRepositoryInterface {
  FakeNoteRepository({this.items = const [], this.throwError = false});

  final List<Note> items;
  final bool throwError;

  @override
  Future<List<Note>> fetchNotes() {
    if (throwError) {
      return Future.error(
        Exception('Koneksi database terkunci (simulasi kegagalan)'),
      );
    }
    return Future.value(items);
  }

  @override
  Future<List<Note>> searchNotes(String query) {
    if (throwError) {
      return Future.error(Exception('Query pencarian gagal'));
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
    if (throwError) {
      return Future.error(Exception('Gagal menambah note'));
    }
    final newNote = Note(
      id: items.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    return Future.value(newNote);
  }

  @override
  Future<Note?> getNote(int id) {
    if (throwError) {
      return Future.error(Exception('Gagal mengambil detail note'));
    }
    final match = items.where((n) => n.id == id);
    return Future.value(match.isNotEmpty ? match.first : null);
  }

  @override
  Future<void> deleteNote(int id) {
    if (throwError) {
      return Future.error(Exception('Gagal menghapus note'));
    }
    return Future.value();
  }

  @override
  Future<void> markAllSynced() {
    return Future.value();
  }
}

void main() {
  group('Unit Test: SearchNotesUseCase dengan FakeRepository', () {
    test('Kasus Sukses: query kosong memanggil fetchNotes()', () async {
      final fakeRepo = FakeNoteRepository(
        items: [
          Note(id: 1, title: 'Catatan 1', updatedAt: DateTime.now()),
          Note(id: 2, title: 'Catatan 2', updatedAt: DateTime.now()),
        ],
      );
      final useCase = SearchNotesUseCase(fakeRepo);

      final result = await useCase.execute('');
      expect(result.length, 2);
    });

    test(
      'Kasus Sukses: query terisi memanggil searchNotes() dengan filter judul',
      () async {
        final fakeRepo = FakeNoteRepository(
          items: [
            Note(id: 1, title: 'Belajar Flutter', updatedAt: DateTime.now()),
            Note(id: 2, title: 'Makan Siang', updatedAt: DateTime.now()),
          ],
        );
        final useCase = SearchNotesUseCase(fakeRepo);

        final result = await useCase.execute('flutter');
        expect(result.length, 1);
        expect(result.first.title, 'Belajar Flutter');
      },
    );

    test(
      'Kasus Kegagalan: repository melempar error tertangkap dengan baik',
      () async {
        final fakeRepo = FakeNoteRepository(throwError: true);
        final useCase = SearchNotesUseCase(fakeRepo);

        expect(() => useCase.execute('flutter'), throwsA(isA<Exception>()));
      },
    );
  });

  group('Async & Riverpod Integration: searchNotesProvider', () {
    test('Provider mengembalikan data sukses saat repository normal', () async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(
              items: [
                Note(id: 1, title: 'Tes Provider', updatedAt: DateTime.now()),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notes = await container.read(searchNotesProvider.future);
      expect(notes.length, 1);
      expect(notes.first.title, 'Tes Provider');
    });

    test(
      'Provider menghasilkan AsyncError saat repository melempar error',
      () async {
        final container = ProviderContainer(
          overrides: [
            noteRepositoryProvider.overrideWithValue(
              FakeNoteRepository(throwError: true),
            ),
          ],
        );
        addTearDown(container.dispose);

        final values = <AsyncValue<List<Note>>>[];
        container.listen(searchNotesProvider, (_, next) => values.add(next));

        await Future.delayed(const Duration(milliseconds: 100));
        expect(values.last.error, isA<Exception>());
      },
    );

    test(
      'StateNotifier SearchQueryNotifier memperbarui dan membersihkan query',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(searchQueryProvider), '');

        container.read(searchQueryProvider.notifier).update('mobile');
        expect(container.read(searchQueryProvider), 'mobile');

        container.read(searchQueryProvider.notifier).clear();
        expect(container.read(searchQueryProvider), '');
      },
    );
  });
}
