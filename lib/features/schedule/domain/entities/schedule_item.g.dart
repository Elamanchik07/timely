// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleItemImpl _$$ScheduleItemImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleItemImpl(
      id: json['id'] as String,
      groupCode: json['groupCode'] as String,
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      pairNumber: (json['pairNumber'] as num).toInt(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      subject: json['subject'] as String,
      subjectId: json['subjectId'] as String?,
      teacher: json['teacher'] as String,
      teacherId: json['teacherId'] as String?,
      room: json['room'] as String,
      roomId: json['roomId'] as String?,
      type: json['type'] as String? ?? 'lecture',
      weekType: json['weekType'] as String? ?? 'ALL',
    );

Map<String, dynamic> _$$ScheduleItemImplToJson(_$ScheduleItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupCode': instance.groupCode,
      'dayOfWeek': instance.dayOfWeek,
      'pairNumber': instance.pairNumber,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'subject': instance.subject,
      'subjectId': instance.subjectId,
      'teacher': instance.teacher,
      'teacherId': instance.teacherId,
      'room': instance.room,
      'roomId': instance.roomId,
      'type': instance.type,
      'weekType': instance.weekType,
    };
