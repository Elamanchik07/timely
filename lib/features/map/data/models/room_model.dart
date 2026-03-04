import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_model.freezed.dart';
part 'room_model.g.dart';

@freezed
class RoomModel with _$RoomModel {
  const factory RoomModel({
    required String id,
    @Default('') String code,
    @Default('') String fullCode,
    @Default('') String shortCode,
    @Default('C1.1') String sector,
    @Default('C1') String building,
    @Default('') String title,
    @Default('') String description,
    @Default('Classroom') String type,
    @Default(1) int floor,
    Coordinates? coordinates,
  }) = _RoomModel;

  factory RoomModel.fromJson(Map<String, dynamic> json) => _$RoomModelFromJson(json);
}

@freezed
class Coordinates with _$Coordinates {
  const factory Coordinates({
    @Default(0.0) double x,
    @Default(0.0) double y,
  }) = _Coordinates;

  factory Coordinates.fromJson(Map<String, dynamic> json) => _$CoordinatesFromJson(json);
}
