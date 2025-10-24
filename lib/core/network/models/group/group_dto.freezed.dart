// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupDto {

 String get id; String get name; String? get description; String get familyId;@JsonKey(name: 'invite_code') String? get inviteCode; String get createdAt; String get updatedAt; String? get userRole; String? get joinedAt; Map<String, dynamic>? get ownerFamily; int? get familyCount; int? get scheduleCount;
/// Create a copy of GroupDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupDtoCopyWith<GroupDto> get copyWith => _$GroupDtoCopyWithImpl<GroupDto>(this as GroupDto, _$identity);

  /// Serializes this GroupDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.userRole, userRole) || other.userRole == userRole)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&const DeepCollectionEquality().equals(other.ownerFamily, ownerFamily)&&(identical(other.familyCount, familyCount) || other.familyCount == familyCount)&&(identical(other.scheduleCount, scheduleCount) || other.scheduleCount == scheduleCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,familyId,inviteCode,createdAt,updatedAt,userRole,joinedAt,const DeepCollectionEquality().hash(ownerFamily),familyCount,scheduleCount);

@override
String toString() {
  return 'GroupDto(id: $id, name: $name, description: $description, familyId: $familyId, inviteCode: $inviteCode, createdAt: $createdAt, updatedAt: $updatedAt, userRole: $userRole, joinedAt: $joinedAt, ownerFamily: $ownerFamily, familyCount: $familyCount, scheduleCount: $scheduleCount)';
}


}

/// @nodoc
abstract mixin class $GroupDtoCopyWith<$Res>  {
  factory $GroupDtoCopyWith(GroupDto value, $Res Function(GroupDto) _then) = _$GroupDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String familyId,@JsonKey(name: 'invite_code') String? inviteCode, String createdAt, String updatedAt, String? userRole, String? joinedAt, Map<String, dynamic>? ownerFamily, int? familyCount, int? scheduleCount
});




}
/// @nodoc
class _$GroupDtoCopyWithImpl<$Res>
    implements $GroupDtoCopyWith<$Res> {
  _$GroupDtoCopyWithImpl(this._self, this._then);

  final GroupDto _self;
  final $Res Function(GroupDto) _then;

/// Create a copy of GroupDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? familyId = null,Object? inviteCode = freezed,Object? createdAt = null,Object? updatedAt = null,Object? userRole = freezed,Object? joinedAt = freezed,Object? ownerFamily = freezed,Object? familyCount = freezed,Object? scheduleCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,familyId: null == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,userRole: freezed == userRole ? _self.userRole : userRole // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String?,ownerFamily: freezed == ownerFamily ? _self.ownerFamily : ownerFamily // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,familyCount: freezed == familyCount ? _self.familyCount : familyCount // ignore: cast_nullable_to_non_nullable
as int?,scheduleCount: freezed == scheduleCount ? _self.scheduleCount : scheduleCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupDto].
extension GroupDtoPatterns on GroupDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupDto value)  $default,){
final _that = this;
switch (_that) {
case _GroupDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupDto value)?  $default,){
final _that = this;
switch (_that) {
case _GroupDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String familyId, @JsonKey(name: 'invite_code')  String? inviteCode,  String createdAt,  String updatedAt,  String? userRole,  String? joinedAt,  Map<String, dynamic>? ownerFamily,  int? familyCount,  int? scheduleCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.familyId,_that.inviteCode,_that.createdAt,_that.updatedAt,_that.userRole,_that.joinedAt,_that.ownerFamily,_that.familyCount,_that.scheduleCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String familyId, @JsonKey(name: 'invite_code')  String? inviteCode,  String createdAt,  String updatedAt,  String? userRole,  String? joinedAt,  Map<String, dynamic>? ownerFamily,  int? familyCount,  int? scheduleCount)  $default,) {final _that = this;
switch (_that) {
case _GroupDto():
return $default(_that.id,_that.name,_that.description,_that.familyId,_that.inviteCode,_that.createdAt,_that.updatedAt,_that.userRole,_that.joinedAt,_that.ownerFamily,_that.familyCount,_that.scheduleCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String familyId, @JsonKey(name: 'invite_code')  String? inviteCode,  String createdAt,  String updatedAt,  String? userRole,  String? joinedAt,  Map<String, dynamic>? ownerFamily,  int? familyCount,  int? scheduleCount)?  $default,) {final _that = this;
switch (_that) {
case _GroupDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.familyId,_that.inviteCode,_that.createdAt,_that.updatedAt,_that.userRole,_that.joinedAt,_that.ownerFamily,_that.familyCount,_that.scheduleCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupDto extends GroupDto {
  const _GroupDto({required this.id, required this.name, this.description, required this.familyId, @JsonKey(name: 'invite_code') this.inviteCode, required this.createdAt, required this.updatedAt, this.userRole, this.joinedAt, final  Map<String, dynamic>? ownerFamily, this.familyCount, this.scheduleCount}): _ownerFamily = ownerFamily,super._();
  factory _GroupDto.fromJson(Map<String, dynamic> json) => _$GroupDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String familyId;
@override@JsonKey(name: 'invite_code') final  String? inviteCode;
@override final  String createdAt;
@override final  String updatedAt;
@override final  String? userRole;
@override final  String? joinedAt;
 final  Map<String, dynamic>? _ownerFamily;
@override Map<String, dynamic>? get ownerFamily {
  final value = _ownerFamily;
  if (value == null) return null;
  if (_ownerFamily is EqualUnmodifiableMapView) return _ownerFamily;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  int? familyCount;
@override final  int? scheduleCount;

/// Create a copy of GroupDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupDtoCopyWith<_GroupDto> get copyWith => __$GroupDtoCopyWithImpl<_GroupDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.userRole, userRole) || other.userRole == userRole)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&const DeepCollectionEquality().equals(other._ownerFamily, _ownerFamily)&&(identical(other.familyCount, familyCount) || other.familyCount == familyCount)&&(identical(other.scheduleCount, scheduleCount) || other.scheduleCount == scheduleCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,familyId,inviteCode,createdAt,updatedAt,userRole,joinedAt,const DeepCollectionEquality().hash(_ownerFamily),familyCount,scheduleCount);

@override
String toString() {
  return 'GroupDto(id: $id, name: $name, description: $description, familyId: $familyId, inviteCode: $inviteCode, createdAt: $createdAt, updatedAt: $updatedAt, userRole: $userRole, joinedAt: $joinedAt, ownerFamily: $ownerFamily, familyCount: $familyCount, scheduleCount: $scheduleCount)';
}


}

/// @nodoc
abstract mixin class _$GroupDtoCopyWith<$Res> implements $GroupDtoCopyWith<$Res> {
  factory _$GroupDtoCopyWith(_GroupDto value, $Res Function(_GroupDto) _then) = __$GroupDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String familyId,@JsonKey(name: 'invite_code') String? inviteCode, String createdAt, String updatedAt, String? userRole, String? joinedAt, Map<String, dynamic>? ownerFamily, int? familyCount, int? scheduleCount
});




}
/// @nodoc
class __$GroupDtoCopyWithImpl<$Res>
    implements _$GroupDtoCopyWith<$Res> {
  __$GroupDtoCopyWithImpl(this._self, this._then);

  final _GroupDto _self;
  final $Res Function(_GroupDto) _then;

/// Create a copy of GroupDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? familyId = null,Object? inviteCode = freezed,Object? createdAt = null,Object? updatedAt = null,Object? userRole = freezed,Object? joinedAt = freezed,Object? ownerFamily = freezed,Object? familyCount = freezed,Object? scheduleCount = freezed,}) {
  return _then(_GroupDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,familyId: null == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,userRole: freezed == userRole ? _self.userRole : userRole // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String?,ownerFamily: freezed == ownerFamily ? _self._ownerFamily : ownerFamily // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,familyCount: freezed == familyCount ? _self.familyCount : familyCount // ignore: cast_nullable_to_non_nullable
as int?,scheduleCount: freezed == scheduleCount ? _self.scheduleCount : scheduleCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
