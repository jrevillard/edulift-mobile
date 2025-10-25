// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_invitation_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvitedByUser {

 String get id; String get name; String get email;
/// Create a copy of InvitedByUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitedByUserCopyWith<InvitedByUser> get copyWith => _$InvitedByUserCopyWithImpl<InvitedByUser>(this as InvitedByUser, _$identity);

  /// Serializes this InvitedByUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitedByUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email);

@override
String toString() {
  return 'InvitedByUser(id: $id, name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class $InvitedByUserCopyWith<$Res>  {
  factory $InvitedByUserCopyWith(InvitedByUser value, $Res Function(InvitedByUser) _then) = _$InvitedByUserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email
});




}
/// @nodoc
class _$InvitedByUserCopyWithImpl<$Res>
    implements $InvitedByUserCopyWith<$Res> {
  _$InvitedByUserCopyWithImpl(this._self, this._then);

  final InvitedByUser _self;
  final $Res Function(InvitedByUser) _then;

/// Create a copy of InvitedByUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [InvitedByUser].
extension InvitedByUserPatterns on InvitedByUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvitedByUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvitedByUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvitedByUser value)  $default,){
final _that = this;
switch (_that) {
case _InvitedByUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvitedByUser value)?  $default,){
final _that = this;
switch (_that) {
case _InvitedByUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvitedByUser() when $default != null:
return $default(_that.id,_that.name,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email)  $default,) {final _that = this;
switch (_that) {
case _InvitedByUser():
return $default(_that.id,_that.name,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email)?  $default,) {final _that = this;
switch (_that) {
case _InvitedByUser() when $default != null:
return $default(_that.id,_that.name,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvitedByUser implements InvitedByUser {
  const _InvitedByUser({required this.id, required this.name, required this.email});
  factory _InvitedByUser.fromJson(Map<String, dynamic> json) => _$InvitedByUserFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;

/// Create a copy of InvitedByUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitedByUserCopyWith<_InvitedByUser> get copyWith => __$InvitedByUserCopyWithImpl<_InvitedByUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvitedByUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvitedByUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email);

@override
String toString() {
  return 'InvitedByUser(id: $id, name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class _$InvitedByUserCopyWith<$Res> implements $InvitedByUserCopyWith<$Res> {
  factory _$InvitedByUserCopyWith(_InvitedByUser value, $Res Function(_InvitedByUser) _then) = __$InvitedByUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email
});




}
/// @nodoc
class __$InvitedByUserCopyWithImpl<$Res>
    implements _$InvitedByUserCopyWith<$Res> {
  __$InvitedByUserCopyWithImpl(this._self, this._then);

  final _InvitedByUser _self;
  final $Res Function(_InvitedByUser) _then;

/// Create a copy of InvitedByUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,}) {
  return _then(_InvitedByUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FamilyInvitationDto {

 String get id; String get familyId; String? get email;// Nullable as per backend schema
 String get role; String? get personalMessage; String get invitedBy; String get createdBy; String? get acceptedBy; String get status; String get inviteCode; DateTime get expiresAt; DateTime? get acceptedAt; DateTime get createdAt; DateTime get updatedAt; InvitedByUser get invitedByUser;
/// Create a copy of FamilyInvitationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyInvitationDtoCopyWith<FamilyInvitationDto> get copyWith => _$FamilyInvitationDtoCopyWithImpl<FamilyInvitationDto>(this as FamilyInvitationDto, _$identity);

  /// Serializes this FamilyInvitationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyInvitationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.personalMessage, personalMessage) || other.personalMessage == personalMessage)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.acceptedBy, acceptedBy) || other.acceptedBy == acceptedBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.invitedByUser, invitedByUser) || other.invitedByUser == invitedByUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,familyId,email,role,personalMessage,invitedBy,createdBy,acceptedBy,status,inviteCode,expiresAt,acceptedAt,createdAt,updatedAt,invitedByUser);

@override
String toString() {
  return 'FamilyInvitationDto(id: $id, familyId: $familyId, email: $email, role: $role, personalMessage: $personalMessage, invitedBy: $invitedBy, createdBy: $createdBy, acceptedBy: $acceptedBy, status: $status, inviteCode: $inviteCode, expiresAt: $expiresAt, acceptedAt: $acceptedAt, createdAt: $createdAt, updatedAt: $updatedAt, invitedByUser: $invitedByUser)';
}


}

/// @nodoc
abstract mixin class $FamilyInvitationDtoCopyWith<$Res>  {
  factory $FamilyInvitationDtoCopyWith(FamilyInvitationDto value, $Res Function(FamilyInvitationDto) _then) = _$FamilyInvitationDtoCopyWithImpl;
@useResult
$Res call({
 String id, String familyId, String? email, String role, String? personalMessage, String invitedBy, String createdBy, String? acceptedBy, String status, String inviteCode, DateTime expiresAt, DateTime? acceptedAt, DateTime createdAt, DateTime updatedAt, InvitedByUser invitedByUser
});


$InvitedByUserCopyWith<$Res> get invitedByUser;

}
/// @nodoc
class _$FamilyInvitationDtoCopyWithImpl<$Res>
    implements $FamilyInvitationDtoCopyWith<$Res> {
  _$FamilyInvitationDtoCopyWithImpl(this._self, this._then);

  final FamilyInvitationDto _self;
  final $Res Function(FamilyInvitationDto) _then;

/// Create a copy of FamilyInvitationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? familyId = null,Object? email = freezed,Object? role = null,Object? personalMessage = freezed,Object? invitedBy = null,Object? createdBy = null,Object? acceptedBy = freezed,Object? status = null,Object? inviteCode = null,Object? expiresAt = null,Object? acceptedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? invitedByUser = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,familyId: null == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,personalMessage: freezed == personalMessage ? _self.personalMessage : personalMessage // ignore: cast_nullable_to_non_nullable
as String?,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,acceptedBy: freezed == acceptedBy ? _self.acceptedBy : acceptedBy // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,invitedByUser: null == invitedByUser ? _self.invitedByUser : invitedByUser // ignore: cast_nullable_to_non_nullable
as InvitedByUser,
  ));
}
/// Create a copy of FamilyInvitationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InvitedByUserCopyWith<$Res> get invitedByUser {
  
  return $InvitedByUserCopyWith<$Res>(_self.invitedByUser, (value) {
    return _then(_self.copyWith(invitedByUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [FamilyInvitationDto].
extension FamilyInvitationDtoPatterns on FamilyInvitationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyInvitationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyInvitationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyInvitationDto value)  $default,){
final _that = this;
switch (_that) {
case _FamilyInvitationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyInvitationDto value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyInvitationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String familyId,  String? email,  String role,  String? personalMessage,  String invitedBy,  String createdBy,  String? acceptedBy,  String status,  String inviteCode,  DateTime expiresAt,  DateTime? acceptedAt,  DateTime createdAt,  DateTime updatedAt,  InvitedByUser invitedByUser)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyInvitationDto() when $default != null:
return $default(_that.id,_that.familyId,_that.email,_that.role,_that.personalMessage,_that.invitedBy,_that.createdBy,_that.acceptedBy,_that.status,_that.inviteCode,_that.expiresAt,_that.acceptedAt,_that.createdAt,_that.updatedAt,_that.invitedByUser);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String familyId,  String? email,  String role,  String? personalMessage,  String invitedBy,  String createdBy,  String? acceptedBy,  String status,  String inviteCode,  DateTime expiresAt,  DateTime? acceptedAt,  DateTime createdAt,  DateTime updatedAt,  InvitedByUser invitedByUser)  $default,) {final _that = this;
switch (_that) {
case _FamilyInvitationDto():
return $default(_that.id,_that.familyId,_that.email,_that.role,_that.personalMessage,_that.invitedBy,_that.createdBy,_that.acceptedBy,_that.status,_that.inviteCode,_that.expiresAt,_that.acceptedAt,_that.createdAt,_that.updatedAt,_that.invitedByUser);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String familyId,  String? email,  String role,  String? personalMessage,  String invitedBy,  String createdBy,  String? acceptedBy,  String status,  String inviteCode,  DateTime expiresAt,  DateTime? acceptedAt,  DateTime createdAt,  DateTime updatedAt,  InvitedByUser invitedByUser)?  $default,) {final _that = this;
switch (_that) {
case _FamilyInvitationDto() when $default != null:
return $default(_that.id,_that.familyId,_that.email,_that.role,_that.personalMessage,_that.invitedBy,_that.createdBy,_that.acceptedBy,_that.status,_that.inviteCode,_that.expiresAt,_that.acceptedAt,_that.createdAt,_that.updatedAt,_that.invitedByUser);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyInvitationDto extends FamilyInvitationDto {
  const _FamilyInvitationDto({required this.id, required this.familyId, this.email, required this.role, this.personalMessage, required this.invitedBy, required this.createdBy, this.acceptedBy, required this.status, required this.inviteCode, required this.expiresAt, this.acceptedAt, required this.createdAt, required this.updatedAt, required this.invitedByUser}): super._();
  factory _FamilyInvitationDto.fromJson(Map<String, dynamic> json) => _$FamilyInvitationDtoFromJson(json);

@override final  String id;
@override final  String familyId;
@override final  String? email;
// Nullable as per backend schema
@override final  String role;
@override final  String? personalMessage;
@override final  String invitedBy;
@override final  String createdBy;
@override final  String? acceptedBy;
@override final  String status;
@override final  String inviteCode;
@override final  DateTime expiresAt;
@override final  DateTime? acceptedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  InvitedByUser invitedByUser;

/// Create a copy of FamilyInvitationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyInvitationDtoCopyWith<_FamilyInvitationDto> get copyWith => __$FamilyInvitationDtoCopyWithImpl<_FamilyInvitationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyInvitationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyInvitationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.personalMessage, personalMessage) || other.personalMessage == personalMessage)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.acceptedBy, acceptedBy) || other.acceptedBy == acceptedBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.invitedByUser, invitedByUser) || other.invitedByUser == invitedByUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,familyId,email,role,personalMessage,invitedBy,createdBy,acceptedBy,status,inviteCode,expiresAt,acceptedAt,createdAt,updatedAt,invitedByUser);

@override
String toString() {
  return 'FamilyInvitationDto(id: $id, familyId: $familyId, email: $email, role: $role, personalMessage: $personalMessage, invitedBy: $invitedBy, createdBy: $createdBy, acceptedBy: $acceptedBy, status: $status, inviteCode: $inviteCode, expiresAt: $expiresAt, acceptedAt: $acceptedAt, createdAt: $createdAt, updatedAt: $updatedAt, invitedByUser: $invitedByUser)';
}


}

/// @nodoc
abstract mixin class _$FamilyInvitationDtoCopyWith<$Res> implements $FamilyInvitationDtoCopyWith<$Res> {
  factory _$FamilyInvitationDtoCopyWith(_FamilyInvitationDto value, $Res Function(_FamilyInvitationDto) _then) = __$FamilyInvitationDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String familyId, String? email, String role, String? personalMessage, String invitedBy, String createdBy, String? acceptedBy, String status, String inviteCode, DateTime expiresAt, DateTime? acceptedAt, DateTime createdAt, DateTime updatedAt, InvitedByUser invitedByUser
});


@override $InvitedByUserCopyWith<$Res> get invitedByUser;

}
/// @nodoc
class __$FamilyInvitationDtoCopyWithImpl<$Res>
    implements _$FamilyInvitationDtoCopyWith<$Res> {
  __$FamilyInvitationDtoCopyWithImpl(this._self, this._then);

  final _FamilyInvitationDto _self;
  final $Res Function(_FamilyInvitationDto) _then;

/// Create a copy of FamilyInvitationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? familyId = null,Object? email = freezed,Object? role = null,Object? personalMessage = freezed,Object? invitedBy = null,Object? createdBy = null,Object? acceptedBy = freezed,Object? status = null,Object? inviteCode = null,Object? expiresAt = null,Object? acceptedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? invitedByUser = null,}) {
  return _then(_FamilyInvitationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,familyId: null == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,personalMessage: freezed == personalMessage ? _self.personalMessage : personalMessage // ignore: cast_nullable_to_non_nullable
as String?,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,acceptedBy: freezed == acceptedBy ? _self.acceptedBy : acceptedBy // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,invitedByUser: null == invitedByUser ? _self.invitedByUser : invitedByUser // ignore: cast_nullable_to_non_nullable
as InvitedByUser,
  ));
}

/// Create a copy of FamilyInvitationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InvitedByUserCopyWith<$Res> get invitedByUser {
  
  return $InvitedByUserCopyWith<$Res>(_self.invitedByUser, (value) {
    return _then(_self.copyWith(invitedByUser: value));
  });
}
}

// dart format on
