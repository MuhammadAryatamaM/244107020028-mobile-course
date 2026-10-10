/// Announcement repository contract — pure domain interface.
/// Implementation lives in data layer.
import '../entities/announcement.dart';
import '../../../../core/failures.dart';

abstract class IAnnouncementRepository {
  /// Fetch all announcements (list).
  /// Returns list of [Announcement] on success, [Failure] on error.
  Future<({List<Announcement> announcements, Failure? failure})> fetchAnnouncements();

  /// Fetch single announcement detail by ID.
  /// Returns [Announcement] on success, [Failure] on error (e.g., not found).
  Future<({Announcement? announcement, Failure? failure})> fetchAnnouncementDetail(String id);
}