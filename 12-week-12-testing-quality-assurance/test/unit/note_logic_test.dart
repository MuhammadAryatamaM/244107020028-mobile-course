import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/domain/note.dart';
import 'package:week5_offline_notes/domain/search_notes_use_case.dart';

void main() {
  group('Unit Test: Note Entity & Serialisasi', () {
    test('fromMap menghasilkan default value saat field opsional/kosong', () {
      final note = Note.fromMap({'title': 'Belanja'});
      expect(note.id, isNull);
      expect(note.title, 'Belanja');
      expect(note.body, '');
      expect(note.dirty, isFalse);
      expect(note.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test(
      'toMap dan fromMap mempertahankan seluruh nilai termasuk dirty flag',
      () {
        final original = Note(
          id: 42,
          title: 'Tugas Mobile',
          body: 'Kerjakan week 12',
          updatedAt: DateTime(2026, 11, 22, 10, 30),
          dirty: true,
        );

        final map = original.toMap();
        final restored = Note.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.body, original.body);
        expect(
          restored.updatedAt.toIso8601String(),
          original.updatedAt.toIso8601String(),
        );
        expect(restored.dirty, isTrue);
      },
    );

    test(
      'Kasus Tepi: fromMap menangani input map kosong tanpa melempar exception',
      () {
        final emptyNote = Note.fromMap({});
        expect(emptyNote.title, '');
        expect(emptyNote.body, '');
        expect(emptyNote.dirty, isFalse);
      },
    );
  });

  group('Unit Test: filterNotesByTitle (Pure Function Logic)', () {
    final sampleNotes = [
      Note(
        title: 'Belanja Sayur',
        body: 'Bayam dan wortel',
        updatedAt: DateTime(2026),
      ),
      Note(
        title: 'Kuliah Mobile',
        body: 'Ruang lab 2',
        updatedAt: DateTime(2026),
      ),
      Note(
        title: 'Beli Buku Flutter',
        body: 'Arsitektur perangkat lunak',
        updatedAt: DateTime(2026),
      ),
    ];

    test('Kasus Sukses: memfilter note dengan substring judul secara case-insensitive', () {
      final result = filterNotesByTitle(sampleNotes, 'bEl');
      expect(result.length, 2);
      expect(
        result.map((n) => n.title),
        containsAll(['Belanja Sayur', 'Beli Buku Flutter']),
      );
    });

    test(
      'Kasus Tepi: whitespace berlebih dipangkas (trimmed) dengan benar',
      () {
        final result = filterNotesByTitle(sampleNotes, '   kuliah   ');
        expect(result.length, 1);
        expect(result.first.title, 'Kuliah Mobile');
      },
    );

    test('Kasus Tepi: query string kosong mengembalikan seluruh list', () {
      expect(filterNotesByTitle(sampleNotes, ''), sampleNotes);
      expect(filterNotesByTitle(sampleNotes, '   '), sampleNotes);
    });

    test('Kasus Kegagalan/Tidak Cocok: query tidak ada yang cocok menghasilkan list kosong', () {
      final result = filterNotesByTitle(sampleNotes, 'Python Backend');
      expect(result, isEmpty);
    });
  });
}
