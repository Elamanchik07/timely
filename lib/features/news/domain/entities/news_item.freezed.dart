// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NewsItem _$NewsItemFromJson(Map<String, dynamic> json) {
  return _NewsItem.fromJson(json);
}

/// @nodoc
mixin _$NewsItem {
  @JsonKey(readValue: _readId)
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get mediaType => throw _privateConstructorUsedError;
  String? get mediaPath => throw _privateConstructorUsedError;
  String? get thumbnailPath => throw _privateConstructorUsedError;
  bool get isPublished => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get publishedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readAuthorId)
  String get authorId => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readAuthor)
  Map<String, dynamic>? get author =>
      throw _privateConstructorUsedError; // ─── Metadata ───
  String get category => throw _privateConstructorUsedError;
  bool get isPinned =>
      throw _privateConstructorUsedError; // ─── Reaction System ───
  List<Map<String, dynamic>> get reactions =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> get reactionCounts =>
      throw _privateConstructorUsedError; // ─── View Tracking ───
  List<String> get viewers => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NewsItemCopyWith<NewsItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsItemCopyWith<$Res> {
  factory $NewsItemCopyWith(NewsItem value, $Res Function(NewsItem) then) =
      _$NewsItemCopyWithImpl<$Res, NewsItem>;
  @useResult
  $Res call(
      {@JsonKey(readValue: _readId) String id,
      String title,
      String content,
      String mediaType,
      String? mediaPath,
      String? thumbnailPath,
      bool isPublished,
      String status,
      DateTime? publishedAt,
      DateTime createdAt,
      DateTime updatedAt,
      @JsonKey(readValue: _readAuthorId) String authorId,
      @JsonKey(readValue: _readAuthor) Map<String, dynamic>? author,
      String category,
      bool isPinned,
      List<Map<String, dynamic>> reactions,
      Map<String, dynamic> reactionCounts,
      List<String> viewers,
      int viewCount});
}

/// @nodoc
class _$NewsItemCopyWithImpl<$Res, $Val extends NewsItem>
    implements $NewsItemCopyWith<$Res> {
  _$NewsItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? mediaType = null,
    Object? mediaPath = freezed,
    Object? thumbnailPath = freezed,
    Object? isPublished = null,
    Object? status = null,
    Object? publishedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? authorId = null,
    Object? author = freezed,
    Object? category = null,
    Object? isPinned = null,
    Object? reactions = null,
    Object? reactionCounts = null,
    Object? viewers = null,
    Object? viewCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
      mediaPath: freezed == mediaPath
          ? _value.mediaPath
          : mediaPath // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailPath: freezed == thumbnailPath
          ? _value.thumbnailPath
          : thumbnailPath // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      author: freezed == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      isPinned: null == isPinned
          ? _value.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
      reactions: null == reactions
          ? _value.reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      reactionCounts: null == reactionCounts
          ? _value.reactionCounts
          : reactionCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      viewers: null == viewers
          ? _value.viewers
          : viewers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NewsItemImplCopyWith<$Res>
    implements $NewsItemCopyWith<$Res> {
  factory _$$NewsItemImplCopyWith(
          _$NewsItemImpl value, $Res Function(_$NewsItemImpl) then) =
      __$$NewsItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(readValue: _readId) String id,
      String title,
      String content,
      String mediaType,
      String? mediaPath,
      String? thumbnailPath,
      bool isPublished,
      String status,
      DateTime? publishedAt,
      DateTime createdAt,
      DateTime updatedAt,
      @JsonKey(readValue: _readAuthorId) String authorId,
      @JsonKey(readValue: _readAuthor) Map<String, dynamic>? author,
      String category,
      bool isPinned,
      List<Map<String, dynamic>> reactions,
      Map<String, dynamic> reactionCounts,
      List<String> viewers,
      int viewCount});
}

/// @nodoc
class __$$NewsItemImplCopyWithImpl<$Res>
    extends _$NewsItemCopyWithImpl<$Res, _$NewsItemImpl>
    implements _$$NewsItemImplCopyWith<$Res> {
  __$$NewsItemImplCopyWithImpl(
      _$NewsItemImpl _value, $Res Function(_$NewsItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? mediaType = null,
    Object? mediaPath = freezed,
    Object? thumbnailPath = freezed,
    Object? isPublished = null,
    Object? status = null,
    Object? publishedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? authorId = null,
    Object? author = freezed,
    Object? category = null,
    Object? isPinned = null,
    Object? reactions = null,
    Object? reactionCounts = null,
    Object? viewers = null,
    Object? viewCount = null,
  }) {
    return _then(_$NewsItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
      mediaPath: freezed == mediaPath
          ? _value.mediaPath
          : mediaPath // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailPath: freezed == thumbnailPath
          ? _value.thumbnailPath
          : thumbnailPath // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      author: freezed == author
          ? _value._author
          : author // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      isPinned: null == isPinned
          ? _value.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
      reactions: null == reactions
          ? _value._reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      reactionCounts: null == reactionCounts
          ? _value._reactionCounts
          : reactionCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      viewers: null == viewers
          ? _value._viewers
          : viewers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NewsItemImpl implements _NewsItem {
  const _$NewsItemImpl(
      {@JsonKey(readValue: _readId) required this.id,
      required this.title,
      required this.content,
      this.mediaType = 'none',
      this.mediaPath,
      this.thumbnailPath,
      this.isPublished = false,
      this.status = 'published',
      this.publishedAt,
      required this.createdAt,
      required this.updatedAt,
      @JsonKey(readValue: _readAuthorId) required this.authorId,
      @JsonKey(readValue: _readAuthor) final Map<String, dynamic>? author,
      this.category = 'Announcements',
      this.isPinned = false,
      final List<Map<String, dynamic>> reactions = const [],
      final Map<String, dynamic> reactionCounts = const {},
      final List<String> viewers = const [],
      this.viewCount = 0})
      : _author = author,
        _reactions = reactions,
        _reactionCounts = reactionCounts,
        _viewers = viewers;

  factory _$NewsItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsItemImplFromJson(json);

  @override
  @JsonKey(readValue: _readId)
  final String id;
  @override
  final String title;
  @override
  final String content;
  @override
  @JsonKey()
  final String mediaType;
  @override
  final String? mediaPath;
  @override
  final String? thumbnailPath;
  @override
  @JsonKey()
  final bool isPublished;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? publishedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey(readValue: _readAuthorId)
  final String authorId;
  final Map<String, dynamic>? _author;
  @override
  @JsonKey(readValue: _readAuthor)
  Map<String, dynamic>? get author {
    final value = _author;
    if (value == null) return null;
    if (_author is EqualUnmodifiableMapView) return _author;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// ─── Metadata ───
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final bool isPinned;
// ─── Reaction System ───
  final List<Map<String, dynamic>> _reactions;
// ─── Reaction System ───
  @override
  @JsonKey()
  List<Map<String, dynamic>> get reactions {
    if (_reactions is EqualUnmodifiableListView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reactions);
  }

  final Map<String, dynamic> _reactionCounts;
  @override
  @JsonKey()
  Map<String, dynamic> get reactionCounts {
    if (_reactionCounts is EqualUnmodifiableMapView) return _reactionCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_reactionCounts);
  }

// ─── View Tracking ───
  final List<String> _viewers;
// ─── View Tracking ───
  @override
  @JsonKey()
  List<String> get viewers {
    if (_viewers is EqualUnmodifiableListView) return _viewers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_viewers);
  }

  @override
  @JsonKey()
  final int viewCount;

  @override
  String toString() {
    return 'NewsItem(id: $id, title: $title, content: $content, mediaType: $mediaType, mediaPath: $mediaPath, thumbnailPath: $thumbnailPath, isPublished: $isPublished, status: $status, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt, authorId: $authorId, author: $author, category: $category, isPinned: $isPinned, reactions: $reactions, reactionCounts: $reactionCounts, viewers: $viewers, viewCount: $viewCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.mediaPath, mediaPath) ||
                other.mediaPath == mediaPath) &&
            (identical(other.thumbnailPath, thumbnailPath) ||
                other.thumbnailPath == thumbnailPath) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            const DeepCollectionEquality().equals(other._author, _author) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            const DeepCollectionEquality()
                .equals(other._reactions, _reactions) &&
            const DeepCollectionEquality()
                .equals(other._reactionCounts, _reactionCounts) &&
            const DeepCollectionEquality().equals(other._viewers, _viewers) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        content,
        mediaType,
        mediaPath,
        thumbnailPath,
        isPublished,
        status,
        publishedAt,
        createdAt,
        updatedAt,
        authorId,
        const DeepCollectionEquality().hash(_author),
        category,
        isPinned,
        const DeepCollectionEquality().hash(_reactions),
        const DeepCollectionEquality().hash(_reactionCounts),
        const DeepCollectionEquality().hash(_viewers),
        viewCount
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsItemImplCopyWith<_$NewsItemImpl> get copyWith =>
      __$$NewsItemImplCopyWithImpl<_$NewsItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsItemImplToJson(
      this,
    );
  }
}

abstract class _NewsItem implements NewsItem {
  const factory _NewsItem(
      {@JsonKey(readValue: _readId) required final String id,
      required final String title,
      required final String content,
      final String mediaType,
      final String? mediaPath,
      final String? thumbnailPath,
      final bool isPublished,
      final String status,
      final DateTime? publishedAt,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      @JsonKey(readValue: _readAuthorId) required final String authorId,
      @JsonKey(readValue: _readAuthor) final Map<String, dynamic>? author,
      final String category,
      final bool isPinned,
      final List<Map<String, dynamic>> reactions,
      final Map<String, dynamic> reactionCounts,
      final List<String> viewers,
      final int viewCount}) = _$NewsItemImpl;

  factory _NewsItem.fromJson(Map<String, dynamic> json) =
      _$NewsItemImpl.fromJson;

  @override
  @JsonKey(readValue: _readId)
  String get id;
  @override
  String get title;
  @override
  String get content;
  @override
  String get mediaType;
  @override
  String? get mediaPath;
  @override
  String? get thumbnailPath;
  @override
  bool get isPublished;
  @override
  String get status;
  @override
  DateTime? get publishedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(readValue: _readAuthorId)
  String get authorId;
  @override
  @JsonKey(readValue: _readAuthor)
  Map<String, dynamic>? get author;
  @override // ─── Metadata ───
  String get category;
  @override
  bool get isPinned;
  @override // ─── Reaction System ───
  List<Map<String, dynamic>> get reactions;
  @override
  Map<String, dynamic> get reactionCounts;
  @override // ─── View Tracking ───
  List<String> get viewers;
  @override
  int get viewCount;
  @override
  @JsonKey(ignore: true)
  _$$NewsItemImplCopyWith<_$NewsItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
