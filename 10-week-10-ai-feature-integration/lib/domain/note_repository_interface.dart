import 'note.dart';

abstract class NoteRepositoryInterface {
  Future<List<Note>> fetchNotes();
  Future<List<Note>> searchNotes(String query);
  Future<Note> addNote({required String title, String body = ''});
  Future<Note?> getNote(int id);
  Future<void> deleteNote(int id);
  Future<int> countDirty();
  Future<void> markAllSynced();
}
