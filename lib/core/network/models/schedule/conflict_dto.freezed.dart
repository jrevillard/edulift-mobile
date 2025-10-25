// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conflict_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConflictDto {
  String get id;
  String get type;
  String get description;
  String get conflictingResourceId;
  DateTime get conflictTime;
  String? get resolution;

  /// Create a copy of ConflictDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ConflictDtoCopyWith<ConflictDto> get copyWith =>
      _$ConflictDtoCopyWithImpl<ConflictDto>(this as ConflictDto, _$identity);

  /// Serializes this ConflictDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ConflictDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.conflictingResourceId, conflictingResourceId) ||
                other.conflictingResourceId == conflictingResourceId) &&
            (identical(other.conflictTime, conflictTime) ||
                other.conflictTime == conflictTime) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, description,
      conflictingResourceId, conflictTime, resolution);

  @override
  String toString() {
    return 'ConflictDto(id: $id, type: $type, description: $description, conflictingResourceId: $conflictingResourceId, conflictTime: $conflictTime, resolution: $resolution)';
  }
}

/// @nodoc
abstract mixin class $ConflictDtoCopyWith<$Res> {
  factory $ConflictDtoCopyWith(
          ConflictDto value, $Res Function(ConflictDto) _then) =
      _$ConflictDtoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String type,
      String description,
      String conflictingResourceId,
      DateTime conflictTime,
      String? resolution});
}

/// @nodoc
class _$ConflictDtoCopyWithImpl<$Res> implements $ConflictDtoCopyWith<$Res> {
  _$ConflictDtoCopyWithImpl(this._self, this._then);

  final ConflictDto _self;
  final $Res Function(ConflictDto) _then;

  /// Create a copy of ConflictDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? description = null,
    Object? conflictingResourceId = null,
    Object? conflictTime = null,
    Object? resolution = freezed,
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
      conflictingResourceId: null == conflictingResourceId
          ? _self.conflictingResourceId
          : conflictingResourceId // ignore: cast_nullable_to_non_nullable
              as String,
      conflictTime: null == conflictTime
          ? _self.conflictTime
          : conflictTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resolution: freezed == resolution
          ? _self.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ConflictDto].
extension ConflictDtoPatterns on ConflictDto {
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
    TResult Function(_ConflictDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConflictDto() when $default != null:
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
    TResult Function(_ConflictDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConflictDto():
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
    TResult? Function(_ConflictDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConflictDto() when $default != null:
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
            String conflictingResourceId,
            DateTime conflictTime,
            String? resolution)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConflictDto() when $default != null:
        return $default(_that.id, _that.type, _that.description,
            _that.conflictingResourceId, _that.conflictTime, _that.resolution);
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
            String conflictingResourceId,
            DateTime conflictTime,
            String? resolution)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConflictDto():
        return $default(_that.id, _that.type, _that.description,
            _that.conflictingResourceId, _that.conflictTime, _that.resolution);
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
            String conflictingResourceId,
            DateTime conflictTime,
            String? resolution)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConflictDto() when $default != null:
        return $default(_that.id, _that.type, _that.description,
            _that.conflictingResourceId, _that.conflictTime, _that.resolution);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ConflictDto extends ConflictDto {
  const _ConflictDto(
      {required this.id,
      required this.type,
      required this.description,
      required this.conflictingResourceId,
      required this.conflictTime,
      this.resolution})
      : super._();
  factory _ConflictDto.fromJson(Map<String, dynamic> json) =>
      _$ConflictDtoFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String description;
  @override
  final String conflictingResourceId;
  @override
  final DateTime conflictTime;
  @override
  final String? resolution;

  /// Create a copy of ConflictDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ConflictDtoCopyWith<_ConflictDto> get copyWith =>
      __$ConflictDtoCopyWithImpl<_ConflictDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ConflictDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ConflictDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.conflictingResourceId, conflictingResourceId) ||
                other.conflictingResourceId == conflictingResourceId) &&
            (identical(other.conflictTime, conflictTime) ||
                other.conflictTime == conflictTime) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, description,
      conflictingResourceId, conflictTime, resolution);

  @override
  String toString() {
    return 'ConflictDto(id: $id, type: $type, description: $description, conflictingResourceId: $conflictingResourceId, conflictTime: $conflictTime, resolution: $resolution)';
  }
}

/// @nodoc
abstract mixin class _$ConflictDtoCopyWith<$Res>
    implements $ConflictDtoCopyWith<$Res> {
  factory _$ConflictDtoCopyWith(
          _ConflictDto value, $Res Function(_ConflictDto) _then) =
      __$ConflictDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String description,
      String conflictingResourceId,
      DateTime conflictTime,
      String? resolution});
}

/// @nodoc
class __$ConflictDtoCopyWithImpl<$Res> implements _$ConflictDtoCopyWith<$Res> {
  __$ConflictDtoCopyWithImpl(this._self, this._then);

  final _ConflictDto _self;
  final $Res Function(_ConflictDto) _then;

  /// Create a copy of ConflictDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? description = null,
    Object? conflictingResourceId = null,
    Object? conflictTime = null,
    Object? resolution = freezed,
  }) {
    return _then(_ConflictDto(
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
      conflictingResourceId: null == conflictingResourceId
          ? _self.conflictingResourceId
          : conflictingResourceId // ignore: cast_nullable_to_non_nullable
              as String,
      conflictTime: null == conflictTime
          ? _self.conflictTime
          : conflictTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resolution: freezed == resolution
          ? _self.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
