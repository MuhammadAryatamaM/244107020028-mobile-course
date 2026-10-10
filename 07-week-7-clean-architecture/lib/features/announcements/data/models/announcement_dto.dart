/// Data transfer object for Announcement — extends domain entity with JSON mapping.
/// Only place where JSON parsing/serialization lives.
import '../../../domain/entities/announcement.dart';

class AnnouncementDto extends Announcement {
  const AnnouncementDto({
    required super.id,
    required super.title,
    required super.body,
    required super.updatedAt,
    super.imageUrl,
  });

  /// Create from backend JSON response.
  factory AnnouncementDto.fromJson(Map<String, dynamic> json) {
    return AnnouncementDto(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: json['title'] ?? json['judul'] ?? '',
      body: json['body'] ?? json['isi'] ?? json['content'] ?? '',
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt'] ?? json['created_at'] ?? json['createdAt']),
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? json['image'],
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  /// Convert to JSON for request body (if needed).
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'updated_at': updatedAt.toIso8601String(),
        'image_url': imageUrl,
      };

  /// Convert to domain entity (pure, no framework deps).
  Announcement toEntity() => Announcement(
        id: id,
        title: title,
        body: body,
        updatedAt: updatedAt,
        imageUrl: imageUrl,
      );
}