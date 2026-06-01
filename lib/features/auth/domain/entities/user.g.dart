// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String? ?? 'STUDENT',
      status: json['status'] as String? ?? 'PENDING',
      course: (json['course'] as num?)?.toInt(),
      groupCode: json['groupCode'] as String?,
      phone: json['phone'] as String?,
      university: json['university'] as String?,
      faculty: json['faculty'] as String?,
      specialty: json['specialty'] as String?,
      isBlocked: json['isBlocked'] as bool? ?? false,
      rejectReason: json['rejectReason'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'role': instance.role,
      'status': instance.status,
      'course': instance.course,
      'groupCode': instance.groupCode,
      'phone': instance.phone,
      'university': instance.university,
      'faculty': instance.faculty,
      'specialty': instance.specialty,
      'isBlocked': instance.isBlocked,
      'rejectReason': instance.rejectReason,
    };
