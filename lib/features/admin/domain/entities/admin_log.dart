import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_log.freezed.dart';
part 'admin_log.g.dart';

@freezed
class AdminLog with _$AdminLog {
  const factory AdminLog({
    String? id,
    required String adminId,
    required String adminEmail,
    required String action,
    String? targetId,
    String? targetModel,
    String? details,
    DateTime? createdAt,
  }) = _AdminLog;

  factory AdminLog.fromJson(Map<String, dynamic> json) => _$AdminLogFromJson(json);
}
