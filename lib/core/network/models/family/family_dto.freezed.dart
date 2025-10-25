// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FamilyDto {
  String get id;
  String get name;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  List<FamilyMemberDto>? get members;
  List<ChildDto>? get children;
  List<VehicleDto>? get vehicles;

  /// Create a copy of FamilyDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FamilyDtoCopyWith<FamilyDto> get copyWith =>
      _$FamilyDtoCopyWithImpl<FamilyDto>(this as FamilyDto, _$identity);

  /// Serializes this FamilyDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FamilyDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other.members, members) &&
            const DeepCollectionEquality().equals(other.children, children) &&
            const DeepCollectionEquality().equals(other.vehicles, vehicles));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(members),
      const DeepCollectionEquality().hash(children),
      const DeepCollectionEquality().hash(vehicles));

  @override
  String toString() {
    return 'FamilyDto(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, members: $members, children: $children, vehicles: $vehicles)';
  }
}

/// @nodoc
abstract mixin class $FamilyDtoCopyWith<$Res> {
  factory $FamilyDtoCopyWith(FamilyDto value, $Res Function(FamilyDto) _then) =
      _$FamilyDtoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<FamilyMemberDto>? members,
      List<ChildDto>? children,
      List<VehicleDto>? vehicles});
}

/// @nodoc
class _$FamilyDtoCopyWithImpl<$Res> implements $FamilyDtoCopyWith<$Res> {
  _$FamilyDtoCopyWithImpl(this._self, this._then);

  final FamilyDto _self;
  final $Res Function(FamilyDto) _then;

  /// Create a copy of FamilyDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? members = freezed,
    Object? children = freezed,
    Object? vehicles = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      members: freezed == members
          ? _self.members
          : members // ignore: cast_nullable_to_non_nullable
              as List<FamilyMemberDto>?,
      children: freezed == children
          ? _self.children
          : children // ignore: cast_nullable_to_non_nullable
              as List<ChildDto>?,
      vehicles: freezed == vehicles
          ? _self.vehicles
          : vehicles // ignore: cast_nullable_to_non_nullable
              as List<VehicleDto>?,
    ));
  }
}

/// Adds pattern-matching-related methods to [FamilyDto].
extension FamilyDtoPatterns on FamilyDto {
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
    TResult Function(_FamilyDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FamilyDto() when $default != null:
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
    TResult Function(_FamilyDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FamilyDto():
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
    TResult? Function(_FamilyDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FamilyDto() when $default != null:
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
            String name,
            DateTime? createdAt,
            DateTime? updatedAt,
            List<FamilyMemberDto>? members,
            List<ChildDto>? children,
            List<VehicleDto>? vehicles)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FamilyDto() when $default != null:
        return $default(_that.id, _that.name, _that.createdAt, _that.updatedAt,
            _that.members, _that.children, _that.vehicles);
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
            String name,
            DateTime? createdAt,
            DateTime? updatedAt,
            List<FamilyMemberDto>? members,
            List<ChildDto>? children,
            List<VehicleDto>? vehicles)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FamilyDto():
        return $default(_that.id, _that.name, _that.createdAt, _that.updatedAt,
            _that.members, _that.children, _that.vehicles);
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
            String name,
            DateTime? createdAt,
            DateTime? updatedAt,
            List<FamilyMemberDto>? members,
            List<ChildDto>? children,
            List<VehicleDto>? vehicles)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FamilyDto() when $default != null:
        return $default(_that.id, _that.name, _that.createdAt, _that.updatedAt,
            _that.members, _that.children, _that.vehicles);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _FamilyDto extends FamilyDto {
  const _FamilyDto(
      {required this.id,
      required this.name,
      this.createdAt,
      this.updatedAt,
      final List<FamilyMemberDto>? members,
      final List<ChildDto>? children,
      final List<VehicleDto>? vehicles})
      : _members = members,
        _children = children,
        _vehicles = vehicles,
        super._();
  factory _FamilyDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyDtoFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  final List<FamilyMemberDto>? _members;
  @override
  List<FamilyMemberDto>? get members {
    final value = _members;
    if (value == null) return null;
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<ChildDto>? _children;
  @override
  List<ChildDto>? get children {
    final value = _children;
    if (value == null) return null;
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<VehicleDto>? _vehicles;
  @override
  List<VehicleDto>? get vehicles {
    final value = _vehicles;
    if (value == null) return null;
    if (_vehicles is EqualUnmodifiableListView) return _vehicles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of FamilyDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FamilyDtoCopyWith<_FamilyDto> get copyWith =>
      __$FamilyDtoCopyWithImpl<_FamilyDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$FamilyDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FamilyDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._members, _members) &&
            const DeepCollectionEquality().equals(other._children, _children) &&
            const DeepCollectionEquality().equals(other._vehicles, _vehicles));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_members),
      const DeepCollectionEquality().hash(_children),
      const DeepCollectionEquality().hash(_vehicles));

  @override
  String toString() {
    return 'FamilyDto(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, members: $members, children: $children, vehicles: $vehicles)';
  }
}

/// @nodoc
abstract mixin class _$FamilyDtoCopyWith<$Res>
    implements $FamilyDtoCopyWith<$Res> {
  factory _$FamilyDtoCopyWith(
          _FamilyDto value, $Res Function(_FamilyDto) _then) =
      __$FamilyDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<FamilyMemberDto>? members,
      List<ChildDto>? children,
      List<VehicleDto>? vehicles});
}

/// @nodoc
class __$FamilyDtoCopyWithImpl<$Res> implements _$FamilyDtoCopyWith<$Res> {
  __$FamilyDtoCopyWithImpl(this._self, this._then);

  final _FamilyDto _self;
  final $Res Function(_FamilyDto) _then;

  /// Create a copy of FamilyDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? members = freezed,
    Object? children = freezed,
    Object? vehicles = freezed,
  }) {
    return _then(_FamilyDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      members: freezed == members
          ? _self._members
          : members // ignore: cast_nullable_to_non_nullable
              as List<FamilyMemberDto>?,
      children: freezed == children
          ? _self._children
          : children // ignore: cast_nullable_to_non_nullable
              as List<ChildDto>?,
      vehicles: freezed == vehicles
          ? _self._vehicles
          : vehicles // ignore: cast_nullable_to_non_nullable
              as List<VehicleDto>?,
    ));
  }
}

// dart format on
