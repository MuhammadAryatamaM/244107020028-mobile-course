/// Pure domain entity for an announcement.
/// No JSON parsing, no framework imports.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final String? imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Announcement &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          body == other.body &&
          updatedAt == other.updatedAt &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      body.hashCode ^
      updatedAt.hashCode ^
      imageUrl.hashCode;

  @override
  String toString() => 'Announcement(id: $id, title: $title, updatedAt: $updatedAt)';
}