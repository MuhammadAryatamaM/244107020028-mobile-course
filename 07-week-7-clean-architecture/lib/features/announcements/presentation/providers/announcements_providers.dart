/// Announcements feature presentation providers — wiring DI + state (FutureProvider).
/// Simple CRUD: repository → FutureProvider directly (no use case needed).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_notify/features/auth/presentation/providers/auth_providers.dart';
import 'package:campus_notify/features/announcements/data/repositories/announcement_repository_impl.dart';
import 'package:campus_notify/features/announcements/domain/repositories/i_announcement_repository.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';

// ==========================================
// DATA LAYER PROVIDER
// ==========================================

/// Repository implementation using shared Dio from auth feature.
final announcementRepositoryProvider = Provider<IAnnouncementRepository>((ref) {
  final dio = ref.watch(apiClientProvider); // Shared Dio with auth interceptor
  return AnnouncementRepositoryImpl(dio: dio);
});

// ==========================================
// PRESENTATION LAYER (State)
// ==========================================

/// Announcements list — FutureProvider for simple async data.
/// Auto-refetches on auth state change (via apiClientProvider dependency).
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final repo = ref.watch(announcementRepositoryProvider);
  final result = await repo.fetchAnnouncements();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.announcements;
});

/// Announcement detail — FutureProvider.family for parameterized fetch.
/// Auto-disposes when not used (cache timeout).
final announcementDetailProvider = FutureProvider.autoDispose.family<Announcement, String>((ref, id) async {
  final repo = ref.watch(announcementRepositoryProvider);
  final result = await repo.fetchAnnouncementDetail(id);
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.announcement!;
});