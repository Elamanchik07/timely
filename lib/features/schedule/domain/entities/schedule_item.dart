import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_item.freezed.dart';
part 'schedule_item.g.dart';

@freezed
class ScheduleItem with _$ScheduleItem {
  const factory ScheduleItem({
    required String id,
    required String groupCode,
    required int dayOfWeek,
    required int pairNumber,
    required String startTime,
    required String endTime,
    required String subject,
    String? subjectId,
    required String teacher,
    String? teacherId,
    required String room,
    String? roomId,
    @Default('lecture') String type,
    @Default('ALL') String weekType,
  }) = _ScheduleItem;

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => _$ScheduleItemFromJson(json);
}
