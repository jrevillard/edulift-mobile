// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_slot_with_details_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleSlotWithDetailsDto {

// Core ScheduleSlot fields
 String get id; String get groupId; DateTime get datetime;@JsonKey(name: 'createdAt') String? get createdAt;@JsonKey(name: 'updatedAt') String? get updatedAt;// Vehicle assignments with full details
@JsonKey(name: 'vehicleAssignments') List<VehicleAssignmentDetailsDto> get vehicleAssignments;// Child assignments linked to vehicle assignments
@JsonKey(name: 'childAssignments') List<ChildAssignmentDetailsDto> get childAssignments;// Computed fields from backend
@JsonKey(name: 'totalCapacity') int get totalCapacity;@JsonKey(name: 'availableSeats') int get availableSeats;
/// Create a copy of ScheduleSlotWithDetailsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleSlotWithDetailsDtoCopyWith<ScheduleSlotWithDetailsDto> get copyWith => _$ScheduleSlotWithDetailsDtoCopyWithImpl<ScheduleSlotWithDetailsDto>(this as ScheduleSlotWithDetailsDto, _$identity);

  /// Serializes this ScheduleSlotWithDetailsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleSlotWithDetailsDto&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.datetime, datetime) || other.datetime == datetime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.vehicleAssignments, vehicleAssignments)&&const DeepCollectionEquality().equals(other.childAssignments, childAssignments)&&(identical(other.totalCapacity, totalCapacity) || other.totalCapacity == totalCapacity)&&(identical(other.availableSeats, availableSeats) || other.availableSeats == availableSeats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,datetime,createdAt,updatedAt,const DeepCollectionEquality().hash(vehicleAssignments),const DeepCollectionEquality().hash(childAssignments),totalCapacity,availableSeats);

@override
String toString() {
  return 'ScheduleSlotWithDetailsDto(id: $id, groupId: $groupId, datetime: $datetime, createdAt: $createdAt, updatedAt: $updatedAt, vehicleAssignments: $vehicleAssignments, childAssignments: $childAssignments, totalCapacity: $totalCapacity, availableSeats: $availableSeats)';
}


}

/// @nodoc
abstract mixin class $ScheduleSlotWithDetailsDtoCopyWith<$Res>  {
  factory $ScheduleSlotWithDetailsDtoCopyWith(ScheduleSlotWithDetailsDto value, $Res Function(ScheduleSlotWithDetailsDto) _then) = _$ScheduleSlotWithDetailsDtoCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, DateTime datetime,@JsonKey(name: 'createdAt') String? createdAt,@JsonKey(name: 'updatedAt') String? updatedAt,@JsonKey(name: 'vehicleAssignments') List<VehicleAssignmentDetailsDto> vehicleAssignments,@JsonKey(name: 'childAssignments') List<ChildAssignmentDetailsDto> childAssignments,@JsonKey(name: 'totalCapacity') int totalCapacity,@JsonKey(name: 'availableSeats') int availableSeats
});




}
/// @nodoc
class _$ScheduleSlotWithDetailsDtoCopyWithImpl<$Res>
    implements $ScheduleSlotWithDetailsDtoCopyWith<$Res> {
  _$ScheduleSlotWithDetailsDtoCopyWithImpl(this._self, this._then);

  final ScheduleSlotWithDetailsDto _self;
  final $Res Function(ScheduleSlotWithDetailsDto) _then;

/// Create a copy of ScheduleSlotWithDetailsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? datetime = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? vehicleAssignments = null,Object? childAssignments = null,Object? totalCapacity = null,Object? availableSeats = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,datetime: null == datetime ? _self.datetime : datetime // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,vehicleAssignments: null == vehicleAssignments ? _self.vehicleAssignments : vehicleAssignments // ignore: cast_nullable_to_non_nullable
as List<VehicleAssignmentDetailsDto>,childAssignments: null == childAssignments ? _self.childAssignments : childAssignments // ignore: cast_nullable_to_non_nullable
as List<ChildAssignmentDetailsDto>,totalCapacity: null == totalCapacity ? _self.totalCapacity : totalCapacity // ignore: cast_nullable_to_non_nullable
as int,availableSeats: null == availableSeats ? _self.availableSeats : availableSeats // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleSlotWithDetailsDto].
extension ScheduleSlotWithDetailsDtoPatterns on ScheduleSlotWithDetailsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleSlotWithDetailsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleSlotWithDetailsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleSlotWithDetailsDto value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleSlotWithDetailsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleSlotWithDetailsDto value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleSlotWithDetailsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  DateTime datetime, @JsonKey(name: 'createdAt')  String? createdAt, @JsonKey(name: 'updatedAt')  String? updatedAt, @JsonKey(name: 'vehicleAssignments')  List<VehicleAssignmentDetailsDto> vehicleAssignments, @JsonKey(name: 'childAssignments')  List<ChildAssignmentDetailsDto> childAssignments, @JsonKey(name: 'totalCapacity')  int totalCapacity, @JsonKey(name: 'availableSeats')  int availableSeats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleSlotWithDetailsDto() when $default != null:
return $default(_that.id,_that.groupId,_that.datetime,_that.createdAt,_that.updatedAt,_that.vehicleAssignments,_that.childAssignments,_that.totalCapacity,_that.availableSeats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  DateTime datetime, @JsonKey(name: 'createdAt')  String? createdAt, @JsonKey(name: 'updatedAt')  String? updatedAt, @JsonKey(name: 'vehicleAssignments')  List<VehicleAssignmentDetailsDto> vehicleAssignments, @JsonKey(name: 'childAssignments')  List<ChildAssignmentDetailsDto> childAssignments, @JsonKey(name: 'totalCapacity')  int totalCapacity, @JsonKey(name: 'availableSeats')  int availableSeats)  $default,) {final _that = this;
switch (_that) {
case _ScheduleSlotWithDetailsDto():
return $default(_that.id,_that.groupId,_that.datetime,_that.createdAt,_that.updatedAt,_that.vehicleAssignments,_that.childAssignments,_that.totalCapacity,_that.availableSeats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  DateTime datetime, @JsonKey(name: 'createdAt')  String? createdAt, @JsonKey(name: 'updatedAt')  String? updatedAt, @JsonKey(name: 'vehicleAssignments')  List<VehicleAssignmentDetailsDto> vehicleAssignments, @JsonKey(name: 'childAssignments')  List<ChildAssignmentDetailsDto> childAssignments, @JsonKey(name: 'totalCapacity')  int totalCapacity, @JsonKey(name: 'availableSeats')  int availableSeats)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleSlotWithDetailsDto() when $default != null:
return $default(_that.id,_that.groupId,_that.datetime,_that.createdAt,_that.updatedAt,_that.vehicleAssignments,_that.childAssignments,_that.totalCapacity,_that.availableSeats);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleSlotWithDetailsDto extends ScheduleSlotWithDetailsDto {
  const _ScheduleSlotWithDetailsDto({required this.id, required this.groupId, required this.datetime, @JsonKey(name: 'createdAt') this.createdAt, @JsonKey(name: 'updatedAt') this.updatedAt, @JsonKey(name: 'vehicleAssignments') required final  List<VehicleAssignmentDetailsDto> vehicleAssignments, @JsonKey(name: 'childAssignments') required final  List<ChildAssignmentDetailsDto> childAssignments, @JsonKey(name: 'totalCapacity') required this.totalCapacity, @JsonKey(name: 'availableSeats') required this.availableSeats}): _vehicleAssignments = vehicleAssignments,_childAssignments = childAssignments,super._();
  factory _ScheduleSlotWithDetailsDto.fromJson(Map<String, dynamic> json) => _$ScheduleSlotWithDetailsDtoFromJson(json);

// Core ScheduleSlot fields
@override final  String id;
@override final  String groupId;
@override final  DateTime datetime;
@override@JsonKey(name: 'createdAt') final  String? createdAt;
@override@JsonKey(name: 'updatedAt') final  String? updatedAt;
// Vehicle assignments with full details
 final  List<VehicleAssignmentDetailsDto> _vehicleAssignments;
// Vehicle assignments with full details
@override@JsonKey(name: 'vehicleAssignments') List<VehicleAssignmentDetailsDto> get vehicleAssignments {
  if (_vehicleAssignments is EqualUnmodifiableListView) return _vehicleAssignments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vehicleAssignments);
}

// Child assignments linked to vehicle assignments
 final  List<ChildAssignmentDetailsDto> _childAssignments;
// Child assignments linked to vehicle assignments
@override@JsonKey(name: 'childAssignments') List<ChildAssignmentDetailsDto> get childAssignments {
  if (_childAssignments is EqualUnmodifiableListView) return _childAssignments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_childAssignments);
}

// Computed fields from backend
@override@JsonKey(name: 'totalCapacity') final  int totalCapacity;
@override@JsonKey(name: 'availableSeats') final  int availableSeats;

/// Create a copy of ScheduleSlotWithDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleSlotWithDetailsDtoCopyWith<_ScheduleSlotWithDetailsDto> get copyWith => __$ScheduleSlotWithDetailsDtoCopyWithImpl<_ScheduleSlotWithDetailsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleSlotWithDetailsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleSlotWithDetailsDto&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.datetime, datetime) || other.datetime == datetime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._vehicleAssignments, _vehicleAssignments)&&const DeepCollectionEquality().equals(other._childAssignments, _childAssignments)&&(identical(other.totalCapacity, totalCapacity) || other.totalCapacity == totalCapacity)&&(identical(other.availableSeats, availableSeats) || other.availableSeats == availableSeats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,datetime,createdAt,updatedAt,const DeepCollectionEquality().hash(_vehicleAssignments),const DeepCollectionEquality().hash(_childAssignments),totalCapacity,availableSeats);

@override
String toString() {
  return 'ScheduleSlotWithDetailsDto(id: $id, groupId: $groupId, datetime: $datetime, createdAt: $createdAt, updatedAt: $updatedAt, vehicleAssignments: $vehicleAssignments, childAssignments: $childAssignments, totalCapacity: $totalCapacity, availableSeats: $availableSeats)';
}


}

/// @nodoc
abstract mixin class _$ScheduleSlotWithDetailsDtoCopyWith<$Res> implements $ScheduleSlotWithDetailsDtoCopyWith<$Res> {
  factory _$ScheduleSlotWithDetailsDtoCopyWith(_ScheduleSlotWithDetailsDto value, $Res Function(_ScheduleSlotWithDetailsDto) _then) = __$ScheduleSlotWithDetailsDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, DateTime datetime,@JsonKey(name: 'createdAt') String? createdAt,@JsonKey(name: 'updatedAt') String? updatedAt,@JsonKey(name: 'vehicleAssignments') List<VehicleAssignmentDetailsDto> vehicleAssignments,@JsonKey(name: 'childAssignments') List<ChildAssignmentDetailsDto> childAssignments,@JsonKey(name: 'totalCapacity') int totalCapacity,@JsonKey(name: 'availableSeats') int availableSeats
});




}
/// @nodoc
class __$ScheduleSlotWithDetailsDtoCopyWithImpl<$Res>
    implements _$ScheduleSlotWithDetailsDtoCopyWith<$Res> {
  __$ScheduleSlotWithDetailsDtoCopyWithImpl(this._self, this._then);

  final _ScheduleSlotWithDetailsDto _self;
  final $Res Function(_ScheduleSlotWithDetailsDto) _then;

/// Create a copy of ScheduleSlotWithDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? datetime = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? vehicleAssignments = null,Object? childAssignments = null,Object? totalCapacity = null,Object? availableSeats = null,}) {
  return _then(_ScheduleSlotWithDetailsDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,datetime: null == datetime ? _self.datetime : datetime // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,vehicleAssignments: null == vehicleAssignments ? _self._vehicleAssignments : vehicleAssignments // ignore: cast_nullable_to_non_nullable
as List<VehicleAssignmentDetailsDto>,childAssignments: null == childAssignments ? _self._childAssignments : childAssignments // ignore: cast_nullable_to_non_nullable
as List<ChildAssignmentDetailsDto>,totalCapacity: null == totalCapacity ? _self.totalCapacity : totalCapacity // ignore: cast_nullable_to_non_nullable
as int,availableSeats: null == availableSeats ? _self.availableSeats : availableSeats // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$VehicleAssignmentDetailsDto {

 String get id;@JsonKey(name: 'scheduleSlotId') String get scheduleSlotId; VehicleDto get vehicle; DriverDto? get driver; int? get seatOverride;
/// Create a copy of VehicleAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleAssignmentDetailsDtoCopyWith<VehicleAssignmentDetailsDto> get copyWith => _$VehicleAssignmentDetailsDtoCopyWithImpl<VehicleAssignmentDetailsDto>(this as VehicleAssignmentDetailsDto, _$identity);

  /// Serializes this VehicleAssignmentDetailsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleAssignmentDetailsDto&&(identical(other.id, id) || other.id == id)&&(identical(other.scheduleSlotId, scheduleSlotId) || other.scheduleSlotId == scheduleSlotId)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.seatOverride, seatOverride) || other.seatOverride == seatOverride));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,scheduleSlotId,vehicle,driver,seatOverride);

@override
String toString() {
  return 'VehicleAssignmentDetailsDto(id: $id, scheduleSlotId: $scheduleSlotId, vehicle: $vehicle, driver: $driver, seatOverride: $seatOverride)';
}


}

/// @nodoc
abstract mixin class $VehicleAssignmentDetailsDtoCopyWith<$Res>  {
  factory $VehicleAssignmentDetailsDtoCopyWith(VehicleAssignmentDetailsDto value, $Res Function(VehicleAssignmentDetailsDto) _then) = _$VehicleAssignmentDetailsDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'scheduleSlotId') String scheduleSlotId, VehicleDto vehicle, DriverDto? driver, int? seatOverride
});


$VehicleDtoCopyWith<$Res> get vehicle;$DriverDtoCopyWith<$Res>? get driver;

}
/// @nodoc
class _$VehicleAssignmentDetailsDtoCopyWithImpl<$Res>
    implements $VehicleAssignmentDetailsDtoCopyWith<$Res> {
  _$VehicleAssignmentDetailsDtoCopyWithImpl(this._self, this._then);

  final VehicleAssignmentDetailsDto _self;
  final $Res Function(VehicleAssignmentDetailsDto) _then;

/// Create a copy of VehicleAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? scheduleSlotId = null,Object? vehicle = null,Object? driver = freezed,Object? seatOverride = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scheduleSlotId: null == scheduleSlotId ? _self.scheduleSlotId : scheduleSlotId // ignore: cast_nullable_to_non_nullable
as String,vehicle: null == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as VehicleDto,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as DriverDto?,seatOverride: freezed == seatOverride ? _self.seatOverride : seatOverride // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of VehicleAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleDtoCopyWith<$Res> get vehicle {
  
  return $VehicleDtoCopyWith<$Res>(_self.vehicle, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}/// Create a copy of VehicleAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverDtoCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $DriverDtoCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}
}


/// Adds pattern-matching-related methods to [VehicleAssignmentDetailsDto].
extension VehicleAssignmentDetailsDtoPatterns on VehicleAssignmentDetailsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleAssignmentDetailsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleAssignmentDetailsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleAssignmentDetailsDto value)  $default,){
final _that = this;
switch (_that) {
case _VehicleAssignmentDetailsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleAssignmentDetailsDto value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleAssignmentDetailsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'scheduleSlotId')  String scheduleSlotId,  VehicleDto vehicle,  DriverDto? driver,  int? seatOverride)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleAssignmentDetailsDto() when $default != null:
return $default(_that.id,_that.scheduleSlotId,_that.vehicle,_that.driver,_that.seatOverride);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'scheduleSlotId')  String scheduleSlotId,  VehicleDto vehicle,  DriverDto? driver,  int? seatOverride)  $default,) {final _that = this;
switch (_that) {
case _VehicleAssignmentDetailsDto():
return $default(_that.id,_that.scheduleSlotId,_that.vehicle,_that.driver,_that.seatOverride);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'scheduleSlotId')  String scheduleSlotId,  VehicleDto vehicle,  DriverDto? driver,  int? seatOverride)?  $default,) {final _that = this;
switch (_that) {
case _VehicleAssignmentDetailsDto() when $default != null:
return $default(_that.id,_that.scheduleSlotId,_that.vehicle,_that.driver,_that.seatOverride);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VehicleAssignmentDetailsDto extends VehicleAssignmentDetailsDto {
  const _VehicleAssignmentDetailsDto({required this.id, @JsonKey(name: 'scheduleSlotId') required this.scheduleSlotId, required this.vehicle, this.driver, this.seatOverride}): super._();
  factory _VehicleAssignmentDetailsDto.fromJson(Map<String, dynamic> json) => _$VehicleAssignmentDetailsDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'scheduleSlotId') final  String scheduleSlotId;
@override final  VehicleDto vehicle;
@override final  DriverDto? driver;
@override final  int? seatOverride;

/// Create a copy of VehicleAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleAssignmentDetailsDtoCopyWith<_VehicleAssignmentDetailsDto> get copyWith => __$VehicleAssignmentDetailsDtoCopyWithImpl<_VehicleAssignmentDetailsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleAssignmentDetailsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleAssignmentDetailsDto&&(identical(other.id, id) || other.id == id)&&(identical(other.scheduleSlotId, scheduleSlotId) || other.scheduleSlotId == scheduleSlotId)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.seatOverride, seatOverride) || other.seatOverride == seatOverride));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,scheduleSlotId,vehicle,driver,seatOverride);

@override
String toString() {
  return 'VehicleAssignmentDetailsDto(id: $id, scheduleSlotId: $scheduleSlotId, vehicle: $vehicle, driver: $driver, seatOverride: $seatOverride)';
}


}

/// @nodoc
abstract mixin class _$VehicleAssignmentDetailsDtoCopyWith<$Res> implements $VehicleAssignmentDetailsDtoCopyWith<$Res> {
  factory _$VehicleAssignmentDetailsDtoCopyWith(_VehicleAssignmentDetailsDto value, $Res Function(_VehicleAssignmentDetailsDto) _then) = __$VehicleAssignmentDetailsDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'scheduleSlotId') String scheduleSlotId, VehicleDto vehicle, DriverDto? driver, int? seatOverride
});


@override $VehicleDtoCopyWith<$Res> get vehicle;@override $DriverDtoCopyWith<$Res>? get driver;

}
/// @nodoc
class __$VehicleAssignmentDetailsDtoCopyWithImpl<$Res>
    implements _$VehicleAssignmentDetailsDtoCopyWith<$Res> {
  __$VehicleAssignmentDetailsDtoCopyWithImpl(this._self, this._then);

  final _VehicleAssignmentDetailsDto _self;
  final $Res Function(_VehicleAssignmentDetailsDto) _then;

/// Create a copy of VehicleAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? scheduleSlotId = null,Object? vehicle = null,Object? driver = freezed,Object? seatOverride = freezed,}) {
  return _then(_VehicleAssignmentDetailsDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scheduleSlotId: null == scheduleSlotId ? _self.scheduleSlotId : scheduleSlotId // ignore: cast_nullable_to_non_nullable
as String,vehicle: null == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as VehicleDto,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as DriverDto?,seatOverride: freezed == seatOverride ? _self.seatOverride : seatOverride // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of VehicleAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleDtoCopyWith<$Res> get vehicle {
  
  return $VehicleDtoCopyWith<$Res>(_self.vehicle, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}/// Create a copy of VehicleAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverDtoCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $DriverDtoCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}
}


/// @nodoc
mixin _$ChildAssignmentDetailsDto {

 String get vehicleAssignmentId; ChildDetailsDto get child;
/// Create a copy of ChildAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildAssignmentDetailsDtoCopyWith<ChildAssignmentDetailsDto> get copyWith => _$ChildAssignmentDetailsDtoCopyWithImpl<ChildAssignmentDetailsDto>(this as ChildAssignmentDetailsDto, _$identity);

  /// Serializes this ChildAssignmentDetailsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildAssignmentDetailsDto&&(identical(other.vehicleAssignmentId, vehicleAssignmentId) || other.vehicleAssignmentId == vehicleAssignmentId)&&(identical(other.child, child) || other.child == child));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vehicleAssignmentId,child);

@override
String toString() {
  return 'ChildAssignmentDetailsDto(vehicleAssignmentId: $vehicleAssignmentId, child: $child)';
}


}

/// @nodoc
abstract mixin class $ChildAssignmentDetailsDtoCopyWith<$Res>  {
  factory $ChildAssignmentDetailsDtoCopyWith(ChildAssignmentDetailsDto value, $Res Function(ChildAssignmentDetailsDto) _then) = _$ChildAssignmentDetailsDtoCopyWithImpl;
@useResult
$Res call({
 String vehicleAssignmentId, ChildDetailsDto child
});


$ChildDetailsDtoCopyWith<$Res> get child;

}
/// @nodoc
class _$ChildAssignmentDetailsDtoCopyWithImpl<$Res>
    implements $ChildAssignmentDetailsDtoCopyWith<$Res> {
  _$ChildAssignmentDetailsDtoCopyWithImpl(this._self, this._then);

  final ChildAssignmentDetailsDto _self;
  final $Res Function(ChildAssignmentDetailsDto) _then;

/// Create a copy of ChildAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vehicleAssignmentId = null,Object? child = null,}) {
  return _then(_self.copyWith(
vehicleAssignmentId: null == vehicleAssignmentId ? _self.vehicleAssignmentId : vehicleAssignmentId // ignore: cast_nullable_to_non_nullable
as String,child: null == child ? _self.child : child // ignore: cast_nullable_to_non_nullable
as ChildDetailsDto,
  ));
}
/// Create a copy of ChildAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChildDetailsDtoCopyWith<$Res> get child {
  
  return $ChildDetailsDtoCopyWith<$Res>(_self.child, (value) {
    return _then(_self.copyWith(child: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChildAssignmentDetailsDto].
extension ChildAssignmentDetailsDtoPatterns on ChildAssignmentDetailsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChildAssignmentDetailsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChildAssignmentDetailsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChildAssignmentDetailsDto value)  $default,){
final _that = this;
switch (_that) {
case _ChildAssignmentDetailsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChildAssignmentDetailsDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChildAssignmentDetailsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String vehicleAssignmentId,  ChildDetailsDto child)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChildAssignmentDetailsDto() when $default != null:
return $default(_that.vehicleAssignmentId,_that.child);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String vehicleAssignmentId,  ChildDetailsDto child)  $default,) {final _that = this;
switch (_that) {
case _ChildAssignmentDetailsDto():
return $default(_that.vehicleAssignmentId,_that.child);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String vehicleAssignmentId,  ChildDetailsDto child)?  $default,) {final _that = this;
switch (_that) {
case _ChildAssignmentDetailsDto() when $default != null:
return $default(_that.vehicleAssignmentId,_that.child);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChildAssignmentDetailsDto extends ChildAssignmentDetailsDto {
  const _ChildAssignmentDetailsDto({required this.vehicleAssignmentId, required this.child}): super._();
  factory _ChildAssignmentDetailsDto.fromJson(Map<String, dynamic> json) => _$ChildAssignmentDetailsDtoFromJson(json);

@override final  String vehicleAssignmentId;
@override final  ChildDetailsDto child;

/// Create a copy of ChildAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChildAssignmentDetailsDtoCopyWith<_ChildAssignmentDetailsDto> get copyWith => __$ChildAssignmentDetailsDtoCopyWithImpl<_ChildAssignmentDetailsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChildAssignmentDetailsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChildAssignmentDetailsDto&&(identical(other.vehicleAssignmentId, vehicleAssignmentId) || other.vehicleAssignmentId == vehicleAssignmentId)&&(identical(other.child, child) || other.child == child));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vehicleAssignmentId,child);

@override
String toString() {
  return 'ChildAssignmentDetailsDto(vehicleAssignmentId: $vehicleAssignmentId, child: $child)';
}


}

/// @nodoc
abstract mixin class _$ChildAssignmentDetailsDtoCopyWith<$Res> implements $ChildAssignmentDetailsDtoCopyWith<$Res> {
  factory _$ChildAssignmentDetailsDtoCopyWith(_ChildAssignmentDetailsDto value, $Res Function(_ChildAssignmentDetailsDto) _then) = __$ChildAssignmentDetailsDtoCopyWithImpl;
@override @useResult
$Res call({
 String vehicleAssignmentId, ChildDetailsDto child
});


@override $ChildDetailsDtoCopyWith<$Res> get child;

}
/// @nodoc
class __$ChildAssignmentDetailsDtoCopyWithImpl<$Res>
    implements _$ChildAssignmentDetailsDtoCopyWith<$Res> {
  __$ChildAssignmentDetailsDtoCopyWithImpl(this._self, this._then);

  final _ChildAssignmentDetailsDto _self;
  final $Res Function(_ChildAssignmentDetailsDto) _then;

/// Create a copy of ChildAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vehicleAssignmentId = null,Object? child = null,}) {
  return _then(_ChildAssignmentDetailsDto(
vehicleAssignmentId: null == vehicleAssignmentId ? _self.vehicleAssignmentId : vehicleAssignmentId // ignore: cast_nullable_to_non_nullable
as String,child: null == child ? _self.child : child // ignore: cast_nullable_to_non_nullable
as ChildDetailsDto,
  ));
}

/// Create a copy of ChildAssignmentDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChildDetailsDtoCopyWith<$Res> get child {
  
  return $ChildDetailsDtoCopyWith<$Res>(_self.child, (value) {
    return _then(_self.copyWith(child: value));
  });
}
}


/// @nodoc
mixin _$VehicleDto {

 String get id; String get name; int get capacity;
/// Create a copy of VehicleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleDtoCopyWith<VehicleDto> get copyWith => _$VehicleDtoCopyWithImpl<VehicleDto>(this as VehicleDto, _$identity);

  /// Serializes this VehicleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.capacity, capacity) || other.capacity == capacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,capacity);

@override
String toString() {
  return 'VehicleDto(id: $id, name: $name, capacity: $capacity)';
}


}

/// @nodoc
abstract mixin class $VehicleDtoCopyWith<$Res>  {
  factory $VehicleDtoCopyWith(VehicleDto value, $Res Function(VehicleDto) _then) = _$VehicleDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, int capacity
});




}
/// @nodoc
class _$VehicleDtoCopyWithImpl<$Res>
    implements $VehicleDtoCopyWith<$Res> {
  _$VehicleDtoCopyWithImpl(this._self, this._then);

  final VehicleDto _self;
  final $Res Function(VehicleDto) _then;

/// Create a copy of VehicleDto
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


/// Adds pattern-matching-related methods to [VehicleDto].
extension VehicleDtoPatterns on VehicleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleDto value)  $default,){
final _that = this;
switch (_that) {
case _VehicleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleDto value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleDto() when $default != null:
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
case _VehicleDto() when $default != null:
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
case _VehicleDto():
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
case _VehicleDto() when $default != null:
return $default(_that.id,_that.name,_that.capacity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VehicleDto implements VehicleDto {
  const _VehicleDto({required this.id, required this.name, required this.capacity});
  factory _VehicleDto.fromJson(Map<String, dynamic> json) => _$VehicleDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  int capacity;

/// Create a copy of VehicleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleDtoCopyWith<_VehicleDto> get copyWith => __$VehicleDtoCopyWithImpl<_VehicleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.capacity, capacity) || other.capacity == capacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,capacity);

@override
String toString() {
  return 'VehicleDto(id: $id, name: $name, capacity: $capacity)';
}


}

/// @nodoc
abstract mixin class _$VehicleDtoCopyWith<$Res> implements $VehicleDtoCopyWith<$Res> {
  factory _$VehicleDtoCopyWith(_VehicleDto value, $Res Function(_VehicleDto) _then) = __$VehicleDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int capacity
});




}
/// @nodoc
class __$VehicleDtoCopyWithImpl<$Res>
    implements _$VehicleDtoCopyWith<$Res> {
  __$VehicleDtoCopyWithImpl(this._self, this._then);

  final _VehicleDto _self;
  final $Res Function(_VehicleDto) _then;

/// Create a copy of VehicleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? capacity = null,}) {
  return _then(_VehicleDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DriverDto {

 String get id; String get name;
/// Create a copy of DriverDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverDtoCopyWith<DriverDto> get copyWith => _$DriverDtoCopyWithImpl<DriverDto>(this as DriverDto, _$identity);

  /// Serializes this DriverDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'DriverDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $DriverDtoCopyWith<$Res>  {
  factory $DriverDtoCopyWith(DriverDto value, $Res Function(DriverDto) _then) = _$DriverDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$DriverDtoCopyWithImpl<$Res>
    implements $DriverDtoCopyWith<$Res> {
  _$DriverDtoCopyWithImpl(this._self, this._then);

  final DriverDto _self;
  final $Res Function(DriverDto) _then;

/// Create a copy of DriverDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverDto].
extension DriverDtoPatterns on DriverDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverDto value)  $default,){
final _that = this;
switch (_that) {
case _DriverDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverDto value)?  $default,){
final _that = this;
switch (_that) {
case _DriverDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverDto() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _DriverDto():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _DriverDto() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverDto implements DriverDto {
  const _DriverDto({required this.id, required this.name});
  factory _DriverDto.fromJson(Map<String, dynamic> json) => _$DriverDtoFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of DriverDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverDtoCopyWith<_DriverDto> get copyWith => __$DriverDtoCopyWithImpl<_DriverDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'DriverDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$DriverDtoCopyWith<$Res> implements $DriverDtoCopyWith<$Res> {
  factory _$DriverDtoCopyWith(_DriverDto value, $Res Function(_DriverDto) _then) = __$DriverDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$DriverDtoCopyWithImpl<$Res>
    implements _$DriverDtoCopyWith<$Res> {
  __$DriverDtoCopyWithImpl(this._self, this._then);

  final _DriverDto _self;
  final $Res Function(_DriverDto) _then;

/// Create a copy of DriverDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_DriverDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ChildDetailsDto {

 String get id; String get name; String get familyId;
/// Create a copy of ChildDetailsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildDetailsDtoCopyWith<ChildDetailsDto> get copyWith => _$ChildDetailsDtoCopyWithImpl<ChildDetailsDto>(this as ChildDetailsDto, _$identity);

  /// Serializes this ChildDetailsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildDetailsDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.familyId, familyId) || other.familyId == familyId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,familyId);

@override
String toString() {
  return 'ChildDetailsDto(id: $id, name: $name, familyId: $familyId)';
}


}

/// @nodoc
abstract mixin class $ChildDetailsDtoCopyWith<$Res>  {
  factory $ChildDetailsDtoCopyWith(ChildDetailsDto value, $Res Function(ChildDetailsDto) _then) = _$ChildDetailsDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String familyId
});




}
/// @nodoc
class _$ChildDetailsDtoCopyWithImpl<$Res>
    implements $ChildDetailsDtoCopyWith<$Res> {
  _$ChildDetailsDtoCopyWithImpl(this._self, this._then);

  final ChildDetailsDto _self;
  final $Res Function(ChildDetailsDto) _then;

/// Create a copy of ChildDetailsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? familyId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,familyId: null == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChildDetailsDto].
extension ChildDetailsDtoPatterns on ChildDetailsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChildDetailsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChildDetailsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChildDetailsDto value)  $default,){
final _that = this;
switch (_that) {
case _ChildDetailsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChildDetailsDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChildDetailsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String familyId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChildDetailsDto() when $default != null:
return $default(_that.id,_that.name,_that.familyId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String familyId)  $default,) {final _that = this;
switch (_that) {
case _ChildDetailsDto():
return $default(_that.id,_that.name,_that.familyId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String familyId)?  $default,) {final _that = this;
switch (_that) {
case _ChildDetailsDto() when $default != null:
return $default(_that.id,_that.name,_that.familyId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChildDetailsDto implements ChildDetailsDto {
  const _ChildDetailsDto({required this.id, required this.name, required this.familyId});
  factory _ChildDetailsDto.fromJson(Map<String, dynamic> json) => _$ChildDetailsDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String familyId;

/// Create a copy of ChildDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChildDetailsDtoCopyWith<_ChildDetailsDto> get copyWith => __$ChildDetailsDtoCopyWithImpl<_ChildDetailsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChildDetailsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChildDetailsDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.familyId, familyId) || other.familyId == familyId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,familyId);

@override
String toString() {
  return 'ChildDetailsDto(id: $id, name: $name, familyId: $familyId)';
}


}

/// @nodoc
abstract mixin class _$ChildDetailsDtoCopyWith<$Res> implements $ChildDetailsDtoCopyWith<$Res> {
  factory _$ChildDetailsDtoCopyWith(_ChildDetailsDto value, $Res Function(_ChildDetailsDto) _then) = __$ChildDetailsDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String familyId
});




}
/// @nodoc
class __$ChildDetailsDtoCopyWithImpl<$Res>
    implements _$ChildDetailsDtoCopyWith<$Res> {
  __$ChildDetailsDtoCopyWithImpl(this._self, this._then);

  final _ChildDetailsDto _self;
  final $Res Function(_ChildDetailsDto) _then;

/// Create a copy of ChildDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? familyId = null,}) {
  return _then(_ChildDetailsDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,familyId: null == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
