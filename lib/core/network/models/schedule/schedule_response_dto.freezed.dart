// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleResponseDto {

 String get groupId; String get startDate; String get endDate; List<ScheduleSlotDto> get scheduleSlots;
/// Create a copy of ScheduleResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleResponseDtoCopyWith<ScheduleResponseDto> get copyWith => _$ScheduleResponseDtoCopyWithImpl<ScheduleResponseDto>(this as ScheduleResponseDto, _$identity);

  /// Serializes this ScheduleResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleResponseDto&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.scheduleSlots, scheduleSlots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,startDate,endDate,const DeepCollectionEquality().hash(scheduleSlots));

@override
String toString() {
  return 'ScheduleResponseDto(groupId: $groupId, startDate: $startDate, endDate: $endDate, scheduleSlots: $scheduleSlots)';
}


}

/// @nodoc
abstract mixin class $ScheduleResponseDtoCopyWith<$Res>  {
  factory $ScheduleResponseDtoCopyWith(ScheduleResponseDto value, $Res Function(ScheduleResponseDto) _then) = _$ScheduleResponseDtoCopyWithImpl;
@useResult
$Res call({
 String groupId, String startDate, String endDate, List<ScheduleSlotDto> scheduleSlots
});




}
/// @nodoc
class _$ScheduleResponseDtoCopyWithImpl<$Res>
    implements $ScheduleResponseDtoCopyWith<$Res> {
  _$ScheduleResponseDtoCopyWithImpl(this._self, this._then);

  final ScheduleResponseDto _self;
  final $Res Function(ScheduleResponseDto) _then;

/// Create a copy of ScheduleResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupId = null,Object? startDate = null,Object? endDate = null,Object? scheduleSlots = null,}) {
  return _then(_self.copyWith(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,scheduleSlots: null == scheduleSlots ? _self.scheduleSlots : scheduleSlots // ignore: cast_nullable_to_non_nullable
as List<ScheduleSlotDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleResponseDto].
extension ScheduleResponseDtoPatterns on ScheduleResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String groupId,  String startDate,  String endDate,  List<ScheduleSlotDto> scheduleSlots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleResponseDto() when $default != null:
return $default(_that.groupId,_that.startDate,_that.endDate,_that.scheduleSlots);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String groupId,  String startDate,  String endDate,  List<ScheduleSlotDto> scheduleSlots)  $default,) {final _that = this;
switch (_that) {
case _ScheduleResponseDto():
return $default(_that.groupId,_that.startDate,_that.endDate,_that.scheduleSlots);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String groupId,  String startDate,  String endDate,  List<ScheduleSlotDto> scheduleSlots)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleResponseDto() when $default != null:
return $default(_that.groupId,_that.startDate,_that.endDate,_that.scheduleSlots);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleResponseDto extends ScheduleResponseDto {
  const _ScheduleResponseDto({required this.groupId, required this.startDate, required this.endDate, required final  List<ScheduleSlotDto> scheduleSlots}): _scheduleSlots = scheduleSlots,super._();
  factory _ScheduleResponseDto.fromJson(Map<String, dynamic> json) => _$ScheduleResponseDtoFromJson(json);

@override final  String groupId;
@override final  String startDate;
@override final  String endDate;
 final  List<ScheduleSlotDto> _scheduleSlots;
@override List<ScheduleSlotDto> get scheduleSlots {
  if (_scheduleSlots is EqualUnmodifiableListView) return _scheduleSlots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scheduleSlots);
}


/// Create a copy of ScheduleResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleResponseDtoCopyWith<_ScheduleResponseDto> get copyWith => __$ScheduleResponseDtoCopyWithImpl<_ScheduleResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleResponseDto&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._scheduleSlots, _scheduleSlots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,startDate,endDate,const DeepCollectionEquality().hash(_scheduleSlots));

@override
String toString() {
  return 'ScheduleResponseDto(groupId: $groupId, startDate: $startDate, endDate: $endDate, scheduleSlots: $scheduleSlots)';
}


}

/// @nodoc
abstract mixin class _$ScheduleResponseDtoCopyWith<$Res> implements $ScheduleResponseDtoCopyWith<$Res> {
  factory _$ScheduleResponseDtoCopyWith(_ScheduleResponseDto value, $Res Function(_ScheduleResponseDto) _then) = __$ScheduleResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String groupId, String startDate, String endDate, List<ScheduleSlotDto> scheduleSlots
});




}
/// @nodoc
class __$ScheduleResponseDtoCopyWithImpl<$Res>
    implements _$ScheduleResponseDtoCopyWith<$Res> {
  __$ScheduleResponseDtoCopyWithImpl(this._self, this._then);

  final _ScheduleResponseDto _self;
  final $Res Function(_ScheduleResponseDto) _then;

/// Create a copy of ScheduleResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? startDate = null,Object? endDate = null,Object? scheduleSlots = null,}) {
  return _then(_ScheduleResponseDto(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,scheduleSlots: null == scheduleSlots ? _self._scheduleSlots : scheduleSlots // ignore: cast_nullable_to_non_nullable
as List<ScheduleSlotDto>,
  ));
}


}

// dart format on
