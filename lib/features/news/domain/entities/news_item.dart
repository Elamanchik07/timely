import 'package:freezed_annotation/freezed_annotation.dart';

part 'news_item.freezed.dart';
part 'news_item.g.dart';

@freezed
// ignore_for_file: invalid_annotation_target
class NewsItem with _$NewsItem {
  const factory NewsItem({
    @JsonKey(readValue: _readId) required String id,
    required String title,
    required String content,
    @Default('none') String mediaType,
    String? mediaPath,
    String? thumbnailPath,
    @Default(false) bool isPublished,
    @Default('published') String status,
    DateTime? publishedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(readValue: _readAuthorId) required String authorId,
    @JsonKey(readValue: _readAuthor) Map<String, dynamic>? author,
    // ─── Metadata ───
    @Default('Announcements') String category,
    @Default(false) bool isPinned,
    // ─── Reaction System ───
    @Default([]) List<Map<String, dynamic>> reactions,
    @Default({}) Map<String, dynamic> reactionCounts,
    // ─── View Tracking ───
    @Default([]) List<String> viewers,
    @Default(0) int viewCount,
  }) = _NewsItem;

  factory NewsItem.fromJson(Map<String, dynamic> json) => _$NewsItemFromJson(json);
}

/// Reads 'id' first, then falls back to '_id' for MongoDB compatibility.
Object? _readId(Map<dynamic, dynamic> json, String key) {
  return json['id'] ?? json['_id'];
}

/// When Mongoose populates authorId, it becomes an object { _id, fullName }.
/// This extracts the _id string in that case.
Object? _readAuthorId(Map<dynamic, dynamic> json, String key) {
  final val = json['authorId'];
  if (val is Map) return val['_id']?.toString() ?? '';
  return val?.toString() ?? '';
}

/// When Mongoose populates authorId, extract it as the author map.
/// Falls back to a dedicated 'author' field if present.
Object? _readAuthor(Map<dynamic, dynamic> json, String key) {
  final authorId = json['authorId'];
  if (authorId is Map) {
    return Map<String, dynamic>.from(authorId);
  }
  return json['author'];
}
