// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomModelImpl _$$RoomModelImplFromJson(Map<String, dynamic> json) =>
    _$RoomModelImpl(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      fullCode: json['fullCode'] as String? ?? '',
      shortCode: json['shortCode'] as String? ?? '',
      sector: json['sector'] as String? ?? 'C1.1',
      building: json['building'] as String? ?? 'C1',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'Classroom',
      floor: (json['floor'] as num?)?.toInt() ?? 1,
      coordinates: json['coordinates'] == null
          ? null
          : Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$RoomModelImplToJson(_$RoomModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'fullCode': instance.fullCode,
      'shortCode': instance.shortCode,
      'sector': instance.sector,
      'building': instance.building,
      'title': instance.title,
      'description': instance.description,
      'type': instance.type,
      'floor': instance.floor,
      'coordinates': instance.coordinates,
    };

_$CoordinatesImpl _$$CoordinatesImplFromJson(Map<String, dynamic> json) =>
    _$CoordinatesImpl(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$CoordinatesImplToJson(_$CoordinatesImpl instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
    };
