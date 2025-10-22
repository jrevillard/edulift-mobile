// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'today_schedule_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TodayScheduleDto {

 String get id; String get time; String get destination; List<String> get childrenNames; String? get vehicleName; String get status;
/// Create a copy of TodayScheduleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayScheduleDtoCopyWith<TodayScheduleDto> get copyWith => _$TodayScheduleDtoCopyWithImpl<TodayScheduleDto>(this as TodayScheduleDto, _$identity);

  /// Serializes this TodayScheduleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayScheduleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.time, time) || other.time == time)&&(identical(other.destination, destination) || other.destination == destination)&&const DeepCollectionEquality().equals(other.childrenNames, childrenNames)&&(identical(other.vehicleName, vehicleName) || other.vehicleName == vehicleName)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,time,destination,const DeepCollectionEquality().hash(childrenNames),vehicleName,status);

@override
String toString() {
  return 'TodayScheduleDto(id: $id, time: $time, destination: $destination, childrenNames: $childrenNames, vehicleName: $vehicleName, status: $status)';
}


}

/// @nodoc
abstract mixin class $TodayScheduleDtoCopyWith<$Res>  {
  factory $TodayScheduleDtoCopyWith(TodayScheduleDto value, $Res Function(TodayScheduleDto) _then) = _$TodayScheduleDtoCopyWithImpl;
@useResult
$Res call({
 String id, String time, String destination, List<String> childrenNames, String? vehicleName, String status
});




}
/// @nodoc
class _$TodayScheduleDtoCopyWithImpl<$Res>
    implements $TodayScheduleDtoCopyWith<$Res> {
  _$TodayScheduleDtoCopyWithImpl(this._self, this._then);

  final TodayScheduleDto _self;
  final $Res Function(TodayScheduleDto) _then;

/// Create a copy of TodayScheduleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? time = null,Object? destination = null,Object? childrenNames = null,Object? vehicleName = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,childrenNames: null == childrenNames ? _self.childrenNames : childrenNames // ignore: cast_nullable_to_non_nullable
as List<String>,vehicleName: freezed == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayScheduleDto].
extension TodayScheduleDtoPatterns on TodayScheduleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayScheduleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayScheduleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayScheduleDto value)  $default,){
final _that = this;
switch (_that) {
case _TodayScheduleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayScheduleDto value)?  $default,){
final _that = this;
switch (_that) {
case _TodayScheduleDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String time,  String destination,  List<String> childrenNames,  String? vehicleName,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayScheduleDto() when $default != null:
return $default(_that.id,_that.time,_that.destination,_that.childrenNames,_that.vehicleName,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String time,  String destination,  List<String> childrenNames,  String? vehicleName,  String status)  $default,) {final _that = this;
switch (_that) {
case _TodayScheduleDto():
return $default(_that.id,_that.time,_that.destination,_that.childrenNames,_that.vehicleName,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String time,  String destination,  List<String> childrenNames,  String? vehicleName,  String status)?  $default,) {final _that = this;
switch (_that) {
case _TodayScheduleDto() when $default != null:
return $default(_that.id,_that.time,_that.destination,_that.childrenNames,_that.vehicleName,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodayScheduleDto implements TodayScheduleDto {
  const _TodayScheduleDto({required this.id, required this.time, required this.destination, required final  List<String> childrenNames, required this.vehicleName, required this.status}): _childrenNames = childrenNames;
  factory _TodayScheduleDto.fromJson(Map<String, dynamic> json) => _$TodayScheduleDtoFromJson(json);

@override final  String id;
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

/// Create a copy of TodayScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayScheduleDtoCopyWith<_TodayScheduleDto> get copyWith => __$TodayScheduleDtoCopyWithImpl<_TodayScheduleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodayScheduleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayScheduleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.time, time) || other.time == time)&&(identical(other.destination, destination) || other.destination == destination)&&const DeepCollectionEquality().equals(other._childrenNames, _childrenNames)&&(identical(other.vehicleName, vehicleName) || other.vehicleName == vehicleName)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,time,destination,const DeepCollectionEquality().hash(_childrenNames),vehicleName,status);

@override
String toString() {
  return 'TodayScheduleDto(id: $id, time: $time, destination: $destination, childrenNames: $childrenNames, vehicleName: $vehicleName, status: $status)';
}


}

/// @nodoc
abstract mixin class _$TodayScheduleDtoCopyWith<$Res> implements $TodayScheduleDtoCopyWith<$Res> {
  factory _$TodayScheduleDtoCopyWith(_TodayScheduleDto value, $Res Function(_TodayScheduleDto) _then) = __$TodayScheduleDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String time, String destination, List<String> childrenNames, String? vehicleName, String status
});




}
/// @nodoc
class __$TodayScheduleDtoCopyWithImpl<$Res>
    implements _$TodayScheduleDtoCopyWith<$Res> {
  __$TodayScheduleDtoCopyWithImpl(this._self, this._then);

  final _TodayScheduleDto _self;
  final $Res Function(_TodayScheduleDto) _then;

/// Create a copy of TodayScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? time = null,Object? destination = null,Object? childrenNames = null,Object? vehicleName = freezed,Object? status = null,}) {
  return _then(_TodayScheduleDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
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
mixin _$TodayScheduleListDto {

 List<TodayScheduleDto> get schedules; String get date;
/// Create a copy of TodayScheduleListDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayScheduleListDtoCopyWith<TodayScheduleListDto> get copyWith => _$TodayScheduleListDtoCopyWithImpl<TodayScheduleListDto>(this as TodayScheduleListDto, _$identity);

  /// Serializes this TodayScheduleListDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayScheduleListDto&&const DeepCollectionEquality().equals(other.schedules, schedules)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(schedules),date);

@override
String toString() {
  return 'TodayScheduleListDto(schedules: $schedules, date: $date)';
}


}

/// @nodoc
abstract mixin class $TodayScheduleListDtoCopyWith<$Res>  {
  factory $TodayScheduleListDtoCopyWith(TodayScheduleListDto value, $Res Function(TodayScheduleListDto) _then) = _$TodayScheduleListDtoCopyWithImpl;
@useResult
$Res call({
 List<TodayScheduleDto> schedules, String date
});




}
/// @nodoc
class _$TodayScheduleListDtoCopyWithImpl<$Res>
    implements $TodayScheduleListDtoCopyWith<$Res> {
  _$TodayScheduleListDtoCopyWithImpl(this._self, this._then);

  final TodayScheduleListDto _self;
  final $Res Function(TodayScheduleListDto) _then;

/// Create a copy of TodayScheduleListDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schedules = null,Object? date = null,}) {
  return _then(_self.copyWith(
schedules: null == schedules ? _self.schedules : schedules // ignore: cast_nullable_to_non_nullable
as List<TodayScheduleDto>,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayScheduleListDto].
extension TodayScheduleListDtoPatterns on TodayScheduleListDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayScheduleListDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayScheduleListDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayScheduleListDto value)  $default,){
final _that = this;
switch (_that) {
case _TodayScheduleListDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayScheduleListDto value)?  $default,){
final _that = this;
switch (_that) {
case _TodayScheduleListDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TodayScheduleDto> schedules,  String date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayScheduleListDto() when $default != null:
return $default(_that.schedules,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TodayScheduleDto> schedules,  String date)  $default,) {final _that = this;
switch (_that) {
case _TodayScheduleListDto():
return $default(_that.schedules,_that.date);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TodayScheduleDto> schedules,  String date)?  $default,) {final _that = this;
switch (_that) {
case _TodayScheduleListDto() when $default != null:
return $default(_that.schedules,_that.date);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodayScheduleListDto implements TodayScheduleListDto {
  const _TodayScheduleListDto({required final  List<TodayScheduleDto> schedules, required this.date}): _schedules = schedules;
  factory _TodayScheduleListDto.fromJson(Map<String, dynamic> json) => _$TodayScheduleListDtoFromJson(json);

 final  List<TodayScheduleDto> _schedules;
@override List<TodayScheduleDto> get schedules {
  if (_schedules is EqualUnmodifiableListView) return _schedules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_schedules);
}

@override final  String date;

/// Create a copy of TodayScheduleListDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayScheduleListDtoCopyWith<_TodayScheduleListDto> get copyWith => __$TodayScheduleListDtoCopyWithImpl<_TodayScheduleListDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodayScheduleListDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayScheduleListDto&&const DeepCollectionEquality().equals(other._schedules, _schedules)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_schedules),date);

@override
String toString() {
  return 'TodayScheduleListDto(schedules: $schedules, date: $date)';
}


}

/// @nodoc
abstract mixin class _$TodayScheduleListDtoCopyWith<$Res> implements $TodayScheduleListDtoCopyWith<$Res> {
  factory _$TodayScheduleListDtoCopyWith(_TodayScheduleListDto value, $Res Function(_TodayScheduleListDto) _then) = __$TodayScheduleListDtoCopyWithImpl;
@override @useResult
$Res call({
 List<TodayScheduleDto> schedules, String date
});




}
/// @nodoc
class __$TodayScheduleListDtoCopyWithImpl<$Res>
    implements _$TodayScheduleListDtoCopyWith<$Res> {
  __$TodayScheduleListDtoCopyWithImpl(this._self, this._then);

  final _TodayScheduleListDto _self;
  final $Res Function(_TodayScheduleListDto) _then;

/// Create a copy of TodayScheduleListDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schedules = null,Object? date = null,}) {
  return _then(_TodayScheduleListDto(
schedules: null == schedules ? _self._schedules : schedules // ignore: cast_nullable_to_non_nullable
as List<TodayScheduleDto>,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
