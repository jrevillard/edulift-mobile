// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fcm_token_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FcmTokenDto {

 String get id; String get platform; bool get isActive; String? get deviceId; String? get createdAt; String? get lastUsed;
/// Create a copy of FcmTokenDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FcmTokenDtoCopyWith<FcmTokenDto> get copyWith => _$FcmTokenDtoCopyWithImpl<FcmTokenDto>(this as FcmTokenDto, _$identity);

  /// Serializes this FcmTokenDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FcmTokenDto&&(identical(other.id, id) || other.id == id)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUsed, lastUsed) || other.lastUsed == lastUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,platform,isActive,deviceId,createdAt,lastUsed);

@override
String toString() {
  return 'FcmTokenDto(id: $id, platform: $platform, isActive: $isActive, deviceId: $deviceId, createdAt: $createdAt, lastUsed: $lastUsed)';
}


}

/// @nodoc
abstract mixin class $FcmTokenDtoCopyWith<$Res>  {
  factory $FcmTokenDtoCopyWith(FcmTokenDto value, $Res Function(FcmTokenDto) _then) = _$FcmTokenDtoCopyWithImpl;
@useResult
$Res call({
 String id, String platform, bool isActive, String? deviceId, String? createdAt, String? lastUsed
});




}
/// @nodoc
class _$FcmTokenDtoCopyWithImpl<$Res>
    implements $FcmTokenDtoCopyWith<$Res> {
  _$FcmTokenDtoCopyWithImpl(this._self, this._then);

  final FcmTokenDto _self;
  final $Res Function(FcmTokenDto) _then;

/// Create a copy of FcmTokenDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? platform = null,Object? isActive = null,Object? deviceId = freezed,Object? createdAt = freezed,Object? lastUsed = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,lastUsed: freezed == lastUsed ? _self.lastUsed : lastUsed // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FcmTokenDto].
extension FcmTokenDtoPatterns on FcmTokenDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FcmTokenDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FcmTokenDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FcmTokenDto value)  $default,){
final _that = this;
switch (_that) {
case _FcmTokenDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FcmTokenDto value)?  $default,){
final _that = this;
switch (_that) {
case _FcmTokenDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String platform,  bool isActive,  String? deviceId,  String? createdAt,  String? lastUsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FcmTokenDto() when $default != null:
return $default(_that.id,_that.platform,_that.isActive,_that.deviceId,_that.createdAt,_that.lastUsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String platform,  bool isActive,  String? deviceId,  String? createdAt,  String? lastUsed)  $default,) {final _that = this;
switch (_that) {
case _FcmTokenDto():
return $default(_that.id,_that.platform,_that.isActive,_that.deviceId,_that.createdAt,_that.lastUsed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String platform,  bool isActive,  String? deviceId,  String? createdAt,  String? lastUsed)?  $default,) {final _that = this;
switch (_that) {
case _FcmTokenDto() when $default != null:
return $default(_that.id,_that.platform,_that.isActive,_that.deviceId,_that.createdAt,_that.lastUsed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FcmTokenDto implements FcmTokenDto {
  const _FcmTokenDto({required this.id, required this.platform, required this.isActive, this.deviceId, this.createdAt, this.lastUsed});
  factory _FcmTokenDto.fromJson(Map<String, dynamic> json) => _$FcmTokenDtoFromJson(json);

@override final  String id;
@override final  String platform;
@override final  bool isActive;
@override final  String? deviceId;
@override final  String? createdAt;
@override final  String? lastUsed;

/// Create a copy of FcmTokenDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FcmTokenDtoCopyWith<_FcmTokenDto> get copyWith => __$FcmTokenDtoCopyWithImpl<_FcmTokenDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FcmTokenDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FcmTokenDto&&(identical(other.id, id) || other.id == id)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUsed, lastUsed) || other.lastUsed == lastUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,platform,isActive,deviceId,createdAt,lastUsed);

@override
String toString() {
  return 'FcmTokenDto(id: $id, platform: $platform, isActive: $isActive, deviceId: $deviceId, createdAt: $createdAt, lastUsed: $lastUsed)';
}


}

/// @nodoc
abstract mixin class _$FcmTokenDtoCopyWith<$Res> implements $FcmTokenDtoCopyWith<$Res> {
  factory _$FcmTokenDtoCopyWith(_FcmTokenDto value, $Res Function(_FcmTokenDto) _then) = __$FcmTokenDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String platform, bool isActive, String? deviceId, String? createdAt, String? lastUsed
});




}
/// @nodoc
class __$FcmTokenDtoCopyWithImpl<$Res>
    implements _$FcmTokenDtoCopyWith<$Res> {
  __$FcmTokenDtoCopyWithImpl(this._self, this._then);

  final _FcmTokenDto _self;
  final $Res Function(_FcmTokenDto) _then;

/// Create a copy of FcmTokenDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? platform = null,Object? isActive = null,Object? deviceId = freezed,Object? createdAt = freezed,Object? lastUsed = freezed,}) {
  return _then(_FcmTokenDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,lastUsed: freezed == lastUsed ? _self.lastUsed : lastUsed // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FcmTokenListDto {

 List<FcmTokenDto> get tokens;
/// Create a copy of FcmTokenListDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FcmTokenListDtoCopyWith<FcmTokenListDto> get copyWith => _$FcmTokenListDtoCopyWithImpl<FcmTokenListDto>(this as FcmTokenListDto, _$identity);

  /// Serializes this FcmTokenListDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FcmTokenListDto&&const DeepCollectionEquality().equals(other.tokens, tokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tokens));

@override
String toString() {
  return 'FcmTokenListDto(tokens: $tokens)';
}


}

/// @nodoc
abstract mixin class $FcmTokenListDtoCopyWith<$Res>  {
  factory $FcmTokenListDtoCopyWith(FcmTokenListDto value, $Res Function(FcmTokenListDto) _then) = _$FcmTokenListDtoCopyWithImpl;
@useResult
$Res call({
 List<FcmTokenDto> tokens
});




}
/// @nodoc
class _$FcmTokenListDtoCopyWithImpl<$Res>
    implements $FcmTokenListDtoCopyWith<$Res> {
  _$FcmTokenListDtoCopyWithImpl(this._self, this._then);

  final FcmTokenListDto _self;
  final $Res Function(FcmTokenListDto) _then;

/// Create a copy of FcmTokenListDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tokens = null,}) {
  return _then(_self.copyWith(
tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as List<FcmTokenDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [FcmTokenListDto].
extension FcmTokenListDtoPatterns on FcmTokenListDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FcmTokenListDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FcmTokenListDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FcmTokenListDto value)  $default,){
final _that = this;
switch (_that) {
case _FcmTokenListDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FcmTokenListDto value)?  $default,){
final _that = this;
switch (_that) {
case _FcmTokenListDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FcmTokenDto> tokens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FcmTokenListDto() when $default != null:
return $default(_that.tokens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FcmTokenDto> tokens)  $default,) {final _that = this;
switch (_that) {
case _FcmTokenListDto():
return $default(_that.tokens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FcmTokenDto> tokens)?  $default,) {final _that = this;
switch (_that) {
case _FcmTokenListDto() when $default != null:
return $default(_that.tokens);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FcmTokenListDto implements FcmTokenListDto {
  const _FcmTokenListDto({required final  List<FcmTokenDto> tokens}): _tokens = tokens;
  factory _FcmTokenListDto.fromJson(Map<String, dynamic> json) => _$FcmTokenListDtoFromJson(json);

 final  List<FcmTokenDto> _tokens;
@override List<FcmTokenDto> get tokens {
  if (_tokens is EqualUnmodifiableListView) return _tokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tokens);
}


/// Create a copy of FcmTokenListDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FcmTokenListDtoCopyWith<_FcmTokenListDto> get copyWith => __$FcmTokenListDtoCopyWithImpl<_FcmTokenListDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FcmTokenListDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FcmTokenListDto&&const DeepCollectionEquality().equals(other._tokens, _tokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tokens));

@override
String toString() {
  return 'FcmTokenListDto(tokens: $tokens)';
}


}

/// @nodoc
abstract mixin class _$FcmTokenListDtoCopyWith<$Res> implements $FcmTokenListDtoCopyWith<$Res> {
  factory _$FcmTokenListDtoCopyWith(_FcmTokenListDto value, $Res Function(_FcmTokenListDto) _then) = __$FcmTokenListDtoCopyWithImpl;
@override @useResult
$Res call({
 List<FcmTokenDto> tokens
});




}
/// @nodoc
class __$FcmTokenListDtoCopyWithImpl<$Res>
    implements _$FcmTokenListDtoCopyWith<$Res> {
  __$FcmTokenListDtoCopyWithImpl(this._self, this._then);

  final _FcmTokenListDto _self;
  final $Res Function(_FcmTokenListDto) _then;

/// Create a copy of FcmTokenListDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tokens = null,}) {
  return _then(_FcmTokenListDto(
tokens: null == tokens ? _self._tokens : tokens // ignore: cast_nullable_to_non_nullable
as List<FcmTokenDto>,
  ));
}


}


/// @nodoc
mixin _$ValidateTokenDto {

 String get token; bool get isValid; bool get isServiceAvailable;
/// Create a copy of ValidateTokenDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidateTokenDtoCopyWith<ValidateTokenDto> get copyWith => _$ValidateTokenDtoCopyWithImpl<ValidateTokenDto>(this as ValidateTokenDto, _$identity);

  /// Serializes this ValidateTokenDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidateTokenDto&&(identical(other.token, token) || other.token == token)&&(identical(other.isValid, isValid) || other.isValid == isValid)&&(identical(other.isServiceAvailable, isServiceAvailable) || other.isServiceAvailable == isServiceAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,isValid,isServiceAvailable);

@override
String toString() {
  return 'ValidateTokenDto(token: $token, isValid: $isValid, isServiceAvailable: $isServiceAvailable)';
}


}

/// @nodoc
abstract mixin class $ValidateTokenDtoCopyWith<$Res>  {
  factory $ValidateTokenDtoCopyWith(ValidateTokenDto value, $Res Function(ValidateTokenDto) _then) = _$ValidateTokenDtoCopyWithImpl;
@useResult
$Res call({
 String token, bool isValid, bool isServiceAvailable
});




}
/// @nodoc
class _$ValidateTokenDtoCopyWithImpl<$Res>
    implements $ValidateTokenDtoCopyWith<$Res> {
  _$ValidateTokenDtoCopyWithImpl(this._self, this._then);

  final ValidateTokenDto _self;
  final $Res Function(ValidateTokenDto) _then;

/// Create a copy of ValidateTokenDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? isValid = null,Object? isServiceAvailable = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,isServiceAvailable: null == isServiceAvailable ? _self.isServiceAvailable : isServiceAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ValidateTokenDto].
extension ValidateTokenDtoPatterns on ValidateTokenDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ValidateTokenDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ValidateTokenDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ValidateTokenDto value)  $default,){
final _that = this;
switch (_that) {
case _ValidateTokenDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ValidateTokenDto value)?  $default,){
final _that = this;
switch (_that) {
case _ValidateTokenDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  bool isValid,  bool isServiceAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ValidateTokenDto() when $default != null:
return $default(_that.token,_that.isValid,_that.isServiceAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  bool isValid,  bool isServiceAvailable)  $default,) {final _that = this;
switch (_that) {
case _ValidateTokenDto():
return $default(_that.token,_that.isValid,_that.isServiceAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  bool isValid,  bool isServiceAvailable)?  $default,) {final _that = this;
switch (_that) {
case _ValidateTokenDto() when $default != null:
return $default(_that.token,_that.isValid,_that.isServiceAvailable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ValidateTokenDto implements ValidateTokenDto {
  const _ValidateTokenDto({required this.token, required this.isValid, required this.isServiceAvailable});
  factory _ValidateTokenDto.fromJson(Map<String, dynamic> json) => _$ValidateTokenDtoFromJson(json);

@override final  String token;
@override final  bool isValid;
@override final  bool isServiceAvailable;

/// Create a copy of ValidateTokenDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidateTokenDtoCopyWith<_ValidateTokenDto> get copyWith => __$ValidateTokenDtoCopyWithImpl<_ValidateTokenDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ValidateTokenDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ValidateTokenDto&&(identical(other.token, token) || other.token == token)&&(identical(other.isValid, isValid) || other.isValid == isValid)&&(identical(other.isServiceAvailable, isServiceAvailable) || other.isServiceAvailable == isServiceAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,isValid,isServiceAvailable);

@override
String toString() {
  return 'ValidateTokenDto(token: $token, isValid: $isValid, isServiceAvailable: $isServiceAvailable)';
}


}

/// @nodoc
abstract mixin class _$ValidateTokenDtoCopyWith<$Res> implements $ValidateTokenDtoCopyWith<$Res> {
  factory _$ValidateTokenDtoCopyWith(_ValidateTokenDto value, $Res Function(_ValidateTokenDto) _then) = __$ValidateTokenDtoCopyWithImpl;
@override @useResult
$Res call({
 String token, bool isValid, bool isServiceAvailable
});




}
/// @nodoc
class __$ValidateTokenDtoCopyWithImpl<$Res>
    implements _$ValidateTokenDtoCopyWith<$Res> {
  __$ValidateTokenDtoCopyWithImpl(this._self, this._then);

  final _ValidateTokenDto _self;
  final $Res Function(_ValidateTokenDto) _then;

/// Create a copy of ValidateTokenDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? isValid = null,Object? isServiceAvailable = null,}) {
  return _then(_ValidateTokenDto(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,isServiceAvailable: null == isServiceAvailable ? _self.isServiceAvailable : isServiceAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SubscribeDto {

 String get token; String get topic; bool get subscribed;
/// Create a copy of SubscribeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscribeDtoCopyWith<SubscribeDto> get copyWith => _$SubscribeDtoCopyWithImpl<SubscribeDto>(this as SubscribeDto, _$identity);

  /// Serializes this SubscribeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscribeDto&&(identical(other.token, token) || other.token == token)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,topic,subscribed);

@override
String toString() {
  return 'SubscribeDto(token: $token, topic: $topic, subscribed: $subscribed)';
}


}

/// @nodoc
abstract mixin class $SubscribeDtoCopyWith<$Res>  {
  factory $SubscribeDtoCopyWith(SubscribeDto value, $Res Function(SubscribeDto) _then) = _$SubscribeDtoCopyWithImpl;
@useResult
$Res call({
 String token, String topic, bool subscribed
});




}
/// @nodoc
class _$SubscribeDtoCopyWithImpl<$Res>
    implements $SubscribeDtoCopyWith<$Res> {
  _$SubscribeDtoCopyWithImpl(this._self, this._then);

  final SubscribeDto _self;
  final $Res Function(SubscribeDto) _then;

/// Create a copy of SubscribeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? topic = null,Object? subscribed = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,subscribed: null == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscribeDto].
extension SubscribeDtoPatterns on SubscribeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscribeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscribeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscribeDto value)  $default,){
final _that = this;
switch (_that) {
case _SubscribeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscribeDto value)?  $default,){
final _that = this;
switch (_that) {
case _SubscribeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String topic,  bool subscribed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscribeDto() when $default != null:
return $default(_that.token,_that.topic,_that.subscribed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String topic,  bool subscribed)  $default,) {final _that = this;
switch (_that) {
case _SubscribeDto():
return $default(_that.token,_that.topic,_that.subscribed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String topic,  bool subscribed)?  $default,) {final _that = this;
switch (_that) {
case _SubscribeDto() when $default != null:
return $default(_that.token,_that.topic,_that.subscribed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscribeDto implements SubscribeDto {
  const _SubscribeDto({required this.token, required this.topic, required this.subscribed});
  factory _SubscribeDto.fromJson(Map<String, dynamic> json) => _$SubscribeDtoFromJson(json);

@override final  String token;
@override final  String topic;
@override final  bool subscribed;

/// Create a copy of SubscribeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscribeDtoCopyWith<_SubscribeDto> get copyWith => __$SubscribeDtoCopyWithImpl<_SubscribeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscribeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscribeDto&&(identical(other.token, token) || other.token == token)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,topic,subscribed);

@override
String toString() {
  return 'SubscribeDto(token: $token, topic: $topic, subscribed: $subscribed)';
}


}

/// @nodoc
abstract mixin class _$SubscribeDtoCopyWith<$Res> implements $SubscribeDtoCopyWith<$Res> {
  factory _$SubscribeDtoCopyWith(_SubscribeDto value, $Res Function(_SubscribeDto) _then) = __$SubscribeDtoCopyWithImpl;
@override @useResult
$Res call({
 String token, String topic, bool subscribed
});




}
/// @nodoc
class __$SubscribeDtoCopyWithImpl<$Res>
    implements _$SubscribeDtoCopyWith<$Res> {
  __$SubscribeDtoCopyWithImpl(this._self, this._then);

  final _SubscribeDto _self;
  final $Res Function(_SubscribeDto) _then;

/// Create a copy of SubscribeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? topic = null,Object? subscribed = null,}) {
  return _then(_SubscribeDto(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,subscribed: null == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TestNotificationDto {

 int get successCount; int get failureCount; List<String> get invalidTokens; int get totalTokens;
/// Create a copy of TestNotificationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TestNotificationDtoCopyWith<TestNotificationDto> get copyWith => _$TestNotificationDtoCopyWithImpl<TestNotificationDto>(this as TestNotificationDto, _$identity);

  /// Serializes this TestNotificationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TestNotificationDto&&(identical(other.successCount, successCount) || other.successCount == successCount)&&(identical(other.failureCount, failureCount) || other.failureCount == failureCount)&&const DeepCollectionEquality().equals(other.invalidTokens, invalidTokens)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,successCount,failureCount,const DeepCollectionEquality().hash(invalidTokens),totalTokens);

@override
String toString() {
  return 'TestNotificationDto(successCount: $successCount, failureCount: $failureCount, invalidTokens: $invalidTokens, totalTokens: $totalTokens)';
}


}

/// @nodoc
abstract mixin class $TestNotificationDtoCopyWith<$Res>  {
  factory $TestNotificationDtoCopyWith(TestNotificationDto value, $Res Function(TestNotificationDto) _then) = _$TestNotificationDtoCopyWithImpl;
@useResult
$Res call({
 int successCount, int failureCount, List<String> invalidTokens, int totalTokens
});




}
/// @nodoc
class _$TestNotificationDtoCopyWithImpl<$Res>
    implements $TestNotificationDtoCopyWith<$Res> {
  _$TestNotificationDtoCopyWithImpl(this._self, this._then);

  final TestNotificationDto _self;
  final $Res Function(TestNotificationDto) _then;

/// Create a copy of TestNotificationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? successCount = null,Object? failureCount = null,Object? invalidTokens = null,Object? totalTokens = null,}) {
  return _then(_self.copyWith(
successCount: null == successCount ? _self.successCount : successCount // ignore: cast_nullable_to_non_nullable
as int,failureCount: null == failureCount ? _self.failureCount : failureCount // ignore: cast_nullable_to_non_nullable
as int,invalidTokens: null == invalidTokens ? _self.invalidTokens : invalidTokens // ignore: cast_nullable_to_non_nullable
as List<String>,totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TestNotificationDto].
extension TestNotificationDtoPatterns on TestNotificationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TestNotificationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TestNotificationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TestNotificationDto value)  $default,){
final _that = this;
switch (_that) {
case _TestNotificationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TestNotificationDto value)?  $default,){
final _that = this;
switch (_that) {
case _TestNotificationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int successCount,  int failureCount,  List<String> invalidTokens,  int totalTokens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TestNotificationDto() when $default != null:
return $default(_that.successCount,_that.failureCount,_that.invalidTokens,_that.totalTokens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int successCount,  int failureCount,  List<String> invalidTokens,  int totalTokens)  $default,) {final _that = this;
switch (_that) {
case _TestNotificationDto():
return $default(_that.successCount,_that.failureCount,_that.invalidTokens,_that.totalTokens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int successCount,  int failureCount,  List<String> invalidTokens,  int totalTokens)?  $default,) {final _that = this;
switch (_that) {
case _TestNotificationDto() when $default != null:
return $default(_that.successCount,_that.failureCount,_that.invalidTokens,_that.totalTokens);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TestNotificationDto implements TestNotificationDto {
  const _TestNotificationDto({required this.successCount, required this.failureCount, required final  List<String> invalidTokens, required this.totalTokens}): _invalidTokens = invalidTokens;
  factory _TestNotificationDto.fromJson(Map<String, dynamic> json) => _$TestNotificationDtoFromJson(json);

@override final  int successCount;
@override final  int failureCount;
 final  List<String> _invalidTokens;
@override List<String> get invalidTokens {
  if (_invalidTokens is EqualUnmodifiableListView) return _invalidTokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invalidTokens);
}

@override final  int totalTokens;

/// Create a copy of TestNotificationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TestNotificationDtoCopyWith<_TestNotificationDto> get copyWith => __$TestNotificationDtoCopyWithImpl<_TestNotificationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TestNotificationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TestNotificationDto&&(identical(other.successCount, successCount) || other.successCount == successCount)&&(identical(other.failureCount, failureCount) || other.failureCount == failureCount)&&const DeepCollectionEquality().equals(other._invalidTokens, _invalidTokens)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,successCount,failureCount,const DeepCollectionEquality().hash(_invalidTokens),totalTokens);

@override
String toString() {
  return 'TestNotificationDto(successCount: $successCount, failureCount: $failureCount, invalidTokens: $invalidTokens, totalTokens: $totalTokens)';
}


}

/// @nodoc
abstract mixin class _$TestNotificationDtoCopyWith<$Res> implements $TestNotificationDtoCopyWith<$Res> {
  factory _$TestNotificationDtoCopyWith(_TestNotificationDto value, $Res Function(_TestNotificationDto) _then) = __$TestNotificationDtoCopyWithImpl;
@override @useResult
$Res call({
 int successCount, int failureCount, List<String> invalidTokens, int totalTokens
});




}
/// @nodoc
class __$TestNotificationDtoCopyWithImpl<$Res>
    implements _$TestNotificationDtoCopyWith<$Res> {
  __$TestNotificationDtoCopyWithImpl(this._self, this._then);

  final _TestNotificationDto _self;
  final $Res Function(_TestNotificationDto) _then;

/// Create a copy of TestNotificationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? successCount = null,Object? failureCount = null,Object? invalidTokens = null,Object? totalTokens = null,}) {
  return _then(_TestNotificationDto(
successCount: null == successCount ? _self.successCount : successCount // ignore: cast_nullable_to_non_nullable
as int,failureCount: null == failureCount ? _self.failureCount : failureCount // ignore: cast_nullable_to_non_nullable
as int,invalidTokens: null == invalidTokens ? _self._invalidTokens : invalidTokens // ignore: cast_nullable_to_non_nullable
as List<String>,totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$FcmStatsDto {

 int get userTokenCount; bool get serviceAvailable; Map<String, int> get platforms;
/// Create a copy of FcmStatsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FcmStatsDtoCopyWith<FcmStatsDto> get copyWith => _$FcmStatsDtoCopyWithImpl<FcmStatsDto>(this as FcmStatsDto, _$identity);

  /// Serializes this FcmStatsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FcmStatsDto&&(identical(other.userTokenCount, userTokenCount) || other.userTokenCount == userTokenCount)&&(identical(other.serviceAvailable, serviceAvailable) || other.serviceAvailable == serviceAvailable)&&const DeepCollectionEquality().equals(other.platforms, platforms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userTokenCount,serviceAvailable,const DeepCollectionEquality().hash(platforms));

@override
String toString() {
  return 'FcmStatsDto(userTokenCount: $userTokenCount, serviceAvailable: $serviceAvailable, platforms: $platforms)';
}


}

/// @nodoc
abstract mixin class $FcmStatsDtoCopyWith<$Res>  {
  factory $FcmStatsDtoCopyWith(FcmStatsDto value, $Res Function(FcmStatsDto) _then) = _$FcmStatsDtoCopyWithImpl;
@useResult
$Res call({
 int userTokenCount, bool serviceAvailable, Map<String, int> platforms
});




}
/// @nodoc
class _$FcmStatsDtoCopyWithImpl<$Res>
    implements $FcmStatsDtoCopyWith<$Res> {
  _$FcmStatsDtoCopyWithImpl(this._self, this._then);

  final FcmStatsDto _self;
  final $Res Function(FcmStatsDto) _then;

/// Create a copy of FcmStatsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userTokenCount = null,Object? serviceAvailable = null,Object? platforms = null,}) {
  return _then(_self.copyWith(
userTokenCount: null == userTokenCount ? _self.userTokenCount : userTokenCount // ignore: cast_nullable_to_non_nullable
as int,serviceAvailable: null == serviceAvailable ? _self.serviceAvailable : serviceAvailable // ignore: cast_nullable_to_non_nullable
as bool,platforms: null == platforms ? _self.platforms : platforms // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [FcmStatsDto].
extension FcmStatsDtoPatterns on FcmStatsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FcmStatsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FcmStatsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FcmStatsDto value)  $default,){
final _that = this;
switch (_that) {
case _FcmStatsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FcmStatsDto value)?  $default,){
final _that = this;
switch (_that) {
case _FcmStatsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int userTokenCount,  bool serviceAvailable,  Map<String, int> platforms)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FcmStatsDto() when $default != null:
return $default(_that.userTokenCount,_that.serviceAvailable,_that.platforms);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int userTokenCount,  bool serviceAvailable,  Map<String, int> platforms)  $default,) {final _that = this;
switch (_that) {
case _FcmStatsDto():
return $default(_that.userTokenCount,_that.serviceAvailable,_that.platforms);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int userTokenCount,  bool serviceAvailable,  Map<String, int> platforms)?  $default,) {final _that = this;
switch (_that) {
case _FcmStatsDto() when $default != null:
return $default(_that.userTokenCount,_that.serviceAvailable,_that.platforms);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FcmStatsDto implements FcmStatsDto {
  const _FcmStatsDto({required this.userTokenCount, required this.serviceAvailable, required final  Map<String, int> platforms}): _platforms = platforms;
  factory _FcmStatsDto.fromJson(Map<String, dynamic> json) => _$FcmStatsDtoFromJson(json);

@override final  int userTokenCount;
@override final  bool serviceAvailable;
 final  Map<String, int> _platforms;
@override Map<String, int> get platforms {
  if (_platforms is EqualUnmodifiableMapView) return _platforms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_platforms);
}


/// Create a copy of FcmStatsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FcmStatsDtoCopyWith<_FcmStatsDto> get copyWith => __$FcmStatsDtoCopyWithImpl<_FcmStatsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FcmStatsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FcmStatsDto&&(identical(other.userTokenCount, userTokenCount) || other.userTokenCount == userTokenCount)&&(identical(other.serviceAvailable, serviceAvailable) || other.serviceAvailable == serviceAvailable)&&const DeepCollectionEquality().equals(other._platforms, _platforms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userTokenCount,serviceAvailable,const DeepCollectionEquality().hash(_platforms));

@override
String toString() {
  return 'FcmStatsDto(userTokenCount: $userTokenCount, serviceAvailable: $serviceAvailable, platforms: $platforms)';
}


}

/// @nodoc
abstract mixin class _$FcmStatsDtoCopyWith<$Res> implements $FcmStatsDtoCopyWith<$Res> {
  factory _$FcmStatsDtoCopyWith(_FcmStatsDto value, $Res Function(_FcmStatsDto) _then) = __$FcmStatsDtoCopyWithImpl;
@override @useResult
$Res call({
 int userTokenCount, bool serviceAvailable, Map<String, int> platforms
});




}
/// @nodoc
class __$FcmStatsDtoCopyWithImpl<$Res>
    implements _$FcmStatsDtoCopyWith<$Res> {
  __$FcmStatsDtoCopyWithImpl(this._self, this._then);

  final _FcmStatsDto _self;
  final $Res Function(_FcmStatsDto) _then;

/// Create a copy of FcmStatsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userTokenCount = null,Object? serviceAvailable = null,Object? platforms = null,}) {
  return _then(_FcmStatsDto(
userTokenCount: null == userTokenCount ? _self.userTokenCount : userTokenCount // ignore: cast_nullable_to_non_nullable
as int,serviceAvailable: null == serviceAvailable ? _self.serviceAvailable : serviceAvailable // ignore: cast_nullable_to_non_nullable
as bool,platforms: null == platforms ? _self._platforms : platforms // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}


/// @nodoc
mixin _$FcmSuccessDto {

 bool get success; String? get message;
/// Create a copy of FcmSuccessDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FcmSuccessDtoCopyWith<FcmSuccessDto> get copyWith => _$FcmSuccessDtoCopyWithImpl<FcmSuccessDto>(this as FcmSuccessDto, _$identity);

  /// Serializes this FcmSuccessDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FcmSuccessDto&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message);

@override
String toString() {
  return 'FcmSuccessDto(success: $success, message: $message)';
}


}

/// @nodoc
abstract mixin class $FcmSuccessDtoCopyWith<$Res>  {
  factory $FcmSuccessDtoCopyWith(FcmSuccessDto value, $Res Function(FcmSuccessDto) _then) = _$FcmSuccessDtoCopyWithImpl;
@useResult
$Res call({
 bool success, String? message
});




}
/// @nodoc
class _$FcmSuccessDtoCopyWithImpl<$Res>
    implements $FcmSuccessDtoCopyWith<$Res> {
  _$FcmSuccessDtoCopyWithImpl(this._self, this._then);

  final FcmSuccessDto _self;
  final $Res Function(FcmSuccessDto) _then;

/// Create a copy of FcmSuccessDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FcmSuccessDto].
extension FcmSuccessDtoPatterns on FcmSuccessDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FcmSuccessDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FcmSuccessDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FcmSuccessDto value)  $default,){
final _that = this;
switch (_that) {
case _FcmSuccessDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FcmSuccessDto value)?  $default,){
final _that = this;
switch (_that) {
case _FcmSuccessDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FcmSuccessDto() when $default != null:
return $default(_that.success,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String? message)  $default,) {final _that = this;
switch (_that) {
case _FcmSuccessDto():
return $default(_that.success,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _FcmSuccessDto() when $default != null:
return $default(_that.success,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FcmSuccessDto implements FcmSuccessDto {
  const _FcmSuccessDto({required this.success, this.message});
  factory _FcmSuccessDto.fromJson(Map<String, dynamic> json) => _$FcmSuccessDtoFromJson(json);

@override final  bool success;
@override final  String? message;

/// Create a copy of FcmSuccessDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FcmSuccessDtoCopyWith<_FcmSuccessDto> get copyWith => __$FcmSuccessDtoCopyWithImpl<_FcmSuccessDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FcmSuccessDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FcmSuccessDto&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message);

@override
String toString() {
  return 'FcmSuccessDto(success: $success, message: $message)';
}


}

/// @nodoc
abstract mixin class _$FcmSuccessDtoCopyWith<$Res> implements $FcmSuccessDtoCopyWith<$Res> {
  factory _$FcmSuccessDtoCopyWith(_FcmSuccessDto value, $Res Function(_FcmSuccessDto) _then) = __$FcmSuccessDtoCopyWithImpl;
@override @useResult
$Res call({
 bool success, String? message
});




}
/// @nodoc
class __$FcmSuccessDtoCopyWithImpl<$Res>
    implements _$FcmSuccessDtoCopyWith<$Res> {
  __$FcmSuccessDtoCopyWithImpl(this._self, this._then);

  final _FcmSuccessDto _self;
  final $Res Function(_FcmSuccessDto) _then;

/// Create a copy of FcmSuccessDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? message = freezed,}) {
  return _then(_FcmSuccessDto(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
