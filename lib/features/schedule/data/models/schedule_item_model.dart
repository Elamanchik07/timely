import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_item_model.freezed.dart';
part 'schedule_item_model.g.dart';

@freezed
class ScheduleItemModel with _$ScheduleItemModel {
  const factory ScheduleItemModel({
    required String id,
    @Default('') String subject,
    @Default('Lecture') String type,
    @Default('') String startTime,
    @Default('') String endTime,
    @Default('') String teacher,
    @Default('') String room,
    @Default(1) int dayOfWeek,
    @Default(1) int pairNumber,
  }) = _ScheduleItemModel;

  factory ScheduleItemModel.fromJson(Map<String, dynamic> json) => _$ScheduleItemModelFromJson(json);
}
