import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/core_providers.dart';
import 'package:mobile_project_app/features/news/domain/entities/news_item.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NewsRepository(apiClient);
});

class NewsRepository {
  final ApiClient _apiClient;

  NewsRepository(this._apiClient);

  /// Detects MIME type by reading the first bytes (magic bytes) of the file.
  /// Works across Native and Web by using XFile stream.
  static Future<MediaType> detectMediaType(XFile file) async {
    try {
      final stream = file.openRead(0, 12);
      final Uint8List header = Uint8List.fromList(await stream.first);

      // JPEG: FF D8 FF
      if (header.length >= 3 &&
          header[0] == 0xFF &&
          header[1] == 0xD8 &&
          header[2] == 0xFF) {
        return MediaType('image', 'jpeg');
      }

      // PNG: 89 50 4E 47 0D 0A 1A 0A
      if (header.length >= 8 &&
          header[0] == 0x89 &&
          header[1] == 0x50 &&
          header[2] == 0x4E &&
          header[3] == 0x47 &&
          header[4] == 0x0D &&
          header[5] == 0x0A &&
          header[6] == 0x1A &&
          header[7] == 0x0A) {
        return MediaType('image', 'png');
      }

      // WebP: RIFF....WEBP
      if (header.length >= 12 &&
          header[0] == 0x52 && // R
          header[1] == 0x49 && // I
          header[2] == 0x46 && // F
          header[3] == 0x46 && // F
          header[8] == 0x57 && // W
          header[9] == 0x45 && // E
          header[10] == 0x42 && // B
          header[11] == 0x50) {
        // P
        return MediaType('image', 'webp');
      }

      // GIF: GIF87a or GIF89a
      if (header.length >= 6 &&
          header[0] == 0x47 && // G
          header[1] == 0x49 && // I
          header[2] == 0x46) {
        // F
        return MediaType('image', 'gif');
      }
    } catch (_) {
      // Fall through to extension-based detection
    }

    // Fallback: detect by extension
    final ext = p.extension(file.name).toLowerCase().replaceAll('.', '');
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'gif':
        return MediaType('image', 'gif');
      default:
        return MediaType('image', 'jpeg'); // Fallback to jpeg to avoid server rejection
    }
  }

  Future<Map<String, dynamic>> getNews({int page = 1, int limit = 10, String? category}) async {
    try {
      final response = await _apiClient.client.get('/news', queryParameters: {
        'page': page,
        'limit': limit,
        if (category != null && category != 'All') 'category': category,
      });

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['news'];
        return {
          'news': items.map((json) => NewsItem.fromJson(json)).toList(),
          'hasMore': response.data['pagination']['hasMore'] ?? false,
        };
      }
      throw Exception(response.data['msg'] ?? 'Ошибка загрузки новостей');
    } on DioException catch (e) {
      throw Exception(e.response?.data['msg'] ?? 'Ошибка сети');
    }
  }

  Future<List<NewsItem>> getAllNewsForAdmin({String? search}) async {
    try {
      final response =
          await _apiClient.client.get('/news/admin/all', queryParameters: {
        if (search != null) 'search': search,
      });

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['news'];
        return items.map((json) => NewsItem.fromJson(json)).toList();
      }
      throw Exception(response.data['msg'] ?? 'Ошибка загрузки');
    } on DioException catch (e) {
      throw Exception(e.response?.data['msg'] ?? 'Ошибка сети');
    }
  }

  Future<NewsItem> createNews({
    required String title,
    required String content,
    bool isPublished = false,
    String category = 'Announcements',
    bool isPinned = false,
    XFile? media,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final formDataMap = <String, dynamic>{
        'title': title,
        'content': content,
        'isPublished': isPublished.toString(),
        'category': category,
        'isPinned': isPinned.toString(),
      };

      if (media != null) {
        final mediaType = await detectMediaType(media);
        if (kIsWeb) {
          final bytes = await media.readAsBytes();
          formDataMap['media'] = MultipartFile.fromBytes(
            bytes,
            filename: media.name,
            contentType: mediaType,
          );
        } else {
          formDataMap['media'] = await MultipartFile.fromFile(
            media.path,
            filename: media.name,
            contentType: mediaType,
          );
        }
      }

      final formData = FormData.fromMap(formDataMap);
      final response = await _apiClient.client.post(
        '/news',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.data['success'] == true) {
        return NewsItem.fromJson(response.data['news']);
      }
      throw Exception(response.data['msg'] ?? 'Ошибка создания');
    } on DioException catch (e) {
      throw Exception(e.response?.data['msg'] ?? 'Ошибка сети');
    }
  }

  Future<NewsItem> updateNews(
    String id, {
    String? title,
    String? content,
    bool? isPublished,
    String? category,
    bool? isPinned,
    XFile? media,
    bool removeMedia = false,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final formDataMap = <String, dynamic>{
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (isPublished != null) 'isPublished': isPublished.toString(),
        if (category != null) 'category': category,
        if (isPinned != null) 'isPinned': isPinned.toString(),
        if (removeMedia) 'removeMedia': 'true',
      };

      if (media != null) {
        final mediaType = await detectMediaType(media);
        if (kIsWeb) {
          final bytes = await media.readAsBytes();
          formDataMap['media'] = MultipartFile.fromBytes(
            bytes,
            filename: media.name,
            contentType: mediaType,
          );
        } else {
          formDataMap['media'] = await MultipartFile.fromFile(
            media.path,
            filename: media.name,
            contentType: mediaType,
          );
        }
      }

      final formData = FormData.fromMap(formDataMap);
      final response = await _apiClient.client.put(
        '/news/$id',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.data['success'] == true) {
        return NewsItem.fromJson(response.data['news']);
      }
      throw Exception(response.data['msg'] ?? 'Ошибка обновления');
    } on DioException catch (e) {
      throw Exception(e.response?.data['msg'] ?? 'Ошибка сети');
    }
  }

  Future<void> togglePublish(String id) async {
    try {
      final response = await _apiClient.client.patch('/news/$id/publish');
      if (response.data['success'] != true) {
        throw Exception(response.data['msg'] ?? 'Ошибка');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['msg'] ?? 'Ошибка сети');
    }
  }

  Future<void> deleteNews(String id) async {
    try {
      final response = await _apiClient.client.delete('/news/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['msg'] ?? 'Ошибка');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['msg'] ?? 'Ошибка сети');
    }
  }

  /// Toggle/change reaction on a news item.
  Future<Map<String, dynamic>> toggleReaction(String newsId, String type) async {
    try {
      final response = await _apiClient.client.put(
        '/news/$newsId/react',
        data: {'type': type},
      );
      if (response.data['success'] == true) {
        return {
          'reactions': response.data['reactions'] ?? [],
          'reactionCounts': response.data['reactionCounts'] ?? {},
        };
      }
      throw Exception(response.data['msg'] ?? 'Ошибка');
    } on DioException catch (e) {
      throw Exception(e.response?.data['msg'] ?? 'Ошибка сети');
    }
  }

  /// Track a unique view for a news item.
  Future<void> trackView(String newsId) async {
    try {
      await _apiClient.client.post('/news/$newsId/view');
    } on DioException catch (e) {
      debugPrint('Error tracking view: $e');
    }
  }
}
