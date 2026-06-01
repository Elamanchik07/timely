import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String email,
    required String fullName,
    @Default('STUDENT') String role,
    @Default('PENDING') String status,
    int? course,
    String? groupCode,
    String? phone,
    String? university,
    String? faculty,
    String? specialty,
    @Default(false) bool isBlocked,
    String? rejectReason,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  bool get isAdmin => role == 'ADMIN';
  bool get isTeacher => role == 'TEACHER';
}
