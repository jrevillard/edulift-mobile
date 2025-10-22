import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

void main() {
  group('Result Pattern Tests', () {
    group('Ok', () {
      test('should create ok result with value', () {
        // Arrange
        const value = 'test value';

        // Act
        const result = Result.ok(value);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.isError, isFalse);
        result.when(
          ok: (val) => expect(val, equals(value)),
          err: (_) => fail('Should not be error'),
        );
      });

      test('should handle equality correctly', () {
        // Arrange & Act
        const result1 = Result.ok('test');
        const result2 = Result.ok('test');
        const result3 = Result.ok('different');

        // Assert
        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });

      test('should have correct toString', () {
        // Arrange & Act
        const result = Result.ok('test');

        // Assert
        expect(result.toString(), contains('Ok'));
        expect(result.toString(), contains('test'));
      });
    });

    group('Err', () {
      test('should create err result with exception', () {
        // Arrange
        const failure = ServerFailure(message: 'Server error');

        // Act
        const result = Result<String, Failure>.err(failure);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.isError, isTrue);
        result.when(
          ok: (_) => fail('Should not be success'),
          err: (error) => expect(error, equals(failure)),
        );
      });

      test('should handle equality correctly', () {
        // Arrange & Act
        const failure1 = ServerFailure(message: 'error');
        const failure2 = ServerFailure(message: 'error');
        const failure3 = NetworkFailure(message: 'network error');

        const result1 = Result<String, Failure>.err(failure1);
        const result2 = Result<String, Failure>.err(failure2);
        const result3 = Result<String, Failure>.err(failure3);

        // Assert
        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });

      test('should have correct toString', () {
        // Arrange & Act
        const failure = ServerFailure(message: 'test error');
        const result = Result<String, Failure>.err(failure);

        // Assert
        expect(result.toString(), contains('Err'));
        expect(result.toString(), contains('test error'));
      });
    });

    group('when() method', () {
      test('should handle ok case', () {
        // Arrange
        const result = Result<String, Failure>.ok('success');
        String? okValue;
        Failure? errValue;

        // Act
        result.when(
          ok: (value) => okValue = value,
          err: (error) => errValue = error,
        );

        // Assert
        expect(okValue, equals('success'));
        expect(errValue, isNull);
      });

      test('should handle err case', () {
        // Arrange
        const failure = NetworkFailure(message: 'network error');
        const result = Result<String, Failure>.err(failure);
        String? okValue;
        Failure? errValue;

        // Act
        result.when(
          ok: (value) => okValue = value,
          err: (error) => errValue = error,
        );

        // Assert
        expect(okValue, isNull);
        expect(errValue, equals(failure));
      });

      test('should be exhaustive and type-safe', () {
        // Arrange
        const result = Result<int, Failure>.ok(42);

        // Act & Assert - This tests compile-time exhaustiveness
        final output = result.when(
          ok: (value) => 'Got: $value',
          err: (error) => 'Error: $error',
        );

        expect(output, equals('Got: 42'));
      });
    });

    group('Extension methods', () {
      test('should create Ok from value', () {
        // Arrange & Act
        final result = 'test'.ok<Failure>();

        // Assert
        expect(result.isSuccess, isTrue);
        result.when(
          ok: (value) => expect(value, equals('test')),
          err: (_) => fail('Should not be error'),
        );
      });

      test('should create Err from exception', () {
        // Arrange & Act
        const failure = ServerFailure(message: 'error');
        final result = failure.err<String>();

        // Assert
        expect(result.isError, isTrue);
        result.when(
          ok: (_) => fail('Should not be success'),
          err: (error) => expect(error, equals(failure)),
        );
      });
    });

    group('Nested Results', () {
      test('should handle nested Result operations', () {
        // Arrange
        const innerResult = Result.ok('inner');
        const outerResult = Result.ok(innerResult);

        // Act & Assert
        outerResult.when(
          ok: (inner) => inner.when(
            ok: (value) => expect(value, equals('inner')),
            err: (_) => fail('Inner should not be error'),
          ),
          err: (_) => fail('Outer should not be error'),
        );
      });
    });

    group('Real-world API simulation', () {
      test('should simulate API success response', () async {
        // Arrange
        Future<Result<String, Failure>> mockApiCall() async {
          const Duration(milliseconds: 1);
          return const Result<String, Failure>.ok('API response data');
        }

        // Act
        final result = await mockApiCall();

        // Assert
        expect(result.isSuccess, isTrue);
        result.when(
          ok: (data) => expect(data, equals('API response data')),
          err: (_) => fail('Should be success'),
        );
      });

      test('should simulate API failure response', () async {
        // Arrange
        Future<Result<String, Failure>> mockApiCall() async {
          const Duration(milliseconds: 1);
          return const Result<String, Failure>.err(
            NetworkFailure(message: 'Connection timeout'),
          );
        }

        // Act
        final result = await mockApiCall();

        // Assert
        expect(result.isError, isTrue);
        result.when(
          ok: (_) => fail('Should be error'),
          err: (failure) => expect(failure, isA<NetworkFailure>()),
        );
      });
    });
  });
}
