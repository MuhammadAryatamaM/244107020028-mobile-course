import 'note.dart';
import 'note_repository_interface.dart';

List<Note> filterNotesByTitle(List<Note> notes, String query) {
  final cleanQuery = query.trim().toLowerCase();
  if (cleanQuery.isEmpty) return notes;
  return notes
      .where((note) => note.title.toLowerCase().contains(cleanQuery))
      .toList();
}

class SearchNotesUseCase {
  final NoteRepositoryInterface _repository;

  const SearchNotesUseCase(this._repository);

  Future<List<Note>> execute(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return _repository.fetchNotes();
    }
    return _repository.searchNotes(cleanQuery);
  }
}
