import '../../domain/entities/announcement.dart';

/// Model data luar (JSON) + mapping ke entity.
class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.body,
    required super.cachedAt,
  });

  factory AnnouncementModel.fromJson(
    Map<String, dynamic> json, {
    required DateTime cachedAt,
  }) {
    return AnnouncementModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      cachedAt: cachedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
      };

  Announcement toEntity() => Announcement(
        id: id,
        title: title,
        body: body,
        cachedAt: cachedAt,
      );
}
