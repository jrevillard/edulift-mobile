// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_assignment_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChildAssignmentDto {

 String get id; String get childId; String get assignmentId; String get status; DateTime? get assignedAt; String? get notes;
/// Create a copy of ChildAssignmentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildAssignmentDtoCopyWith<ChildAssignmentDto> get copyWith => _$ChildAssignmentDtoCopyWithImpl<ChildAssignmentDto>(this as ChildAssignmentDto, _$identity);

  /// Serializes this ChildAssignmentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildAssignmentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.childId, childId) || other.childId == childId)&&(identical(other.assignmentId, assignmentId) || other.assignmentId == assignmentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,childId,assignmentId,status,assignedAt,notes);

@override
String toString() {
  return 'ChildAssignmentDto(id: $id, childId: $childId, assignmentId: $assignmentId, status: $status, assignedAt: $assignedAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $ChildAssignmentDtoCopyWith<$Res>  {
  factory $ChildAssignmentDtoCopyWith(ChildAssignmentDto value, $Res Function(ChildAssignmentDto) _then) = _$ChildAssignmentDtoCopyWithImpl;
@useResult
$Res call({
 String id, String childId, String assignmentId, String status, DateTime? assignedAt, String? notes
});




}
/// @nodoc
class _$ChildAssignmentDtoCopyWithImpl<$Res>
    implements $ChildAssignmentDtoCopyWith<$Res> {
  _$ChildAssignmentDtoCopyWithImpl(this._self, this._then);

  final ChildAssignmentDto _self;
  final $Res Function(ChildAssignmentDto) _then;

/// Create a copy of ChildAssignmentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? childId = null,Object? assignmentId = null,Object? status = null,Object? assignedAt = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,childId: null == childId ? _self.childId : childId // ignore: cast_nullable_to_non_nullable
as String,assignmentId: null == assignmentId ? _self.assignmentId : assignmentId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,assignedAt: freezed == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChildAssignmentDto].
extension ChildAssignmentDtoPatterns on ChildAssignmentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChildAssignmentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChildAssignmentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChildAssignmentDto value)  $default,){
final _that = this;
switch (_that) {
case _ChildAssignmentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChildAssignmentDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChildAssignmentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String childId,  String assignmentId,  String status,  DateTime? assignedAt,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChildAssignmentDto() when $default != null:
return $default(_that.id,_that.childId,_that.assignmentId,_that.status,_that.assignedAt,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String childId,  String assignmentId,  String status,  DateTime? assignedAt,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _ChildAssignmentDto():
return $default(_that.id,_that.childId,_that.assignmentId,_that.status,_that.assignedAt,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String childId,  String assignmentId,  String status,  DateTime? assignedAt,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _ChildAssignmentDto() when $default != null:
return $default(_that.id,_that.childId,_that.assignmentId,_that.status,_that.assignedAt,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChildAssignmentDto extends ChildAssignmentDto {
  const _ChildAssignmentDto({required this.id, required this.childId, required this.assignmentId, required this.status, this.assignedAt, this.notes}): super._();
  factory _ChildAssignmentDto.fromJson(Map<String, dynamic> json) => _$ChildAssignmentDtoFromJson(json);

@override final  String id;
@override final  String childId;
@override final  String assignmentId;
@override final  String status;
@override final  DateTime? assignedAt;
@override final  String? notes;

/// Create a copy of ChildAssignmentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChildAssignmentDtoCopyWith<_ChildAssignmentDto> get copyWith => __$ChildAssignmentDtoCopyWithImpl<_ChildAssignmentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChildAssignmentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChildAssignmentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.childId, childId) || other.childId == childId)&&(identical(other.assignmentId, assignmentId) || other.assignmentId == assignmentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,childId,assignmentId,status,assignedAt,notes);

@override
String toString() {
  return 'ChildAssignmentDto(id: $id, childId: $childId, assignmentId: $assignmentId, status: $status, assignedAt: $assignedAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$ChildAssignmentDtoCopyWith<$Res> implements $ChildAssignmentDtoCopyWith<$Res> {
  factory _$ChildAssignmentDtoCopyWith(_ChildAssignmentDto value, $Res Function(_ChildAssignmentDto) _then) = __$ChildAssignmentDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String childId, String assignmentId, String status, DateTime? assignedAt, String? notes
});




}
/// @nodoc
class __$ChildAssignmentDtoCopyWithImpl<$Res>
    implements _$ChildAssignmentDtoCopyWith<$Res> {
  __$ChildAssignmentDtoCopyWithImpl(this._self, this._then);

  final _ChildAssignmentDto _self;
  final $Res Function(_ChildAssignmentDto) _then;

/// Create a copy of ChildAssignmentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? childId = null,Object? assignmentId = null,Object? status = null,Object? assignedAt = freezed,Object? notes = freezed,}) {
  return _then(_ChildAssignmentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,childId: null == childId ? _self.childId : childId // ignore: cast_nullable_to_non_nullable
as String,assignmentId: null == assignmentId ? _self.assignmentId : assignmentId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,assignedAt: freezed == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
