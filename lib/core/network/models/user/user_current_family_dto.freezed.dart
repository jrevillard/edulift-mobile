// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_current_family_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserCurrentFamilyDto {
  String get id;
  String get email;
  String get name;
  String get timezone;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @JsonKey(name: 'is_biometric_enabled')
  bool get isBiometricEnabled;
  @JsonKey(name: 'family_id')
  String? get familyId;
  @JsonKey(name: 'family_name')
  String? get familyName;
  @JsonKey(name: 'user_role')
  String? get userRole;
  @JsonKey(name: 'joined_at')
  DateTime? get joinedAt;
  @JsonKey(name: 'is_active')
  bool? get isActive;

  /// Create a copy of UserCurrentFamilyDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserCurrentFamilyDtoCopyWith<UserCurrentFamilyDto> get copyWith =>
      _$UserCurrentFamilyDtoCopyWithImpl<UserCurrentFamilyDto>(
          this as UserCurrentFamilyDto, _$identity);

  /// Serializes this UserCurrentFamilyDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserCurrentFamilyDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isBiometricEnabled, isBiometricEnabled) ||
                other.isBiometricEnabled == isBiometricEnabled) &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.familyName, familyName) ||
                other.familyName == familyName) &&
            (identical(other.userRole, userRole) ||
                other.userRole == userRole) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      name,
      timezone,
      createdAt,
      updatedAt,
      isBiometricEnabled,
      familyId,
      familyName,
      userRole,
      joinedAt,
      isActive);

  @override
  String toString() {
    return 'UserCurrentFamilyDto(id: $id, email: $email, name: $name, timezone: $timezone, createdAt: $createdAt, updatedAt: $updatedAt, isBiometricEnabled: $isBiometricEnabled, familyId: $familyId, familyName: $familyName, userRole: $userRole, joinedAt: $joinedAt, isActive: $isActive)';
  }
}

/// @nodoc
abstract mixin class $UserCurrentFamilyDtoCopyWith<$Res> {
  factory $UserCurrentFamilyDtoCopyWith(UserCurrentFamilyDto value,
          $Res Function(UserCurrentFamilyDto) _then) =
      _$UserCurrentFamilyDtoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      String timezone,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'is_biometric_enabled') bool isBiometricEnabled,
      @JsonKey(name: 'family_id') String? familyId,
      @JsonKey(name: 'family_name') String? familyName,
      @JsonKey(name: 'user_role') String? userRole,
      @JsonKey(name: 'joined_at') DateTime? joinedAt,
      @JsonKey(name: 'is_active') bool? isActive});
}

/// @nodoc
class _$UserCurrentFamilyDtoCopyWithImpl<$Res>
    implements $UserCurrentFamilyDtoCopyWith<$Res> {
  _$UserCurrentFamilyDtoCopyWithImpl(this._self, this._then);

  final UserCurrentFamilyDto _self;
  final $Res Function(UserCurrentFamilyDto) _then;

  /// Create a copy of UserCurrentFamilyDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? timezone = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isBiometricEnabled = null,
    Object? familyId = freezed,
    Object? familyName = freezed,
    Object? userRole = freezed,
    Object? joinedAt = freezed,
    Object? isActive = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      timezone: null == timezone
          ? _self.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isBiometricEnabled: null == isBiometricEnabled
          ? _self.isBiometricEnabled
          : isBiometricEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      familyId: freezed == familyId
          ? _self.familyId
          : familyId // ignore: cast_nullable_to_non_nullable
              as String?,
      familyName: freezed == familyName
          ? _self.familyName
          : familyName // ignore: cast_nullable_to_non_nullable
              as String?,
      userRole: freezed == userRole
          ? _self.userRole
          : userRole // ignore: cast_nullable_to_non_nullable
              as String?,
      joinedAt: freezed == joinedAt
          ? _self.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: freezed == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// Adds pattern-matching-related methods to [UserCurrentFamilyDto].
extension UserCurrentFamilyDtoPatterns on UserCurrentFamilyDto {
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
    TResult Function(_UserCurrentFamilyDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserCurrentFamilyDto() when $default != null:
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
    TResult Function(_UserCurrentFamilyDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserCurrentFamilyDto():
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
    TResult? Function(_UserCurrentFamilyDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserCurrentFamilyDto() when $default != null:
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
            String email,
            String name,
            String timezone,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            @JsonKey(name: 'is_biometric_enabled') bool isBiometricEnabled,
            @JsonKey(name: 'family_id') String? familyId,
            @JsonKey(name: 'family_name') String? familyName,
            @JsonKey(name: 'user_role') String? userRole,
            @JsonKey(name: 'joined_at') DateTime? joinedAt,
            @JsonKey(name: 'is_active') bool? isActive)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserCurrentFamilyDto() when $default != null:
        return $default(
            _that.id,
            _that.email,
            _that.name,
            _that.timezone,
            _that.createdAt,
            _that.updatedAt,
            _that.isBiometricEnabled,
            _that.familyId,
            _that.familyName,
            _that.userRole,
            _that.joinedAt,
            _that.isActive);
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
            String email,
            String name,
            String timezone,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            @JsonKey(name: 'is_biometric_enabled') bool isBiometricEnabled,
            @JsonKey(name: 'family_id') String? familyId,
            @JsonKey(name: 'family_name') String? familyName,
            @JsonKey(name: 'user_role') String? userRole,
            @JsonKey(name: 'joined_at') DateTime? joinedAt,
            @JsonKey(name: 'is_active') bool? isActive)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserCurrentFamilyDto():
        return $default(
            _that.id,
            _that.email,
            _that.name,
            _that.timezone,
            _that.createdAt,
            _that.updatedAt,
            _that.isBiometricEnabled,
            _that.familyId,
            _that.familyName,
            _that.userRole,
            _that.joinedAt,
            _that.isActive);
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
            String email,
            String name,
            String timezone,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            @JsonKey(name: 'is_biometric_enabled') bool isBiometricEnabled,
            @JsonKey(name: 'family_id') String? familyId,
            @JsonKey(name: 'family_name') String? familyName,
            @JsonKey(name: 'user_role') String? userRole,
            @JsonKey(name: 'joined_at') DateTime? joinedAt,
            @JsonKey(name: 'is_active') bool? isActive)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserCurrentFamilyDto() when $default != null:
        return $default(
            _that.id,
            _that.email,
            _that.name,
            _that.timezone,
            _that.createdAt,
            _that.updatedAt,
            _that.isBiometricEnabled,
            _that.familyId,
            _that.familyName,
            _that.userRole,
            _that.joinedAt,
            _that.isActive);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _UserCurrentFamilyDto implements UserCurrentFamilyDto {
  const _UserCurrentFamilyDto(
      {required this.id,
      required this.email,
      required this.name,
      this.timezone = 'UTC',
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'is_biometric_enabled') this.isBiometricEnabled = false,
      @JsonKey(name: 'family_id') this.familyId,
      @JsonKey(name: 'family_name') this.familyName,
      @JsonKey(name: 'user_role') this.userRole,
      @JsonKey(name: 'joined_at') this.joinedAt,
      @JsonKey(name: 'is_active') this.isActive});
  factory _UserCurrentFamilyDto.fromJson(Map<String, dynamic> json) =>
      _$UserCurrentFamilyDtoFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String name;
  @override
  @JsonKey()
  final String timezone;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'is_biometric_enabled')
  final bool isBiometricEnabled;
  @override
  @JsonKey(name: 'family_id')
  final String? familyId;
  @override
  @JsonKey(name: 'family_name')
  final String? familyName;
  @override
  @JsonKey(name: 'user_role')
  final String? userRole;
  @override
  @JsonKey(name: 'joined_at')
  final DateTime? joinedAt;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;

  /// Create a copy of UserCurrentFamilyDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserCurrentFamilyDtoCopyWith<_UserCurrentFamilyDto> get copyWith =>
      __$UserCurrentFamilyDtoCopyWithImpl<_UserCurrentFamilyDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserCurrentFamilyDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserCurrentFamilyDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isBiometricEnabled, isBiometricEnabled) ||
                other.isBiometricEnabled == isBiometricEnabled) &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.familyName, familyName) ||
                other.familyName == familyName) &&
            (identical(other.userRole, userRole) ||
                other.userRole == userRole) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      name,
      timezone,
      createdAt,
      updatedAt,
      isBiometricEnabled,
      familyId,
      familyName,
      userRole,
      joinedAt,
      isActive);

  @override
  String toString() {
    return 'UserCurrentFamilyDto(id: $id, email: $email, name: $name, timezone: $timezone, createdAt: $createdAt, updatedAt: $updatedAt, isBiometricEnabled: $isBiometricEnabled, familyId: $familyId, familyName: $familyName, userRole: $userRole, joinedAt: $joinedAt, isActive: $isActive)';
  }
}

/// @nodoc
abstract mixin class _$UserCurrentFamilyDtoCopyWith<$Res>
    implements $UserCurrentFamilyDtoCopyWith<$Res> {
  factory _$UserCurrentFamilyDtoCopyWith(_UserCurrentFamilyDto value,
          $Res Function(_UserCurrentFamilyDto) _then) =
      __$UserCurrentFamilyDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      String timezone,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'is_biometric_enabled') bool isBiometricEnabled,
      @JsonKey(name: 'family_id') String? familyId,
      @JsonKey(name: 'family_name') String? familyName,
      @JsonKey(name: 'user_role') String? userRole,
      @JsonKey(name: 'joined_at') DateTime? joinedAt,
      @JsonKey(name: 'is_active') bool? isActive});
}

/// @nodoc
class __$UserCurrentFamilyDtoCopyWithImpl<$Res>
    implements _$UserCurrentFamilyDtoCopyWith<$Res> {
  __$UserCurrentFamilyDtoCopyWithImpl(this._self, this._then);

  final _UserCurrentFamilyDto _self;
  final $Res Function(_UserCurrentFamilyDto) _then;

  /// Create a copy of UserCurrentFamilyDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? timezone = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isBiometricEnabled = null,
    Object? familyId = freezed,
    Object? familyName = freezed,
    Object? userRole = freezed,
    Object? joinedAt = freezed,
    Object? isActive = freezed,
  }) {
    return _then(_UserCurrentFamilyDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      timezone: null == timezone
          ? _self.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isBiometricEnabled: null == isBiometricEnabled
          ? _self.isBiometricEnabled
          : isBiometricEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      familyId: freezed == familyId
          ? _self.familyId
          : familyId // ignore: cast_nullable_to_non_nullable
              as String?,
      familyName: freezed == familyName
          ? _self.familyName
          : familyName // ignore: cast_nullable_to_non_nullable
              as String?,
      userRole: freezed == userRole
          ? _self.userRole
          : userRole // ignore: cast_nullable_to_non_nullable
              as String?,
      joinedAt: freezed == joinedAt
          ? _self.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: freezed == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

// dart format on
