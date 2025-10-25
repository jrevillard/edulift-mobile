// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_assignment_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VehicleAssignmentDto {

// Core fields from backend API response (EXACT match to API)
 String get id;// CRITICAL FIX: scheduleSlotId is NOT sent in nested vehicle assignments
// Backend only sends scheduleSlotId in standalone vehicle assignment responses
// When vehicleAssignments are nested in ScheduleSlot, this field is absent
@JsonKey(name: 'scheduleSlotId') String? get scheduleSlotId;@JsonKey(name: 'seatOverride') int? get seatOverride;// Relations from API includes (nested objects)
 VehicleNestedDto get vehicle;
/// Create a copy of VehicleAssignmentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleAssignmentDtoCopyWith<VehicleAssignmentDto> get copyWith => _$VehicleAssignmentDtoCopyWithImpl<VehicleAssignmentDto>(this as VehicleAssignmentDto, _$identity);

  /// Serializes this VehicleAssignmentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleAssignmentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.scheduleSlotId, scheduleSlotId) || other.scheduleSlotId == scheduleSlotId)&&(identical(other.seatOverride, seatOverride) || other.seatOverride == seatOverride)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,scheduleSlotId,seatOverride,vehicle);

@override
String toString() {
  return 'VehicleAssignmentDto(id: $id, scheduleSlotId: $scheduleSlotId, seatOverride: $seatOverride, vehicle: $vehicle)';
}


}

/// @nodoc
abstract mixin class $VehicleAssignmentDtoCopyWith<$Res>  {
  factory $VehicleAssignmentDtoCopyWith(VehicleAssignmentDto value, $Res Function(VehicleAssignmentDto) _then) = _$VehicleAssignmentDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'scheduleSlotId') String? scheduleSlotId,@JsonKey(name: 'seatOverride') int? seatOverride, VehicleNestedDto vehicle
});


$VehicleNestedDtoCopyWith<$Res> get vehicle;

}
/// @nodoc
class _$VehicleAssignmentDtoCopyWithImpl<$Res>
    implements $VehicleAssignmentDtoCopyWith<$Res> {
  _$VehicleAssignmentDtoCopyWithImpl(this._self, this._then);

  final VehicleAssignmentDto _self;
  final $Res Function(VehicleAssignmentDto) _then;

/// Create a copy of VehicleAssignmentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? scheduleSlotId = freezed,Object? seatOverride = freezed,Object? vehicle = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scheduleSlotId: freezed == scheduleSlotId ? _self.scheduleSlotId : scheduleSlotId // ignore: cast_nullable_to_non_nullable
as String?,seatOverride: freezed == seatOverride ? _self.seatOverride : seatOverride // ignore: cast_nullable_to_non_nullable
as int?,vehicle: null == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as VehicleNestedDto,
  ));
}
/// Create a copy of VehicleAssignmentDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleNestedDtoCopyWith<$Res> get vehicle {
  
  return $VehicleNestedDtoCopyWith<$Res>(_self.vehicle, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}
}


/// Adds pattern-matching-related methods to [VehicleAssignmentDto].
extension VehicleAssignmentDtoPatterns on VehicleAssignmentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleAssignmentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleAssignmentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleAssignmentDto value)  $default,){
final _that = this;
switch (_that) {
case _VehicleAssignmentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleAssignmentDto value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleAssignmentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'scheduleSlotId')  String? scheduleSlotId, @JsonKey(name: 'seatOverride')  int? seatOverride,  VehicleNestedDto vehicle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleAssignmentDto() when $default != null:
return $default(_that.id,_that.scheduleSlotId,_that.seatOverride,_that.vehicle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'scheduleSlotId')  String? scheduleSlotId, @JsonKey(name: 'seatOverride')  int? seatOverride,  VehicleNestedDto vehicle)  $default,) {final _that = this;
switch (_that) {
case _VehicleAssignmentDto():
return $default(_that.id,_that.scheduleSlotId,_that.seatOverride,_that.vehicle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'scheduleSlotId')  String? scheduleSlotId, @JsonKey(name: 'seatOverride')  int? seatOverride,  VehicleNestedDto vehicle)?  $default,) {final _that = this;
switch (_that) {
case _VehicleAssignmentDto() when $default != null:
return $default(_that.id,_that.scheduleSlotId,_that.seatOverride,_that.vehicle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VehicleAssignmentDto extends VehicleAssignmentDto {
  const _VehicleAssignmentDto({required this.id, @JsonKey(name: 'scheduleSlotId') this.scheduleSlotId, @JsonKey(name: 'seatOverride') this.seatOverride, required this.vehicle}): super._();
  factory _VehicleAssignmentDto.fromJson(Map<String, dynamic> json) => _$VehicleAssignmentDtoFromJson(json);

// Core fields from backend API response (EXACT match to API)
@override final  String id;
// CRITICAL FIX: scheduleSlotId is NOT sent in nested vehicle assignments
// Backend only sends scheduleSlotId in standalone vehicle assignment responses
// When vehicleAssignments are nested in ScheduleSlot, this field is absent
@override@JsonKey(name: 'scheduleSlotId') final  String? scheduleSlotId;
@override@JsonKey(name: 'seatOverride') final  int? seatOverride;
// Relations from API includes (nested objects)
@override final  VehicleNestedDto vehicle;

/// Create a copy of VehicleAssignmentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleAssignmentDtoCopyWith<_VehicleAssignmentDto> get copyWith => __$VehicleAssignmentDtoCopyWithImpl<_VehicleAssignmentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleAssignmentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleAssignmentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.scheduleSlotId, scheduleSlotId) || other.scheduleSlotId == scheduleSlotId)&&(identical(other.seatOverride, seatOverride) || other.seatOverride == seatOverride)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,scheduleSlotId,seatOverride,vehicle);

@override
String toString() {
  return 'VehicleAssignmentDto(id: $id, scheduleSlotId: $scheduleSlotId, seatOverride: $seatOverride, vehicle: $vehicle)';
}


}

/// @nodoc
abstract mixin class _$VehicleAssignmentDtoCopyWith<$Res> implements $VehicleAssignmentDtoCopyWith<$Res> {
  factory _$VehicleAssignmentDtoCopyWith(_VehicleAssignmentDto value, $Res Function(_VehicleAssignmentDto) _then) = __$VehicleAssignmentDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'scheduleSlotId') String? scheduleSlotId,@JsonKey(name: 'seatOverride') int? seatOverride, VehicleNestedDto vehicle
});


@override $VehicleNestedDtoCopyWith<$Res> get vehicle;

}
/// @nodoc
class __$VehicleAssignmentDtoCopyWithImpl<$Res>
    implements _$VehicleAssignmentDtoCopyWith<$Res> {
  __$VehicleAssignmentDtoCopyWithImpl(this._self, this._then);

  final _VehicleAssignmentDto _self;
  final $Res Function(_VehicleAssignmentDto) _then;

/// Create a copy of VehicleAssignmentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? scheduleSlotId = freezed,Object? seatOverride = freezed,Object? vehicle = null,}) {
  return _then(_VehicleAssignmentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scheduleSlotId: freezed == scheduleSlotId ? _self.scheduleSlotId : scheduleSlotId // ignore: cast_nullable_to_non_nullable
as String?,seatOverride: freezed == seatOverride ? _self.seatOverride : seatOverride // ignore: cast_nullable_to_non_nullable
as int?,vehicle: null == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as VehicleNestedDto,
  ));
}

/// Create a copy of VehicleAssignmentDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleNestedDtoCopyWith<$Res> get vehicle {
  
  return $VehicleNestedDtoCopyWith<$Res>(_self.vehicle, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}
}


/// @nodoc
mixin _$VehicleNestedDto {

 String get id; String get name; int get capacity;
/// Create a copy of VehicleNestedDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleNestedDtoCopyWith<VehicleNestedDto> get copyWith => _$VehicleNestedDtoCopyWithImpl<VehicleNestedDto>(this as VehicleNestedDto, _$identity);

  /// Serializes this VehicleNestedDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleNestedDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.capacity, capacity) || other.capacity == capacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,capacity);

@override
String toString() {
  return 'VehicleNestedDto(id: $id, name: $name, capacity: $capacity)';
}


}

/// @nodoc
abstract mixin class $VehicleNestedDtoCopyWith<$Res>  {
  factory $VehicleNestedDtoCopyWith(VehicleNestedDto value, $Res Function(VehicleNestedDto) _then) = _$VehicleNestedDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, int capacity
});




}
/// @nodoc
class _$VehicleNestedDtoCopyWithImpl<$Res>
    implements $VehicleNestedDtoCopyWith<$Res> {
  _$VehicleNestedDtoCopyWithImpl(this._self, this._then);

  final VehicleNestedDto _self;
  final $Res Function(VehicleNestedDto) _then;

/// Create a copy of VehicleNestedDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? capacity = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleNestedDto].
extension VehicleNestedDtoPatterns on VehicleNestedDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleNestedDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleNestedDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleNestedDto value)  $default,){
final _that = this;
switch (_that) {
case _VehicleNestedDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleNestedDto value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleNestedDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int capacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleNestedDto() when $default != null:
return $default(_that.id,_that.name,_that.capacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int capacity)  $default,) {final _that = this;
switch (_that) {
case _VehicleNestedDto():
return $default(_that.id,_that.name,_that.capacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int capacity)?  $default,) {final _that = this;
switch (_that) {
case _VehicleNestedDto() when $default != null:
return $default(_that.id,_that.name,_that.capacity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VehicleNestedDto implements VehicleNestedDto {
  const _VehicleNestedDto({required this.id, required this.name, required this.capacity});
  factory _VehicleNestedDto.fromJson(Map<String, dynamic> json) => _$VehicleNestedDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  int capacity;

/// Create a copy of VehicleNestedDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleNestedDtoCopyWith<_VehicleNestedDto> get copyWith => __$VehicleNestedDtoCopyWithImpl<_VehicleNestedDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleNestedDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleNestedDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.capacity, capacity) || other.capacity == capacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,capacity);

@override
String toString() {
  return 'VehicleNestedDto(id: $id, name: $name, capacity: $capacity)';
}


}

/// @nodoc
abstract mixin class _$VehicleNestedDtoCopyWith<$Res> implements $VehicleNestedDtoCopyWith<$Res> {
  factory _$VehicleNestedDtoCopyWith(_VehicleNestedDto value, $Res Function(_VehicleNestedDto) _then) = __$VehicleNestedDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int capacity
});




}
/// @nodoc
class __$VehicleNestedDtoCopyWithImpl<$Res>
    implements _$VehicleNestedDtoCopyWith<$Res> {
  __$VehicleNestedDtoCopyWithImpl(this._self, this._then);

  final _VehicleNestedDto _self;
  final $Res Function(_VehicleNestedDto) _then;

/// Create a copy of VehicleNestedDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? capacity = null,}) {
  return _then(_VehicleNestedDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
