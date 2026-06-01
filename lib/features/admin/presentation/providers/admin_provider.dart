import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_repository.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/teacher.dart';
import '../../../map/domain/entities/room.dart';
import '../../../schedule/domain/entities/schedule_item.dart';

// ─── Search & Filter Providers ──────────────────────
final adminSearchQueryProvider = StateProvider<String>((ref) => '');
final adminFilterStatusProvider = StateProvider<String?>((ref) => null);

// ─── Students Provider ──────────────────────────────
final adminStudentsProvider = StateNotifierProvider.family<AdminStudentsNotifier, AsyncValue<List<User>>, String?>((ref, status) {
  final repository = ref.watch(adminRepositoryProvider);
  final search = ref.watch(adminSearchQueryProvider);
  return AdminStudentsNotifier(repository, status, search);
});

class AdminStudentsNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final AdminRepository _repository;
  final String? status;
  final String search;

  AdminStudentsNotifier(this._repository, this.status, this.search) : super(const AsyncValue.loading()) {
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getStudents(status: status, search: search.isEmpty ? null : search);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> approve(String id) async {
    try {
      await _repository.updateStudent(id, {'status': 'APPROVED'});
      await fetchStudents();
    } catch (e) {
      // Rethrow for UI to handle
      rethrow;
    }
  }

  Future<void> reject(String id, {String? reason}) async {
    try {
      await _repository.updateStudent(id, {'status': 'REJECTED', 'rejectReason': reason});
      await fetchStudents();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleBlock(String id, bool currentStatus) async {
    try {
      await _repository.updateStudent(id, {'isBlocked': !currentStatus});
      await fetchStudents();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStudent(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateStudent(id, data);
      await fetchStudents();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.deleteStudent(id);
      await fetchStudents();
    } catch (e) {
      rethrow;
    }
  }
}

// ─── Schedule Provider ──────────────────────────────
final adminScheduleListProvider = StateNotifierProvider<AdminScheduleNotifier, AsyncValue<List<ScheduleItem>>>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminScheduleNotifier(repository);
});

class AdminScheduleNotifier extends StateNotifier<AsyncValue<List<ScheduleItem>>> {
  final AdminRepository _repository;
  String? _currentGroupCode;

  AdminScheduleNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<void> fetchByGroup(String groupCode) async {
    _currentGroupCode = groupCode;
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getScheduleByGroup(groupCode);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _repository.createScheduleItem(data);
    if (_currentGroupCode != null) await fetchByGroup(_currentGroupCode!);
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    await _repository.updateScheduleItem(id, data);
    if (_currentGroupCode != null) await fetchByGroup(_currentGroupCode!);
  }

  Future<void> delete(String id) async {
    await _repository.deleteScheduleItem(id);
    if (_currentGroupCode != null) await fetchByGroup(_currentGroupCode!);
  }

  Future<void> clearSchedule(String groupCode) async {
    await _repository.clearSchedule(groupCode);
    if (_currentGroupCode == groupCode) await fetchByGroup(groupCode);
  }

  Future<void> copySchedule(String fromGroup, String toGroup) async {
    await _repository.copySchedule(fromGroup, toGroup);
    if (_currentGroupCode == toGroup) await fetchByGroup(toGroup);
  }
}

// ─── Courses Provider ──────────────────────────────
final adminCoursesProvider = StateNotifierProvider<AdminCoursesNotifier, AsyncValue<List<Course>>>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminCoursesNotifier(repository);
});

class AdminCoursesNotifier extends StateNotifier<AsyncValue<List<Course>>> {
  final AdminRepository _repository;
  AdminCoursesNotifier(this._repository) : super(const AsyncValue.loading()) { fetchCourses(); }

  Future<void> fetchCourses() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getCourses();
      state = AsyncValue.data(items);
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _repository.createCourse(data);
    await fetchCourses();
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _repository.updateCourse(id, data);
    await fetchCourses();
  }

  Future<void> delete(String id) async {
    await _repository.deleteCourse(id);
    await fetchCourses();
  }
}

// ─── Groups Provider ──────────────────────────────
final adminGroupsProvider = StateNotifierProvider<AdminGroupsNotifier, AsyncValue<List<Group>>>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminGroupsNotifier(repository);
});

class AdminGroupsNotifier extends StateNotifier<AsyncValue<List<Group>>> {
  final AdminRepository _repository;
  AdminGroupsNotifier(this._repository) : super(const AsyncValue.loading()) { fetchGroups(); }

  Future<void> fetchGroups() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getGroups();
      state = AsyncValue.data(items);
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _repository.createGroup(data);
    await fetchGroups();
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _repository.updateGroup(id, data);
    await fetchGroups();
  }

  Future<void> delete(String id) async {
    await _repository.deleteGroup(id);
    await fetchGroups();
  }
}

// ─── Subjects Provider ──────────────────────────────
final adminSubjectsProvider = StateNotifierProvider<AdminSubjectsNotifier, AsyncValue<List<Subject>>>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminSubjectsNotifier(repository);
});

class AdminSubjectsNotifier extends StateNotifier<AsyncValue<List<Subject>>> {
  final AdminRepository _repository;
  AdminSubjectsNotifier(this._repository) : super(const AsyncValue.loading()) { fetchSubjects(); }

  Future<void> fetchSubjects() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getSubjects();
      state = AsyncValue.data(items);
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _repository.createSubject(data);
    await fetchSubjects();
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _repository.updateSubject(id, data);
    await fetchSubjects();
  }

  Future<void> delete(String id) async {
    await _repository.deleteSubject(id);
    await fetchSubjects();
  }
}

// ─── Teachers Provider ──────────────────────────────
final adminTeachersProvider = StateNotifierProvider<AdminTeachersNotifier, AsyncValue<List<Teacher>>>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminTeachersNotifier(repository);
});

class AdminTeachersNotifier extends StateNotifier<AsyncValue<List<Teacher>>> {
  final AdminRepository _repository;
  AdminTeachersNotifier(this._repository) : super(const AsyncValue.loading()) { fetchTeachers(); }

  Future<void> fetchTeachers() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getTeachers();
      state = AsyncValue.data(items);
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _repository.createTeacher(data);
    await fetchTeachers();
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _repository.updateTeacher(id, data);
    await fetchTeachers();
  }

  Future<void> delete(String id) async {
    await _repository.deleteTeacher(id);
    await fetchTeachers();
  }
}

// ─── Rooms Provider ──────────────────────────────
final adminRoomsProvider = StateNotifierProvider<AdminRoomsNotifier, AsyncValue<List<Room>>>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminRoomsNotifier(repository);
});

class AdminRoomsNotifier extends StateNotifier<AsyncValue<List<Room>>> {
  final AdminRepository _repository;
  AdminRoomsNotifier(this._repository) : super(const AsyncValue.loading()) { fetchRooms(); }

  Future<void> fetchRooms() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getRooms();
      state = AsyncValue.data(items);
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _repository.createRoom(data);
    await fetchRooms();
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _repository.updateRoom(id, data);
    await fetchRooms();
  }

  Future<void> delete(String id) async {
    await _repository.deleteRoom(id);
    await fetchRooms();
  }
}
