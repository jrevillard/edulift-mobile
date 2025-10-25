// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_code_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InviteCodeResponseDto {
  String get inviteCode;
  DateTime get expiresAt;
  String? get shareUrl;

  /// Create a copy of InviteCodeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InviteCodeResponseDtoCopyWith<InviteCodeResponseDto> get copyWith =>
      _$InviteCodeResponseDtoCopyWithImpl<InviteCodeResponseDto>(
          this as InviteCodeResponseDto, _$identity);

  /// Serializes this InviteCodeResponseDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InviteCodeResponseDto &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.shareUrl, shareUrl) ||
                other.shareUrl == shareUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, inviteCode, expiresAt, shareUrl);

  @override
  String toString() {
    return 'InviteCodeResponseDto(inviteCode: $inviteCode, expiresAt: $expiresAt, shareUrl: $shareUrl)';
  }
}

/// @nodoc
abstract mixin class $InviteCodeResponseDtoCopyWith<$Res> {
  factory $InviteCodeResponseDtoCopyWith(InviteCodeResponseDto value,
          $Res Function(InviteCodeResponseDto) _then) =
      _$InviteCodeResponseDtoCopyWithImpl;
  @useResult
  $Res call({String inviteCode, DateTime expiresAt, String? shareUrl});
}

/// @nodoc
class _$InviteCodeResponseDtoCopyWithImpl<$Res>
    implements $InviteCodeResponseDtoCopyWith<$Res> {
  _$InviteCodeResponseDtoCopyWithImpl(this._self, this._then);

  final InviteCodeResponseDto _self;
  final $Res Function(InviteCodeResponseDto) _then;

  /// Create a copy of InviteCodeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inviteCode = null,
    Object? expiresAt = null,
    Object? shareUrl = freezed,
  }) {
    return _then(_self.copyWith(
      inviteCode: null == inviteCode
          ? _self.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      shareUrl: freezed == shareUrl
          ? _self.shareUrl
          : shareUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [InviteCodeResponseDto].
extension InviteCodeResponseDtoPatterns on InviteCodeResponseDto {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_InviteCodeResponseDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InviteCodeResponseDto() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_InviteCodeResponseDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InviteCodeResponseDto():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_InviteCodeResponseDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InviteCodeResponseDto() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String inviteCode, DateTime expiresAt, String? shareUrl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InviteCodeResponseDto() when $default != null:
        return $default(_that.inviteCode, _that.expiresAt, _that.shareUrl);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String inviteCode, DateTime expiresAt, String? shareUrl)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InviteCodeResponseDto():
        return $default(_that.inviteCode, _that.expiresAt, _that.shareUrl);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String inviteCode, DateTime expiresAt, String? shareUrl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InviteCodeResponseDto() when $default != null:
        return $default(_that.inviteCode, _that.expiresAt, _that.shareUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _InviteCodeResponseDto implements InviteCodeResponseDto {
  const _InviteCodeResponseDto(
      {required this.inviteCode, required this.expiresAt, this.shareUrl});
  factory _InviteCodeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$InviteCodeResponseDtoFromJson(json);

  @override
  final String inviteCode;
  @override
  final DateTime expiresAt;
  @override
  final String? shareUrl;

  /// Create a copy of InviteCodeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InviteCodeResponseDtoCopyWith<_InviteCodeResponseDto> get copyWith =>
      __$InviteCodeResponseDtoCopyWithImpl<_InviteCodeResponseDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InviteCodeResponseDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InviteCodeResponseDto &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.shareUrl, shareUrl) ||
                other.shareUrl == shareUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, inviteCode, expiresAt, shareUrl);

  @override
  String toString() {
    return 'InviteCodeResponseDto(inviteCode: $inviteCode, expiresAt: $expiresAt, shareUrl: $shareUrl)';
  }
}

/// @nodoc
abstract mixin class _$InviteCodeResponseDtoCopyWith<$Res>
    implements $InviteCodeResponseDtoCopyWith<$Res> {
  factory _$InviteCodeResponseDtoCopyWith(_InviteCodeResponseDto value,
          $Res Function(_InviteCodeResponseDto) _then) =
      __$InviteCodeResponseDtoCopyWithImpl;
  @override
  @useResult
  $Res call({String inviteCode, DateTime expiresAt, String? shareUrl});
}

/// @nodoc
class __$InviteCodeResponseDtoCopyWithImpl<$Res>
    implements _$InviteCodeResponseDtoCopyWith<$Res> {
  __$InviteCodeResponseDtoCopyWithImpl(this._self, this._then);

  final _InviteCodeResponseDto _self;
  final $Res Function(_InviteCodeResponseDto) _then;

  /// Create a copy of InviteCodeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? inviteCode = null,
    Object? expiresAt = null,
    Object? shareUrl = freezed,
  }) {
    return _then(_InviteCodeResponseDto(
      inviteCode: null == inviteCode
          ? _self.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      shareUrl: freezed == shareUrl
          ? _self.shareUrl
          : shareUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
