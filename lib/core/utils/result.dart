// Result pattern implementation for type-safe error handling

import 'dart:async';
import 'package:flutter/foundation.dart';

/// A type-safe result pattern for handling success and failure cases.
///
/// This sealed class ensures exhaustive handling of both success and failure
/// scenarios, replacing the broken ApiResponse.map() pattern.
///
/// Example usage:
/// ```dart
/// final result = await apiCall();
/// return result.when(
///   ok: (data) => processData(data),
///   err: (error) => handleError(error),
/// );
/// ```
sealed class Result<T, E extends Exception> {
  const Result();

  /// Create a successful result
  const factory Result.ok(T value) = Ok<T, E>;

  /// Create an error result
  const factory Result.err(E error) = Err<T, E>;

  /// Transform the result using pattern matching
  /// Supports both sync and async callbacks automatically
  /// - For sync: result.when(ok: (data) => data.length, err: (e) => 0)
  /// - For async: await result.when(ok: (data) async => await process(data), err: (e) async => 0)
  FutureOr<R> when<R>({
    required FutureOr<R> Function(T value) ok,
    required FutureOr<R> Function(E error) err,
  });

  /// Map the success value while preserving error
  Result<R, E> map<R>(R Function(T value) mapper);

  /// Map the error while preserving success value
  Result<T, F> mapError<F extends Exception>(F Function(E error) mapper);

  /// Check if this is a success result
  bool get isSuccess;

  /// Check if this is an error result
  bool get isError;

  /// Get the success value or null
  T? get value;

  /// Get the error or null
  E? get error;

  /// Fold the result into a single type
  /// This provides compatibility with existing code using fold patterns
  R fold<R>(R Function(E error) left, R Function(T value) right);

  /// Compatibility: Check if this is an Ok result (isOk for Rust-style)
  bool get isOk => isSuccess;

  /// Compatibility: Check if this is an Err result (isErr for Rust-style)
  bool get isErr => isError;

  /// Compatibility: Unwrap the success value (throws if error)
  T unwrap() {
    if (isSuccess) {
      return value!;
    }
    throw Exception('Called unwrap on Err result: $error');
  }

  /// Compatibility: Unwrap the error value (throws if success)
  E unwrapErr() {
    if (isError) {
      return error!;
    }
    throw Exception('Called unwrapErr on Ok result: $value');
  }
}

/// TDD London compatibility extensions for Either pattern
extension ResultTDDExtensions<T, E extends Exception> on Result<T, E> {
  /// TDD London compatibility: Check if result is successful (Right)
  bool isRight() => isSuccess;

  /// TDD London compatibility: Check if result is error (Left)
  bool isLeft() => isError;

  /// TDD London compatibility: Get right value
  T? get right => value;

  /// TDD London compatibility: Get left error
  E? get left => error;
}

@immutable
final class Ok<T, E extends Exception> extends Result<T, E> {
  final T _value;

  const Ok(this._value);

  @override
  FutureOr<R> when<R>({
    required FutureOr<R> Function(T value) ok,
    required FutureOr<R> Function(E error) err,
  }) =>
      ok(_value);

  @override
  Result<R, E> map<R>(R Function(T value) mapper) => Ok(mapper(_value));

  @override
  Result<T, F> mapError<F extends Exception>(F Function(E error) mapper) =>
      Ok(_value);

  @override
  bool get isSuccess => true;

  @override
  bool get isError => false;

  @override
  T get value => _value;

  @override
  E? get error => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ok<T, E> &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Ok($_value)';

  @override
  R fold<R>(R Function(E error) left, R Function(T value) right) =>
      right(_value);
}

@immutable
final class Err<T, E extends Exception> extends Result<T, E> {
  final E _error;

  const Err(this._error);

  @override
  FutureOr<R> when<R>({
    required FutureOr<R> Function(T value) ok,
    required FutureOr<R> Function(E error) err,
  }) =>
      err(_error);

  @override
  Result<R, E> map<R>(R Function(T value) mapper) => Err(_error);

  @override
  Result<T, F> mapError<F extends Exception>(F Function(E error) mapper) =>
      Err(mapper(_error));

  @override
  bool get isSuccess => false;

  @override
  bool get isError => true;

  @override
  T? get value => null;

  @override
  E get error => _error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Err<T, E> &&
          runtimeType == other.runtimeType &&
          _error == other._error;

  @override
  int get hashCode => _error.hashCode;

  @override
  String toString() => 'Err($_error)';

  @override
  R fold<R>(R Function(E error) left, R Function(T value) right) =>
      left(_error);
}

/// Extension methods for convenient Result creation.
extension ResultExtensions<T> on T {
  /// Wrap this value in an Ok result.
  Result<T, E> ok<E extends Exception>() => Result<T, E>.ok(this);
}

/// Extension methods for Exception to create Err results.
extension ExceptionExtensions<E extends Exception> on E {
  /// Wrap this exception in an Err result.
  Result<S, E> err<S>() => Result<S, E>.err(this);
}
