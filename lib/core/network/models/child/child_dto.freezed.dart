// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChildDto {

 String? get id; String? get name; String? get familyId; int? get age; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of ChildDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildDtoCopyWith<ChildDto> get copyWith => _$ChildDtoCopyWithImpl<ChildDto>(this as ChildDto, _$identity);

  /// Serializes this ChildDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.age, age) || other.age == age)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,familyId,age,createdAt,updatedAt);

@override
String toString() {
  return 'ChildDto(id: $id, name: $name, familyId: $familyId, age: $age, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ChildDtoCopyWith<$Res>  {
  factory $ChildDtoCopyWith(ChildDto value, $Res Function(ChildDto) _then) = _$ChildDtoCopyWithImpl;
@useResult
$Res call({
 String? id, String? name, String? familyId, int? age, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ChildDtoCopyWithImpl<$Res>
    implements $ChildDtoCopyWith<$Res> {
  _$ChildDtoCopyWithImpl(this._self, this._then);

  final ChildDto _self;
  final $Res Function(ChildDto) _then;

/// Create a copy of ChildDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? familyId = freezed,Object? age = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,familyId: freezed == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChildDto].
extension ChildDtoPatterns on ChildDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChildDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChildDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChildDto value)  $default,){
final _that = this;
switch (_that) {
case _ChildDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChildDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChildDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? name,  String? familyId,  int? age,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChildDto() when $default != null:
return $default(_that.id,_that.name,_that.familyId,_that.age,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? name,  String? familyId,  int? age,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ChildDto():
return $default(_that.id,_that.name,_that.familyId,_that.age,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? name,  String? familyId,  int? age,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChildDto() when $default != null:
return $default(_that.id,_that.name,_that.familyId,_that.age,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChildDto extends ChildDto {
  const _ChildDto({this.id, this.name, this.familyId, this.age, this.createdAt, this.updatedAt}): super._();
  factory _ChildDto.fromJson(Map<String, dynamic> json) => _$ChildDtoFromJson(json);

@override final  String? id;
@override final  String? name;
@override final  String? familyId;
@override final  int? age;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of ChildDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChildDtoCopyWith<_ChildDto> get copyWith => __$ChildDtoCopyWithImpl<_ChildDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChildDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChildDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.age, age) || other.age == age)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,familyId,age,createdAt,updatedAt);

@override
String toString() {
  return 'ChildDto(id: $id, name: $name, familyId: $familyId, age: $age, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChildDtoCopyWith<$Res> implements $ChildDtoCopyWith<$Res> {
  factory _$ChildDtoCopyWith(_ChildDto value, $Res Function(_ChildDto) _then) = __$ChildDtoCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? name, String? familyId, int? age, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ChildDtoCopyWithImpl<$Res>
    implements _$ChildDtoCopyWith<$Res> {
  __$ChildDtoCopyWithImpl(this._self, this._then);

  final _ChildDto _self;
  final $Res Function(_ChildDto) _then;

/// Create a copy of ChildDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? familyId = freezed,Object? age = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ChildDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,familyId: freezed == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$FamilyChildrenResponseDto {

 List<ChildDto> get children; int get totalCount;
/// Create a copy of FamilyChildrenResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyChildrenResponseDtoCopyWith<FamilyChildrenResponseDto> get copyWith => _$FamilyChildrenResponseDtoCopyWithImpl<FamilyChildrenResponseDto>(this as FamilyChildrenResponseDto, _$identity);

  /// Serializes this FamilyChildrenResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyChildrenResponseDto&&const DeepCollectionEquality().equals(other.children, children)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(children),totalCount);

@override
String toString() {
  return 'FamilyChildrenResponseDto(children: $children, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class $FamilyChildrenResponseDtoCopyWith<$Res>  {
  factory $FamilyChildrenResponseDtoCopyWith(FamilyChildrenResponseDto value, $Res Function(FamilyChildrenResponseDto) _then) = _$FamilyChildrenResponseDtoCopyWithImpl;
@useResult
$Res call({
 List<ChildDto> children, int totalCount
});




}
/// @nodoc
class _$FamilyChildrenResponseDtoCopyWithImpl<$Res>
    implements $FamilyChildrenResponseDtoCopyWith<$Res> {
  _$FamilyChildrenResponseDtoCopyWithImpl(this._self, this._then);

  final FamilyChildrenResponseDto _self;
  final $Res Function(FamilyChildrenResponseDto) _then;

/// Create a copy of FamilyChildrenResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? children = null,Object? totalCount = null,}) {
  return _then(_self.copyWith(
children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<ChildDto>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyChildrenResponseDto].
extension FamilyChildrenResponseDtoPatterns on FamilyChildrenResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyChildrenResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyChildrenResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyChildrenResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _FamilyChildrenResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyChildrenResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyChildrenResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ChildDto> children,  int totalCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyChildrenResponseDto() when $default != null:
return $default(_that.children,_that.totalCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ChildDto> children,  int totalCount)  $default,) {final _that = this;
switch (_that) {
case _FamilyChildrenResponseDto():
return $default(_that.children,_that.totalCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ChildDto> children,  int totalCount)?  $default,) {final _that = this;
switch (_that) {
case _FamilyChildrenResponseDto() when $default != null:
return $default(_that.children,_that.totalCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyChildrenResponseDto extends FamilyChildrenResponseDto {
  const _FamilyChildrenResponseDto({required final  List<ChildDto> children, this.totalCount = 0}): _children = children,super._();
  factory _FamilyChildrenResponseDto.fromJson(Map<String, dynamic> json) => _$FamilyChildrenResponseDtoFromJson(json);

 final  List<ChildDto> _children;
@override List<ChildDto> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

@override@JsonKey() final  int totalCount;

/// Create a copy of FamilyChildrenResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyChildrenResponseDtoCopyWith<_FamilyChildrenResponseDto> get copyWith => __$FamilyChildrenResponseDtoCopyWithImpl<_FamilyChildrenResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyChildrenResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyChildrenResponseDto&&const DeepCollectionEquality().equals(other._children, _children)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_children),totalCount);

@override
String toString() {
  return 'FamilyChildrenResponseDto(children: $children, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class _$FamilyChildrenResponseDtoCopyWith<$Res> implements $FamilyChildrenResponseDtoCopyWith<$Res> {
  factory _$FamilyChildrenResponseDtoCopyWith(_FamilyChildrenResponseDto value, $Res Function(_FamilyChildrenResponseDto) _then) = __$FamilyChildrenResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 List<ChildDto> children, int totalCount
});




}
/// @nodoc
class __$FamilyChildrenResponseDtoCopyWithImpl<$Res>
    implements _$FamilyChildrenResponseDtoCopyWith<$Res> {
  __$FamilyChildrenResponseDtoCopyWithImpl(this._self, this._then);

  final _FamilyChildrenResponseDto _self;
  final $Res Function(_FamilyChildrenResponseDto) _then;

/// Create a copy of FamilyChildrenResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? children = null,Object? totalCount = null,}) {
  return _then(_FamilyChildrenResponseDto(
children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<ChildDto>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
