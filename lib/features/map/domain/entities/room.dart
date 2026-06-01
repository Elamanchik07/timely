import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    @Default('') String code, 
    required String fullCode, // C1.1.201
    @Default('') String shortCode, 
    @Default('C1.1') String sector,
    required String title,
    required int floor,
    required String building, // '1', '2'
    required double? lat,
    required double? lng,
    String? teacherId,
    String? description,
    @Default(true) bool isActive,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}
