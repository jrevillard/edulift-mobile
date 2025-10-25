// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardStatsDto {
  int get groups;
  int get children;
  int get vehicles;
  @JsonKey(name: 'this_week_trips')
  int get thisWeekTrips;
  @JsonKey(name: 'pending_invitations')
  int get pendingInvitations;
  TrendsDto? get trends;

  /// Create a copy of DashboardStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DashboardStatsDtoCopyWith<DashboardStatsDto> get copyWith =>
      _$DashboardStatsDtoCopyWithImpl<DashboardStatsDto>(
          this as DashboardStatsDto, _$identity);

  /// Serializes this DashboardStatsDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DashboardStatsDto &&
            (identical(other.groups, groups) || other.groups == groups) &&
            (identical(other.children, children) ||
                other.children == children) &&
            (identical(other.vehicles, vehicles) ||
                other.vehicles == vehicles) &&
            (identical(other.thisWeekTrips, thisWeekTrips) ||
                other.thisWeekTrips == thisWeekTrips) &&
            (identical(other.pendingInvitations, pendingInvitations) ||
                other.pendingInvitations == pendingInvitations) &&
            (identical(other.trends, trends) || other.trends == trends));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, groups, children, vehicles,
      thisWeekTrips, pendingInvitations, trends);

  @override
  String toString() {
    return 'DashboardStatsDto(groups: $groups, children: $children, vehicles: $vehicles, thisWeekTrips: $thisWeekTrips, pendingInvitations: $pendingInvitations, trends: $trends)';
  }
}

/// @nodoc
abstract mixin class $DashboardStatsDtoCopyWith<$Res> {
  factory $DashboardStatsDtoCopyWith(
          DashboardStatsDto value, $Res Function(DashboardStatsDto) _then) =
      _$DashboardStatsDtoCopyWithImpl;
  @useResult
  $Res call(
      {int groups,
      int children,
      int vehicles,
      @JsonKey(name: 'this_week_trips') int thisWeekTrips,
      @JsonKey(name: 'pending_invitations') int pendingInvitations,
      TrendsDto? trends});

  $TrendsDtoCopyWith<$Res>? get trends;
}

/// @nodoc
class _$DashboardStatsDtoCopyWithImpl<$Res>
    implements $DashboardStatsDtoCopyWith<$Res> {
  _$DashboardStatsDtoCopyWithImpl(this._self, this._then);

  final DashboardStatsDto _self;
  final $Res Function(DashboardStatsDto) _then;

  /// Create a copy of DashboardStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groups = null,
    Object? children = null,
    Object? vehicles = null,
    Object? thisWeekTrips = null,
    Object? pendingInvitations = null,
    Object? trends = freezed,
  }) {
    return _then(_self.copyWith(
      groups: null == groups
          ? _self.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as int,
      children: null == children
          ? _self.children
          : children // ignore: cast_nullable_to_non_nullable
              as int,
      vehicles: null == vehicles
          ? _self.vehicles
          : vehicles // ignore: cast_nullable_to_non_nullable
              as int,
      thisWeekTrips: null == thisWeekTrips
          ? _self.thisWeekTrips
          : thisWeekTrips // ignore: cast_nullable_to_non_nullable
              as int,
      pendingInvitations: null == pendingInvitations
          ? _self.pendingInvitations
          : pendingInvitations // ignore: cast_nullable_to_non_nullable
              as int,
      trends: freezed == trends
          ? _self.trends
          : trends // ignore: cast_nullable_to_non_nullable
              as TrendsDto?,
    ));
  }

  /// Create a copy of DashboardStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrendsDtoCopyWith<$Res>? get trends {
    if (_self.trends == null) {
      return null;
    }

    return $TrendsDtoCopyWith<$Res>(_self.trends!, (value) {
      return _then(_self.copyWith(trends: value));
    });
  }
}

/// Adds pattern-matching-related methods to [DashboardStatsDto].
extension DashboardStatsDtoPatterns on DashboardStatsDto {
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
    TResult Function(_DashboardStatsDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardStatsDto() when $default != null:
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
    TResult Function(_DashboardStatsDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardStatsDto():
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
    TResult? Function(_DashboardStatsDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardStatsDto() when $default != null:
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
            int groups,
            int children,
            int vehicles,
            @JsonKey(name: 'this_week_trips') int thisWeekTrips,
            @JsonKey(name: 'pending_invitations') int pendingInvitations,
            TrendsDto? trends)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardStatsDto() when $default != null:
        return $default(_that.groups, _that.children, _that.vehicles,
            _that.thisWeekTrips, _that.pendingInvitations, _that.trends);
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
            int groups,
            int children,
            int vehicles,
            @JsonKey(name: 'this_week_trips') int thisWeekTrips,
            @JsonKey(name: 'pending_invitations') int pendingInvitations,
            TrendsDto? trends)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardStatsDto():
        return $default(_that.groups, _that.children, _that.vehicles,
            _that.thisWeekTrips, _that.pendingInvitations, _that.trends);
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
            int groups,
            int children,
            int vehicles,
            @JsonKey(name: 'this_week_trips') int thisWeekTrips,
            @JsonKey(name: 'pending_invitations') int pendingInvitations,
            TrendsDto? trends)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardStatsDto() when $default != null:
        return $default(_that.groups, _that.children, _that.vehicles,
            _that.thisWeekTrips, _that.pendingInvitations, _that.trends);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DashboardStatsDto implements DashboardStatsDto {
  const _DashboardStatsDto(
      {required this.groups,
      required this.children,
      required this.vehicles,
      @JsonKey(name: 'this_week_trips') required this.thisWeekTrips,
      @JsonKey(name: 'pending_invitations') required this.pendingInvitations,
      this.trends});
  factory _DashboardStatsDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsDtoFromJson(json);

  @override
  final int groups;
  @override
  final int children;
  @override
  final int vehicles;
  @override
  @JsonKey(name: 'this_week_trips')
  final int thisWeekTrips;
  @override
  @JsonKey(name: 'pending_invitations')
  final int pendingInvitations;
  @override
  final TrendsDto? trends;

  /// Create a copy of DashboardStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DashboardStatsDtoCopyWith<_DashboardStatsDto> get copyWith =>
      __$DashboardStatsDtoCopyWithImpl<_DashboardStatsDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DashboardStatsDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DashboardStatsDto &&
            (identical(other.groups, groups) || other.groups == groups) &&
            (identical(other.children, children) ||
                other.children == children) &&
            (identical(other.vehicles, vehicles) ||
                other.vehicles == vehicles) &&
            (identical(other.thisWeekTrips, thisWeekTrips) ||
                other.thisWeekTrips == thisWeekTrips) &&
            (identical(other.pendingInvitations, pendingInvitations) ||
                other.pendingInvitations == pendingInvitations) &&
            (identical(other.trends, trends) || other.trends == trends));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, groups, children, vehicles,
      thisWeekTrips, pendingInvitations, trends);

  @override
  String toString() {
    return 'DashboardStatsDto(groups: $groups, children: $children, vehicles: $vehicles, thisWeekTrips: $thisWeekTrips, pendingInvitations: $pendingInvitations, trends: $trends)';
  }
}

/// @nodoc
abstract mixin class _$DashboardStatsDtoCopyWith<$Res>
    implements $DashboardStatsDtoCopyWith<$Res> {
  factory _$DashboardStatsDtoCopyWith(
          _DashboardStatsDto value, $Res Function(_DashboardStatsDto) _then) =
      __$DashboardStatsDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int groups,
      int children,
      int vehicles,
      @JsonKey(name: 'this_week_trips') int thisWeekTrips,
      @JsonKey(name: 'pending_invitations') int pendingInvitations,
      TrendsDto? trends});

  @override
  $TrendsDtoCopyWith<$Res>? get trends;
}

/// @nodoc
class __$DashboardStatsDtoCopyWithImpl<$Res>
    implements _$DashboardStatsDtoCopyWith<$Res> {
  __$DashboardStatsDtoCopyWithImpl(this._self, this._then);

  final _DashboardStatsDto _self;
  final $Res Function(_DashboardStatsDto) _then;

  /// Create a copy of DashboardStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? groups = null,
    Object? children = null,
    Object? vehicles = null,
    Object? thisWeekTrips = null,
    Object? pendingInvitations = null,
    Object? trends = freezed,
  }) {
    return _then(_DashboardStatsDto(
      groups: null == groups
          ? _self.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as int,
      children: null == children
          ? _self.children
          : children // ignore: cast_nullable_to_non_nullable
              as int,
      vehicles: null == vehicles
          ? _self.vehicles
          : vehicles // ignore: cast_nullable_to_non_nullable
              as int,
      thisWeekTrips: null == thisWeekTrips
          ? _self.thisWeekTrips
          : thisWeekTrips // ignore: cast_nullable_to_non_nullable
              as int,
      pendingInvitations: null == pendingInvitations
          ? _self.pendingInvitations
          : pendingInvitations // ignore: cast_nullable_to_non_nullable
              as int,
      trends: freezed == trends
          ? _self.trends
          : trends // ignore: cast_nullable_to_non_nullable
              as TrendsDto?,
    ));
  }

  /// Create a copy of DashboardStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrendsDtoCopyWith<$Res>? get trends {
    if (_self.trends == null) {
      return null;
    }

    return $TrendsDtoCopyWith<$Res>(_self.trends!, (value) {
      return _then(_self.copyWith(trends: value));
    });
  }
}

/// @nodoc
mixin _$TrendsDto {
  @JsonKey(name: 'groups_change')
  double? get groupsChange;
  @JsonKey(name: 'children_change')
  double? get childrenChange;
  @JsonKey(name: 'vehicles_change')
  double? get vehiclesChange;
  @JsonKey(name: 'trips_change')
  double? get tripsChange;

  /// Create a copy of TrendsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TrendsDtoCopyWith<TrendsDto> get copyWith =>
      _$TrendsDtoCopyWithImpl<TrendsDto>(this as TrendsDto, _$identity);

  /// Serializes this TrendsDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TrendsDto &&
            (identical(other.groupsChange, groupsChange) ||
                other.groupsChange == groupsChange) &&
            (identical(other.childrenChange, childrenChange) ||
                other.childrenChange == childrenChange) &&
            (identical(other.vehiclesChange, vehiclesChange) ||
                other.vehiclesChange == vehiclesChange) &&
            (identical(other.tripsChange, tripsChange) ||
                other.tripsChange == tripsChange));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, groupsChange, childrenChange, vehiclesChange, tripsChange);

  @override
  String toString() {
    return 'TrendsDto(groupsChange: $groupsChange, childrenChange: $childrenChange, vehiclesChange: $vehiclesChange, tripsChange: $tripsChange)';
  }
}

/// @nodoc
abstract mixin class $TrendsDtoCopyWith<$Res> {
  factory $TrendsDtoCopyWith(TrendsDto value, $Res Function(TrendsDto) _then) =
      _$TrendsDtoCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'groups_change') double? groupsChange,
      @JsonKey(name: 'children_change') double? childrenChange,
      @JsonKey(name: 'vehicles_change') double? vehiclesChange,
      @JsonKey(name: 'trips_change') double? tripsChange});
}

/// @nodoc
class _$TrendsDtoCopyWithImpl<$Res> implements $TrendsDtoCopyWith<$Res> {
  _$TrendsDtoCopyWithImpl(this._self, this._then);

  final TrendsDto _self;
  final $Res Function(TrendsDto) _then;

  /// Create a copy of TrendsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupsChange = freezed,
    Object? childrenChange = freezed,
    Object? vehiclesChange = freezed,
    Object? tripsChange = freezed,
  }) {
    return _then(_self.copyWith(
      groupsChange: freezed == groupsChange
          ? _self.groupsChange
          : groupsChange // ignore: cast_nullable_to_non_nullable
              as double?,
      childrenChange: freezed == childrenChange
          ? _self.childrenChange
          : childrenChange // ignore: cast_nullable_to_non_nullable
              as double?,
      vehiclesChange: freezed == vehiclesChange
          ? _self.vehiclesChange
          : vehiclesChange // ignore: cast_nullable_to_non_nullable
              as double?,
      tripsChange: freezed == tripsChange
          ? _self.tripsChange
          : tripsChange // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// Adds pattern-matching-related methods to [TrendsDto].
extension TrendsDtoPatterns on TrendsDto {
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
    TResult Function(_TrendsDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TrendsDto() when $default != null:
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
    TResult Function(_TrendsDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrendsDto():
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
    TResult? Function(_TrendsDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrendsDto() when $default != null:
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
            @JsonKey(name: 'groups_change') double? groupsChange,
            @JsonKey(name: 'children_change') double? childrenChange,
            @JsonKey(name: 'vehicles_change') double? vehiclesChange,
            @JsonKey(name: 'trips_change') double? tripsChange)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TrendsDto() when $default != null:
        return $default(_that.groupsChange, _that.childrenChange,
            _that.vehiclesChange, _that.tripsChange);
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
            @JsonKey(name: 'groups_change') double? groupsChange,
            @JsonKey(name: 'children_change') double? childrenChange,
            @JsonKey(name: 'vehicles_change') double? vehiclesChange,
            @JsonKey(name: 'trips_change') double? tripsChange)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrendsDto():
        return $default(_that.groupsChange, _that.childrenChange,
            _that.vehiclesChange, _that.tripsChange);
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
            @JsonKey(name: 'groups_change') double? groupsChange,
            @JsonKey(name: 'children_change') double? childrenChange,
            @JsonKey(name: 'vehicles_change') double? vehiclesChange,
            @JsonKey(name: 'trips_change') double? tripsChange)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrendsDto() when $default != null:
        return $default(_that.groupsChange, _that.childrenChange,
            _that.vehiclesChange, _that.tripsChange);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TrendsDto implements TrendsDto {
  const _TrendsDto(
      {@JsonKey(name: 'groups_change') this.groupsChange,
      @JsonKey(name: 'children_change') this.childrenChange,
      @JsonKey(name: 'vehicles_change') this.vehiclesChange,
      @JsonKey(name: 'trips_change') this.tripsChange});
  factory _TrendsDto.fromJson(Map<String, dynamic> json) =>
      _$TrendsDtoFromJson(json);

  @override
  @JsonKey(name: 'groups_change')
  final double? groupsChange;
  @override
  @JsonKey(name: 'children_change')
  final double? childrenChange;
  @override
  @JsonKey(name: 'vehicles_change')
  final double? vehiclesChange;
  @override
  @JsonKey(name: 'trips_change')
  final double? tripsChange;

  /// Create a copy of TrendsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TrendsDtoCopyWith<_TrendsDto> get copyWith =>
      __$TrendsDtoCopyWithImpl<_TrendsDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TrendsDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TrendsDto &&
            (identical(other.groupsChange, groupsChange) ||
                other.groupsChange == groupsChange) &&
            (identical(other.childrenChange, childrenChange) ||
                other.childrenChange == childrenChange) &&
            (identical(other.vehiclesChange, vehiclesChange) ||
                other.vehiclesChange == vehiclesChange) &&
            (identical(other.tripsChange, tripsChange) ||
                other.tripsChange == tripsChange));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, groupsChange, childrenChange, vehiclesChange, tripsChange);

  @override
  String toString() {
    return 'TrendsDto(groupsChange: $groupsChange, childrenChange: $childrenChange, vehiclesChange: $vehiclesChange, tripsChange: $tripsChange)';
  }
}

/// @nodoc
abstract mixin class _$TrendsDtoCopyWith<$Res>
    implements $TrendsDtoCopyWith<$Res> {
  factory _$TrendsDtoCopyWith(
          _TrendsDto value, $Res Function(_TrendsDto) _then) =
      __$TrendsDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'groups_change') double? groupsChange,
      @JsonKey(name: 'children_change') double? childrenChange,
      @JsonKey(name: 'vehicles_change') double? vehiclesChange,
      @JsonKey(name: 'trips_change') double? tripsChange});
}

/// @nodoc
class __$TrendsDtoCopyWithImpl<$Res> implements _$TrendsDtoCopyWith<$Res> {
  __$TrendsDtoCopyWithImpl(this._self, this._then);

  final _TrendsDto _self;
  final $Res Function(_TrendsDto) _then;

  /// Create a copy of TrendsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? groupsChange = freezed,
    Object? childrenChange = freezed,
    Object? vehiclesChange = freezed,
    Object? tripsChange = freezed,
  }) {
    return _then(_TrendsDto(
      groupsChange: freezed == groupsChange
          ? _self.groupsChange
          : groupsChange // ignore: cast_nullable_to_non_nullable
              as double?,
      childrenChange: freezed == childrenChange
          ? _self.childrenChange
          : childrenChange // ignore: cast_nullable_to_non_nullable
              as double?,
      vehiclesChange: freezed == vehiclesChange
          ? _self.vehiclesChange
          : vehiclesChange // ignore: cast_nullable_to_non_nullable
              as double?,
      tripsChange: freezed == tripsChange
          ? _self.tripsChange
          : tripsChange // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

// dart format on
