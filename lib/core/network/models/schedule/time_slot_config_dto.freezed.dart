// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_slot_config_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimeSlotConfigDto {
  String get id;
  String get groupId;
  List<String> get availableDays;
  List<String> get timeSlots;
  Map<String, dynamic> get settings;
  DateTime? get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of TimeSlotConfigDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TimeSlotConfigDtoCopyWith<TimeSlotConfigDto> get copyWith =>
      _$TimeSlotConfigDtoCopyWithImpl<TimeSlotConfigDto>(
          this as TimeSlotConfigDto, _$identity);

  /// Serializes this TimeSlotConfigDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TimeSlotConfigDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            const DeepCollectionEquality()
                .equals(other.availableDays, availableDays) &&
            const DeepCollectionEquality().equals(other.timeSlots, timeSlots) &&
            const DeepCollectionEquality().equals(other.settings, settings) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      groupId,
      const DeepCollectionEquality().hash(availableDays),
      const DeepCollectionEquality().hash(timeSlots),
      const DeepCollectionEquality().hash(settings),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'TimeSlotConfigDto(id: $id, groupId: $groupId, availableDays: $availableDays, timeSlots: $timeSlots, settings: $settings, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $TimeSlotConfigDtoCopyWith<$Res> {
  factory $TimeSlotConfigDtoCopyWith(
          TimeSlotConfigDto value, $Res Function(TimeSlotConfigDto) _then) =
      _$TimeSlotConfigDtoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String groupId,
      List<String> availableDays,
      List<String> timeSlots,
      Map<String, dynamic> settings,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$TimeSlotConfigDtoCopyWithImpl<$Res>
    implements $TimeSlotConfigDtoCopyWith<$Res> {
  _$TimeSlotConfigDtoCopyWithImpl(this._self, this._then);

  final TimeSlotConfigDto _self;
  final $Res Function(TimeSlotConfigDto) _then;

  /// Create a copy of TimeSlotConfigDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? availableDays = null,
    Object? timeSlots = null,
    Object? settings = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      availableDays: null == availableDays
          ? _self.availableDays
          : availableDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timeSlots: null == timeSlots
          ? _self.timeSlots
          : timeSlots // ignore: cast_nullable_to_non_nullable
              as List<String>,
      settings: null == settings
          ? _self.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [TimeSlotConfigDto].
extension TimeSlotConfigDtoPatterns on TimeSlotConfigDto {
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
    TResult Function(_TimeSlotConfigDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TimeSlotConfigDto() when $default != null:
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
    TResult Function(_TimeSlotConfigDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TimeSlotConfigDto():
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
    TResult? Function(_TimeSlotConfigDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TimeSlotConfigDto() when $default != null:
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
            String groupId,
            List<String> availableDays,
            List<String> timeSlots,
            Map<String, dynamic> settings,
            DateTime? createdAt,
            DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TimeSlotConfigDto() when $default != null:
        return $default(_that.id, _that.groupId, _that.availableDays,
            _that.timeSlots, _that.settings, _that.createdAt, _that.updatedAt);
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
            String groupId,
            List<String> availableDays,
            List<String> timeSlots,
            Map<String, dynamic> settings,
            DateTime? createdAt,
            DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TimeSlotConfigDto():
        return $default(_that.id, _that.groupId, _that.availableDays,
            _that.timeSlots, _that.settings, _that.createdAt, _that.updatedAt);
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
            String groupId,
            List<String> availableDays,
            List<String> timeSlots,
            Map<String, dynamic> settings,
            DateTime? createdAt,
            DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TimeSlotConfigDto() when $default != null:
        return $default(_that.id, _that.groupId, _that.availableDays,
            _that.timeSlots, _that.settings, _that.createdAt, _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TimeSlotConfigDto extends TimeSlotConfigDto {
  const _TimeSlotConfigDto(
      {required this.id,
      required this.groupId,
      required final List<String> availableDays,
      required final List<String> timeSlots,
      required final Map<String, dynamic> settings,
      this.createdAt,
      this.updatedAt})
      : _availableDays = availableDays,
        _timeSlots = timeSlots,
        _settings = settings,
        super._();
  factory _TimeSlotConfigDto.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotConfigDtoFromJson(json);

  @override
  final String id;
  @override
  final String groupId;
  final List<String> _availableDays;
  @override
  List<String> get availableDays {
    if (_availableDays is EqualUnmodifiableListView) return _availableDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableDays);
  }

  final List<String> _timeSlots;
  @override
  List<String> get timeSlots {
    if (_timeSlots is EqualUnmodifiableListView) return _timeSlots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeSlots);
  }

  final Map<String, dynamic> _settings;
  @override
  Map<String, dynamic> get settings {
    if (_settings is EqualUnmodifiableMapView) return _settings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_settings);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Create a copy of TimeSlotConfigDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TimeSlotConfigDtoCopyWith<_TimeSlotConfigDto> get copyWith =>
      __$TimeSlotConfigDtoCopyWithImpl<_TimeSlotConfigDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TimeSlotConfigDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TimeSlotConfigDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            const DeepCollectionEquality()
                .equals(other._availableDays, _availableDays) &&
            const DeepCollectionEquality()
                .equals(other._timeSlots, _timeSlots) &&
            const DeepCollectionEquality().equals(other._settings, _settings) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      groupId,
      const DeepCollectionEquality().hash(_availableDays),
      const DeepCollectionEquality().hash(_timeSlots),
      const DeepCollectionEquality().hash(_settings),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'TimeSlotConfigDto(id: $id, groupId: $groupId, availableDays: $availableDays, timeSlots: $timeSlots, settings: $settings, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$TimeSlotConfigDtoCopyWith<$Res>
    implements $TimeSlotConfigDtoCopyWith<$Res> {
  factory _$TimeSlotConfigDtoCopyWith(
          _TimeSlotConfigDto value, $Res Function(_TimeSlotConfigDto) _then) =
      __$TimeSlotConfigDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String groupId,
      List<String> availableDays,
      List<String> timeSlots,
      Map<String, dynamic> settings,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$TimeSlotConfigDtoCopyWithImpl<$Res>
    implements _$TimeSlotConfigDtoCopyWith<$Res> {
  __$TimeSlotConfigDtoCopyWithImpl(this._self, this._then);

  final _TimeSlotConfigDto _self;
  final $Res Function(_TimeSlotConfigDto) _then;

  /// Create a copy of TimeSlotConfigDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? availableDays = null,
    Object? timeSlots = null,
    Object? settings = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_TimeSlotConfigDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      availableDays: null == availableDays
          ? _self._availableDays
          : availableDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timeSlots: null == timeSlots
          ? _self._timeSlots
          : timeSlots // ignore: cast_nullable_to_non_nullable
              as List<String>,
      settings: null == settings
          ? _self._settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
