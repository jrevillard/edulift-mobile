// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActivityItemDto {
  String get id;
  String
      get type; // 'schedule_created', 'child_added', 'vehicle_assigned', etc.
  String get description;
  String get timestamp;
  String? get userId;
  String? get userName;
  Map<String, dynamic>? get metadata;

  /// Create a copy of ActivityItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ActivityItemDtoCopyWith<ActivityItemDto> get copyWith =>
      _$ActivityItemDtoCopyWithImpl<ActivityItemDto>(
          this as ActivityItemDto, _$identity);

  /// Serializes this ActivityItemDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ActivityItemDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            const DeepCollectionEquality().equals(other.metadata, metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, description, timestamp,
      userId, userName, const DeepCollectionEquality().hash(metadata));

  @override
  String toString() {
    return 'ActivityItemDto(id: $id, type: $type, description: $description, timestamp: $timestamp, userId: $userId, userName: $userName, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $ActivityItemDtoCopyWith<$Res> {
  factory $ActivityItemDtoCopyWith(
          ActivityItemDto value, $Res Function(ActivityItemDto) _then) =
      _$ActivityItemDtoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String type,
      String description,
      String timestamp,
      String? userId,
      String? userName,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$ActivityItemDtoCopyWithImpl<$Res>
    implements $ActivityItemDtoCopyWith<$Res> {
  _$ActivityItemDtoCopyWithImpl(this._self, this._then);

  final ActivityItemDto _self;
  final $Res Function(ActivityItemDto) _then;

  /// Create a copy of ActivityItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? description = null,
    Object? timestamp = null,
    Object? userId = freezed,
    Object? userName = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ActivityItemDto].
extension ActivityItemDtoPatterns on ActivityItemDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ActivityItemDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActivityItemDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ActivityItemDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivityItemDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ActivityItemDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivityItemDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String type,
            String description,
            String timestamp,
            String? userId,
            String? userName,
            Map<String, dynamic>? metadata)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActivityItemDto() when $default != null:
        return $default(_that.id, _that.type, _that.description,
            _that.timestamp, _that.userId, _that.userName, _that.metadata);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String type,
            String description,
            String timestamp,
            String? userId,
            String? userName,
            Map<String, dynamic>? metadata)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivityItemDto():
        return $default(_that.id, _that.type, _that.description,
            _that.timestamp, _that.userId, _that.userName, _that.metadata);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String type,
            String description,
            String timestamp,
            String? userId,
            String? userName,
            Map<String, dynamic>? metadata)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivityItemDto() when $default != null:
        return $default(_that.id, _that.type, _that.description,
            _that.timestamp, _that.userId, _that.userName, _that.metadata);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ActivityItemDto implements ActivityItemDto {
  const _ActivityItemDto(
      {required this.id,
      required this.type,
      required this.description,
      required this.timestamp,
      required this.userId,
      required this.userName,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;
  factory _ActivityItemDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemDtoFromJson(json);

  @override
  final String id;
  @override
  final String type;
// 'schedule_created', 'child_added', 'vehicle_assigned', etc.
  @override
  final String description;
  @override
  final String timestamp;
  @override
  final String? userId;
  @override
  final String? userName;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of ActivityItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ActivityItemDtoCopyWith<_ActivityItemDto> get copyWith =>
      __$ActivityItemDtoCopyWithImpl<_ActivityItemDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ActivityItemDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ActivityItemDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, description, timestamp,
      userId, userName, const DeepCollectionEquality().hash(_metadata));

  @override
  String toString() {
    return 'ActivityItemDto(id: $id, type: $type, description: $description, timestamp: $timestamp, userId: $userId, userName: $userName, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$ActivityItemDtoCopyWith<$Res>
    implements $ActivityItemDtoCopyWith<$Res> {
  factory _$ActivityItemDtoCopyWith(
          _ActivityItemDto value, $Res Function(_ActivityItemDto) _then) =
      __$ActivityItemDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String description,
      String timestamp,
      String? userId,
      String? userName,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$ActivityItemDtoCopyWithImpl<$Res>
    implements _$ActivityItemDtoCopyWith<$Res> {
  __$ActivityItemDtoCopyWithImpl(this._self, this._then);

  final _ActivityItemDto _self;
  final $Res Function(_ActivityItemDto) _then;

  /// Create a copy of ActivityItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? description = null,
    Object? timestamp = null,
    Object? userId = freezed,
    Object? userName = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_ActivityItemDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

// dart format on
