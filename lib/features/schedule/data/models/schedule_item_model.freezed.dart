// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScheduleItemModel _$ScheduleItemModelFromJson(Map<String, dynamic> json) {
  return _ScheduleItemModel.fromJson(json);
}

/// @nodoc
mixin _$ScheduleItemModel {
  String get id => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;
  String get teacher => throw _privateConstructorUsedError;
  String get room => throw _privateConstructorUsedError;
  int get dayOfWeek => throw _privateConstructorUsedError;
  int get pairNumber => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScheduleItemModelCopyWith<ScheduleItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleItemModelCopyWith<$Res> {
  factory $ScheduleItemModelCopyWith(
          ScheduleItemModel value, $Res Function(ScheduleItemModel) then) =
      _$ScheduleItemModelCopyWithImpl<$Res, ScheduleItemModel>;
  @useResult
  $Res call(
      {String id,
      String subject,
      String type,
      String startTime,
      String endTime,
      String teacher,
      String room,
      int dayOfWeek,
      int pairNumber});
}

/// @nodoc
class _$ScheduleItemModelCopyWithImpl<$Res, $Val extends ScheduleItemModel>
    implements $ScheduleItemModelCopyWith<$Res> {
  _$ScheduleItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? type = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? teacher = null,
    Object? room = null,
    Object? dayOfWeek = null,
    Object? pairNumber = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      teacher: null == teacher
          ? _value.teacher
          : teacher // ignore: cast_nullable_to_non_nullable
              as String,
      room: null == room
          ? _value.room
          : room // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      pairNumber: null == pairNumber
          ? _value.pairNumber
          : pairNumber // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleItemModelImplCopyWith<$Res>
    implements $ScheduleItemModelCopyWith<$Res> {
  factory _$$ScheduleItemModelImplCopyWith(_$ScheduleItemModelImpl value,
          $Res Function(_$ScheduleItemModelImpl) then) =
      __$$ScheduleItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String subject,
      String type,
      String startTime,
      String endTime,
      String teacher,
      String room,
      int dayOfWeek,
      int pairNumber});
}

/// @nodoc
class __$$ScheduleItemModelImplCopyWithImpl<$Res>
    extends _$ScheduleItemModelCopyWithImpl<$Res, _$ScheduleItemModelImpl>
    implements _$$ScheduleItemModelImplCopyWith<$Res> {
  __$$ScheduleItemModelImplCopyWithImpl(_$ScheduleItemModelImpl _value,
      $Res Function(_$ScheduleItemModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? type = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? teacher = null,
    Object? room = null,
    Object? dayOfWeek = null,
    Object? pairNumber = null,
  }) {
    return _then(_$ScheduleItemModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      teacher: null == teacher
          ? _value.teacher
          : teacher // ignore: cast_nullable_to_non_nullable
              as String,
      room: null == room
          ? _value.room
          : room // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      pairNumber: null == pairNumber
          ? _value.pairNumber
          : pairNumber // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleItemModelImpl implements _ScheduleItemModel {
  const _$ScheduleItemModelImpl(
      {required this.id,
      this.subject = '',
      this.type = 'Lecture',
      this.startTime = '',
      this.endTime = '',
      this.teacher = '',
      this.room = '',
      this.dayOfWeek = 1,
      this.pairNumber = 1});

  factory _$ScheduleItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleItemModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String subject;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final String startTime;
  @override
  @JsonKey()
  final String endTime;
  @override
  @JsonKey()
  final String teacher;
  @override
  @JsonKey()
  final String room;
  @override
  @JsonKey()
  final int dayOfWeek;
  @override
  @JsonKey()
  final int pairNumber;

  @override
  String toString() {
    return 'ScheduleItemModel(id: $id, subject: $subject, type: $type, startTime: $startTime, endTime: $endTime, teacher: $teacher, room: $room, dayOfWeek: $dayOfWeek, pairNumber: $pairNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.teacher, teacher) || other.teacher == teacher) &&
            (identical(other.room, room) || other.room == room) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.pairNumber, pairNumber) ||
                other.pairNumber == pairNumber));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, subject, type, startTime,
      endTime, teacher, room, dayOfWeek, pairNumber);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleItemModelImplCopyWith<_$ScheduleItemModelImpl> get copyWith =>
      __$$ScheduleItemModelImplCopyWithImpl<_$ScheduleItemModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleItemModelImplToJson(
      this,
    );
  }
}

abstract class _ScheduleItemModel implements ScheduleItemModel {
  const factory _ScheduleItemModel(
      {required final String id,
      final String subject,
      final String type,
      final String startTime,
      final String endTime,
      final String teacher,
      final String room,
      final int dayOfWeek,
      final int pairNumber}) = _$ScheduleItemModelImpl;

  factory _ScheduleItemModel.fromJson(Map<String, dynamic> json) =
      _$ScheduleItemModelImpl.fromJson;

  @override
  String get id;
  @override
  String get subject;
  @override
  String get type;
  @override
  String get startTime;
  @override
  String get endTime;
  @override
  String get teacher;
  @override
  String get room;
  @override
  int get dayOfWeek;
  @override
  int get pairNumber;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleItemModelImplCopyWith<_$ScheduleItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
