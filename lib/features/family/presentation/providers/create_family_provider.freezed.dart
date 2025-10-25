// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_family_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateFamilyState {
  bool get isLoading;
  String? get error;
  family_entity.Family? get family;
  bool get isSuccess;

  /// Create a copy of CreateFamilyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CreateFamilyStateCopyWith<CreateFamilyState> get copyWith =>
      _$CreateFamilyStateCopyWithImpl<CreateFamilyState>(
          this as CreateFamilyState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CreateFamilyState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.family, family) || other.family == family) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, error, family, isSuccess);

  @override
  String toString() {
    return 'CreateFamilyState(isLoading: $isLoading, error: $error, family: $family, isSuccess: $isSuccess)';
  }
}

/// @nodoc
abstract mixin class $CreateFamilyStateCopyWith<$Res> {
  factory $CreateFamilyStateCopyWith(
          CreateFamilyState value, $Res Function(CreateFamilyState) _then) =
      _$CreateFamilyStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      family_entity.Family? family,
      bool isSuccess});
}

/// @nodoc
class _$CreateFamilyStateCopyWithImpl<$Res>
    implements $CreateFamilyStateCopyWith<$Res> {
  _$CreateFamilyStateCopyWithImpl(this._self, this._then);

  final CreateFamilyState _self;
  final $Res Function(CreateFamilyState) _then;

  /// Create a copy of CreateFamilyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? family = freezed,
    Object? isSuccess = null,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      family: freezed == family
          ? _self.family
          : family // ignore: cast_nullable_to_non_nullable
              as family_entity.Family?,
      isSuccess: null == isSuccess
          ? _self.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [CreateFamilyState].
extension CreateFamilyStatePatterns on CreateFamilyState {
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
    TResult Function(_CreateFamilyState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CreateFamilyState() when $default != null:
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
    TResult Function(_CreateFamilyState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateFamilyState():
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
    TResult? Function(_CreateFamilyState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateFamilyState() when $default != null:
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
    TResult Function(bool isLoading, String? error,
            family_entity.Family? family, bool isSuccess)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CreateFamilyState() when $default != null:
        return $default(
            _that.isLoading, _that.error, _that.family, _that.isSuccess);
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
    TResult Function(bool isLoading, String? error,
            family_entity.Family? family, bool isSuccess)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateFamilyState():
        return $default(
            _that.isLoading, _that.error, _that.family, _that.isSuccess);
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
    TResult? Function(bool isLoading, String? error,
            family_entity.Family? family, bool isSuccess)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateFamilyState() when $default != null:
        return $default(
            _that.isLoading, _that.error, _that.family, _that.isSuccess);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CreateFamilyState implements CreateFamilyState {
  const _CreateFamilyState(
      {this.isLoading = false,
      this.error,
      this.family,
      this.isSuccess = false});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  final family_entity.Family? family;
  @override
  @JsonKey()
  final bool isSuccess;

  /// Create a copy of CreateFamilyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CreateFamilyStateCopyWith<_CreateFamilyState> get copyWith =>
      __$CreateFamilyStateCopyWithImpl<_CreateFamilyState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CreateFamilyState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.family, family) || other.family == family) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, error, family, isSuccess);

  @override
  String toString() {
    return 'CreateFamilyState(isLoading: $isLoading, error: $error, family: $family, isSuccess: $isSuccess)';
  }
}

/// @nodoc
abstract mixin class _$CreateFamilyStateCopyWith<$Res>
    implements $CreateFamilyStateCopyWith<$Res> {
  factory _$CreateFamilyStateCopyWith(
          _CreateFamilyState value, $Res Function(_CreateFamilyState) _then) =
      __$CreateFamilyStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      family_entity.Family? family,
      bool isSuccess});
}

/// @nodoc
class __$CreateFamilyStateCopyWithImpl<$Res>
    implements _$CreateFamilyStateCopyWith<$Res> {
  __$CreateFamilyStateCopyWithImpl(this._self, this._then);

  final _CreateFamilyState _self;
  final $Res Function(_CreateFamilyState) _then;

  /// Create a copy of CreateFamilyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? family = freezed,
    Object? isSuccess = null,
  }) {
    return _then(_CreateFamilyState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      family: freezed == family
          ? _self.family
          : family // ignore: cast_nullable_to_non_nullable
              as family_entity.Family?,
      isSuccess: null == isSuccess
          ? _self.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
