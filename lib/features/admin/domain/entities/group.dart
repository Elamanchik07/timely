import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

@freezed
class Group with _$Group {
  const factory Group({
    String? id,
    required String groupCode,
    String? title,
    String? description,
    int? course,
    String? courseId,
    required int shift,
    @Default(true) bool isActive,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}
