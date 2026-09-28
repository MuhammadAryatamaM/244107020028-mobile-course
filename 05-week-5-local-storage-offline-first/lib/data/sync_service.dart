import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repositories/note_repository.dart';
import 'network_provider.dart';

final syncServiceProvider = Provider((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  return SyncService(repo, ref);
});

class SyncService {
  final NoteRepository repo;
  final Ref ref;

  SyncService(this.repo, this.ref);

  Future<int> syncNotes() async {
    final isOffline = ref.read(forceOfflineProvider);
    if (isOffline) {
      // Simulate that sync fails when offline
      throw Exception('Force Offline is ON. Cannot sync.');
    }

    final dirtyCount = await repo.countDirty();
    if (dirtyCount == 0) return 0;

    // Simulasi upload: pada project nyata, kirim tiap catatan dirty
    // ke REST API di sini, lalu tandai bersih bila server menjawab 2xx.
    await Future.delayed(const Duration(seconds: 1));
    await repo.markAllSynced();

    return dirtyCount;
  }
}
