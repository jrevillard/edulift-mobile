// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_schedule_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeeklyScheduleItemDto {

 String get id; String get day; String get time; String get destination; List<String> get childrenNames; String? get vehicleName; String get status;
/// Create a copy of WeeklyScheduleItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyScheduleItemDtoCopyWith<WeeklyScheduleItemDto> get copyWith => _$WeeklyScheduleItemDtoCopyWithImpl<WeeklyScheduleItemDto>(this as WeeklyScheduleItemDto, _$identity);

  /// Serializes this WeeklyScheduleItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyScheduleItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.time, time) || other.time == time)&&(identical(other.destination, destination) || other.destination == destination)&&const DeepCollectionEquality().equals(other.childrenNames, childrenNames)&&(identical(other.vehicleName, vehicleName) || other.vehicleName == vehicleName)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,day,time,destination,const DeepCollectionEquality().hash(childrenNames),vehicleName,status);

@override
String toString() {
  return 'WeeklyScheduleItemDto(id: $id, day: $day, time: $time, destination: $destination, childrenNames: $childrenNames, vehicleName: $vehicleName, status: $status)';
}


}

/// @nodoc
abstract mixin class $WeeklyScheduleItemDtoCopyWith<$Res>  {
  factory $WeeklyScheduleItemDtoCopyWith(WeeklyScheduleItemDto value, $Res Function(WeeklyScheduleItemDto) _then) = _$WeeklyScheduleItemDtoCopyWithImpl;
@useResult
$Res call({
 String id, String day, String time, String destination, List<String> childrenNames, String? vehicleName, String status
});




}
/// @nodoc
class _$WeeklyScheduleItemDtoCopyWithImpl<$Res>
    implements $WeeklyScheduleItemDtoCopyWith<$Res> {
  _$WeeklyScheduleItemDtoCopyWithImpl(this._self, this._then);

  final WeeklyScheduleItemDto _self;
  final $Res Function(WeeklyScheduleItemDto) _then;

/// Create a copy of WeeklyScheduleItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? day = null,Object? time = null,Object? destination = null,Object? childrenNames = null,Object? vehicleName = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,childrenNames: null == childrenNames ? _self.childrenNames : childrenNames // ignore: cast_nullable_to_non_nullable
as List<String>,vehicleName: freezed == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklyScheduleItemDto].
extension WeeklyScheduleItemDtoPatterns on WeeklyScheduleItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklyScheduleItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklyScheduleItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklyScheduleItemDto value)  $default,){
final _that = this;
switch (_that) {
case _WeeklyScheduleItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklyScheduleItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklyScheduleItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String day,  String time,  String destination,  List<String> childrenNames,  String? vehicleName,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklyScheduleItemDto() when $default != null:
return $default(_that.id,_that.day,_that.time,_that.destination,_that.childrenNames,_that.vehicleName,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String day,  String time,  String destination,  List<String> childrenNames,  String? vehicleName,  String status)  $default,) {final _that = this;
switch (_that) {
case _WeeklyScheduleItemDto():
return $default(_that.id,_that.day,_that.time,_that.destination,_that.childrenNames,_that.vehicleName,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String day,  String time,  String destination,  List<String> childrenNames,  String? vehicleName,  String status)?  $default,) {final _that = this;
switch (_that) {
case _WeeklyScheduleItemDto() when $default != null:
return $default(_that.id,_that.day,_that.time,_that.destination,_that.childrenNames,_that.vehicleName,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklyScheduleItemDto implements WeeklyScheduleItemDto {
  const _WeeklyScheduleItemDto({required this.id, required this.day, required this.time, required this.destination, required final  List<String> childrenNames, required this.vehicleName, required this.status}): _childrenNames = childrenNames;
  factory _WeeklyScheduleItemDto.fromJson(Map<String, dynamic> json) => _$WeeklyScheduleItemDtoFromJson(json);

@override final  String id;
@override final  String day;
@override final  String time;
@override final  String destination;
 final  List<String> _childrenNames;
@override List<String> get childrenNames {
  if (_childrenNames is EqualUnmodifiableListView) return _childrenNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_childrenNames);
}

@override final  String? vehicleName;
@override final  String status;

/// Create a copy of WeeklyScheduleItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyScheduleItemDtoCopyWith<_WeeklyScheduleItemDto> get copyWith => __$WeeklyScheduleItemDtoCopyWithImpl<_WeeklyScheduleItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyScheduleItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklyScheduleItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.time, time) || other.time == time)&&(identical(other.destination, destination) || other.destination == destination)&&const DeepCollectionEquality().equals(other._childrenNames, _childrenNames)&&(identical(other.vehicleName, vehicleName) || other.vehicleName == vehicleName)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,day,time,destination,const DeepCollectionEquality().hash(_childrenNames),vehicleName,status);

@override
String toString() {
  return 'WeeklyScheduleItemDto(id: $id, day: $day, time: $time, destination: $destination, childrenNames: $childrenNames, vehicleName: $vehicleName, status: $status)';
}


}

/// @nodoc
abstract mixin class _$WeeklyScheduleItemDtoCopyWith<$Res> implements $WeeklyScheduleItemDtoCopyWith<$Res> {
  factory _$WeeklyScheduleItemDtoCopyWith(_WeeklyScheduleItemDto value, $Res Function(_WeeklyScheduleItemDto) _then) = __$WeeklyScheduleItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String day, String time, String destination, List<String> childrenNames, String? vehicleName, String status
});




}
/// @nodoc
class __$WeeklyScheduleItemDtoCopyWithImpl<$Res>
    implements _$WeeklyScheduleItemDtoCopyWith<$Res> {
  __$WeeklyScheduleItemDtoCopyWithImpl(this._self, this._then);

  final _WeeklyScheduleItemDto _self;
  final $Res Function(_WeeklyScheduleItemDto) _then;

/// Create a copy of WeeklyScheduleItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? day = null,Object? time = null,Object? destination = null,Object? childrenNames = null,Object? vehicleName = freezed,Object? status = null,}) {
  return _then(_WeeklyScheduleItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,childrenNames: null == childrenNames ? _self._childrenNames : childrenNames // ignore: cast_nullable_to_non_nullable
as List<String>,vehicleName: freezed == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$WeeklyScheduleDto {

 List<WeeklyScheduleItemDto> get schedules; String get weekStart; String get weekEnd;
/// Create a copy of WeeklyScheduleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyScheduleDtoCopyWith<WeeklyScheduleDto> get copyWith => _$WeeklyScheduleDtoCopyWithImpl<WeeklyScheduleDto>(this as WeeklyScheduleDto, _$identity);

  /// Serializes this WeeklyScheduleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyScheduleDto&&const DeepCollectionEquality().equals(other.schedules, schedules)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&(identical(other.weekEnd, weekEnd) || other.weekEnd == weekEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(schedules),weekStart,weekEnd);

@override
String toString() {
  return 'WeeklyScheduleDto(schedules: $schedules, weekStart: $weekStart, weekEnd: $weekEnd)';
}


}

/// @nodoc
abstract mixin class $WeeklyScheduleDtoCopyWith<$Res>  {
  factory $WeeklyScheduleDtoCopyWith(WeeklyScheduleDto value, $Res Function(WeeklyScheduleDto) _then) = _$WeeklyScheduleDtoCopyWithImpl;
@useResult
$Res call({
 List<WeeklyScheduleItemDto> schedules, String weekStart, String weekEnd
});




}
/// @nodoc
class _$WeeklyScheduleDtoCopyWithImpl<$Res>
    implements $WeeklyScheduleDtoCopyWith<$Res> {
  _$WeeklyScheduleDtoCopyWithImpl(this._self, this._then);

  final WeeklyScheduleDto _self;
  final $Res Function(WeeklyScheduleDto) _then;

/// Create a copy of WeeklyScheduleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schedules = null,Object? weekStart = null,Object? weekEnd = null,}) {
  return _then(_self.copyWith(
schedules: null == schedules ? _self.schedules : schedules // ignore: cast_nullable_to_non_nullable
as List<WeeklyScheduleItemDto>,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as String,weekEnd: null == weekEnd ? _self.weekEnd : weekEnd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklyScheduleDto].
extension WeeklyScheduleDtoPatterns on WeeklyScheduleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklyScheduleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklyScheduleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklyScheduleDto value)  $default,){
final _that = this;
switch (_that) {
case _WeeklyScheduleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklyScheduleDto value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklyScheduleDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<WeeklyScheduleItemDto> schedules,  String weekStart,  String weekEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklyScheduleDto() when $default != null:
return $default(_that.schedules,_that.weekStart,_that.weekEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<WeeklyScheduleItemDto> schedules,  String weekStart,  String weekEnd)  $default,) {final _that = this;
switch (_that) {
case _WeeklyScheduleDto():
return $default(_that.schedules,_that.weekStart,_that.weekEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<WeeklyScheduleItemDto> schedules,  String weekStart,  String weekEnd)?  $default,) {final _that = this;
switch (_that) {
case _WeeklyScheduleDto() when $default != null:
return $default(_that.schedules,_that.weekStart,_that.weekEnd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklyScheduleDto implements WeeklyScheduleDto {
  const _WeeklyScheduleDto({required final  List<WeeklyScheduleItemDto> schedules, required this.weekStart, required this.weekEnd}): _schedules = schedules;
  factory _WeeklyScheduleDto.fromJson(Map<String, dynamic> json) => _$WeeklyScheduleDtoFromJson(json);

 final  List<WeeklyScheduleItemDto> _schedules;
@override List<WeeklyScheduleItemDto> get schedules {
  if (_schedules is EqualUnmodifiableListView) return _schedules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_schedules);
}

@override final  String weekStart;
@override final  String weekEnd;

/// Create a copy of WeeklyScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyScheduleDtoCopyWith<_WeeklyScheduleDto> get copyWith => __$WeeklyScheduleDtoCopyWithImpl<_WeeklyScheduleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyScheduleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklyScheduleDto&&const DeepCollectionEquality().equals(other._schedules, _schedules)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&(identical(other.weekEnd, weekEnd) || other.weekEnd == weekEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_schedules),weekStart,weekEnd);

@override
String toString() {
  return 'WeeklyScheduleDto(schedules: $schedules, weekStart: $weekStart, weekEnd: $weekEnd)';
}


}

/// @nodoc
abstract mixin class _$WeeklyScheduleDtoCopyWith<$Res> implements $WeeklyScheduleDtoCopyWith<$Res> {
  factory _$WeeklyScheduleDtoCopyWith(_WeeklyScheduleDto value, $Res Function(_WeeklyScheduleDto) _then) = __$WeeklyScheduleDtoCopyWithImpl;
@override @useResult
$Res call({
 List<WeeklyScheduleItemDto> schedules, String weekStart, String weekEnd
});




}
/// @nodoc
class __$WeeklyScheduleDtoCopyWithImpl<$Res>
    implements _$WeeklyScheduleDtoCopyWith<$Res> {
  __$WeeklyScheduleDtoCopyWithImpl(this._self, this._then);

  final _WeeklyScheduleDto _self;
  final $Res Function(_WeeklyScheduleDto) _then;

/// Create a copy of WeeklyScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schedules = null,Object? weekStart = null,Object? weekEnd = null,}) {
  return _then(_WeeklyScheduleDto(
schedules: null == schedules ? _self._schedules : schedules // ignore: cast_nullable_to_non_nullable
as List<WeeklyScheduleItemDto>,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as String,weekEnd: null == weekEnd ? _self.weekEnd : weekEnd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
