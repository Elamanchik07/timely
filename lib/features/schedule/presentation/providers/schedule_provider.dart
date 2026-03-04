import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/schedule_repository.dart';
import '../../domain/entities/schedule_item.dart';
import '../../../../core/providers/notification_settings_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../notification_service.dart';

final scheduleProvider = StateNotifierProvider.family<ScheduleNotifier, AsyncValue<List<ScheduleItem>>, String>((ref, groupCode) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return ScheduleNotifier(repository, groupCode, ref);
});

class ScheduleNotifier extends StateNotifier<AsyncValue<List<ScheduleItem>>> {
  final ScheduleRepository _repository;
  final String groupCode;
  final Ref _ref;

  ScheduleNotifier(this._repository, this.groupCode, this._ref) : super(const AsyncValue.loading()) {
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getSchedule(groupCode);
      state = AsyncValue.data(items);

      // Automatically schedule notifications for the fetched items
      _scheduleNotifications(items);

    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    try {
      final items = await _repository.getSchedule(groupCode);
      state = AsyncValue.data(items);
      _scheduleNotifications(items);
    } catch (e) {
      throw e;
    }
  }

  void _scheduleNotifications(List<ScheduleItem> items) async {
    final settings = _ref.read(notificationSettingsProvider);
    if (!settings.isEnabled) return;

    final List<LessonSchedule> lessons = [];
    final now = DateTime.now();
    // Start of current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (final item in items) {
      try {
        // item.dayOfWeek is 1-7
        final lessonDate = startOfWeek.add(Duration(days: item.dayOfWeek - 1));
        
        // Parse time "HH:mm" -> "09:00"
        final startTimeParts = item.startTime.split(':');
        final endTimeParts = item.endTime.split(':');
        
        if (startTimeParts.length == 2 && endTimeParts.length == 2) {
          DateTime startTime = DateTime(
            lessonDate.year, lessonDate.month, lessonDate.day, 
            int.parse(startTimeParts[0]), int.parse(startTimeParts[1])
          );
          DateTime endTime = DateTime(
            lessonDate.year, lessonDate.month, lessonDate.day, 
            int.parse(endTimeParts[0]), int.parse(endTimeParts[1])
          );

          // If the lesson for this week has already passed, schedule it for next week
          if (startTime.isBefore(now)) {
             startTime = startTime.add(const Duration(days: 7));
             endTime = endTime.add(const Duration(days: 7));
          }

          lessons.add(LessonSchedule(
            id: item.id,
            name: item.subject,
            roomNumber: item.room,
            floor: 1, // Optional: attempt to parse floor from room code if needed, but not strictly necessary for notification
            startTime: startTime,
            endTime: endTime,
          ));
        }
      } catch (e) {
        // Skip invalid formats
      }
    }

    try {
      final l10n = _ref.read(l10nProvider);
      await NotificationService().scheduleLessonNotifications(lessons, settings, l10n);
    } catch(e) {
      // Ignore notification scheduling errors safely
    }
  }
}
