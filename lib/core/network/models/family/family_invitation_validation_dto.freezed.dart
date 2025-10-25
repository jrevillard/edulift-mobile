// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_invitation_validation_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FamilyInvitationValidationDto {

 bool get valid; String? get familyId; String? get familyName; String? get inviterName; String? get role; DateTime? get expiresAt; String? get error; String? get errorCode; bool? get requiresAuth; bool? get alreadyMember;
/// Create a copy of FamilyInvitationValidationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyInvitationValidationDtoCopyWith<FamilyInvitationValidationDto> get copyWith => _$FamilyInvitationValidationDtoCopyWithImpl<FamilyInvitationValidationDto>(this as FamilyInvitationValidationDto, _$identity);

  /// Serializes this FamilyInvitationValidationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyInvitationValidationDto&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.inviterName, inviterName) || other.inviterName == inviterName)&&(identical(other.role, role) || other.role == role)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.requiresAuth, requiresAuth) || other.requiresAuth == requiresAuth)&&(identical(other.alreadyMember, alreadyMember) || other.alreadyMember == alreadyMember));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,valid,familyId,familyName,inviterName,role,expiresAt,error,errorCode,requiresAuth,alreadyMember);

@override
String toString() {
  return 'FamilyInvitationValidationDto(valid: $valid, familyId: $familyId, familyName: $familyName, inviterName: $inviterName, role: $role, expiresAt: $expiresAt, error: $error, errorCode: $errorCode, requiresAuth: $requiresAuth, alreadyMember: $alreadyMember)';
}


}

/// @nodoc
abstract mixin class $FamilyInvitationValidationDtoCopyWith<$Res>  {
  factory $FamilyInvitationValidationDtoCopyWith(FamilyInvitationValidationDto value, $Res Function(FamilyInvitationValidationDto) _then) = _$FamilyInvitationValidationDtoCopyWithImpl;
@useResult
$Res call({
 bool valid, String? familyId, String? familyName, String? inviterName, String? role, DateTime? expiresAt, String? error, String? errorCode, bool? requiresAuth, bool? alreadyMember
});




}
/// @nodoc
class _$FamilyInvitationValidationDtoCopyWithImpl<$Res>
    implements $FamilyInvitationValidationDtoCopyWith<$Res> {
  _$FamilyInvitationValidationDtoCopyWithImpl(this._self, this._then);

  final FamilyInvitationValidationDto _self;
  final $Res Function(FamilyInvitationValidationDto) _then;

/// Create a copy of FamilyInvitationValidationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? valid = null,Object? familyId = freezed,Object? familyName = freezed,Object? inviterName = freezed,Object? role = freezed,Object? expiresAt = freezed,Object? error = freezed,Object? errorCode = freezed,Object? requiresAuth = freezed,Object? alreadyMember = freezed,}) {
  return _then(_self.copyWith(
valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,familyId: freezed == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String?,familyName: freezed == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String?,inviterName: freezed == inviterName ? _self.inviterName : inviterName // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,requiresAuth: freezed == requiresAuth ? _self.requiresAuth : requiresAuth // ignore: cast_nullable_to_non_nullable
as bool?,alreadyMember: freezed == alreadyMember ? _self.alreadyMember : alreadyMember // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyInvitationValidationDto].
extension FamilyInvitationValidationDtoPatterns on FamilyInvitationValidationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyInvitationValidationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyInvitationValidationDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyInvitationValidationDto value)  $default,){
final _that = this;
switch (_that) {
case _FamilyInvitationValidationDto():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyInvitationValidationDto value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyInvitationValidationDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool valid,  String? familyId,  String? familyName,  String? inviterName,  String? role,  DateTime? expiresAt,  String? error,  String? errorCode,  bool? requiresAuth,  bool? alreadyMember)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyInvitationValidationDto() when $default != null:
return $default(_that.valid,_that.familyId,_that.familyName,_that.inviterName,_that.role,_that.expiresAt,_that.error,_that.errorCode,_that.requiresAuth,_that.alreadyMember);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool valid,  String? familyId,  String? familyName,  String? inviterName,  String? role,  DateTime? expiresAt,  String? error,  String? errorCode,  bool? requiresAuth,  bool? alreadyMember)  $default,) {final _that = this;
switch (_that) {
case _FamilyInvitationValidationDto():
return $default(_that.valid,_that.familyId,_that.familyName,_that.inviterName,_that.role,_that.expiresAt,_that.error,_that.errorCode,_that.requiresAuth,_that.alreadyMember);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool valid,  String? familyId,  String? familyName,  String? inviterName,  String? role,  DateTime? expiresAt,  String? error,  String? errorCode,  bool? requiresAuth,  bool? alreadyMember)?  $default,) {final _that = this;
switch (_that) {
case _FamilyInvitationValidationDto() when $default != null:
return $default(_that.valid,_that.familyId,_that.familyName,_that.inviterName,_that.role,_that.expiresAt,_that.error,_that.errorCode,_that.requiresAuth,_that.alreadyMember);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyInvitationValidationDto implements FamilyInvitationValidationDto {
  const _FamilyInvitationValidationDto({required this.valid, this.familyId, this.familyName, this.inviterName, this.role, this.expiresAt, this.error, this.errorCode, this.requiresAuth, this.alreadyMember});
  factory _FamilyInvitationValidationDto.fromJson(Map<String, dynamic> json) => _$FamilyInvitationValidationDtoFromJson(json);

@override final  bool valid;
@override final  String? familyId;
@override final  String? familyName;
@override final  String? inviterName;
@override final  String? role;
@override final  DateTime? expiresAt;
@override final  String? error;
@override final  String? errorCode;
@override final  bool? requiresAuth;
@override final  bool? alreadyMember;

/// Create a copy of FamilyInvitationValidationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyInvitationValidationDtoCopyWith<_FamilyInvitationValidationDto> get copyWith => __$FamilyInvitationValidationDtoCopyWithImpl<_FamilyInvitationValidationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyInvitationValidationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyInvitationValidationDto&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.inviterName, inviterName) || other.inviterName == inviterName)&&(identical(other.role, role) || other.role == role)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.requiresAuth, requiresAuth) || other.requiresAuth == requiresAuth)&&(identical(other.alreadyMember, alreadyMember) || other.alreadyMember == alreadyMember));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,valid,familyId,familyName,inviterName,role,expiresAt,error,errorCode,requiresAuth,alreadyMember);

@override
String toString() {
  return 'FamilyInvitationValidationDto(valid: $valid, familyId: $familyId, familyName: $familyName, inviterName: $inviterName, role: $role, expiresAt: $expiresAt, error: $error, errorCode: $errorCode, requiresAuth: $requiresAuth, alreadyMember: $alreadyMember)';
}


}

/// @nodoc
abstract mixin class _$FamilyInvitationValidationDtoCopyWith<$Res> implements $FamilyInvitationValidationDtoCopyWith<$Res> {
  factory _$FamilyInvitationValidationDtoCopyWith(_FamilyInvitationValidationDto value, $Res Function(_FamilyInvitationValidationDto) _then) = __$FamilyInvitationValidationDtoCopyWithImpl;
@override @useResult
$Res call({
 bool valid, String? familyId, String? familyName, String? inviterName, String? role, DateTime? expiresAt, String? error, String? errorCode, bool? requiresAuth, bool? alreadyMember
});




}
/// @nodoc
class __$FamilyInvitationValidationDtoCopyWithImpl<$Res>
    implements _$FamilyInvitationValidationDtoCopyWith<$Res> {
  __$FamilyInvitationValidationDtoCopyWithImpl(this._self, this._then);

  final _FamilyInvitationValidationDto _self;
  final $Res Function(_FamilyInvitationValidationDto) _then;

/// Create a copy of FamilyInvitationValidationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? valid = null,Object? familyId = freezed,Object? familyName = freezed,Object? inviterName = freezed,Object? role = freezed,Object? expiresAt = freezed,Object? error = freezed,Object? errorCode = freezed,Object? requiresAuth = freezed,Object? alreadyMember = freezed,}) {
  return _then(_FamilyInvitationValidationDto(
valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,familyId: freezed == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String?,familyName: freezed == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String?,inviterName: freezed == inviterName ? _self.inviterName : inviterName // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,requiresAuth: freezed == requiresAuth ? _self.requiresAuth : requiresAuth // ignore: cast_nullable_to_non_nullable
as bool?,alreadyMember: freezed == alreadyMember ? _self.alreadyMember : alreadyMember // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$PermissionsDto {

 List<String> get permissions; String get role;
/// Create a copy of PermissionsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PermissionsDtoCopyWith<PermissionsDto> get copyWith => _$PermissionsDtoCopyWithImpl<PermissionsDto>(this as PermissionsDto, _$identity);

  /// Serializes this PermissionsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PermissionsDto&&const DeepCollectionEquality().equals(other.permissions, permissions)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(permissions),role);

@override
String toString() {
  return 'PermissionsDto(permissions: $permissions, role: $role)';
}


}

/// @nodoc
abstract mixin class $PermissionsDtoCopyWith<$Res>  {
  factory $PermissionsDtoCopyWith(PermissionsDto value, $Res Function(PermissionsDto) _then) = _$PermissionsDtoCopyWithImpl;
@useResult
$Res call({
 List<String> permissions, String role
});




}
/// @nodoc
class _$PermissionsDtoCopyWithImpl<$Res>
    implements $PermissionsDtoCopyWith<$Res> {
  _$PermissionsDtoCopyWithImpl(this._self, this._then);

  final PermissionsDto _self;
  final $Res Function(PermissionsDto) _then;

/// Create a copy of PermissionsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? permissions = null,Object? role = null,}) {
  return _then(_self.copyWith(
permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PermissionsDto].
extension PermissionsDtoPatterns on PermissionsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PermissionsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PermissionsDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PermissionsDto value)  $default,){
final _that = this;
switch (_that) {
case _PermissionsDto():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PermissionsDto value)?  $default,){
final _that = this;
switch (_that) {
case _PermissionsDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> permissions,  String role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PermissionsDto() when $default != null:
return $default(_that.permissions,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> permissions,  String role)  $default,) {final _that = this;
switch (_that) {
case _PermissionsDto():
return $default(_that.permissions,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> permissions,  String role)?  $default,) {final _that = this;
switch (_that) {
case _PermissionsDto() when $default != null:
return $default(_that.permissions,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PermissionsDto implements PermissionsDto {
  const _PermissionsDto({required final  List<String> permissions, required this.role}): _permissions = permissions;
  factory _PermissionsDto.fromJson(Map<String, dynamic> json) => _$PermissionsDtoFromJson(json);

 final  List<String> _permissions;
@override List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}

@override final  String role;

/// Create a copy of PermissionsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PermissionsDtoCopyWith<_PermissionsDto> get copyWith => __$PermissionsDtoCopyWithImpl<_PermissionsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PermissionsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PermissionsDto&&const DeepCollectionEquality().equals(other._permissions, _permissions)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_permissions),role);

@override
String toString() {
  return 'PermissionsDto(permissions: $permissions, role: $role)';
}


}

/// @nodoc
abstract mixin class _$PermissionsDtoCopyWith<$Res> implements $PermissionsDtoCopyWith<$Res> {
  factory _$PermissionsDtoCopyWith(_PermissionsDto value, $Res Function(_PermissionsDto) _then) = __$PermissionsDtoCopyWithImpl;
@override @useResult
$Res call({
 List<String> permissions, String role
});




}
/// @nodoc
class __$PermissionsDtoCopyWithImpl<$Res>
    implements _$PermissionsDtoCopyWith<$Res> {
  __$PermissionsDtoCopyWithImpl(this._self, this._then);

  final _PermissionsDto _self;
  final $Res Function(_PermissionsDto) _then;

/// Create a copy of PermissionsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? permissions = null,Object? role = null,}) {
  return _then(_PermissionsDto(
permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
