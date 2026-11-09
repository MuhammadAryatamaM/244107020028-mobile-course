import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/note_repository.dart';
import '../domain/note.dart';
import '../domain/search_notes_use_case.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final searchNotesUseCaseProvider = Provider<SearchNotesUseCase>((ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return SearchNotesUseCase(repository);
});

final searchNotesProvider = FutureProvider.autoDispose<List<Note>>((ref) async {
  final useCase = ref.watch(searchNotesUseCaseProvider);
  final query = ref.watch(searchQueryProvider).trim();

  if (query.isNotEmpty) {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  return useCase.execute(query);
});

final dirtyCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.countDirty();
});
