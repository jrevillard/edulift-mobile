// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'displayable_time_slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DisplayableTimeSlot {

/// Day of the week for this slot
 DayOfWeek get dayOfWeek;/// Time of day for this slot
 TimeOfDayValue get timeOfDay;/// Week identifier (ISO format: "2025-W46")
 String get week;/// The actual schedule slot from backend (null if not yet created)
 ScheduleSlot? get scheduleSlot;/// Whether this slot exists in the backend
 bool get existsInBackend;
/// Create a copy of DisplayableTimeSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisplayableTimeSlotCopyWith<DisplayableTimeSlot> get copyWith => _$DisplayableTimeSlotCopyWithImpl<DisplayableTimeSlot>(this as DisplayableTimeSlot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisplayableTimeSlot&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.timeOfDay, timeOfDay) || other.timeOfDay == timeOfDay)&&(identical(other.week, week) || other.week == week)&&(identical(other.scheduleSlot, scheduleSlot) || other.scheduleSlot == scheduleSlot)&&(identical(other.existsInBackend, existsInBackend) || other.existsInBackend == existsInBackend));
}


@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,timeOfDay,week,scheduleSlot,existsInBackend);

@override
String toString() {
  return 'DisplayableTimeSlot(dayOfWeek: $dayOfWeek, timeOfDay: $timeOfDay, week: $week, scheduleSlot: $scheduleSlot, existsInBackend: $existsInBackend)';
}


}

/// @nodoc
abstract mixin class $DisplayableTimeSlotCopyWith<$Res>  {
  factory $DisplayableTimeSlotCopyWith(DisplayableTimeSlot value, $Res Function(DisplayableTimeSlot) _then) = _$DisplayableTimeSlotCopyWithImpl;
@useResult
$Res call({
 DayOfWeek dayOfWeek, TimeOfDayValue timeOfDay, String week, ScheduleSlot? scheduleSlot, bool existsInBackend
});




}
/// @nodoc
class _$DisplayableTimeSlotCopyWithImpl<$Res>
    implements $DisplayableTimeSlotCopyWith<$Res> {
  _$DisplayableTimeSlotCopyWithImpl(this._self, this._then);

  final DisplayableTimeSlot _self;
  final $Res Function(DisplayableTimeSlot) _then;

/// Create a copy of DisplayableTimeSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayOfWeek = null,Object? timeOfDay = null,Object? week = null,Object? scheduleSlot = freezed,Object? existsInBackend = null,}) {
  return _then(_self.copyWith(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as DayOfWeek,timeOfDay: null == timeOfDay ? _self.timeOfDay : timeOfDay // ignore: cast_nullable_to_non_nullable
as TimeOfDayValue,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as String,scheduleSlot: freezed == scheduleSlot ? _self.scheduleSlot : scheduleSlot // ignore: cast_nullable_to_non_nullable
as ScheduleSlot?,existsInBackend: null == existsInBackend ? _self.existsInBackend : existsInBackend // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DisplayableTimeSlot].
extension DisplayableTimeSlotPatterns on DisplayableTimeSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisplayableTimeSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisplayableTimeSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisplayableTimeSlot value)  $default,){
final _that = this;
switch (_that) {
case _DisplayableTimeSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisplayableTimeSlot value)?  $default,){
final _that = this;
switch (_that) {
case _DisplayableTimeSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DayOfWeek dayOfWeek,  TimeOfDayValue timeOfDay,  String week,  ScheduleSlot? scheduleSlot,  bool existsInBackend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisplayableTimeSlot() when $default != null:
return $default(_that.dayOfWeek,_that.timeOfDay,_that.week,_that.scheduleSlot,_that.existsInBackend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DayOfWeek dayOfWeek,  TimeOfDayValue timeOfDay,  String week,  ScheduleSlot? scheduleSlot,  bool existsInBackend)  $default,) {final _that = this;
switch (_that) {
case _DisplayableTimeSlot():
return $default(_that.dayOfWeek,_that.timeOfDay,_that.week,_that.scheduleSlot,_that.existsInBackend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DayOfWeek dayOfWeek,  TimeOfDayValue timeOfDay,  String week,  ScheduleSlot? scheduleSlot,  bool existsInBackend)?  $default,) {final _that = this;
switch (_that) {
case _DisplayableTimeSlot() when $default != null:
return $default(_that.dayOfWeek,_that.timeOfDay,_that.week,_that.scheduleSlot,_that.existsInBackend);case _:
  return null;

}
}

}

/// @nodoc


class _DisplayableTimeSlot extends DisplayableTimeSlot {
  const _DisplayableTimeSlot({required this.dayOfWeek, required this.timeOfDay, required this.week, this.scheduleSlot, required this.existsInBackend}): super._();
  

/// Day of the week for this slot
@override final  DayOfWeek dayOfWeek;
/// Time of day for this slot
@override final  TimeOfDayValue timeOfDay;
/// Week identifier (ISO format: "2025-W46")
@override final  String week;
/// The actual schedule slot from backend (null if not yet created)
@override final  ScheduleSlot? scheduleSlot;
/// Whether this slot exists in the backend
@override final  bool existsInBackend;

/// Create a copy of DisplayableTimeSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisplayableTimeSlotCopyWith<_DisplayableTimeSlot> get copyWith => __$DisplayableTimeSlotCopyWithImpl<_DisplayableTimeSlot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisplayableTimeSlot&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.timeOfDay, timeOfDay) || other.timeOfDay == timeOfDay)&&(identical(other.week, week) || other.week == week)&&(identical(other.scheduleSlot, scheduleSlot) || other.scheduleSlot == scheduleSlot)&&(identical(other.existsInBackend, existsInBackend) || other.existsInBackend == existsInBackend));
}


@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,timeOfDay,week,scheduleSlot,existsInBackend);

@override
String toString() {
  return 'DisplayableTimeSlot(dayOfWeek: $dayOfWeek, timeOfDay: $timeOfDay, week: $week, scheduleSlot: $scheduleSlot, existsInBackend: $existsInBackend)';
}


}

/// @nodoc
abstract mixin class _$DisplayableTimeSlotCopyWith<$Res> implements $DisplayableTimeSlotCopyWith<$Res> {
  factory _$DisplayableTimeSlotCopyWith(_DisplayableTimeSlot value, $Res Function(_DisplayableTimeSlot) _then) = __$DisplayableTimeSlotCopyWithImpl;
@override @useResult
$Res call({
 DayOfWeek dayOfWeek, TimeOfDayValue timeOfDay, String week, ScheduleSlot? scheduleSlot, bool existsInBackend
});




}
/// @nodoc
class __$DisplayableTimeSlotCopyWithImpl<$Res>
    implements _$DisplayableTimeSlotCopyWith<$Res> {
  __$DisplayableTimeSlotCopyWithImpl(this._self, this._then);

  final _DisplayableTimeSlot _self;
  final $Res Function(_DisplayableTimeSlot) _then;

/// Create a copy of DisplayableTimeSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayOfWeek = null,Object? timeOfDay = null,Object? week = null,Object? scheduleSlot = freezed,Object? existsInBackend = null,}) {
  return _then(_DisplayableTimeSlot(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as DayOfWeek,timeOfDay: null == timeOfDay ? _self.timeOfDay : timeOfDay // ignore: cast_nullable_to_non_nullable
as TimeOfDayValue,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as String,scheduleSlot: freezed == scheduleSlot ? _self.scheduleSlot : scheduleSlot // ignore: cast_nullable_to_non_nullable
as ScheduleSlot?,existsInBackend: null == existsInBackend ? _self.existsInBackend : existsInBackend // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
