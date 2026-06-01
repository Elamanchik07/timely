import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String fullName,
    required String email,
    required String role, // 'STUDENT' or 'ADMIN'
    required String status, // 'PENDING', 'APPROVED', 'REJECTED'
    String? groupCode,
    String? phone,
    String? avatar,
    String? faculty,
    int? course,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
