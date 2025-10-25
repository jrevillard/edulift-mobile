// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_slot_child_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleSlotChildDto {
// Core fields from ScheduleSlotChild Prisma schema
// Optional because simplified list responses may omit them
  String? get scheduleSlotId; // Missing in list responses
  String? get childId; // Missing in list responses (use child.id instead)
  String get vehicleAssignmentId; // Always present
  DateTime? get assignedAt; // Missing in list responses (use current time)
// Nested relations from API includes (when present)
  ChildDto? get child;

  /// Create a copy of ScheduleSlotChildDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleSlotChildDtoCopyWith<ScheduleSlotChildDto> get copyWith =>
      _$ScheduleSlotChildDtoCopyWithImpl<ScheduleSlotChildDto>(
          this as ScheduleSlotChildDto, _$identity);

  /// Serializes this ScheduleSlotChildDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleSlotChildDto &&
            (identical(other.scheduleSlotId, scheduleSlotId) ||
                other.scheduleSlotId == scheduleSlotId) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.vehicleAssignmentId, vehicleAssignmentId) ||
                other.vehicleAssignmentId == vehicleAssignmentId) &&
            (identical(other.assignedAt, assignedAt) ||
                other.assignedAt == assignedAt) &&
            (identical(other.child, child) || other.child == child));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, scheduleSlotId, childId,
      vehicleAssignmentId, assignedAt, child);

  @override
  String toString() {
    return 'ScheduleSlotChildDto(scheduleSlotId: $scheduleSlotId, childId: $childId, vehicleAssignmentId: $vehicleAssignmentId, assignedAt: $assignedAt, child: $child)';
  }
}

/// @nodoc
abstract mixin class $ScheduleSlotChildDtoCopyWith<$Res> {
  factory $ScheduleSlotChildDtoCopyWith(ScheduleSlotChildDto value,
          $Res Function(ScheduleSlotChildDto) _then) =
      _$ScheduleSlotChildDtoCopyWithImpl;
  @useResult
  $Res call(
      {String? scheduleSlotId,
      String? childId,
      String vehicleAssignmentId,
      DateTime? assignedAt,
      ChildDto? child});

  $ChildDtoCopyWith<$Res>? get child;
}

/// @nodoc
class _$ScheduleSlotChildDtoCopyWithImpl<$Res>
    implements $ScheduleSlotChildDtoCopyWith<$Res> {
  _$ScheduleSlotChildDtoCopyWithImpl(this._self, this._then);

  final ScheduleSlotChildDto _self;
  final $Res Function(ScheduleSlotChildDto) _then;

  /// Create a copy of ScheduleSlotChildDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduleSlotId = freezed,
    Object? childId = freezed,
    Object? vehicleAssignmentId = null,
    Object? assignedAt = freezed,
    Object? child = freezed,
  }) {
    return _then(_self.copyWith(
      scheduleSlotId: freezed == scheduleSlotId
          ? _self.scheduleSlotId
          : scheduleSlotId // ignore: cast_nullable_to_non_nullable
              as String?,
      childId: freezed == childId
          ? _self.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleAssignmentId: null == vehicleAssignmentId
          ? _self.vehicleAssignmentId
          : vehicleAssignmentId // ignore: cast_nullable_to_non_nullable
              as String,
      assignedAt: freezed == assignedAt
          ? _self.assignedAt
          : assignedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      child: freezed == child
          ? _self.child
          : child // ignore: cast_nullable_to_non_nullable
              as ChildDto?,
    ));
  }

  /// Create a copy of ScheduleSlotChildDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChildDtoCopyWith<$Res>? get child {
    if (_self.child == null) {
      return null;
    }

    return $ChildDtoCopyWith<$Res>(_self.child!, (value) {
      return _then(_self.copyWith(child: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ScheduleSlotChildDto].
extension ScheduleSlotChildDtoPatterns on ScheduleSlotChildDto {
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
    TResult Function(_ScheduleSlotChildDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleSlotChildDto() when $default != null:
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
    TResult Function(_ScheduleSlotChildDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleSlotChildDto():
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
    TResult? Function(_ScheduleSlotChildDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleSlotChildDto() when $default != null:
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
    TResult Function(String? scheduleSlotId, String? childId,
            String vehicleAssignmentId, DateTime? assignedAt, ChildDto? child)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleSlotChildDto() when $default != null:
        return $default(_that.scheduleSlotId, _that.childId,
            _that.vehicleAssignmentId, _that.assignedAt, _that.child);
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
    TResult Function(String? scheduleSlotId, String? childId,
            String vehicleAssignmentId, DateTime? assignedAt, ChildDto? child)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleSlotChildDto():
        return $default(_that.scheduleSlotId, _that.childId,
            _that.vehicleAssignmentId, _that.assignedAt, _that.child);
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
    TResult? Function(String? scheduleSlotId, String? childId,
            String vehicleAssignmentId, DateTime? assignedAt, ChildDto? child)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleSlotChildDto() when $default != null:
        return $default(_that.scheduleSlotId, _that.childId,
            _that.vehicleAssignmentId, _that.assignedAt, _that.child);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ScheduleSlotChildDto extends ScheduleSlotChildDto {
  const _ScheduleSlotChildDto(
      {this.scheduleSlotId,
      this.childId,
      required this.vehicleAssignmentId,
      this.assignedAt,
      this.child})
      : super._();
  factory _ScheduleSlotChildDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleSlotChildDtoFromJson(json);

// Core fields from ScheduleSlotChild Prisma schema
// Optional because simplified list responses may omit them
  @override
  final String? scheduleSlotId;
// Missing in list responses
  @override
  final String? childId;
// Missing in list responses (use child.id instead)
  @override
  final String vehicleAssignmentId;
// Always present
  @override
  final DateTime? assignedAt;
// Missing in list responses (use current time)
// Nested relations from API includes (when present)
  @override
  final ChildDto? child;

  /// Create a copy of ScheduleSlotChildDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleSlotChildDtoCopyWith<_ScheduleSlotChildDto> get copyWith =>
      __$ScheduleSlotChildDtoCopyWithImpl<_ScheduleSlotChildDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ScheduleSlotChildDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduleSlotChildDto &&
            (identical(other.scheduleSlotId, scheduleSlotId) ||
                other.scheduleSlotId == scheduleSlotId) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.vehicleAssignmentId, vehicleAssignmentId) ||
                other.vehicleAssignmentId == vehicleAssignmentId) &&
            (identical(other.assignedAt, assignedAt) ||
                other.assignedAt == assignedAt) &&
            (identical(other.child, child) || other.child == child));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, scheduleSlotId, childId,
      vehicleAssignmentId, assignedAt, child);

  @override
  String toString() {
    return 'ScheduleSlotChildDto(scheduleSlotId: $scheduleSlotId, childId: $childId, vehicleAssignmentId: $vehicleAssignmentId, assignedAt: $assignedAt, child: $child)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleSlotChildDtoCopyWith<$Res>
    implements $ScheduleSlotChildDtoCopyWith<$Res> {
  factory _$ScheduleSlotChildDtoCopyWith(_ScheduleSlotChildDto value,
          $Res Function(_ScheduleSlotChildDto) _then) =
      __$ScheduleSlotChildDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? scheduleSlotId,
      String? childId,
      String vehicleAssignmentId,
      DateTime? assignedAt,
      ChildDto? child});

  @override
  $ChildDtoCopyWith<$Res>? get child;
}

/// @nodoc
class __$ScheduleSlotChildDtoCopyWithImpl<$Res>
    implements _$ScheduleSlotChildDtoCopyWith<$Res> {
  __$ScheduleSlotChildDtoCopyWithImpl(this._self, this._then);

  final _ScheduleSlotChildDto _self;
  final $Res Function(_ScheduleSlotChildDto) _then;

  /// Create a copy of ScheduleSlotChildDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? scheduleSlotId = freezed,
    Object? childId = freezed,
    Object? vehicleAssignmentId = null,
    Object? assignedAt = freezed,
    Object? child = freezed,
  }) {
    return _then(_ScheduleSlotChildDto(
      scheduleSlotId: freezed == scheduleSlotId
          ? _self.scheduleSlotId
          : scheduleSlotId // ignore: cast_nullable_to_non_nullable
              as String?,
      childId: freezed == childId
          ? _self.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleAssignmentId: null == vehicleAssignmentId
          ? _self.vehicleAssignmentId
          : vehicleAssignmentId // ignore: cast_nullable_to_non_nullable
              as String,
      assignedAt: freezed == assignedAt
          ? _self.assignedAt
          : assignedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      child: freezed == child
          ? _self.child
          : child // ignore: cast_nullable_to_non_nullable
              as ChildDto?,
    ));
  }

  /// Create a copy of ScheduleSlotChildDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChildDtoCopyWith<$Res>? get child {
    if (_self.child == null) {
      return null;
    }

    return $ChildDtoCopyWith<$Res>(_self.child!, (value) {
      return _then(_self.copyWith(child: value));
    });
  }
}

// dart format on
