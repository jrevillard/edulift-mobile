// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthUserProfileDto {

 UserCurrentFamilyDto get data;
/// Create a copy of AuthUserProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUserProfileDtoCopyWith<AuthUserProfileDto> get copyWith => _$AuthUserProfileDtoCopyWithImpl<AuthUserProfileDto>(this as AuthUserProfileDto, _$identity);

  /// Serializes this AuthUserProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUserProfileDto&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'AuthUserProfileDto(data: $data)';
}


}

/// @nodoc
abstract mixin class $AuthUserProfileDtoCopyWith<$Res>  {
  factory $AuthUserProfileDtoCopyWith(AuthUserProfileDto value, $Res Function(AuthUserProfileDto) _then) = _$AuthUserProfileDtoCopyWithImpl;
@useResult
$Res call({
 UserCurrentFamilyDto data
});


$UserCurrentFamilyDtoCopyWith<$Res> get data;

}
/// @nodoc
class _$AuthUserProfileDtoCopyWithImpl<$Res>
    implements $AuthUserProfileDtoCopyWith<$Res> {
  _$AuthUserProfileDtoCopyWithImpl(this._self, this._then);

  final AuthUserProfileDto _self;
  final $Res Function(AuthUserProfileDto) _then;

/// Create a copy of AuthUserProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UserCurrentFamilyDto,
  ));
}
/// Create a copy of AuthUserProfileDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCurrentFamilyDtoCopyWith<$Res> get data {
  
  return $UserCurrentFamilyDtoCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthUserProfileDto].
extension AuthUserProfileDtoPatterns on AuthUserProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthUserProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthUserProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthUserProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _AuthUserProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthUserProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuthUserProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserCurrentFamilyDto data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthUserProfileDto() when $default != null:
return $default(_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserCurrentFamilyDto data)  $default,) {final _that = this;
switch (_that) {
case _AuthUserProfileDto():
return $default(_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserCurrentFamilyDto data)?  $default,) {final _that = this;
switch (_that) {
case _AuthUserProfileDto() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthUserProfileDto implements AuthUserProfileDto {
  const _AuthUserProfileDto({required this.data});
  factory _AuthUserProfileDto.fromJson(Map<String, dynamic> json) => _$AuthUserProfileDtoFromJson(json);

@override final  UserCurrentFamilyDto data;

/// Create a copy of AuthUserProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthUserProfileDtoCopyWith<_AuthUserProfileDto> get copyWith => __$AuthUserProfileDtoCopyWithImpl<_AuthUserProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthUserProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthUserProfileDto&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'AuthUserProfileDto(data: $data)';
}


}

/// @nodoc
abstract mixin class _$AuthUserProfileDtoCopyWith<$Res> implements $AuthUserProfileDtoCopyWith<$Res> {
  factory _$AuthUserProfileDtoCopyWith(_AuthUserProfileDto value, $Res Function(_AuthUserProfileDto) _then) = __$AuthUserProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 UserCurrentFamilyDto data
});


@override $UserCurrentFamilyDtoCopyWith<$Res> get data;

}
/// @nodoc
class __$AuthUserProfileDtoCopyWithImpl<$Res>
    implements _$AuthUserProfileDtoCopyWith<$Res> {
  __$AuthUserProfileDtoCopyWithImpl(this._self, this._then);

  final _AuthUserProfileDto _self;
  final $Res Function(_AuthUserProfileDto) _then;

/// Create a copy of AuthUserProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_AuthUserProfileDto(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UserCurrentFamilyDto,
  ));
}

/// Create a copy of AuthUserProfileDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCurrentFamilyDtoCopyWith<$Res> get data {
  
  return $UserCurrentFamilyDtoCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$AuthConfigDto {

 String get nodeEnv; String get emailUser; bool get hasCredentials; String get mockServiceTest;
/// Create a copy of AuthConfigDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthConfigDtoCopyWith<AuthConfigDto> get copyWith => _$AuthConfigDtoCopyWithImpl<AuthConfigDto>(this as AuthConfigDto, _$identity);

  /// Serializes this AuthConfigDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthConfigDto&&(identical(other.nodeEnv, nodeEnv) || other.nodeEnv == nodeEnv)&&(identical(other.emailUser, emailUser) || other.emailUser == emailUser)&&(identical(other.hasCredentials, hasCredentials) || other.hasCredentials == hasCredentials)&&(identical(other.mockServiceTest, mockServiceTest) || other.mockServiceTest == mockServiceTest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nodeEnv,emailUser,hasCredentials,mockServiceTest);

@override
String toString() {
  return 'AuthConfigDto(nodeEnv: $nodeEnv, emailUser: $emailUser, hasCredentials: $hasCredentials, mockServiceTest: $mockServiceTest)';
}


}

/// @nodoc
abstract mixin class $AuthConfigDtoCopyWith<$Res>  {
  factory $AuthConfigDtoCopyWith(AuthConfigDto value, $Res Function(AuthConfigDto) _then) = _$AuthConfigDtoCopyWithImpl;
@useResult
$Res call({
 String nodeEnv, String emailUser, bool hasCredentials, String mockServiceTest
});




}
/// @nodoc
class _$AuthConfigDtoCopyWithImpl<$Res>
    implements $AuthConfigDtoCopyWith<$Res> {
  _$AuthConfigDtoCopyWithImpl(this._self, this._then);

  final AuthConfigDto _self;
  final $Res Function(AuthConfigDto) _then;

/// Create a copy of AuthConfigDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nodeEnv = null,Object? emailUser = null,Object? hasCredentials = null,Object? mockServiceTest = null,}) {
  return _then(_self.copyWith(
nodeEnv: null == nodeEnv ? _self.nodeEnv : nodeEnv // ignore: cast_nullable_to_non_nullable
as String,emailUser: null == emailUser ? _self.emailUser : emailUser // ignore: cast_nullable_to_non_nullable
as String,hasCredentials: null == hasCredentials ? _self.hasCredentials : hasCredentials // ignore: cast_nullable_to_non_nullable
as bool,mockServiceTest: null == mockServiceTest ? _self.mockServiceTest : mockServiceTest // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthConfigDto].
extension AuthConfigDtoPatterns on AuthConfigDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthConfigDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthConfigDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthConfigDto value)  $default,){
final _that = this;
switch (_that) {
case _AuthConfigDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthConfigDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuthConfigDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nodeEnv,  String emailUser,  bool hasCredentials,  String mockServiceTest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthConfigDto() when $default != null:
return $default(_that.nodeEnv,_that.emailUser,_that.hasCredentials,_that.mockServiceTest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nodeEnv,  String emailUser,  bool hasCredentials,  String mockServiceTest)  $default,) {final _that = this;
switch (_that) {
case _AuthConfigDto():
return $default(_that.nodeEnv,_that.emailUser,_that.hasCredentials,_that.mockServiceTest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nodeEnv,  String emailUser,  bool hasCredentials,  String mockServiceTest)?  $default,) {final _that = this;
switch (_that) {
case _AuthConfigDto() when $default != null:
return $default(_that.nodeEnv,_that.emailUser,_that.hasCredentials,_that.mockServiceTest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthConfigDto implements AuthConfigDto {
  const _AuthConfigDto({required this.nodeEnv, required this.emailUser, required this.hasCredentials, required this.mockServiceTest});
  factory _AuthConfigDto.fromJson(Map<String, dynamic> json) => _$AuthConfigDtoFromJson(json);

@override final  String nodeEnv;
@override final  String emailUser;
@override final  bool hasCredentials;
@override final  String mockServiceTest;

/// Create a copy of AuthConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthConfigDtoCopyWith<_AuthConfigDto> get copyWith => __$AuthConfigDtoCopyWithImpl<_AuthConfigDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthConfigDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthConfigDto&&(identical(other.nodeEnv, nodeEnv) || other.nodeEnv == nodeEnv)&&(identical(other.emailUser, emailUser) || other.emailUser == emailUser)&&(identical(other.hasCredentials, hasCredentials) || other.hasCredentials == hasCredentials)&&(identical(other.mockServiceTest, mockServiceTest) || other.mockServiceTest == mockServiceTest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nodeEnv,emailUser,hasCredentials,mockServiceTest);

@override
String toString() {
  return 'AuthConfigDto(nodeEnv: $nodeEnv, emailUser: $emailUser, hasCredentials: $hasCredentials, mockServiceTest: $mockServiceTest)';
}


}

/// @nodoc
abstract mixin class _$AuthConfigDtoCopyWith<$Res> implements $AuthConfigDtoCopyWith<$Res> {
  factory _$AuthConfigDtoCopyWith(_AuthConfigDto value, $Res Function(_AuthConfigDto) _then) = __$AuthConfigDtoCopyWithImpl;
@override @useResult
$Res call({
 String nodeEnv, String emailUser, bool hasCredentials, String mockServiceTest
});




}
/// @nodoc
class __$AuthConfigDtoCopyWithImpl<$Res>
    implements _$AuthConfigDtoCopyWith<$Res> {
  __$AuthConfigDtoCopyWithImpl(this._self, this._then);

  final _AuthConfigDto _self;
  final $Res Function(_AuthConfigDto) _then;

/// Create a copy of AuthConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nodeEnv = null,Object? emailUser = null,Object? hasCredentials = null,Object? mockServiceTest = null,}) {
  return _then(_AuthConfigDto(
nodeEnv: null == nodeEnv ? _self.nodeEnv : nodeEnv // ignore: cast_nullable_to_non_nullable
as String,emailUser: null == emailUser ? _self.emailUser : emailUser // ignore: cast_nullable_to_non_nullable
as String,hasCredentials: null == hasCredentials ? _self.hasCredentials : hasCredentials // ignore: cast_nullable_to_non_nullable
as bool,mockServiceTest: null == mockServiceTest ? _self.mockServiceTest : mockServiceTest // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserExistsDto {

 bool get exists;
/// Create a copy of UserExistsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserExistsDtoCopyWith<UserExistsDto> get copyWith => _$UserExistsDtoCopyWithImpl<UserExistsDto>(this as UserExistsDto, _$identity);

  /// Serializes this UserExistsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserExistsDto&&(identical(other.exists, exists) || other.exists == exists));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exists);

@override
String toString() {
  return 'UserExistsDto(exists: $exists)';
}


}

/// @nodoc
abstract mixin class $UserExistsDtoCopyWith<$Res>  {
  factory $UserExistsDtoCopyWith(UserExistsDto value, $Res Function(UserExistsDto) _then) = _$UserExistsDtoCopyWithImpl;
@useResult
$Res call({
 bool exists
});




}
/// @nodoc
class _$UserExistsDtoCopyWithImpl<$Res>
    implements $UserExistsDtoCopyWith<$Res> {
  _$UserExistsDtoCopyWithImpl(this._self, this._then);

  final UserExistsDto _self;
  final $Res Function(UserExistsDto) _then;

/// Create a copy of UserExistsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exists = null,}) {
  return _then(_self.copyWith(
exists: null == exists ? _self.exists : exists // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserExistsDto].
extension UserExistsDtoPatterns on UserExistsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserExistsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserExistsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserExistsDto value)  $default,){
final _that = this;
switch (_that) {
case _UserExistsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserExistsDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserExistsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool exists)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserExistsDto() when $default != null:
return $default(_that.exists);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool exists)  $default,) {final _that = this;
switch (_that) {
case _UserExistsDto():
return $default(_that.exists);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool exists)?  $default,) {final _that = this;
switch (_that) {
case _UserExistsDto() when $default != null:
return $default(_that.exists);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserExistsDto implements UserExistsDto {
  const _UserExistsDto({required this.exists});
  factory _UserExistsDto.fromJson(Map<String, dynamic> json) => _$UserExistsDtoFromJson(json);

@override final  bool exists;

/// Create a copy of UserExistsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserExistsDtoCopyWith<_UserExistsDto> get copyWith => __$UserExistsDtoCopyWithImpl<_UserExistsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserExistsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserExistsDto&&(identical(other.exists, exists) || other.exists == exists));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exists);

@override
String toString() {
  return 'UserExistsDto(exists: $exists)';
}


}

/// @nodoc
abstract mixin class _$UserExistsDtoCopyWith<$Res> implements $UserExistsDtoCopyWith<$Res> {
  factory _$UserExistsDtoCopyWith(_UserExistsDto value, $Res Function(_UserExistsDto) _then) = __$UserExistsDtoCopyWithImpl;
@override @useResult
$Res call({
 bool exists
});




}
/// @nodoc
class __$UserExistsDtoCopyWithImpl<$Res>
    implements _$UserExistsDtoCopyWith<$Res> {
  __$UserExistsDtoCopyWithImpl(this._self, this._then);

  final _UserExistsDto _self;
  final $Res Function(_UserExistsDto) _then;

/// Create a copy of UserExistsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exists = null,}) {
  return _then(_UserExistsDto(
exists: null == exists ? _self.exists : exists // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TokenRefreshResponseDto {

 String get accessToken; String get refreshToken; int get expiresIn; String get tokenType;
/// Create a copy of TokenRefreshResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenRefreshResponseDtoCopyWith<TokenRefreshResponseDto> get copyWith => _$TokenRefreshResponseDtoCopyWithImpl<TokenRefreshResponseDto>(this as TokenRefreshResponseDto, _$identity);

  /// Serializes this TokenRefreshResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenRefreshResponseDto&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,expiresIn,tokenType);

@override
String toString() {
  return 'TokenRefreshResponseDto(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn, tokenType: $tokenType)';
}


}

/// @nodoc
abstract mixin class $TokenRefreshResponseDtoCopyWith<$Res>  {
  factory $TokenRefreshResponseDtoCopyWith(TokenRefreshResponseDto value, $Res Function(TokenRefreshResponseDto) _then) = _$TokenRefreshResponseDtoCopyWithImpl;
@useResult
$Res call({
 String accessToken, String refreshToken, int expiresIn, String tokenType
});




}
/// @nodoc
class _$TokenRefreshResponseDtoCopyWithImpl<$Res>
    implements $TokenRefreshResponseDtoCopyWith<$Res> {
  _$TokenRefreshResponseDtoCopyWithImpl(this._self, this._then);

  final TokenRefreshResponseDto _self;
  final $Res Function(TokenRefreshResponseDto) _then;

/// Create a copy of TokenRefreshResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? refreshToken = null,Object? expiresIn = null,Object? tokenType = null,}) {
  return _then(_self.copyWith(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TokenRefreshResponseDto].
extension TokenRefreshResponseDtoPatterns on TokenRefreshResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TokenRefreshResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TokenRefreshResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TokenRefreshResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _TokenRefreshResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TokenRefreshResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _TokenRefreshResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  int expiresIn,  String tokenType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TokenRefreshResponseDto() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn,_that.tokenType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  int expiresIn,  String tokenType)  $default,) {final _that = this;
switch (_that) {
case _TokenRefreshResponseDto():
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn,_that.tokenType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  String refreshToken,  int expiresIn,  String tokenType)?  $default,) {final _that = this;
switch (_that) {
case _TokenRefreshResponseDto() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn,_that.tokenType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TokenRefreshResponseDto implements TokenRefreshResponseDto {
  const _TokenRefreshResponseDto({required this.accessToken, required this.refreshToken, required this.expiresIn, this.tokenType = 'Bearer'});
  factory _TokenRefreshResponseDto.fromJson(Map<String, dynamic> json) => _$TokenRefreshResponseDtoFromJson(json);

@override final  String accessToken;
@override final  String refreshToken;
@override final  int expiresIn;
@override@JsonKey() final  String tokenType;

/// Create a copy of TokenRefreshResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenRefreshResponseDtoCopyWith<_TokenRefreshResponseDto> get copyWith => __$TokenRefreshResponseDtoCopyWithImpl<_TokenRefreshResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenRefreshResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TokenRefreshResponseDto&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,expiresIn,tokenType);

@override
String toString() {
  return 'TokenRefreshResponseDto(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn, tokenType: $tokenType)';
}


}

/// @nodoc
abstract mixin class _$TokenRefreshResponseDtoCopyWith<$Res> implements $TokenRefreshResponseDtoCopyWith<$Res> {
  factory _$TokenRefreshResponseDtoCopyWith(_TokenRefreshResponseDto value, $Res Function(_TokenRefreshResponseDto) _then) = __$TokenRefreshResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, String refreshToken, int expiresIn, String tokenType
});




}
/// @nodoc
class __$TokenRefreshResponseDtoCopyWithImpl<$Res>
    implements _$TokenRefreshResponseDtoCopyWith<$Res> {
  __$TokenRefreshResponseDtoCopyWithImpl(this._self, this._then);

  final _TokenRefreshResponseDto _self;
  final $Res Function(_TokenRefreshResponseDto) _then;

/// Create a copy of TokenRefreshResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? refreshToken = null,Object? expiresIn = null,Object? tokenType = null,}) {
  return _then(_TokenRefreshResponseDto(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
