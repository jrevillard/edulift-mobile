// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'available_children_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AvailableChildrenDto {
  List<ChildDto> get availableChildren;
  String get groupId;
  String get week;
  String get day;
  String get time;

  /// Create a copy of AvailableChildrenDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AvailableChildrenDtoCopyWith<AvailableChildrenDto> get copyWith =>
      _$AvailableChildrenDtoCopyWithImpl<AvailableChildrenDto>(
          this as AvailableChildrenDto, _$identity);

  /// Serializes this AvailableChildrenDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AvailableChildrenDto &&
            const DeepCollectionEquality()
                .equals(other.availableChildren, availableChildren) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.week, week) || other.week == week) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(availableChildren),
      groupId,
      week,
      day,
      time);

  @override
  String toString() {
    return 'AvailableChildrenDto(availableChildren: $availableChildren, groupId: $groupId, week: $week, day: $day, time: $time)';
  }
}

/// @nodoc
abstract mixin class $AvailableChildrenDtoCopyWith<$Res> {
  factory $AvailableChildrenDtoCopyWith(AvailableChildrenDto value,
          $Res Function(AvailableChildrenDto) _then) =
      _$AvailableChildrenDtoCopyWithImpl;
  @useResult
  $Res call(
      {List<ChildDto> availableChildren,
      String groupId,
      String week,
      String day,
      String time});
}

/// @nodoc
class _$AvailableChildrenDtoCopyWithImpl<$Res>
    implements $AvailableChildrenDtoCopyWith<$Res> {
  _$AvailableChildrenDtoCopyWithImpl(this._self, this._then);

  final AvailableChildrenDto _self;
  final $Res Function(AvailableChildrenDto) _then;

  /// Create a copy of AvailableChildrenDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? availableChildren = null,
    Object? groupId = null,
    Object? week = null,
    Object? day = null,
    Object? time = null,
  }) {
    return _then(_self.copyWith(
      availableChildren: null == availableChildren
          ? _self.availableChildren
          : availableChildren // ignore: cast_nullable_to_non_nullable
              as List<ChildDto>,
      groupId: null == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      week: null == week
          ? _self.week
          : week // ignore: cast_nullable_to_non_nullable
              as String,
      day: null == day
          ? _self.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [AvailableChildrenDto].
extension AvailableChildrenDtoPatterns on AvailableChildrenDto {
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
    TResult Function(_AvailableChildrenDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AvailableChildrenDto() when $default != null:
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
    TResult Function(_AvailableChildrenDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AvailableChildrenDto():
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
    TResult? Function(_AvailableChildrenDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AvailableChildrenDto() when $default != null:
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
    TResult Function(List<ChildDto> availableChildren, String groupId,
            String week, String day, String time)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AvailableChildrenDto() when $default != null:
        return $default(_that.availableChildren, _that.groupId, _that.week,
            _that.day, _that.time);
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
    TResult Function(List<ChildDto> availableChildren, String groupId,
            String week, String day, String time)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AvailableChildrenDto():
        return $default(_that.availableChildren, _that.groupId, _that.week,
            _that.day, _that.time);
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
    TResult? Function(List<ChildDto> availableChildren, String groupId,
            String week, String day, String time)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AvailableChildrenDto() when $default != null:
        return $default(_that.availableChildren, _that.groupId, _that.week,
            _that.day, _that.time);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AvailableChildrenDto extends AvailableChildrenDto {
  const _AvailableChildrenDto(
      {required final List<ChildDto> availableChildren,
      required this.groupId,
      required this.week,
      required this.day,
      required this.time})
      : _availableChildren = availableChildren,
        super._();
  factory _AvailableChildrenDto.fromJson(Map<String, dynamic> json) =>
      _$AvailableChildrenDtoFromJson(json);

  final List<ChildDto> _availableChildren;
  @override
  List<ChildDto> get availableChildren {
    if (_availableChildren is EqualUnmodifiableListView)
      return _availableChildren;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableChildren);
  }

  @override
  final String groupId;
  @override
  final String week;
  @override
  final String day;
  @override
  final String time;

  /// Create a copy of AvailableChildrenDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AvailableChildrenDtoCopyWith<_AvailableChildrenDto> get copyWith =>
      __$AvailableChildrenDtoCopyWithImpl<_AvailableChildrenDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AvailableChildrenDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AvailableChildrenDto &&
            const DeepCollectionEquality()
                .equals(other._availableChildren, _availableChildren) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.week, week) || other.week == week) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_availableChildren),
      groupId,
      week,
      day,
      time);

  @override
  String toString() {
    return 'AvailableChildrenDto(availableChildren: $availableChildren, groupId: $groupId, week: $week, day: $day, time: $time)';
  }
}

/// @nodoc
abstract mixin class _$AvailableChildrenDtoCopyWith<$Res>
    implements $AvailableChildrenDtoCopyWith<$Res> {
  factory _$AvailableChildrenDtoCopyWith(_AvailableChildrenDto value,
          $Res Function(_AvailableChildrenDto) _then) =
      __$AvailableChildrenDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<ChildDto> availableChildren,
      String groupId,
      String week,
      String day,
      String time});
}

/// @nodoc
class __$AvailableChildrenDtoCopyWithImpl<$Res>
    implements _$AvailableChildrenDtoCopyWith<$Res> {
  __$AvailableChildrenDtoCopyWithImpl(this._self, this._then);

  final _AvailableChildrenDto _self;
  final $Res Function(_AvailableChildrenDto) _then;

  /// Create a copy of AvailableChildrenDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? availableChildren = null,
    Object? groupId = null,
    Object? week = null,
    Object? day = null,
    Object? time = null,
  }) {
    return _then(_AvailableChildrenDto(
      availableChildren: null == availableChildren
          ? _self._availableChildren
          : availableChildren // ignore: cast_nullable_to_non_nullable
              as List<ChildDto>,
      groupId: null == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      week: null == week
          ? _self.week
          : week // ignore: cast_nullable_to_non_nullable
              as String,
      day: null == day
          ? _self.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
