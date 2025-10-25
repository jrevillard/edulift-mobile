// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_conflicts_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleConflictsDto {
  List<ConflictDto> get conflicts;
  bool get hasConflicts;
  String get groupId;
  Map<String, dynamic>? get conflictDetails;

  /// Create a copy of ScheduleConflictsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleConflictsDtoCopyWith<ScheduleConflictsDto> get copyWith =>
      _$ScheduleConflictsDtoCopyWithImpl<ScheduleConflictsDto>(
          this as ScheduleConflictsDto, _$identity);

  /// Serializes this ScheduleConflictsDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleConflictsDto &&
            const DeepCollectionEquality().equals(other.conflicts, conflicts) &&
            (identical(other.hasConflicts, hasConflicts) ||
                other.hasConflicts == hasConflicts) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            const DeepCollectionEquality()
                .equals(other.conflictDetails, conflictDetails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(conflicts),
      hasConflicts,
      groupId,
      const DeepCollectionEquality().hash(conflictDetails));

  @override
  String toString() {
    return 'ScheduleConflictsDto(conflicts: $conflicts, hasConflicts: $hasConflicts, groupId: $groupId, conflictDetails: $conflictDetails)';
  }
}

/// @nodoc
abstract mixin class $ScheduleConflictsDtoCopyWith<$Res> {
  factory $ScheduleConflictsDtoCopyWith(ScheduleConflictsDto value,
          $Res Function(ScheduleConflictsDto) _then) =
      _$ScheduleConflictsDtoCopyWithImpl;
  @useResult
  $Res call(
      {List<ConflictDto> conflicts,
      bool hasConflicts,
      String groupId,
      Map<String, dynamic>? conflictDetails});
}

/// @nodoc
class _$ScheduleConflictsDtoCopyWithImpl<$Res>
    implements $ScheduleConflictsDtoCopyWith<$Res> {
  _$ScheduleConflictsDtoCopyWithImpl(this._self, this._then);

  final ScheduleConflictsDto _self;
  final $Res Function(ScheduleConflictsDto) _then;

  /// Create a copy of ScheduleConflictsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conflicts = null,
    Object? hasConflicts = null,
    Object? groupId = null,
    Object? conflictDetails = freezed,
  }) {
    return _then(_self.copyWith(
      conflicts: null == conflicts
          ? _self.conflicts
          : conflicts // ignore: cast_nullable_to_non_nullable
              as List<ConflictDto>,
      hasConflicts: null == hasConflicts
          ? _self.hasConflicts
          : hasConflicts // ignore: cast_nullable_to_non_nullable
              as bool,
      groupId: null == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      conflictDetails: freezed == conflictDetails
          ? _self.conflictDetails
          : conflictDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ScheduleConflictsDto].
extension ScheduleConflictsDtoPatterns on ScheduleConflictsDto {
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
    TResult Function(_ScheduleConflictsDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleConflictsDto() when $default != null:
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
    TResult Function(_ScheduleConflictsDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleConflictsDto():
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
    TResult? Function(_ScheduleConflictsDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleConflictsDto() when $default != null:
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
    TResult Function(List<ConflictDto> conflicts, bool hasConflicts,
            String groupId, Map<String, dynamic>? conflictDetails)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleConflictsDto() when $default != null:
        return $default(_that.conflicts, _that.hasConflicts, _that.groupId,
            _that.conflictDetails);
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
    TResult Function(List<ConflictDto> conflicts, bool hasConflicts,
            String groupId, Map<String, dynamic>? conflictDetails)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleConflictsDto():
        return $default(_that.conflicts, _that.hasConflicts, _that.groupId,
            _that.conflictDetails);
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
    TResult? Function(List<ConflictDto> conflicts, bool hasConflicts,
            String groupId, Map<String, dynamic>? conflictDetails)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleConflictsDto() when $default != null:
        return $default(_that.conflicts, _that.hasConflicts, _that.groupId,
            _that.conflictDetails);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ScheduleConflictsDto implements ScheduleConflictsDto {
  const _ScheduleConflictsDto(
      {required final List<ConflictDto> conflicts,
      required this.hasConflicts,
      required this.groupId,
      final Map<String, dynamic>? conflictDetails})
      : _conflicts = conflicts,
        _conflictDetails = conflictDetails;
  factory _ScheduleConflictsDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleConflictsDtoFromJson(json);

  final List<ConflictDto> _conflicts;
  @override
  List<ConflictDto> get conflicts {
    if (_conflicts is EqualUnmodifiableListView) return _conflicts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conflicts);
  }

  @override
  final bool hasConflicts;
  @override
  final String groupId;
  final Map<String, dynamic>? _conflictDetails;
  @override
  Map<String, dynamic>? get conflictDetails {
    final value = _conflictDetails;
    if (value == null) return null;
    if (_conflictDetails is EqualUnmodifiableMapView) return _conflictDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of ScheduleConflictsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleConflictsDtoCopyWith<_ScheduleConflictsDto> get copyWith =>
      __$ScheduleConflictsDtoCopyWithImpl<_ScheduleConflictsDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ScheduleConflictsDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduleConflictsDto &&
            const DeepCollectionEquality()
                .equals(other._conflicts, _conflicts) &&
            (identical(other.hasConflicts, hasConflicts) ||
                other.hasConflicts == hasConflicts) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            const DeepCollectionEquality()
                .equals(other._conflictDetails, _conflictDetails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_conflicts),
      hasConflicts,
      groupId,
      const DeepCollectionEquality().hash(_conflictDetails));

  @override
  String toString() {
    return 'ScheduleConflictsDto(conflicts: $conflicts, hasConflicts: $hasConflicts, groupId: $groupId, conflictDetails: $conflictDetails)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleConflictsDtoCopyWith<$Res>
    implements $ScheduleConflictsDtoCopyWith<$Res> {
  factory _$ScheduleConflictsDtoCopyWith(_ScheduleConflictsDto value,
          $Res Function(_ScheduleConflictsDto) _then) =
      __$ScheduleConflictsDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<ConflictDto> conflicts,
      bool hasConflicts,
      String groupId,
      Map<String, dynamic>? conflictDetails});
}

/// @nodoc
class __$ScheduleConflictsDtoCopyWithImpl<$Res>
    implements _$ScheduleConflictsDtoCopyWith<$Res> {
  __$ScheduleConflictsDtoCopyWithImpl(this._self, this._then);

  final _ScheduleConflictsDto _self;
  final $Res Function(_ScheduleConflictsDto) _then;

  /// Create a copy of ScheduleConflictsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? conflicts = null,
    Object? hasConflicts = null,
    Object? groupId = null,
    Object? conflictDetails = freezed,
  }) {
    return _then(_ScheduleConflictsDto(
      conflicts: null == conflicts
          ? _self._conflicts
          : conflicts // ignore: cast_nullable_to_non_nullable
              as List<ConflictDto>,
      hasConflicts: null == hasConflicts
          ? _self.hasConflicts
          : hasConflicts // ignore: cast_nullable_to_non_nullable
              as bool,
      groupId: null == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      conflictDetails: freezed == conflictDetails
          ? _self._conflictDetails
          : conflictDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

// dart format on
