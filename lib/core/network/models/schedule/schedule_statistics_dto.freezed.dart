// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_statistics_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleStatisticsDto {
  int get totalSlots;
  int get filledSlots;
  int get availableSlots;
  Map<String, int> get slotsByDay;
  Map<String, int> get childrenByDay;
  Map<String, int> get vehiclesByDay;
  String get groupId;
  String get week;
  double? get utilizationRate;

  /// Create a copy of ScheduleStatisticsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleStatisticsDtoCopyWith<ScheduleStatisticsDto> get copyWith =>
      _$ScheduleStatisticsDtoCopyWithImpl<ScheduleStatisticsDto>(
          this as ScheduleStatisticsDto, _$identity);

  /// Serializes this ScheduleStatisticsDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleStatisticsDto &&
            (identical(other.totalSlots, totalSlots) ||
                other.totalSlots == totalSlots) &&
            (identical(other.filledSlots, filledSlots) ||
                other.filledSlots == filledSlots) &&
            (identical(other.availableSlots, availableSlots) ||
                other.availableSlots == availableSlots) &&
            const DeepCollectionEquality()
                .equals(other.slotsByDay, slotsByDay) &&
            const DeepCollectionEquality()
                .equals(other.childrenByDay, childrenByDay) &&
            const DeepCollectionEquality()
                .equals(other.vehiclesByDay, vehiclesByDay) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.week, week) || other.week == week) &&
            (identical(other.utilizationRate, utilizationRate) ||
                other.utilizationRate == utilizationRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalSlots,
      filledSlots,
      availableSlots,
      const DeepCollectionEquality().hash(slotsByDay),
      const DeepCollectionEquality().hash(childrenByDay),
      const DeepCollectionEquality().hash(vehiclesByDay),
      groupId,
      week,
      utilizationRate);

  @override
  String toString() {
    return 'ScheduleStatisticsDto(totalSlots: $totalSlots, filledSlots: $filledSlots, availableSlots: $availableSlots, slotsByDay: $slotsByDay, childrenByDay: $childrenByDay, vehiclesByDay: $vehiclesByDay, groupId: $groupId, week: $week, utilizationRate: $utilizationRate)';
  }
}

/// @nodoc
abstract mixin class $ScheduleStatisticsDtoCopyWith<$Res> {
  factory $ScheduleStatisticsDtoCopyWith(ScheduleStatisticsDto value,
          $Res Function(ScheduleStatisticsDto) _then) =
      _$ScheduleStatisticsDtoCopyWithImpl;
  @useResult
  $Res call(
      {int totalSlots,
      int filledSlots,
      int availableSlots,
      Map<String, int> slotsByDay,
      Map<String, int> childrenByDay,
      Map<String, int> vehiclesByDay,
      String groupId,
      String week,
      double? utilizationRate});
}

/// @nodoc
class _$ScheduleStatisticsDtoCopyWithImpl<$Res>
    implements $ScheduleStatisticsDtoCopyWith<$Res> {
  _$ScheduleStatisticsDtoCopyWithImpl(this._self, this._then);

  final ScheduleStatisticsDto _self;
  final $Res Function(ScheduleStatisticsDto) _then;

  /// Create a copy of ScheduleStatisticsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSlots = null,
    Object? filledSlots = null,
    Object? availableSlots = null,
    Object? slotsByDay = null,
    Object? childrenByDay = null,
    Object? vehiclesByDay = null,
    Object? groupId = null,
    Object? week = null,
    Object? utilizationRate = freezed,
  }) {
    return _then(_self.copyWith(
      totalSlots: null == totalSlots
          ? _self.totalSlots
          : totalSlots // ignore: cast_nullable_to_non_nullable
              as int,
      filledSlots: null == filledSlots
          ? _self.filledSlots
          : filledSlots // ignore: cast_nullable_to_non_nullable
              as int,
      availableSlots: null == availableSlots
          ? _self.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int,
      slotsByDay: null == slotsByDay
          ? _self.slotsByDay
          : slotsByDay // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      childrenByDay: null == childrenByDay
          ? _self.childrenByDay
          : childrenByDay // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      vehiclesByDay: null == vehiclesByDay
          ? _self.vehiclesByDay
          : vehiclesByDay // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      groupId: null == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      week: null == week
          ? _self.week
          : week // ignore: cast_nullable_to_non_nullable
              as String,
      utilizationRate: freezed == utilizationRate
          ? _self.utilizationRate
          : utilizationRate // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ScheduleStatisticsDto].
extension ScheduleStatisticsDtoPatterns on ScheduleStatisticsDto {
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
    TResult Function(_ScheduleStatisticsDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleStatisticsDto() when $default != null:
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
    TResult Function(_ScheduleStatisticsDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleStatisticsDto():
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
    TResult? Function(_ScheduleStatisticsDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleStatisticsDto() when $default != null:
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
            int totalSlots,
            int filledSlots,
            int availableSlots,
            Map<String, int> slotsByDay,
            Map<String, int> childrenByDay,
            Map<String, int> vehiclesByDay,
            String groupId,
            String week,
            double? utilizationRate)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleStatisticsDto() when $default != null:
        return $default(
            _that.totalSlots,
            _that.filledSlots,
            _that.availableSlots,
            _that.slotsByDay,
            _that.childrenByDay,
            _that.vehiclesByDay,
            _that.groupId,
            _that.week,
            _that.utilizationRate);
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
            int totalSlots,
            int filledSlots,
            int availableSlots,
            Map<String, int> slotsByDay,
            Map<String, int> childrenByDay,
            Map<String, int> vehiclesByDay,
            String groupId,
            String week,
            double? utilizationRate)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleStatisticsDto():
        return $default(
            _that.totalSlots,
            _that.filledSlots,
            _that.availableSlots,
            _that.slotsByDay,
            _that.childrenByDay,
            _that.vehiclesByDay,
            _that.groupId,
            _that.week,
            _that.utilizationRate);
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
            int totalSlots,
            int filledSlots,
            int availableSlots,
            Map<String, int> slotsByDay,
            Map<String, int> childrenByDay,
            Map<String, int> vehiclesByDay,
            String groupId,
            String week,
            double? utilizationRate)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleStatisticsDto() when $default != null:
        return $default(
            _that.totalSlots,
            _that.filledSlots,
            _that.availableSlots,
            _that.slotsByDay,
            _that.childrenByDay,
            _that.vehiclesByDay,
            _that.groupId,
            _that.week,
            _that.utilizationRate);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ScheduleStatisticsDto implements ScheduleStatisticsDto {
  const _ScheduleStatisticsDto(
      {required this.totalSlots,
      required this.filledSlots,
      required this.availableSlots,
      required final Map<String, int> slotsByDay,
      required final Map<String, int> childrenByDay,
      required final Map<String, int> vehiclesByDay,
      required this.groupId,
      required this.week,
      this.utilizationRate})
      : _slotsByDay = slotsByDay,
        _childrenByDay = childrenByDay,
        _vehiclesByDay = vehiclesByDay;
  factory _ScheduleStatisticsDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleStatisticsDtoFromJson(json);

  @override
  final int totalSlots;
  @override
  final int filledSlots;
  @override
  final int availableSlots;
  final Map<String, int> _slotsByDay;
  @override
  Map<String, int> get slotsByDay {
    if (_slotsByDay is EqualUnmodifiableMapView) return _slotsByDay;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_slotsByDay);
  }

  final Map<String, int> _childrenByDay;
  @override
  Map<String, int> get childrenByDay {
    if (_childrenByDay is EqualUnmodifiableMapView) return _childrenByDay;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_childrenByDay);
  }

  final Map<String, int> _vehiclesByDay;
  @override
  Map<String, int> get vehiclesByDay {
    if (_vehiclesByDay is EqualUnmodifiableMapView) return _vehiclesByDay;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_vehiclesByDay);
  }

  @override
  final String groupId;
  @override
  final String week;
  @override
  final double? utilizationRate;

  /// Create a copy of ScheduleStatisticsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleStatisticsDtoCopyWith<_ScheduleStatisticsDto> get copyWith =>
      __$ScheduleStatisticsDtoCopyWithImpl<_ScheduleStatisticsDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ScheduleStatisticsDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduleStatisticsDto &&
            (identical(other.totalSlots, totalSlots) ||
                other.totalSlots == totalSlots) &&
            (identical(other.filledSlots, filledSlots) ||
                other.filledSlots == filledSlots) &&
            (identical(other.availableSlots, availableSlots) ||
                other.availableSlots == availableSlots) &&
            const DeepCollectionEquality()
                .equals(other._slotsByDay, _slotsByDay) &&
            const DeepCollectionEquality()
                .equals(other._childrenByDay, _childrenByDay) &&
            const DeepCollectionEquality()
                .equals(other._vehiclesByDay, _vehiclesByDay) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.week, week) || other.week == week) &&
            (identical(other.utilizationRate, utilizationRate) ||
                other.utilizationRate == utilizationRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalSlots,
      filledSlots,
      availableSlots,
      const DeepCollectionEquality().hash(_slotsByDay),
      const DeepCollectionEquality().hash(_childrenByDay),
      const DeepCollectionEquality().hash(_vehiclesByDay),
      groupId,
      week,
      utilizationRate);

  @override
  String toString() {
    return 'ScheduleStatisticsDto(totalSlots: $totalSlots, filledSlots: $filledSlots, availableSlots: $availableSlots, slotsByDay: $slotsByDay, childrenByDay: $childrenByDay, vehiclesByDay: $vehiclesByDay, groupId: $groupId, week: $week, utilizationRate: $utilizationRate)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleStatisticsDtoCopyWith<$Res>
    implements $ScheduleStatisticsDtoCopyWith<$Res> {
  factory _$ScheduleStatisticsDtoCopyWith(_ScheduleStatisticsDto value,
          $Res Function(_ScheduleStatisticsDto) _then) =
      __$ScheduleStatisticsDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int totalSlots,
      int filledSlots,
      int availableSlots,
      Map<String, int> slotsByDay,
      Map<String, int> childrenByDay,
      Map<String, int> vehiclesByDay,
      String groupId,
      String week,
      double? utilizationRate});
}

/// @nodoc
class __$ScheduleStatisticsDtoCopyWithImpl<$Res>
    implements _$ScheduleStatisticsDtoCopyWith<$Res> {
  __$ScheduleStatisticsDtoCopyWithImpl(this._self, this._then);

  final _ScheduleStatisticsDto _self;
  final $Res Function(_ScheduleStatisticsDto) _then;

  /// Create a copy of ScheduleStatisticsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? totalSlots = null,
    Object? filledSlots = null,
    Object? availableSlots = null,
    Object? slotsByDay = null,
    Object? childrenByDay = null,
    Object? vehiclesByDay = null,
    Object? groupId = null,
    Object? week = null,
    Object? utilizationRate = freezed,
  }) {
    return _then(_ScheduleStatisticsDto(
      totalSlots: null == totalSlots
          ? _self.totalSlots
          : totalSlots // ignore: cast_nullable_to_non_nullable
              as int,
      filledSlots: null == filledSlots
          ? _self.filledSlots
          : filledSlots // ignore: cast_nullable_to_non_nullable
              as int,
      availableSlots: null == availableSlots
          ? _self.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int,
      slotsByDay: null == slotsByDay
          ? _self._slotsByDay
          : slotsByDay // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      childrenByDay: null == childrenByDay
          ? _self._childrenByDay
          : childrenByDay // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      vehiclesByDay: null == vehiclesByDay
          ? _self._vehiclesByDay
          : vehiclesByDay // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      groupId: null == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      week: null == week
          ? _self.week
          : week // ignore: cast_nullable_to_non_nullable
              as String,
      utilizationRate: freezed == utilizationRate
          ? _self.utilizationRate
          : utilizationRate // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

// dart format on
