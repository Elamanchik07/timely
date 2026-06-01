import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/room_utils.dart';
import '../domain/entities/schedule_item.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ScheduleRepository(apiClient);
});

class ScheduleRepository {
  final ApiClient _apiClient;

  ScheduleRepository(this._apiClient);

  Future<List<ScheduleItem>> getSchedule(String groupCode) async {
    try {
      final response = await _apiClient.client.get(
        '/schedule',
        queryParameters: {'groupCode': groupCode},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> items = response.data['scheduleItems'] ?? [];
        return items.map((json) {
          final map = Map<String, dynamic>.from(json);
          // Normalize MongoDB _id to id
          if (map.containsKey('_id') && !map.containsKey('id')) {
            map['id'] = map['_id'];
          }
          // Normalize room code to full format (e.g., C1.1.225)
          if (map.containsKey('room') && map['room'] != null) {
            map['room'] = RoomUtils.displayCode(map['room'].toString());
          }
          return ScheduleItem.fromJson(map);
        }).toList();
      } else {
        throw Exception(response.data['msg'] ?? 'Не удалось загрузить расписание');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Превышено время ожидания. Проверьте подключение.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Нет соединения с сервером');
      }
      throw Exception(e.response?.data?['msg'] ?? 'Ошибка загрузки расписания');
    }
  }
}
