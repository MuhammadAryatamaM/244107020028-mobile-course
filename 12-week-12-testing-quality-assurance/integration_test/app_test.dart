import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/domain/note.dart';
import 'package:week5_offline_notes/domain/note_repository_interface.dart';
import 'package:week5_offline_notes/pages/home_page.dart';

class InMemoryNoteRepository implements NoteRepositoryInterface {
  final List<Note> _notes = [];

  @override
  Future<List<Note>> fetchNotes() async => List.unmodifiable(_notes);

  @override
  Future<List<Note>> searchNotes(String query) async {
    final q = query.toLowerCase();
    return _notes.where((n) => n.title.toLowerCase().contains(q)).toList();
  }

  @override
  Future<int> countDirty() async => _notes.where((n) => n.dirty).length;

  @override
  Future<Note> addNote({required String title, String body = ''}) async {
    final note = Note(
      id: _notes.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    _notes.insert(0, note);
    return note;
  }

  @override
  Future<Note?> getNote(int id) async {
    final match = _notes.where((n) => n.id == id);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<void> deleteNote(int id) async {
    _notes.removeWhere((n) => n.id == id);
  }

  @override
  Future<void> markAllSynced() async {
    for (var i = 0; i < _notes.length; i++) {
      if (_notes[i].dirty) {
        _notes[i] = Note(
          id: _notes[i].id,
          title: _notes[i].title,
          body: _notes[i].body,
          updatedAt: _notes[i].updatedAt,
          dirty: false,
        );
      }
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Integration Test: Alur Utama End-to-End (Buka Notes -> Tambah Note -> Cari -> Buka Tab)',
    (tester) async {
      final inMemoryRepo = InMemoryNoteRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [noteRepositoryProvider.overrideWithValue(inMemoryRepo)],
          child: const MaterialApp(home: HomePage()),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Pindah ke Tab Notes dari BottomNavigationBar
      final notesNavTab = find.byIcon(Icons.note_outlined);
      expect(notesNavTab, findsOneWidget);
      await tester.tap(notesNavTab);
      await tester.pumpAndSettle();

      // 2. Verifikasi kondisi awal (belum ada catatan)
      expect(find.text('No notes yet.'), findsOneWidget);

      // 3. Tambah Catatan Baru melalui FAB
      final addFab = find.byType(FloatingActionButton);
      expect(addFab, findsOneWidget);
      await tester.tap(addFab);
      await tester.pumpAndSettle();

      // Verifikasi catatan baru muncul di ListView
      expect(find.text('No notes yet.'), findsNothing);
      expect(find.byType(ListView), findsOneWidget);

      // 4. Uji Alur Pencarian Judul
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Cari kata kunci yang cocok
      await tester.enterText(searchField, 'New Note');
      await tester.pump(const Duration(milliseconds: 500)); // Tunggu debounce
      await tester.pumpAndSettle();
      expect(find.textContaining('New Note'), findsOneWidget);

      // Cari kata kunci yang tidak cocok -> harus memicu empty state
      await tester.enterText(searchField, 'Data Tidak Ada 9999');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('search_empty_state')), findsOneWidget);

      // 5. Bersihkan pencarian melalui tombol clear
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Catatan kembali tampil
      expect(find.textContaining('New Note'), findsOneWidget);
    },
  );
}
