import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/errors/exceptions.dart';

void main() {
  group('Exception Hierarchy Tests - TDD London', () {
    group('AppException', () {
      test('should be abstract base class', () {
        // Assert - Cannot instantiate abstract class directly
        expect(AppException, isA<Type>());
        // Abstract class test - verify by checking subclass behavior
        const exception = ServerException('test');
        expect(exception, isA<AppException>());
        expect(exception.message, equals('test'));
      });
    });

    group('ServerException', () {
      test('should create server exception with message', () {
        // Arrange & Act
        const exception = ServerException('Server error');

        // Assert
        expect(exception.message, equals('Server error'));
        expect(exception.statusCode, isNull);
        expect(exception.errorCode, isNull);
        expect(exception, isA<AppException>());
      });

      test('should create server exception with status code', () {
        // Arrange & Act
        const exception = ServerException(
          'Internal Server Error',
          statusCode: 500,
        );

        // Assert
        expect(exception.message, equals('Internal Server Error'));
        expect(exception.statusCode, equals(500));
        expect(exception.errorCode, isNull);
      });

      test('should create server exception with error code', () {
        // Arrange & Act
        const exception = ServerException(
          'Bad Request',
          statusCode: 400,
          errorCode: 'INVALID_INPUT',
        );

        // Assert
        expect(exception.message, equals('Bad Request'));
        expect(exception.statusCode, equals(400));
        expect(exception.errorCode, equals('INVALID_INPUT'));
      });

      test('should have meaningful toString', () {
        // Arrange & Act
        const exception = ServerException('Server error', statusCode: 500);

        // Assert
        expect(exception.toString(), contains('ServerException'));
        expect(exception.toString(), contains('500'));
        expect(exception.toString(), contains('Server error'));
      });
    });

    group('CacheException', () {
      test('should create cache exception', () {
        // Arrange & Act
        const exception = CacheException('Cache read failed');

        // Assert
        expect(exception.message, equals('Cache read failed'));
        expect(exception.operation, isNull);
        expect(exception, isA<AppException>());
      });

      test('should create cache exception with operation', () {
        // Arrange & Act
        const exception = CacheException(
          'Cache operation failed',
          operation: 'READ',
        );

        // Assert
        expect(exception.message, equals('Cache operation failed'));
        expect(exception.operation, equals('READ'));
      });

      test('should have meaningful toString with operation', () {
        // Arrange & Act
        const exception = CacheException('Failed to read', operation: 'READ');

        // Assert
        expect(exception.toString(), contains('CacheException'));
        expect(exception.toString(), contains('Failed to read'));
        expect(exception.toString(), contains('READ'));
      });
    });

    group('NetworkException', () {
      test('should create network exception', () {
        // Arrange & Act
        const exception = NetworkException('No internet connection');

        // Assert
        expect(exception.message, equals('No internet connection'));
        expect(exception, isA<AppException>());
      });

      test('should have meaningful toString', () {
        // Arrange & Act
        const exception = NetworkException('Connection timeout');

        // Assert
        expect(exception.toString(), contains('NetworkException'));
        expect(exception.toString(), contains('Connection timeout'));
      });
    });

    group('AuthenticationException', () {
      test('should create authentication exception', () {
        // Arrange & Act
        const exception = AuthenticationException('Invalid credentials');

        // Assert
        expect(exception.message, equals('Invalid credentials'));
        expect(exception.authCode, isNull);
        expect(exception, isA<AppException>());
      });

      test('should create authentication exception with auth code', () {
        // Arrange & Act
        const exception = AuthenticationException(
          'Token expired',
          authCode: 'TOKEN_EXPIRED',
        );

        // Assert
        expect(exception.message, equals('Token expired'));
        expect(exception.authCode, equals('TOKEN_EXPIRED'));
      });
    });

    group('AuthorizationException', () {
      test('should create authorization exception', () {
        // Arrange & Act
        const exception = AuthorizationException('Access denied');

        // Assert
        expect(exception.message, equals('Access denied'));
        expect(exception.requiredPermission, isNull);
        expect(exception, isA<AppException>());
      });

      test(
        'should create authorization exception with required permission',
        () {
          // Arrange & Act
          const exception = AuthorizationException(
            'Insufficient permissions',
            requiredPermission: 'admin',
          );

          // Assert
          expect(exception.message, equals('Insufficient permissions'));
          expect(exception.requiredPermission, equals('admin'));
        },
      );
    });

    group('ValidationException', () {
      test('should create validation exception', () {
        // Arrange & Act
        const exception = ValidationException('Validation failed');

        // Assert
        expect(exception.message, equals('Validation failed'));
        expect(exception.fieldErrors, isNull);
        expect(exception, isA<AppException>());
      });

      test('should create validation exception with field errors', () {
        // Arrange & Act
        const fieldErrors = {
          'email': 'Invalid format',
          'password': 'Too short',
        };
        const exception = ValidationException(
          'Form validation failed',
          fieldErrors: fieldErrors,
        );

        // Assert
        expect(exception.message, equals('Form validation failed'));
        expect(exception.fieldErrors, equals(fieldErrors));
        expect(exception.fieldErrors!['email'], equals('Invalid format'));
        expect(exception.fieldErrors!['password'], equals('Too short'));
      });
    });

    group('SyncException', () {
      test('should create sync exception', () {
        // Arrange & Act
        const exception = SyncException('Sync failed');

        // Assert
        expect(exception.message, equals('Sync failed'));
        expect(exception.operation, isNull);
        expect(exception.conflictCount, isNull);
        expect(exception, isA<AppException>());
      });

      test('should create sync exception with details', () {
        // Arrange & Act
        const exception = SyncException(
          'Conflicts detected',
          operation: 'MERGE',
          conflictCount: 3,
        );

        // Assert
        expect(exception.message, equals('Conflicts detected'));
        expect(exception.operation, equals('MERGE'));
        expect(exception.conflictCount, equals(3));
      });
    });

    group('StorageException', () {
      test('should create storage exception', () {
        // Arrange & Act
        const exception = StorageException('Storage write failed');

        // Assert
        expect(exception.message, equals('Storage write failed'));
        expect(exception.operation, isNull);
        expect(exception, isA<AppException>());
      });

      test('should create storage exception with operation', () {
        // Arrange & Act
        const exception = StorageException(
          'Operation failed',
          operation: 'WRITE',
        );

        // Assert
        expect(exception.message, equals('Operation failed'));
        expect(exception.operation, equals('WRITE'));
      });
    });

    group('CryptographyException', () {
      test('should create cryptography exception', () {
        // Arrange & Act
        const exception = CryptographyException('Encryption failed');

        // Assert
        expect(exception.message, equals('Encryption failed'));
        expect(exception.operation, isNull);
        expect(exception.algorithm, isNull);
        expect(exception, isA<AppException>());
      });

      test('should create cryptography exception with details', () {
        // Arrange & Act
        const exception = CryptographyException(
          'Key generation failed',
          operation: 'KEY_GEN',
          algorithm: 'AES-256',
        );

        // Assert
        expect(exception.message, equals('Key generation failed'));
        expect(exception.operation, equals('KEY_GEN'));
        expect(exception.algorithm, equals('AES-256'));
      });

      test('should have meaningful toString with details', () {
        // Arrange & Act
        const exception = CryptographyException(
          'Decryption failed',
          operation: 'DECRYPT',
          algorithm: 'AES-256',
        );

        // Assert
        expect(exception.toString(), contains('CryptographyException'));
        expect(exception.toString(), contains('Decryption failed'));
        expect(exception.toString(), contains('DECRYPT'));
        expect(exception.toString(), contains('AES-256'));
      });
    });

    group('AuthException alias', () {
      test('should be alias for AuthenticationException', () {
        // Arrange & Act
        const exception = AuthException('Auth failed');

        // Assert
        expect(exception, isA<AuthenticationException>());
        expect(exception.message, equals('Auth failed'));
      });
    });

    group('Exception hierarchy polymorphism', () {
      test('should support polymorphic behavior', () {
        // Arrange
        const exceptions = <AppException>[
          ServerException('Server error', statusCode: 500),
          CacheException('Cache error', operation: 'READ'),
          NetworkException('Network error'),
          AuthenticationException('Auth error', authCode: 'INVALID'),
          ValidationException('Validation error'),
          SyncException('Sync error', conflictCount: 2),
          StorageException('Storage error', operation: 'WRITE'),
          CryptographyException('Crypto error', algorithm: 'AES'),
        ];

        // Act & Assert
        for (final exception in exceptions) {
          expect(exception, isA<AppException>());
          expect(exception.message, isNotEmpty);
          expect(exception.toString(), isNotEmpty);
        }
      });
    });
  });
}
