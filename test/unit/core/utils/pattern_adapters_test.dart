import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/utils/pattern_adapters.dart';

void main() {
  group('PatternAdapters', () {
    group('eitherToResult', () {
      test('should convert Right to Result.ok', () {
        // Arrange
        const testValue = 'test data';
        const either = Right<Failure, String>(testValue);

        // Act
        final result = PatternAdapters.eitherToResult(either);

        // Assert
        expect(result, isA<Result<String, ApiFailure>>());
        result.when(
          ok: (value) => expect(value, testValue),
          err: (error) => fail('Expected Ok, got Err: $error'),
        );
      });

      test(
        'should convert Left with ServerFailure to Result.err with ApiFailure.serverError',
        () {
          // Arrange
          const failure = ServerFailure(message: 'Server error');
          const either = Left<Failure, String>(failure);

          // Act
          final result = PatternAdapters.eitherToResult(either);

          // Assert
          expect(result, isA<Result<String, ApiFailure>>());
          result.when(
            ok: (value) => fail('Expected Err, got Ok: $value'),
            err: (error) {
              expect(error, isA<ApiFailure>());
              expect(error.message, 'Server error');
              expect(error.statusCode, 500);
            },
          );
        },
      );

      test(
        'should convert Left with NetworkFailure to Result.err with ApiFailure.noConnection',
        () {
          // Arrange
          const failure = NetworkFailure(message: 'Network error');
          const either = Left<Failure, String>(failure);

          // Act
          final result = PatternAdapters.eitherToResult(either);

          // Assert
          expect(result, isA<Result<String, ApiFailure>>());
          result.when(
            ok: (value) => fail('Expected Err, got Ok: $value'),
            err: (error) {
              expect(error, isA<ApiFailure>());
              expect(error.message, 'No internet connection');
              expect(error.statusCode, 0);
            },
          );
        },
      );

      test(
        'should convert Left with AuthFailure to Result.err with ApiFailure.unauthorized',
        () {
          // Arrange
          const failure = AuthFailure(message: 'Auth error');
          const either = Left<Failure, String>(failure);

          // Act
          final result = PatternAdapters.eitherToResult(either);

          // Assert
          expect(result, isA<Result<String, ApiFailure>>());
          result.when(
            ok: (value) => fail('Expected Err, got Ok: $value'),
            err: (error) {
              expect(error, isA<ApiFailure>());
              expect(error.message, 'Unauthorized access');
              expect(error.statusCode, 401);
            },
          );
        },
      );
    });

    group('resultToEither', () {
      test('should convert Result.ok to Right', () {
        // Arrange
        const testValue = 'test data';
        const result = Result<String, ApiFailure>.ok(testValue);

        // Act
        final either = PatternAdapters.resultToEither(result);

        // Assert
        expect(either, isA<Either<Failure, String>>());
        either.fold(
          (failure) => fail('Expected Right, got Left: $failure'),
          (value) => expect(value, testValue),
        );
      });

      test('should convert Result.err to Left', () {
        // Arrange
        final apiFailure = ApiFailure.serverError(message: 'Server error');
        final result = Result<String, ApiFailure>.err(apiFailure);

        // Act
        final either = PatternAdapters.resultToEither(result);

        // Assert
        expect(either, isA<Either<Failure, String>>());
        either.fold((failure) {
          expect(failure, apiFailure);
          expect(failure.message, 'Server error');
        }, (value) => fail('Expected Left, got Right: $value'));
      });
    });

    group('Extension methods', () {
      test('Either.toResult() extension should work', () {
        // Arrange
        const either = Right<Failure, String>('test');

        // Act
        final result = either.toResult();

        // Assert
        expect(result, isA<Result<String, ApiFailure>>());
        result.when(
          ok: (value) => expect(value, 'test'),
          err: (error) => fail('Expected Ok, got Err: $error'),
        );
      });

      test('Result.toEither() extension should work', () {
        // Arrange
        const result = Result<String, ApiFailure>.ok('test');

        // Act
        final either = result.toEither();

        // Assert
        expect(either, isA<Either<Failure, String>>());
        either.fold(
          (failure) => fail('Expected Right, got Left: $failure'),
          (value) => expect(value, 'test'),
        );
      });
    });

    group('Async methods', () {
      test(
        'futureEitherToResult should convert Future<Either> to Future<Result>',
        () async {
          // Arrange
          final futureEither = Future.value(
            const Right<Failure, String>('test'),
          );

          // Act
          final futureResult = PatternAdapters.futureEitherToResult(
            futureEither,
          );
          final result = await futureResult;

          // Assert
          expect(result, isA<Result<String, ApiFailure>>());
          result.when(
            ok: (value) => expect(value, 'test'),
            err: (error) => fail('Expected Ok, got Err: $error'),
          );
        },
      );

      test(
        'futureResultToEither should convert Future<Result> to Future<Either>',
        () async {
          // Arrange
          final futureResult = Future.value(
            const Result<String, ApiFailure>.ok('test'),
          );

          // Act
          final futureEither = PatternAdapters.futureResultToEither(
            futureResult,
          );
          final either = await futureEither;

          // Assert
          expect(either, isA<Either<Failure, String>>());
          either.fold(
            (failure) => fail('Expected Right, got Left: $failure'),
            (value) => expect(value, 'test'),
          );
        },
      );

      test('Future<Either> extension should work', () async {
        // Arrange
        final futureEither = Future.value(const Right<Failure, String>('test'));

        // Act
        final result = await futureEither.toResult();

        // Assert
        expect(result, isA<Result<String, ApiFailure>>());
        result.when(
          ok: (value) => expect(value, 'test'),
          err: (error) => fail('Expected Ok, got Err: $error'),
        );
      });

      test('Future<Result> extension should work', () async {
        // Arrange
        final futureResult = Future.value(
          const Result<String, ApiFailure>.ok('test'),
        );

        // Act
        final either = await futureResult.toEither();

        // Assert
        expect(either, isA<Either<Failure, String>>());
        either.fold(
          (failure) => fail('Expected Right, got Left: $failure'),
          (value) => expect(value, 'test'),
        );
      });
    });

    group('Stream methods', () {
      test(
        'streamEitherToResult should convert Stream<Either> to Stream<Result>',
        () async {
          // Arrange
          final streamEither = Stream.value(
            const Right<Failure, String>('test'),
          );

          // Act
          final streamResult = PatternAdapters.streamEitherToResult(
            streamEither,
          );
          final result = await streamResult.first;

          // Assert
          expect(result, isA<Result<String, ApiFailure>>());
          result.when(
            ok: (value) => expect(value, 'test'),
            err: (error) => fail('Expected Ok, got Err: $error'),
          );
        },
      );

      test(
        'streamResultToEither should convert Stream<Result> to Stream<Either>',
        () async {
          // Arrange
          final streamResult = Stream.value(
            const Result<String, ApiFailure>.ok('test'),
          );

          // Act
          final streamEither = PatternAdapters.streamResultToEither(
            streamResult,
          );
          final either = await streamEither.first;

          // Assert
          expect(either, isA<Either<Failure, String>>());
          either.fold(
            (failure) => fail('Expected Right, got Left: $failure'),
            (value) => expect(value, 'test'),
          );
        },
      );

      test('Stream<Either> extension should work', () async {
        // Arrange
        final streamEither = Stream.value(const Right<Failure, String>('test'));

        // Act
        final result = await streamEither.toResult().first;

        // Assert
        expect(result, isA<Result<String, ApiFailure>>());
        result.when(
          ok: (value) => expect(value, 'test'),
          err: (error) => fail('Expected Ok, got Err: $error'),
        );
      });

      test('Stream<Result> extension should work', () async {
        // Arrange
        final streamResult = Stream.value(
          const Result<String, ApiFailure>.ok('test'),
        );

        // Act
        final either = await streamResult.toEither().first;

        // Assert
        expect(either, isA<Either<Failure, String>>());
        either.fold(
          (failure) => fail('Expected Right, got Left: $failure'),
          (value) => expect(value, 'test'),
        );
      });
    });
  });
}
