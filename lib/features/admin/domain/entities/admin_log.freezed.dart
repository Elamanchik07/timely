// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AdminLog _$AdminLogFromJson(Map<String, dynamic> json) {
  return _AdminLog.fromJson(json);
}

/// @nodoc
mixin _$AdminLog {
  String? get id => throw _privateConstructorUsedError;
  String get adminId => throw _privateConstructorUsedError;
  String get adminEmail => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  String? get targetId => throw _privateConstructorUsedError;
  String? get targetModel => throw _privateConstructorUsedError;
  String? get details => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AdminLogCopyWith<AdminLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminLogCopyWith<$Res> {
  factory $AdminLogCopyWith(AdminLog value, $Res Function(AdminLog) then) =
      _$AdminLogCopyWithImpl<$Res, AdminLog>;
  @useResult
  $Res call(
      {String? id,
      String adminId,
      String adminEmail,
      String action,
      String? targetId,
      String? targetModel,
      String? details,
      DateTime? createdAt});
}

/// @nodoc
class _$AdminLogCopyWithImpl<$Res, $Val extends AdminLog>
    implements $AdminLogCopyWith<$Res> {
  _$AdminLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? adminId = null,
    Object? adminEmail = null,
    Object? action = null,
    Object? targetId = freezed,
    Object? targetModel = freezed,
    Object? details = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      adminId: null == adminId
          ? _value.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
              as String,
      adminEmail: null == adminEmail
          ? _value.adminEmail
          : adminEmail // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      targetId: freezed == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetModel: freezed == targetModel
          ? _value.targetModel
          : targetModel // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdminLogImplCopyWith<$Res>
    implements $AdminLogCopyWith<$Res> {
  factory _$$AdminLogImplCopyWith(
          _$AdminLogImpl value, $Res Function(_$AdminLogImpl) then) =
      __$$AdminLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String adminId,
      String adminEmail,
      String action,
      String? targetId,
      String? targetModel,
      String? details,
      DateTime? createdAt});
}

/// @nodoc
class __$$AdminLogImplCopyWithImpl<$Res>
    extends _$AdminLogCopyWithImpl<$Res, _$AdminLogImpl>
    implements _$$AdminLogImplCopyWith<$Res> {
  __$$AdminLogImplCopyWithImpl(
      _$AdminLogImpl _value, $Res Function(_$AdminLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? adminId = null,
    Object? adminEmail = null,
    Object? action = null,
    Object? targetId = freezed,
    Object? targetModel = freezed,
    Object? details = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$AdminLogImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      adminId: null == adminId
          ? _value.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
              as String,
      adminEmail: null == adminEmail
          ? _value.adminEmail
          : adminEmail // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      targetId: freezed == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetModel: freezed == targetModel
          ? _value.targetModel
          : targetModel // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminLogImpl implements _AdminLog {
  const _$AdminLogImpl(
      {this.id,
      required this.adminId,
      required this.adminEmail,
      required this.action,
      this.targetId,
      this.targetModel,
      this.details,
      this.createdAt});

  factory _$AdminLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminLogImplFromJson(json);

  @override
  final String? id;
  @override
  final String adminId;
  @override
  final String adminEmail;
  @override
  final String action;
  @override
  final String? targetId;
  @override
  final String? targetModel;
  @override
  final String? details;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AdminLog(id: $id, adminId: $adminId, adminEmail: $adminEmail, action: $action, targetId: $targetId, targetModel: $targetModel, details: $details, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.adminId, adminId) || other.adminId == adminId) &&
            (identical(other.adminEmail, adminEmail) ||
                other.adminEmail == adminEmail) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.targetModel, targetModel) ||
                other.targetModel == targetModel) &&
            (identical(other.details, details) || other.details == details) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, adminId, adminEmail, action,
      targetId, targetModel, details, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminLogImplCopyWith<_$AdminLogImpl> get copyWith =>
      __$$AdminLogImplCopyWithImpl<_$AdminLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminLogImplToJson(
      this,
    );
  }
}

abstract class _AdminLog implements AdminLog {
  const factory _AdminLog(
      {final String? id,
      required final String adminId,
      required final String adminEmail,
      required final String action,
      final String? targetId,
      final String? targetModel,
      final String? details,
      final DateTime? createdAt}) = _$AdminLogImpl;

  factory _AdminLog.fromJson(Map<String, dynamic> json) =
      _$AdminLogImpl.fromJson;

  @override
  String? get id;
  @override
  String get adminId;
  @override
  String get adminEmail;
  @override
  String get action;
  @override
  String? get targetId;
  @override
  String? get targetModel;
  @override
  String? get details;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$AdminLogImplCopyWith<_$AdminLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
