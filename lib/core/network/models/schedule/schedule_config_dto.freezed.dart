// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_config_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleConfigDto {

// Core ScheduleConfig fields from API
 String get id; String get groupId; Map<String, List<String>> get scheduleHours; DateTime? get createdAt; DateTime? get updatedAt;// Relations from API includes (nested objects)
 Map<String, dynamic>? get group; int? get totalSlots; bool get isDefault;
/// Create a copy of ScheduleConfigDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleConfigDtoCopyWith<ScheduleConfigDto> get copyWith => _$ScheduleConfigDtoCopyWithImpl<ScheduleConfigDto>(this as ScheduleConfigDto, _$identity);

  /// Serializes this ScheduleConfigDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleConfigDto&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&const DeepCollectionEquality().equals(other.scheduleHours, scheduleHours)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.group, group)&&(identical(other.totalSlots, totalSlots) || other.totalSlots == totalSlots)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,const DeepCollectionEquality().hash(scheduleHours),createdAt,updatedAt,const DeepCollectionEquality().hash(group),totalSlots,isDefault);

@override
String toString() {
  return 'ScheduleConfigDto(id: $id, groupId: $groupId, scheduleHours: $scheduleHours, createdAt: $createdAt, updatedAt: $updatedAt, group: $group, totalSlots: $totalSlots, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $ScheduleConfigDtoCopyWith<$Res>  {
  factory $ScheduleConfigDtoCopyWith(ScheduleConfigDto value, $Res Function(ScheduleConfigDto) _then) = _$ScheduleConfigDtoCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, Map<String, List<String>> scheduleHours, DateTime? createdAt, DateTime? updatedAt, Map<String, dynamic>? group, int? totalSlots, bool isDefault
});




}
/// @nodoc
class _$ScheduleConfigDtoCopyWithImpl<$Res>
    implements $ScheduleConfigDtoCopyWith<$Res> {
  _$ScheduleConfigDtoCopyWithImpl(this._self, this._then);

  final ScheduleConfigDto _self;
  final $Res Function(ScheduleConfigDto) _then;

/// Create a copy of ScheduleConfigDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? scheduleHours = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? group = freezed,Object? totalSlots = freezed,Object? isDefault = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,scheduleHours: null == scheduleHours ? _self.scheduleHours : scheduleHours // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,totalSlots: freezed == totalSlots ? _self.totalSlots : totalSlots // ignore: cast_nullable_to_non_nullable
as int?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleConfigDto].
extension ScheduleConfigDtoPatterns on ScheduleConfigDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleConfigDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleConfigDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleConfigDto value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleConfigDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleConfigDto value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleConfigDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  Map<String, List<String>> scheduleHours,  DateTime? createdAt,  DateTime? updatedAt,  Map<String, dynamic>? group,  int? totalSlots,  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleConfigDto() when $default != null:
return $default(_that.id,_that.groupId,_that.scheduleHours,_that.createdAt,_that.updatedAt,_that.group,_that.totalSlots,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  Map<String, List<String>> scheduleHours,  DateTime? createdAt,  DateTime? updatedAt,  Map<String, dynamic>? group,  int? totalSlots,  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _ScheduleConfigDto():
return $default(_that.id,_that.groupId,_that.scheduleHours,_that.createdAt,_that.updatedAt,_that.group,_that.totalSlots,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  Map<String, List<String>> scheduleHours,  DateTime? createdAt,  DateTime? updatedAt,  Map<String, dynamic>? group,  int? totalSlots,  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleConfigDto() when $default != null:
return $default(_that.id,_that.groupId,_that.scheduleHours,_that.createdAt,_that.updatedAt,_that.group,_that.totalSlots,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleConfigDto extends ScheduleConfigDto {
  const _ScheduleConfigDto({required this.id, required this.groupId, final  Map<String, List<String>> scheduleHours = const {}, this.createdAt, this.updatedAt, final  Map<String, dynamic>? group, this.totalSlots, this.isDefault = false}): _scheduleHours = scheduleHours,_group = group,super._();
  factory _ScheduleConfigDto.fromJson(Map<String, dynamic> json) => _$ScheduleConfigDtoFromJson(json);

// Core ScheduleConfig fields from API
@override final  String id;
@override final  String groupId;
 final  Map<String, List<String>> _scheduleHours;
@override@JsonKey() Map<String, List<String>> get scheduleHours {
  if (_scheduleHours is EqualUnmodifiableMapView) return _scheduleHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_scheduleHours);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
// Relations from API includes (nested objects)
 final  Map<String, dynamic>? _group;
// Relations from API includes (nested objects)
@override Map<String, dynamic>? get group {
  final value = _group;
  if (value == null) return null;
  if (_group is EqualUnmodifiableMapView) return _group;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  int? totalSlots;
@override@JsonKey() final  bool isDefault;

/// Create a copy of ScheduleConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleConfigDtoCopyWith<_ScheduleConfigDto> get copyWith => __$ScheduleConfigDtoCopyWithImpl<_ScheduleConfigDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleConfigDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleConfigDto&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&const DeepCollectionEquality().equals(other._scheduleHours, _scheduleHours)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._group, _group)&&(identical(other.totalSlots, totalSlots) || other.totalSlots == totalSlots)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,const DeepCollectionEquality().hash(_scheduleHours),createdAt,updatedAt,const DeepCollectionEquality().hash(_group),totalSlots,isDefault);

@override
String toString() {
  return 'ScheduleConfigDto(id: $id, groupId: $groupId, scheduleHours: $scheduleHours, createdAt: $createdAt, updatedAt: $updatedAt, group: $group, totalSlots: $totalSlots, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$ScheduleConfigDtoCopyWith<$Res> implements $ScheduleConfigDtoCopyWith<$Res> {
  factory _$ScheduleConfigDtoCopyWith(_ScheduleConfigDto value, $Res Function(_ScheduleConfigDto) _then) = __$ScheduleConfigDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, Map<String, List<String>> scheduleHours, DateTime? createdAt, DateTime? updatedAt, Map<String, dynamic>? group, int? totalSlots, bool isDefault
});




}
/// @nodoc
class __$ScheduleConfigDtoCopyWithImpl<$Res>
    implements _$ScheduleConfigDtoCopyWith<$Res> {
  __$ScheduleConfigDtoCopyWithImpl(this._self, this._then);

  final _ScheduleConfigDto _self;
  final $Res Function(_ScheduleConfigDto) _then;

/// Create a copy of ScheduleConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? scheduleHours = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? group = freezed,Object? totalSlots = freezed,Object? isDefault = null,}) {
  return _then(_ScheduleConfigDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,scheduleHours: null == scheduleHours ? _self._scheduleHours : scheduleHours // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,group: freezed == group ? _self._group : group // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,totalSlots: freezed == totalSlots ? _self.totalSlots : totalSlots // ignore: cast_nullable_to_non_nullable
as int?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
