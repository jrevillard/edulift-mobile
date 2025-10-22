import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/utils/result.dart';

void main() {
  group('Failure Hierarchy Tests - TDD London', () {
    group('AuthFailure', () {
      test('should create auth failure', () {
        // Arrange
        const message = 'Authentication failed';

        // Act
        const failure = AuthFailure(message: message);

        // Assert
        expect(failure.message, equals(message));
        expect(failure, isA<Failure>());
        expect(failure.runtimeType, equals(AuthFailure));
      });

      test('should support equality', () {
        // Arrange & Act
        const failure1 = AuthFailure(message: 'test');
        const failure2 = AuthFailure(message: 'test');
        const failure3 = AuthFailure(message: 'different');

        // Assert
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });

      test('should have meaningful toString', () {
        // Arrange & Act
        const failure = AuthFailure(message: 'Invalid credentials');

        // Assert
        expect(failure.toString(), contains('AuthFailure'));
        expect(failure.toString(), contains('Invalid credentials'));
      });
    });

    group('ApiFailure', () {
      test('should create API failure with status code', () {
        // Arrange
        const message = 'API request failed';
        const statusCode = 400;

        // Act
        const failure = ApiFailure(message: message, statusCode: statusCode);

        // Assert
        expect(failure.message, equals(message));
        expect(failure.statusCode, equals(statusCode));
        expect(failure, isA<Failure>());
      });

      test('should create API failure without status code', () {
        // Arrange & Act
        const failure = ApiFailure(message: 'Generic API error');

        // Assert
        expect(failure.message, equals('Generic API error'));
        expect(failure.statusCode, isNull);
      });

      test('should support equality with status code', () {
        // Arrange & Act
        const failure1 = ApiFailure(message: 'error', statusCode: 404);
        const failure2 = ApiFailure(message: 'error', statusCode: 404);
        const failure3 = ApiFailure(message: 'error', statusCode: 500);

        // Assert
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });

      test('should have meaningful toString with status code', () {
        // Arrange & Act
        const failure = ApiFailure(message: 'Not found', statusCode: 404);

        // Assert
        expect(failure.toString(), contains('ApiFailure'));
        expect(failure.toString(), contains('Not found'));
        expect(failure.toString(), contains('404'));
      });
    });

    group('NetworkFailure', () {
      test('should create network failure', () {
        // Arrange
        const message = 'No internet connection';

        // Act
        const failure = NetworkFailure(message: message);

        // Assert
        expect(failure.message, equals(message));
        expect(failure, isA<Failure>());
      });

      test('should support equality', () {
        // Arrange & Act
        const failure1 = NetworkFailure(message: 'connection error');
        const failure2 = NetworkFailure(message: 'connection error');
        const failure3 = NetworkFailure(message: 'timeout error');

        // Assert
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('ServerFailure', () {
      test('should create server failure', () {
        // Arrange
        const message = 'Internal server error';

        // Act
        const failure = ServerFailure(message: message);

        // Assert
        expect(failure.message, equals(message));
        expect(failure, isA<Failure>());
      });

      test('should support equality', () {
        // Arrange & Act
        const failure1 = ServerFailure(message: '500 error');
        const failure2 = ServerFailure(message: '500 error');
        const failure3 = ServerFailure(message: '503 error');

        // Assert
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('CacheFailure', () {
      test('should create cache failure', () {
        // Arrange
        const message = 'Cache read error';

        // Act
        const failure = CacheFailure(message: message);

        // Assert
        expect(failure.message, equals(message));
        expect(failure, isA<Failure>());
      });

      test('should support equality', () {
        // Arrange & Act
        const failure1 = CacheFailure(message: 'cache miss');
        const failure2 = CacheFailure(message: 'cache miss');
        const failure3 = CacheFailure(message: 'cache full');

        // Assert
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('ValidationFailure', () {
      test('should create validation failure', () {
        // Arrange
        const message = 'Invalid input format';

        // Act
        const failure = ValidationFailure(message: message);

        // Assert
        expect(failure.message, equals(message));
        expect(failure, isA<Failure>());
      });

      test('should support equality', () {
        // Arrange & Act
        const failure1 = ValidationFailure(message: 'email invalid');
        const failure2 = ValidationFailure(message: 'email invalid');
        const failure3 = ValidationFailure(message: 'phone invalid');

        // Assert
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('Failure hierarchy polymorphism', () {
      test('should support polymorphic behavior', () {
        // Arrange
        const failures = <Failure>[
          AuthFailure(message: 'auth error'),
          NetworkFailure(message: 'network error'),
          ServerFailure(message: 'server error'),
          ApiFailure(message: 'api error', statusCode: 400),
        ];

        // Act & Assert
        for (final failure in failures) {
          expect(failure, isA<Failure>());
          expect(failure.message, isNotEmpty);
          expect(failure.toString(), isNotEmpty);
        }
      });

      test('should handle different failure types in Result pattern', () {
        // Arrange
        const authResult = Result<String, Failure>.err(
          AuthFailure(message: 'auth failed'),
        );
        const networkResult = Result<String, Failure>.err(
          NetworkFailure(message: 'network failed'),
        );

        // Act & Assert
        authResult.when(
          ok: (_) => fail('Should be error'),
          err: (failure) => expect(failure, isA<AuthFailure>()),
        );

        networkResult.when(
          ok: (_) => fail('Should be error'),
          err: (failure) => expect(failure, isA<NetworkFailure>()),
        );
      });
    });

    group('Real-world failure scenarios', () {
      test('should handle HTTP error mapping', () {
        // Arrange & Act
        const failure400 = ApiFailure(message: 'Bad Request', statusCode: 400);
        const failure401 = ApiFailure(message: 'Unauthorized', statusCode: 401);
        const failure404 = ApiFailure(message: 'Not Found', statusCode: 404);
        const failure500 = ApiFailure(
          message: 'Internal Server Error',
          statusCode: 500,
        );

        // Assert
        expect(failure400.statusCode, equals(400));
        expect(failure401.statusCode, equals(401));
        expect(failure404.statusCode, equals(404));
        expect(failure500.statusCode, equals(500));

        // All should be different
        expect(failure400, isNot(equals(failure401)));
        expect(failure401, isNot(equals(failure404)));
        expect(failure404, isNot(equals(failure500)));
      });

      test('should handle nested error propagation', () {
        // Arrange
        Future<Result<String, Failure>> mockNetworkCall() async {
          return const Result.err(
            NetworkFailure(message: 'Connection timeout'),
          );
        }

        Future<Result<String, Failure>> mockServiceCall() async {
          final networkResult = await mockNetworkCall();
          return networkResult.when(
            ok: (data) => Result.ok('Processed: $data'),
            err: (failure) => Result.err(failure), // Propagate network failure
          );
        }

        // Act & Assert
        mockServiceCall().then((result) {
          result.when(
            ok: (_) => fail('Should propagate network error'),
            err: (failure) => expect(failure, isA<NetworkFailure>()),
          );
        });
      });
    });
  });
}
