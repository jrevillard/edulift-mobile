// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_slot_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleSlotDto {

// Only fields that exist in backend ScheduleSlot schema
 String get id; String get groupId; DateTime get datetime; DateTime? get createdAt; DateTime? get updatedAt;// Relations from API includes (when populated)
 List<VehicleAssignmentDto>? get vehicleAssignments; List<ScheduleSlotChildDto>? get childAssignments;
/// Create a copy of ScheduleSlotDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleSlotDtoCopyWith<ScheduleSlotDto> get copyWith => _$ScheduleSlotDtoCopyWithImpl<ScheduleSlotDto>(this as ScheduleSlotDto, _$identity);

  /// Serializes this ScheduleSlotDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleSlotDto&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.datetime, datetime) || other.datetime == datetime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.vehicleAssignments, vehicleAssignments)&&const DeepCollectionEquality().equals(other.childAssignments, childAssignments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,datetime,createdAt,updatedAt,const DeepCollectionEquality().hash(vehicleAssignments),const DeepCollectionEquality().hash(childAssignments));

@override
String toString() {
  return 'ScheduleSlotDto(id: $id, groupId: $groupId, datetime: $datetime, createdAt: $createdAt, updatedAt: $updatedAt, vehicleAssignments: $vehicleAssignments, childAssignments: $childAssignments)';
}


}

/// @nodoc
abstract mixin class $ScheduleSlotDtoCopyWith<$Res>  {
  factory $ScheduleSlotDtoCopyWith(ScheduleSlotDto value, $Res Function(ScheduleSlotDto) _then) = _$ScheduleSlotDtoCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, DateTime datetime, DateTime? createdAt, DateTime? updatedAt, List<VehicleAssignmentDto>? vehicleAssignments, List<ScheduleSlotChildDto>? childAssignments
});




}
/// @nodoc
class _$ScheduleSlotDtoCopyWithImpl<$Res>
    implements $ScheduleSlotDtoCopyWith<$Res> {
  _$ScheduleSlotDtoCopyWithImpl(this._self, this._then);

  final ScheduleSlotDto _self;
  final $Res Function(ScheduleSlotDto) _then;

/// Create a copy of ScheduleSlotDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? datetime = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? vehicleAssignments = freezed,Object? childAssignments = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,datetime: null == datetime ? _self.datetime : datetime // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,vehicleAssignments: freezed == vehicleAssignments ? _self.vehicleAssignments : vehicleAssignments // ignore: cast_nullable_to_non_nullable
as List<VehicleAssignmentDto>?,childAssignments: freezed == childAssignments ? _self.childAssignments : childAssignments // ignore: cast_nullable_to_non_nullable
as List<ScheduleSlotChildDto>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleSlotDto].
extension ScheduleSlotDtoPatterns on ScheduleSlotDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleSlotDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleSlotDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleSlotDto value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleSlotDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleSlotDto value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleSlotDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  DateTime datetime,  DateTime? createdAt,  DateTime? updatedAt,  List<VehicleAssignmentDto>? vehicleAssignments,  List<ScheduleSlotChildDto>? childAssignments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleSlotDto() when $default != null:
return $default(_that.id,_that.groupId,_that.datetime,_that.createdAt,_that.updatedAt,_that.vehicleAssignments,_that.childAssignments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  DateTime datetime,  DateTime? createdAt,  DateTime? updatedAt,  List<VehicleAssignmentDto>? vehicleAssignments,  List<ScheduleSlotChildDto>? childAssignments)  $default,) {final _that = this;
switch (_that) {
case _ScheduleSlotDto():
return $default(_that.id,_that.groupId,_that.datetime,_that.createdAt,_that.updatedAt,_that.vehicleAssignments,_that.childAssignments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  DateTime datetime,  DateTime? createdAt,  DateTime? updatedAt,  List<VehicleAssignmentDto>? vehicleAssignments,  List<ScheduleSlotChildDto>? childAssignments)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleSlotDto() when $default != null:
return $default(_that.id,_that.groupId,_that.datetime,_that.createdAt,_that.updatedAt,_that.vehicleAssignments,_that.childAssignments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleSlotDto extends ScheduleSlotDto {
  const _ScheduleSlotDto({required this.id, required this.groupId, required this.datetime, this.createdAt, this.updatedAt, final  List<VehicleAssignmentDto>? vehicleAssignments, final  List<ScheduleSlotChildDto>? childAssignments}): _vehicleAssignments = vehicleAssignments,_childAssignments = childAssignments,super._();
  factory _ScheduleSlotDto.fromJson(Map<String, dynamic> json) => _$ScheduleSlotDtoFromJson(json);

// Only fields that exist in backend ScheduleSlot schema
@override final  String id;
@override final  String groupId;
@override final  DateTime datetime;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
// Relations from API includes (when populated)
 final  List<VehicleAssignmentDto>? _vehicleAssignments;
// Relations from API includes (when populated)
@override List<VehicleAssignmentDto>? get vehicleAssignments {
  final value = _vehicleAssignments;
  if (value == null) return null;
  if (_vehicleAssignments is EqualUnmodifiableListView) return _vehicleAssignments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<ScheduleSlotChildDto>? _childAssignments;
@override List<ScheduleSlotChildDto>? get childAssignments {
  final value = _childAssignments;
  if (value == null) return null;
  if (_childAssignments is EqualUnmodifiableListView) return _childAssignments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ScheduleSlotDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleSlotDtoCopyWith<_ScheduleSlotDto> get copyWith => __$ScheduleSlotDtoCopyWithImpl<_ScheduleSlotDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleSlotDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleSlotDto&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.datetime, datetime) || other.datetime == datetime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._vehicleAssignments, _vehicleAssignments)&&const DeepCollectionEquality().equals(other._childAssignments, _childAssignments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,datetime,createdAt,updatedAt,const DeepCollectionEquality().hash(_vehicleAssignments),const DeepCollectionEquality().hash(_childAssignments));

@override
String toString() {
  return 'ScheduleSlotDto(id: $id, groupId: $groupId, datetime: $datetime, createdAt: $createdAt, updatedAt: $updatedAt, vehicleAssignments: $vehicleAssignments, childAssignments: $childAssignments)';
}


}

/// @nodoc
abstract mixin class _$ScheduleSlotDtoCopyWith<$Res> implements $ScheduleSlotDtoCopyWith<$Res> {
  factory _$ScheduleSlotDtoCopyWith(_ScheduleSlotDto value, $Res Function(_ScheduleSlotDto) _then) = __$ScheduleSlotDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, DateTime datetime, DateTime? createdAt, DateTime? updatedAt, List<VehicleAssignmentDto>? vehicleAssignments, List<ScheduleSlotChildDto>? childAssignments
});




}
/// @nodoc
class __$ScheduleSlotDtoCopyWithImpl<$Res>
    implements _$ScheduleSlotDtoCopyWith<$Res> {
  __$ScheduleSlotDtoCopyWithImpl(this._self, this._then);

  final _ScheduleSlotDto _self;
  final $Res Function(_ScheduleSlotDto) _then;

/// Create a copy of ScheduleSlotDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? datetime = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? vehicleAssignments = freezed,Object? childAssignments = freezed,}) {
  return _then(_ScheduleSlotDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,datetime: null == datetime ? _self.datetime : datetime // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,vehicleAssignments: freezed == vehicleAssignments ? _self._vehicleAssignments : vehicleAssignments // ignore: cast_nullable_to_non_nullable
as List<VehicleAssignmentDto>?,childAssignments: freezed == childAssignments ? _self._childAssignments : childAssignments // ignore: cast_nullable_to_non_nullable
as List<ScheduleSlotChildDto>?,
  ));
}


}

// dart format on
