import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/room_utils.dart';
import '../domain/entities/room.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MapRepository(apiClient);
});

class MapRepository {
  final ApiClient _apiClient;

  MapRepository(this._apiClient);

  Future<List<Room>> getRooms({String? building, int? floor}) async {
    try {
      final query = <String, dynamic>{};
      if (building != null) query['building'] = building;
      if (floor != null) query['floor'] = floor;

      final response = await _apiClient.client.get('/rooms', queryParameters: query);
      
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> items = response.data['rooms'];
        return items.map((json) {
           final map = Map<String, dynamic>.from(json);
           if (!map.containsKey('id') && map.containsKey('_id')) {
              map['id'] = map['_id'].toString();
           }
           if (map.containsKey('positionX')) {
              map['lat'] = (map['positionX'] as num).toDouble();
           }
           if (map.containsKey('positionY')) {
              map['lng'] = (map['positionY'] as num).toDouble();
           }
           if (map.containsKey('shortCode') && map['shortCode'] != null && map['shortCode'].toString().isNotEmpty) {
              map['code'] = map['shortCode'];
           }
           if (!map.containsKey('fullCode') || map['fullCode'] == null || map['fullCode'].toString().isEmpty) {
              map['fullCode'] = RoomCodeNormalizer.toFullCode(map['code'] ?? '');
           }
           if (!map.containsKey('title')) {
              map['title'] = map['code'] ?? '';
           }
           return Room.fromJson(map);
        }).toList();
      } else {
        throw Exception('Failed to load rooms');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error');
    }
  }
}
