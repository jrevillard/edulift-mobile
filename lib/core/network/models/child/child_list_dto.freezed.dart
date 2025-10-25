// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_list_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChildrenListDto {
  List<ChildDto> get children;

  /// Create a copy of ChildrenListDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChildrenListDtoCopyWith<ChildrenListDto> get copyWith =>
      _$ChildrenListDtoCopyWithImpl<ChildrenListDto>(
          this as ChildrenListDto, _$identity);

  /// Serializes this ChildrenListDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChildrenListDto &&
            const DeepCollectionEquality().equals(other.children, children));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(children));

  @override
  String toString() {
    return 'ChildrenListDto(children: $children)';
  }
}

/// @nodoc
abstract mixin class $ChildrenListDtoCopyWith<$Res> {
  factory $ChildrenListDtoCopyWith(
          ChildrenListDto value, $Res Function(ChildrenListDto) _then) =
      _$ChildrenListDtoCopyWithImpl;
  @useResult
  $Res call({List<ChildDto> children});
}

/// @nodoc
class _$ChildrenListDtoCopyWithImpl<$Res>
    implements $ChildrenListDtoCopyWith<$Res> {
  _$ChildrenListDtoCopyWithImpl(this._self, this._then);

  final ChildrenListDto _self;
  final $Res Function(ChildrenListDto) _then;

  /// Create a copy of ChildrenListDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? children = null,
  }) {
    return _then(_self.copyWith(
      children: null == children
          ? _self.children
          : children // ignore: cast_nullable_to_non_nullable
              as List<ChildDto>,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChildrenListDto].
extension ChildrenListDtoPatterns on ChildrenListDto {
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
    TResult Function(_ChildrenListDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChildrenListDto() when $default != null:
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
    TResult Function(_ChildrenListDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChildrenListDto():
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
    TResult? Function(_ChildrenListDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChildrenListDto() when $default != null:
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
    TResult Function(List<ChildDto> children)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChildrenListDto() when $default != null:
        return $default(_that.children);
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
    TResult Function(List<ChildDto> children) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChildrenListDto():
        return $default(_that.children);
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
    TResult? Function(List<ChildDto> children)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChildrenListDto() when $default != null:
        return $default(_that.children);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChildrenListDto implements ChildrenListDto {
  const _ChildrenListDto({required final List<ChildDto> children})
      : _children = children;
  factory _ChildrenListDto.fromJson(Map<String, dynamic> json) =>
      _$ChildrenListDtoFromJson(json);

  final List<ChildDto> _children;
  @override
  List<ChildDto> get children {
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_children);
  }

  /// Create a copy of ChildrenListDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChildrenListDtoCopyWith<_ChildrenListDto> get copyWith =>
      __$ChildrenListDtoCopyWithImpl<_ChildrenListDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChildrenListDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChildrenListDto &&
            const DeepCollectionEquality().equals(other._children, _children));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_children));

  @override
  String toString() {
    return 'ChildrenListDto(children: $children)';
  }
}

/// @nodoc
abstract mixin class _$ChildrenListDtoCopyWith<$Res>
    implements $ChildrenListDtoCopyWith<$Res> {
  factory _$ChildrenListDtoCopyWith(
          _ChildrenListDto value, $Res Function(_ChildrenListDto) _then) =
      __$ChildrenListDtoCopyWithImpl;
  @override
  @useResult
  $Res call({List<ChildDto> children});
}

/// @nodoc
class __$ChildrenListDtoCopyWithImpl<$Res>
    implements _$ChildrenListDtoCopyWith<$Res> {
  __$ChildrenListDtoCopyWithImpl(this._self, this._then);

  final _ChildrenListDto _self;
  final $Res Function(_ChildrenListDto) _then;

  /// Create a copy of ChildrenListDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? children = null,
  }) {
    return _then(_ChildrenListDto(
      children: null == children
          ? _self._children
          : children // ignore: cast_nullable_to_non_nullable
              as List<ChildDto>,
    ));
  }
}

/// @nodoc
mixin _$AssignmentDto {
  String get id;
  String get childId;
  String get scheduleSlotId;
  String? get vehicleAssignmentId;
  String get status;
  String get createdAt;
  String get updatedAt;

  /// Create a copy of AssignmentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AssignmentDtoCopyWith<AssignmentDto> get copyWith =>
      _$AssignmentDtoCopyWithImpl<AssignmentDto>(
          this as AssignmentDto, _$identity);

  /// Serializes this AssignmentDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AssignmentDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.scheduleSlotId, scheduleSlotId) ||
                other.scheduleSlotId == scheduleSlotId) &&
            (identical(other.vehicleAssignmentId, vehicleAssignmentId) ||
                other.vehicleAssignmentId == vehicleAssignmentId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, childId, scheduleSlotId,
      vehicleAssignmentId, status, createdAt, updatedAt);

  @override
  String toString() {
    return 'AssignmentDto(id: $id, childId: $childId, scheduleSlotId: $scheduleSlotId, vehicleAssignmentId: $vehicleAssignmentId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $AssignmentDtoCopyWith<$Res> {
  factory $AssignmentDtoCopyWith(
          AssignmentDto value, $Res Function(AssignmentDto) _then) =
      _$AssignmentDtoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String childId,
      String scheduleSlotId,
      String? vehicleAssignmentId,
      String status,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class _$AssignmentDtoCopyWithImpl<$Res>
    implements $AssignmentDtoCopyWith<$Res> {
  _$AssignmentDtoCopyWithImpl(this._self, this._then);

  final AssignmentDto _self;
  final $Res Function(AssignmentDto) _then;

  /// Create a copy of AssignmentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? scheduleSlotId = null,
    Object? vehicleAssignmentId = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _self.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      scheduleSlotId: null == scheduleSlotId
          ? _self.scheduleSlotId
          : scheduleSlotId // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleAssignmentId: freezed == vehicleAssignmentId
          ? _self.vehicleAssignmentId
          : vehicleAssignmentId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [AssignmentDto].
extension AssignmentDtoPatterns on AssignmentDto {
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
    TResult Function(_AssignmentDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AssignmentDto() when $default != null:
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
    TResult Function(_AssignmentDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AssignmentDto():
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
    TResult? Function(_AssignmentDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AssignmentDto() when $default != null:
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
            String childId,
            String scheduleSlotId,
            String? vehicleAssignmentId,
            String status,
            String createdAt,
            String updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AssignmentDto() when $default != null:
        return $default(
            _that.id,
            _that.childId,
            _that.scheduleSlotId,
            _that.vehicleAssignmentId,
            _that.status,
            _that.createdAt,
            _that.updatedAt);
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
            String childId,
            String scheduleSlotId,
            String? vehicleAssignmentId,
            String status,
            String createdAt,
            String updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AssignmentDto():
        return $default(
            _that.id,
            _that.childId,
            _that.scheduleSlotId,
            _that.vehicleAssignmentId,
            _that.status,
            _that.createdAt,
            _that.updatedAt);
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
            String childId,
            String scheduleSlotId,
            String? vehicleAssignmentId,
            String status,
            String createdAt,
            String updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AssignmentDto() when $default != null:
        return $default(
            _that.id,
            _that.childId,
            _that.scheduleSlotId,
            _that.vehicleAssignmentId,
            _that.status,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AssignmentDto implements AssignmentDto {
  const _AssignmentDto(
      {required this.id,
      required this.childId,
      required this.scheduleSlotId,
      this.vehicleAssignmentId,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  factory _AssignmentDto.fromJson(Map<String, dynamic> json) =>
      _$AssignmentDtoFromJson(json);

  @override
  final String id;
  @override
  final String childId;
  @override
  final String scheduleSlotId;
  @override
  final String? vehicleAssignmentId;
  @override
  final String status;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  /// Create a copy of AssignmentDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AssignmentDtoCopyWith<_AssignmentDto> get copyWith =>
      __$AssignmentDtoCopyWithImpl<_AssignmentDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AssignmentDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AssignmentDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.scheduleSlotId, scheduleSlotId) ||
                other.scheduleSlotId == scheduleSlotId) &&
            (identical(other.vehicleAssignmentId, vehicleAssignmentId) ||
                other.vehicleAssignmentId == vehicleAssignmentId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, childId, scheduleSlotId,
      vehicleAssignmentId, status, createdAt, updatedAt);

  @override
  String toString() {
    return 'AssignmentDto(id: $id, childId: $childId, scheduleSlotId: $scheduleSlotId, vehicleAssignmentId: $vehicleAssignmentId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$AssignmentDtoCopyWith<$Res>
    implements $AssignmentDtoCopyWith<$Res> {
  factory _$AssignmentDtoCopyWith(
          _AssignmentDto value, $Res Function(_AssignmentDto) _then) =
      __$AssignmentDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String childId,
      String scheduleSlotId,
      String? vehicleAssignmentId,
      String status,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class __$AssignmentDtoCopyWithImpl<$Res>
    implements _$AssignmentDtoCopyWith<$Res> {
  __$AssignmentDtoCopyWithImpl(this._self, this._then);

  final _AssignmentDto _self;
  final $Res Function(_AssignmentDto) _then;

  /// Create a copy of AssignmentDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? scheduleSlotId = null,
    Object? vehicleAssignmentId = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_AssignmentDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _self.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      scheduleSlotId: null == scheduleSlotId
          ? _self.scheduleSlotId
          : scheduleSlotId // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleAssignmentId: freezed == vehicleAssignmentId
          ? _self.vehicleAssignmentId
          : vehicleAssignmentId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ChildAssignmentsDto {
  List<AssignmentDto> get assignments;

  /// Create a copy of ChildAssignmentsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChildAssignmentsDtoCopyWith<ChildAssignmentsDto> get copyWith =>
      _$ChildAssignmentsDtoCopyWithImpl<ChildAssignmentsDto>(
          this as ChildAssignmentsDto, _$identity);

  /// Serializes this ChildAssignmentsDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChildAssignmentsDto &&
            const DeepCollectionEquality()
                .equals(other.assignments, assignments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(assignments));

  @override
  String toString() {
    return 'ChildAssignmentsDto(assignments: $assignments)';
  }
}

/// @nodoc
abstract mixin class $ChildAssignmentsDtoCopyWith<$Res> {
  factory $ChildAssignmentsDtoCopyWith(
          ChildAssignmentsDto value, $Res Function(ChildAssignmentsDto) _then) =
      _$ChildAssignmentsDtoCopyWithImpl;
  @useResult
  $Res call({List<AssignmentDto> assignments});
}

/// @nodoc
class _$ChildAssignmentsDtoCopyWithImpl<$Res>
    implements $ChildAssignmentsDtoCopyWith<$Res> {
  _$ChildAssignmentsDtoCopyWithImpl(this._self, this._then);

  final ChildAssignmentsDto _self;
  final $Res Function(ChildAssignmentsDto) _then;

  /// Create a copy of ChildAssignmentsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignments = null,
  }) {
    return _then(_self.copyWith(
      assignments: null == assignments
          ? _self.assignments
          : assignments // ignore: cast_nullable_to_non_nullable
              as List<AssignmentDto>,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChildAssignmentsDto].
extension ChildAssignmentsDtoPatterns on ChildAssignmentsDto {
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
    TResult Function(_ChildAssignmentsDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChildAssignmentsDto() when $default != null:
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
    TResult Function(_ChildAssignmentsDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChildAssignmentsDto():
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
    TResult? Function(_ChildAssignmentsDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChildAssignmentsDto() when $default != null:
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
    TResult Function(List<AssignmentDto> assignments)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChildAssignmentsDto() when $default != null:
        return $default(_that.assignments);
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
    TResult Function(List<AssignmentDto> assignments) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChildAssignmentsDto():
        return $default(_that.assignments);
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
    TResult? Function(List<AssignmentDto> assignments)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChildAssignmentsDto() when $default != null:
        return $default(_that.assignments);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChildAssignmentsDto implements ChildAssignmentsDto {
  const _ChildAssignmentsDto({required final List<AssignmentDto> assignments})
      : _assignments = assignments;
  factory _ChildAssignmentsDto.fromJson(Map<String, dynamic> json) =>
      _$ChildAssignmentsDtoFromJson(json);

  final List<AssignmentDto> _assignments;
  @override
  List<AssignmentDto> get assignments {
    if (_assignments is EqualUnmodifiableListView) return _assignments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignments);
  }

  /// Create a copy of ChildAssignmentsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChildAssignmentsDtoCopyWith<_ChildAssignmentsDto> get copyWith =>
      __$ChildAssignmentsDtoCopyWithImpl<_ChildAssignmentsDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChildAssignmentsDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChildAssignmentsDto &&
            const DeepCollectionEquality()
                .equals(other._assignments, _assignments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_assignments));

  @override
  String toString() {
    return 'ChildAssignmentsDto(assignments: $assignments)';
  }
}

/// @nodoc
abstract mixin class _$ChildAssignmentsDtoCopyWith<$Res>
    implements $ChildAssignmentsDtoCopyWith<$Res> {
  factory _$ChildAssignmentsDtoCopyWith(_ChildAssignmentsDto value,
          $Res Function(_ChildAssignmentsDto) _then) =
      __$ChildAssignmentsDtoCopyWithImpl;
  @override
  @useResult
  $Res call({List<AssignmentDto> assignments});
}

/// @nodoc
class __$ChildAssignmentsDtoCopyWithImpl<$Res>
    implements _$ChildAssignmentsDtoCopyWith<$Res> {
  __$ChildAssignmentsDtoCopyWithImpl(this._self, this._then);

  final _ChildAssignmentsDto _self;
  final $Res Function(_ChildAssignmentsDto) _then;

  /// Create a copy of ChildAssignmentsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? assignments = null,
  }) {
    return _then(_ChildAssignmentsDto(
      assignments: null == assignments
          ? _self._assignments
          : assignments // ignore: cast_nullable_to_non_nullable
              as List<AssignmentDto>,
    ));
  }
}

/// @nodoc
mixin _$GroupMembershipDto {
  String get id;
  String get childId;
  String get groupId;
  String get groupName;
  String get createdAt;

  /// Create a copy of GroupMembershipDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GroupMembershipDtoCopyWith<GroupMembershipDto> get copyWith =>
      _$GroupMembershipDtoCopyWithImpl<GroupMembershipDto>(
          this as GroupMembershipDto, _$identity);

  /// Serializes this GroupMembershipDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GroupMembershipDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, childId, groupId, groupName, createdAt);

  @override
  String toString() {
    return 'GroupMembershipDto(id: $id, childId: $childId, groupId: $groupId, groupName: $groupName, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $GroupMembershipDtoCopyWith<$Res> {
  factory $GroupMembershipDtoCopyWith(
          GroupMembershipDto value, $Res Function(GroupMembershipDto) _then) =
      _$GroupMembershipDtoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String childId,
      String groupId,
      String groupName,
      String createdAt});
}

/// @nodoc
class _$GroupMembershipDtoCopyWithImpl<$Res>
    implements $GroupMembershipDtoCopyWith<$Res> {
  _$GroupMembershipDtoCopyWithImpl(this._self, this._then);

  final GroupMembershipDto _self;
  final $Res Function(GroupMembershipDto) _then;

  /// Create a copy of GroupMembershipDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? groupId = null,
    Object? groupName = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _self.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      groupName: null == groupName
          ? _self.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [GroupMembershipDto].
extension GroupMembershipDtoPatterns on GroupMembershipDto {
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
    TResult Function(_GroupMembershipDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupMembershipDto() when $default != null:
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
    TResult Function(_GroupMembershipDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupMembershipDto():
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
    TResult? Function(_GroupMembershipDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupMembershipDto() when $default != null:
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
    TResult Function(String id, String childId, String groupId,
            String groupName, String createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupMembershipDto() when $default != null:
        return $default(_that.id, _that.childId, _that.groupId, _that.groupName,
            _that.createdAt);
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
    TResult Function(String id, String childId, String groupId,
            String groupName, String createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupMembershipDto():
        return $default(_that.id, _that.childId, _that.groupId, _that.groupName,
            _that.createdAt);
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
    TResult? Function(String id, String childId, String groupId,
            String groupName, String createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupMembershipDto() when $default != null:
        return $default(_that.id, _that.childId, _that.groupId, _that.groupName,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GroupMembershipDto implements GroupMembershipDto {
  const _GroupMembershipDto(
      {required this.id,
      required this.childId,
      required this.groupId,
      required this.groupName,
      required this.createdAt});
  factory _GroupMembershipDto.fromJson(Map<String, dynamic> json) =>
      _$GroupMembershipDtoFromJson(json);

  @override
  final String id;
  @override
  final String childId;
  @override
  final String groupId;
  @override
  final String groupName;
  @override
  final String createdAt;

  /// Create a copy of GroupMembershipDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GroupMembershipDtoCopyWith<_GroupMembershipDto> get copyWith =>
      __$GroupMembershipDtoCopyWithImpl<_GroupMembershipDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GroupMembershipDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GroupMembershipDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, childId, groupId, groupName, createdAt);

  @override
  String toString() {
    return 'GroupMembershipDto(id: $id, childId: $childId, groupId: $groupId, groupName: $groupName, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$GroupMembershipDtoCopyWith<$Res>
    implements $GroupMembershipDtoCopyWith<$Res> {
  factory _$GroupMembershipDtoCopyWith(
          _GroupMembershipDto value, $Res Function(_GroupMembershipDto) _then) =
      __$GroupMembershipDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String childId,
      String groupId,
      String groupName,
      String createdAt});
}

/// @nodoc
class __$GroupMembershipDtoCopyWithImpl<$Res>
    implements _$GroupMembershipDtoCopyWith<$Res> {
  __$GroupMembershipDtoCopyWithImpl(this._self, this._then);

  final _GroupMembershipDto _self;
  final $Res Function(_GroupMembershipDto) _then;

  /// Create a copy of GroupMembershipDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? groupId = null,
    Object? groupName = null,
    Object? createdAt = null,
  }) {
    return _then(_GroupMembershipDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _self.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      groupName: null == groupName
          ? _self.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ChildGroupMembershipsDto {
  List<GroupMembershipDto> get memberships;

  /// Create a copy of ChildGroupMembershipsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChildGroupMembershipsDtoCopyWith<ChildGroupMembershipsDto> get copyWith =>
      _$ChildGroupMembershipsDtoCopyWithImpl<ChildGroupMembershipsDto>(
          this as ChildGroupMembershipsDto, _$identity);

  /// Serializes this ChildGroupMembershipsDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChildGroupMembershipsDto &&
            const DeepCollectionEquality()
                .equals(other.memberships, memberships));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(memberships));

  @override
  String toString() {
    return 'ChildGroupMembershipsDto(memberships: $memberships)';
  }
}

/// @nodoc
abstract mixin class $ChildGroupMembershipsDtoCopyWith<$Res> {
  factory $ChildGroupMembershipsDtoCopyWith(ChildGroupMembershipsDto value,
          $Res Function(ChildGroupMembershipsDto) _then) =
      _$ChildGroupMembershipsDtoCopyWithImpl;
  @useResult
  $Res call({List<GroupMembershipDto> memberships});
}

/// @nodoc
class _$ChildGroupMembershipsDtoCopyWithImpl<$Res>
    implements $ChildGroupMembershipsDtoCopyWith<$Res> {
  _$ChildGroupMembershipsDtoCopyWithImpl(this._self, this._then);

  final ChildGroupMembershipsDto _self;
  final $Res Function(ChildGroupMembershipsDto) _then;

  /// Create a copy of ChildGroupMembershipsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberships = null,
  }) {
    return _then(_self.copyWith(
      memberships: null == memberships
          ? _self.memberships
          : memberships // ignore: cast_nullable_to_non_nullable
              as List<GroupMembershipDto>,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChildGroupMembershipsDto].
extension ChildGroupMembershipsDtoPatterns on ChildGroupMembershipsDto {
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
    TResult Function(_ChildGroupMembershipsDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChildGroupMembershipsDto() when $default != null:
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
    TResult Function(_ChildGroupMembershipsDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChildGroupMembershipsDto():
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
    TResult? Function(_ChildGroupMembershipsDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChildGroupMembershipsDto() when $default != null:
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
    TResult Function(List<GroupMembershipDto> memberships)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChildGroupMembershipsDto() when $default != null:
        return $default(_that.memberships);
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
    TResult Function(List<GroupMembershipDto> memberships) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChildGroupMembershipsDto():
        return $default(_that.memberships);
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
    TResult? Function(List<GroupMembershipDto> memberships)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChildGroupMembershipsDto() when $default != null:
        return $default(_that.memberships);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChildGroupMembershipsDto implements ChildGroupMembershipsDto {
  const _ChildGroupMembershipsDto(
      {required final List<GroupMembershipDto> memberships})
      : _memberships = memberships;
  factory _ChildGroupMembershipsDto.fromJson(Map<String, dynamic> json) =>
      _$ChildGroupMembershipsDtoFromJson(json);

  final List<GroupMembershipDto> _memberships;
  @override
  List<GroupMembershipDto> get memberships {
    if (_memberships is EqualUnmodifiableListView) return _memberships;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberships);
  }

  /// Create a copy of ChildGroupMembershipsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChildGroupMembershipsDtoCopyWith<_ChildGroupMembershipsDto> get copyWith =>
      __$ChildGroupMembershipsDtoCopyWithImpl<_ChildGroupMembershipsDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChildGroupMembershipsDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChildGroupMembershipsDto &&
            const DeepCollectionEquality()
                .equals(other._memberships, _memberships));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_memberships));

  @override
  String toString() {
    return 'ChildGroupMembershipsDto(memberships: $memberships)';
  }
}

/// @nodoc
abstract mixin class _$ChildGroupMembershipsDtoCopyWith<$Res>
    implements $ChildGroupMembershipsDtoCopyWith<$Res> {
  factory _$ChildGroupMembershipsDtoCopyWith(_ChildGroupMembershipsDto value,
          $Res Function(_ChildGroupMembershipsDto) _then) =
      __$ChildGroupMembershipsDtoCopyWithImpl;
  @override
  @useResult
  $Res call({List<GroupMembershipDto> memberships});
}

/// @nodoc
class __$ChildGroupMembershipsDtoCopyWithImpl<$Res>
    implements _$ChildGroupMembershipsDtoCopyWith<$Res> {
  __$ChildGroupMembershipsDtoCopyWithImpl(this._self, this._then);

  final _ChildGroupMembershipsDto _self;
  final $Res Function(_ChildGroupMembershipsDto) _then;

  /// Create a copy of ChildGroupMembershipsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? memberships = null,
  }) {
    return _then(_ChildGroupMembershipsDto(
      memberships: null == memberships
          ? _self._memberships
          : memberships // ignore: cast_nullable_to_non_nullable
              as List<GroupMembershipDto>,
    ));
  }
}

// dart format on
