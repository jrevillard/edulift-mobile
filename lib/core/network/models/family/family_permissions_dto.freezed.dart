// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_permissions_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FamilyPermissionsDto {
  String get id;
  String get familyId;
  String get userId;
  bool get canManageFamily;
  bool get canInviteMembers;
  bool get canManageMembers;
  bool get canManageChildren;
  bool get canManageVehicles;
  bool get canManageSchedule;
  bool get canViewReports;
  bool get isAdmin;
  String get role;
  DateTime get createdAt;
  DateTime get updatedAt;

  /// Create a copy of FamilyPermissionsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FamilyPermissionsDtoCopyWith<FamilyPermissionsDto> get copyWith =>
      _$FamilyPermissionsDtoCopyWithImpl<FamilyPermissionsDto>(
          this as FamilyPermissionsDto, _$identity);

  /// Serializes this FamilyPermissionsDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FamilyPermissionsDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.canManageFamily, canManageFamily) ||
                other.canManageFamily == canManageFamily) &&
            (identical(other.canInviteMembers, canInviteMembers) ||
                other.canInviteMembers == canInviteMembers) &&
            (identical(other.canManageMembers, canManageMembers) ||
                other.canManageMembers == canManageMembers) &&
            (identical(other.canManageChildren, canManageChildren) ||
                other.canManageChildren == canManageChildren) &&
            (identical(other.canManageVehicles, canManageVehicles) ||
                other.canManageVehicles == canManageVehicles) &&
            (identical(other.canManageSchedule, canManageSchedule) ||
                other.canManageSchedule == canManageSchedule) &&
            (identical(other.canViewReports, canViewReports) ||
                other.canViewReports == canViewReports) &&
            (identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin) &&
            (identical(other.role, role) || other.role == role) &&
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
      familyId,
      userId,
      canManageFamily,
      canInviteMembers,
      canManageMembers,
      canManageChildren,
      canManageVehicles,
      canManageSchedule,
      canViewReports,
      isAdmin,
      role,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'FamilyPermissionsDto(id: $id, familyId: $familyId, userId: $userId, canManageFamily: $canManageFamily, canInviteMembers: $canInviteMembers, canManageMembers: $canManageMembers, canManageChildren: $canManageChildren, canManageVehicles: $canManageVehicles, canManageSchedule: $canManageSchedule, canViewReports: $canViewReports, isAdmin: $isAdmin, role: $role, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $FamilyPermissionsDtoCopyWith<$Res> {
  factory $FamilyPermissionsDtoCopyWith(FamilyPermissionsDto value,
          $Res Function(FamilyPermissionsDto) _then) =
      _$FamilyPermissionsDtoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String familyId,
      String userId,
      bool canManageFamily,
      bool canInviteMembers,
      bool canManageMembers,
      bool canManageChildren,
      bool canManageVehicles,
      bool canManageSchedule,
      bool canViewReports,
      bool isAdmin,
      String role,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$FamilyPermissionsDtoCopyWithImpl<$Res>
    implements $FamilyPermissionsDtoCopyWith<$Res> {
  _$FamilyPermissionsDtoCopyWithImpl(this._self, this._then);

  final FamilyPermissionsDto _self;
  final $Res Function(FamilyPermissionsDto) _then;

  /// Create a copy of FamilyPermissionsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? familyId = null,
    Object? userId = null,
    Object? canManageFamily = null,
    Object? canInviteMembers = null,
    Object? canManageMembers = null,
    Object? canManageChildren = null,
    Object? canManageVehicles = null,
    Object? canManageSchedule = null,
    Object? canViewReports = null,
    Object? isAdmin = null,
    Object? role = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      familyId: null == familyId
          ? _self.familyId
          : familyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      canManageFamily: null == canManageFamily
          ? _self.canManageFamily
          : canManageFamily // ignore: cast_nullable_to_non_nullable
              as bool,
      canInviteMembers: null == canInviteMembers
          ? _self.canInviteMembers
          : canInviteMembers // ignore: cast_nullable_to_non_nullable
              as bool,
      canManageMembers: null == canManageMembers
          ? _self.canManageMembers
          : canManageMembers // ignore: cast_nullable_to_non_nullable
              as bool,
      canManageChildren: null == canManageChildren
          ? _self.canManageChildren
          : canManageChildren // ignore: cast_nullable_to_non_nullable
              as bool,
      canManageVehicles: null == canManageVehicles
          ? _self.canManageVehicles
          : canManageVehicles // ignore: cast_nullable_to_non_nullable
              as bool,
      canManageSchedule: null == canManageSchedule
          ? _self.canManageSchedule
          : canManageSchedule // ignore: cast_nullable_to_non_nullable
              as bool,
      canViewReports: null == canViewReports
          ? _self.canViewReports
          : canViewReports // ignore: cast_nullable_to_non_nullable
              as bool,
      isAdmin: null == isAdmin
          ? _self.isAdmin
          : isAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [FamilyPermissionsDto].
extension FamilyPermissionsDtoPatterns on FamilyPermissionsDto {
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
    TResult Function(_FamilyPermissionsDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FamilyPermissionsDto() when $default != null:
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
    TResult Function(_FamilyPermissionsDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FamilyPermissionsDto():
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
    TResult? Function(_FamilyPermissionsDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FamilyPermissionsDto() when $default != null:
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
            String familyId,
            String userId,
            bool canManageFamily,
            bool canInviteMembers,
            bool canManageMembers,
            bool canManageChildren,
            bool canManageVehicles,
            bool canManageSchedule,
            bool canViewReports,
            bool isAdmin,
            String role,
            DateTime createdAt,
            DateTime updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FamilyPermissionsDto() when $default != null:
        return $default(
            _that.id,
            _that.familyId,
            _that.userId,
            _that.canManageFamily,
            _that.canInviteMembers,
            _that.canManageMembers,
            _that.canManageChildren,
            _that.canManageVehicles,
            _that.canManageSchedule,
            _that.canViewReports,
            _that.isAdmin,
            _that.role,
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
            String familyId,
            String userId,
            bool canManageFamily,
            bool canInviteMembers,
            bool canManageMembers,
            bool canManageChildren,
            bool canManageVehicles,
            bool canManageSchedule,
            bool canViewReports,
            bool isAdmin,
            String role,
            DateTime createdAt,
            DateTime updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FamilyPermissionsDto():
        return $default(
            _that.id,
            _that.familyId,
            _that.userId,
            _that.canManageFamily,
            _that.canInviteMembers,
            _that.canManageMembers,
            _that.canManageChildren,
            _that.canManageVehicles,
            _that.canManageSchedule,
            _that.canViewReports,
            _that.isAdmin,
            _that.role,
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
            String familyId,
            String userId,
            bool canManageFamily,
            bool canInviteMembers,
            bool canManageMembers,
            bool canManageChildren,
            bool canManageVehicles,
            bool canManageSchedule,
            bool canViewReports,
            bool isAdmin,
            String role,
            DateTime createdAt,
            DateTime updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FamilyPermissionsDto() when $default != null:
        return $default(
            _that.id,
            _that.familyId,
            _that.userId,
            _that.canManageFamily,
            _that.canInviteMembers,
            _that.canManageMembers,
            _that.canManageChildren,
            _that.canManageVehicles,
            _that.canManageSchedule,
            _that.canViewReports,
            _that.isAdmin,
            _that.role,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _FamilyPermissionsDto extends FamilyPermissionsDto {
  const _FamilyPermissionsDto(
      {required this.id,
      required this.familyId,
      required this.userId,
      required this.canManageFamily,
      required this.canInviteMembers,
      required this.canManageMembers,
      required this.canManageChildren,
      required this.canManageVehicles,
      required this.canManageSchedule,
      required this.canViewReports,
      required this.isAdmin,
      required this.role,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  factory _FamilyPermissionsDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyPermissionsDtoFromJson(json);

  @override
  final String id;
  @override
  final String familyId;
  @override
  final String userId;
  @override
  final bool canManageFamily;
  @override
  final bool canInviteMembers;
  @override
  final bool canManageMembers;
  @override
  final bool canManageChildren;
  @override
  final bool canManageVehicles;
  @override
  final bool canManageSchedule;
  @override
  final bool canViewReports;
  @override
  final bool isAdmin;
  @override
  final String role;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  /// Create a copy of FamilyPermissionsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FamilyPermissionsDtoCopyWith<_FamilyPermissionsDto> get copyWith =>
      __$FamilyPermissionsDtoCopyWithImpl<_FamilyPermissionsDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$FamilyPermissionsDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FamilyPermissionsDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.canManageFamily, canManageFamily) ||
                other.canManageFamily == canManageFamily) &&
            (identical(other.canInviteMembers, canInviteMembers) ||
                other.canInviteMembers == canInviteMembers) &&
            (identical(other.canManageMembers, canManageMembers) ||
                other.canManageMembers == canManageMembers) &&
            (identical(other.canManageChildren, canManageChildren) ||
                other.canManageChildren == canManageChildren) &&
            (identical(other.canManageVehicles, canManageVehicles) ||
                other.canManageVehicles == canManageVehicles) &&
            (identical(other.canManageSchedule, canManageSchedule) ||
                other.canManageSchedule == canManageSchedule) &&
            (identical(other.canViewReports, canViewReports) ||
                other.canViewReports == canViewReports) &&
            (identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin) &&
            (identical(other.role, role) || other.role == role) &&
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
      familyId,
      userId,
      canManageFamily,
      canInviteMembers,
      canManageMembers,
      canManageChildren,
      canManageVehicles,
      canManageSchedule,
      canViewReports,
      isAdmin,
      role,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'FamilyPermissionsDto(id: $id, familyId: $familyId, userId: $userId, canManageFamily: $canManageFamily, canInviteMembers: $canInviteMembers, canManageMembers: $canManageMembers, canManageChildren: $canManageChildren, canManageVehicles: $canManageVehicles, canManageSchedule: $canManageSchedule, canViewReports: $canViewReports, isAdmin: $isAdmin, role: $role, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$FamilyPermissionsDtoCopyWith<$Res>
    implements $FamilyPermissionsDtoCopyWith<$Res> {
  factory _$FamilyPermissionsDtoCopyWith(_FamilyPermissionsDto value,
          $Res Function(_FamilyPermissionsDto) _then) =
      __$FamilyPermissionsDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String familyId,
      String userId,
      bool canManageFamily,
      bool canInviteMembers,
      bool canManageMembers,
      bool canManageChildren,
      bool canManageVehicles,
      bool canManageSchedule,
      bool canViewReports,
      bool isAdmin,
      String role,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$FamilyPermissionsDtoCopyWithImpl<$Res>
    implements _$FamilyPermissionsDtoCopyWith<$Res> {
  __$FamilyPermissionsDtoCopyWithImpl(this._self, this._then);

  final _FamilyPermissionsDto _self;
  final $Res Function(_FamilyPermissionsDto) _then;

  /// Create a copy of FamilyPermissionsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? familyId = null,
    Object? userId = null,
    Object? canManageFamily = null,
    Object? canInviteMembers = null,
    Object? canManageMembers = null,
    Object? canManageChildren = null,
    Object? canManageVehicles = null,
    Object? canManageSchedule = null,
    Object? canViewReports = null,
    Object? isAdmin = null,
    Object? role = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_FamilyPermissionsDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      familyId: null == familyId
          ? _self.familyId
          : familyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      canManageFamily: null == canManageFamily
          ? _self.canManageFamily
          : canManageFamily // ignore: cast_nullable_to_non_nullable
              as bool,
      canInviteMembers: null == canInviteMembers
          ? _self.canInviteMembers
          : canInviteMembers // ignore: cast_nullable_to_non_nullable
              as bool,
      canManageMembers: null == canManageMembers
          ? _self.canManageMembers
          : canManageMembers // ignore: cast_nullable_to_non_nullable
              as bool,
      canManageChildren: null == canManageChildren
          ? _self.canManageChildren
          : canManageChildren // ignore: cast_nullable_to_non_nullable
              as bool,
      canManageVehicles: null == canManageVehicles
          ? _self.canManageVehicles
          : canManageVehicles // ignore: cast_nullable_to_non_nullable
              as bool,
      canManageSchedule: null == canManageSchedule
          ? _self.canManageSchedule
          : canManageSchedule // ignore: cast_nullable_to_non_nullable
              as bool,
      canViewReports: null == canViewReports
          ? _self.canViewReports
          : canViewReports // ignore: cast_nullable_to_non_nullable
              as bool,
      isAdmin: null == isAdmin
          ? _self.isAdmin
          : isAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
