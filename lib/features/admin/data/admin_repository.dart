import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/domain/entities/user.dart';
import '../domain/entities/group.dart';
import '../domain/entities/course.dart';
import '../domain/entities/subject.dart';
import '../domain/entities/teacher.dart';
import '../../map/domain/entities/room.dart';
import '../domain/entities/admin_log.dart';
import '../../schedule/domain/entities/schedule_item.dart';
import '../../../core/utils/room_utils.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminRepository(apiClient);
});

class AdminRepository {
  final ApiClient _apiClient;

  AdminRepository(this._apiClient);

  // ─── Students ─────────────────────────────────────

  Future<List<User>> getStudents({String? status, String? search, String? course, String? groupCode}) async {
    try {
      final query = <String, dynamic>{};
      if (status != null && status.isNotEmpty) query['status'] = status;
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (course != null && course.isNotEmpty) query['course'] = course;
      if (groupCode != null && groupCode.isNotEmpty) query['groupCode'] = groupCode;

      final response = await _apiClient.client.get('/admin/students', queryParameters: query);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> items = response.data['students'] ?? [];
        return items.map((json) => User.fromJson(_fixId(json))).toList();
      }
      throw Exception(response.data['msg'] ?? 'Не удалось загрузить пользователей');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['msg'] ?? 'Ошибка сети');
    }
  }

  Future<User> createStudent(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.post('/admin/students', data: data);
      if (response.data['success'] == true) {
        return User.fromJson(_fixId(response.data['student']));
      }
      throw Exception(response.data['msg'] ?? 'Ошибка создания студента');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['msg'] ?? 'Ошибка сети');
    }
  }

  Future<User> updateStudent(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.put('/admin/students/$id', data: data);
      if (response.data['success'] == true) {
        return User.fromJson(_fixId(response.data['student']));
      }
      throw Exception(response.data['msg'] ?? 'Ошибка обновления студента');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['msg'] ?? 'Ошибка сети');
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      final response = await _apiClient.client.delete('/admin/students/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['msg'] ?? 'Не удалось удалить');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['msg'] ?? 'Ошибка сети');
    }
  }

  Future<void> bulkActionStudents(List<String> studentIds, String action, String? payload) async {
    try {
      final response = await _apiClient.client.post('/admin/students/bulk', data: {
        'studentIds': studentIds,
        'action': action,
        'payload': payload,
      });
      if (response.data['success'] != true) {
        throw Exception(response.data['msg'] ?? 'Не удалось выполнить действие');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['msg'] ?? 'Ошибка сети');
    }
  }

  // ─── Courses ─────────────────────────────────────

  Future<List<Course>> getCourses() async {
    try {
      final response = await _apiClient.client.get('/admin/courses');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> items = response.data['courses'] ?? [];
        return items.map((json) => Course.fromJson(_fixId(json))).toList();
      }
      return [];
    } catch (_) { return []; }
  }

  Future<void> createCourse(Map<String, dynamic> data) async {
    await _apiClient.client.post('/admin/courses', data: data);
  }

  Future<void> updateCourse(String id, Map<String, dynamic> data) async {
    await _apiClient.client.put('/admin/courses/$id', data: data);
  }

  Future<void> deleteCourse(String id) async {
    await _apiClient.client.delete('/admin/courses/$id');
  }

  // ─── Groups ─────────────────────────────────────

  Future<List<Group>> getGroups() async {
    try {
      final response = await _apiClient.client.get('/admin/groups');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> items = response.data['groups'] ?? [];
        return items.map((json) => Group.fromJson(_fixId(json))).toList();
      }
      return [];
    } catch (_) { return []; }
  }

  Future<void> createGroup(Map<String, dynamic> data) async {
    await _apiClient.client.post('/admin/groups', data: data);
  }

  Future<void> updateGroup(String id, Map<String, dynamic> data) async {
    await _apiClient.client.put('/admin/groups/$id', data: data);
  }

  Future<void> deleteGroup(String id) async {
    await _apiClient.client.delete('/admin/groups/$id');
  }

  // ─── Teachers ─────────────────────────────────────

  Future<List<Teacher>> getTeachers() async {
    try {
      final response = await _apiClient.client.get('/admin/teachers');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> items = response.data['teachers'] ?? [];
        return items.map((json) => Teacher.fromJson(_fixId(json))).toList();
      }
      return [];
    } catch (_) { return []; }
  }

  Future<void> createTeacher(Map<String, dynamic> data) async {
    await _apiClient.client.post('/admin/teachers', data: data);
  }

  Future<void> updateTeacher(String id, Map<String, dynamic> data) async {
    await _apiClient.client.put('/admin/teachers/$id', data: data);
  }

  Future<void> deleteTeacher(String id) async {
    await _apiClient.client.delete('/admin/teachers/$id');
  }

  // ─── Rooms ─────────────────────────────────────

  Future<List<Room>> getRooms() async {
    try {
      final response = await _apiClient.client.get('/rooms');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> items = response.data['rooms'] ?? [];
        return items.map((json) {
           final map = _fixId(json);
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
      }
      return [];
    } catch (_) { return []; }
  }

  Future<void> createRoom(Map<String, dynamic> data) async {
    await _apiClient.client.post('/rooms', data: data);
  }

  Future<void> updateRoom(String id, Map<String, dynamic> data) async {
    await _apiClient.client.put('/rooms/$id', data: data);
  }

  Future<void> deleteRoom(String id) async {
    await _apiClient.client.delete('/rooms/$id');
  }

  Future<String> bulkImportRooms(List<dynamic> rooms) async {
    try {
      final response = await _apiClient.client.post('/admin/rooms/bulk-import', data: {
        'rooms': rooms,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        final imported = response.data['imported'] ?? 0;
        final skipped = response.data['skipped'] ?? 0;
        return 'Импортировано: $imported, Пропущено: $skipped';
      }
      return 'Ошибка импорта';
    } catch (e) {
      return 'Ошибка: $e';
    }
  }

  // ─── Subjects ─────────────────────────────────────

  Future<List<Subject>> getSubjects() async {
    try {
      final response = await _apiClient.client.get('/admin/subjects');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> items = response.data['subjects'] ?? [];
        return items.map((json) => Subject.fromJson(_fixId(json))).toList();
      }
      return [];
    } catch (_) { return []; }
  }

  Future<void> createSubject(Map<String, dynamic> data) async {
    await _apiClient.client.post('/admin/subjects', data: data);
  }

  Future<void> updateSubject(String id, Map<String, dynamic> data) async {
    await _apiClient.client.put('/admin/subjects/$id', data: data);
  }

  Future<void> deleteSubject(String id) async {
    await _apiClient.client.delete('/admin/subjects/$id');
  }

  // ─── Admin Logs ─────────────────────────────────────

  Future<List<AdminLog>> getAdminLogs() async {
    try {
      final response = await _apiClient.client.get('/admin/logs');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> items = response.data['logs'] ?? [];
        return items.map((json) => AdminLog.fromJson(_fixId(json))).toList();
      }
      return [];
    } catch (_) { return []; }
  }

  // ─── Schedule CRUD ────────────────────────────────

  Future<List<ScheduleItem>> getScheduleByGroup(String groupCode) async {
    try {
      final response = await _apiClient.client.get('/schedule', queryParameters: {'groupCode': groupCode});
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> items = response.data['scheduleItems'] ?? [];
        return items.map((json) => ScheduleItem.fromJson(_fixId(json))).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['msg'] ?? 'Ошибка загрузки расписания');
    }
  }

  Future<void> createScheduleItem(Map<String, dynamic> data) async {
    await _apiClient.client.post('/schedule', data: data);
  }

  Future<void> updateScheduleItem(String id, Map<String, dynamic> data) async {
    await _apiClient.client.put('/schedule/$id', data: data);
  }

  Future<void> deleteScheduleItem(String id) async {
    await _apiClient.client.delete('/schedule/$id');
  }

  Future<void> clearSchedule(String groupCode, {int? dayOfWeek}) async {
    final data = <String, dynamic>{'groupCode': groupCode};
    if (dayOfWeek != null) data['dayOfWeek'] = dayOfWeek;
    await _apiClient.client.post('/schedule/clear', data: data);
  }

  Future<void> copySchedule(String fromGroup, String toGroup) async {
    await _apiClient.client.post('/schedule/copy', data: {
      'fromGroup': fromGroup,
      'toGroup': toGroup,
    });
  }

  // Util
  Map<String, dynamic> _fixId(dynamic json) {
    final map = Map<String, dynamic>.from(json);
    if (map.containsKey('_id') && !map.containsKey('id')) {
      map['id'] = map['_id'];
    }
    return map;
  }
}
