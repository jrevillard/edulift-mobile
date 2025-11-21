import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/core/security/data_protection_service.dart';
import 'package:edulift/core/errors/exceptions.dart';
import 'package:edulift/core/utils/result.dart';

import '../../../test_mocks/test_mocks.mocks.dart';

// Test fixtures for crypto results
class CryptoTestResults {
  static const encryptionSuccess = Result<String, CryptographyException>.ok(
    'encrypted_test_data_base64',
  );
  static const encryptionFailure = Result<String, CryptographyException>.err(
    CryptographyException(
      'Encryption failed',
      operation: 'encrypt',
      algorithm: 'AES-256-GCM',
    ),
  );

  static const decryptionSuccess =
      Result<({String plaintext, int keyId}), CryptographyException>.ok((
        plaintext: 'Test sensitive data',
        keyId: 1,
      ));
  static const decryptionFailure =
      Result<({String plaintext, int keyId}), CryptographyException>.err(
        CryptographyException(
          'Authentication tag verification failed',
          operation: 'decrypt',
          algorithm: 'AES-256-GCM',
        ),
      );
}

class SecurityTestFixtures {
  static const testPlaintext = 'Test sensitive data';
  static const testCiphertext = 'encrypted_test_data_base64';
  static const masterKeysStorageKey = 'master_encryption_keys';
  static final testMasterKeyBytes = Uint8List.fromList(
    List.generate(32, (i) => i + 1),
  );

  static String get testKeyStorage => jsonEncode({
    'currentKeyId': 1,
    'keys': {'1': base64Encode(testMasterKeyBytes)},
  });
}

void main() {
  // Provide dummy values for Result types to fix MissingDummyValueError
  setUpAll(() {
    provideDummy<Result<String, CryptographyException>>(
      const Result.ok('dummy_encrypted_data'),
    );
    provideDummy<
      Result<({String plaintext, int keyId}), CryptographyException>
    >(const Result.ok((plaintext: 'dummy_plaintext', keyId: 1)));
    provideDummy<Result<Uint8List, CryptographyException>>(
      Result.ok(Uint8List.fromList([1, 2, 3])),
    );
  });

  // Clean test data using CryptoTestResults and SecurityTestFixtures
  group('DataProtectionService Tests - TDD London (Updated)', () {
    late DataProtectionService dataProtectionService;
    late MockCryptoService mockCryptoService;
    late MockAdaptiveStorageService mockAdaptiveStorageService;

    setUp(() {
      mockCryptoService = MockCryptoService();
      mockAdaptiveStorageService = MockAdaptiveStorageService();
      dataProtectionService = DataProtectionService(
        mockCryptoService,
        mockAdaptiveStorageService,
      );
    });

    group('Encryption Tests', () {
      test('should encrypt successfully with existing master key', () async {
        // Arrange - Mock storage has existing key structure
        when(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).thenAnswer((_) async => SecurityTestFixtures.testKeyStorage);
        when(
          mockCryptoService.encrypt(SecurityTestFixtures.testPlaintext, any),
        ).thenAnswer((_) async => CryptoTestResults.encryptionSuccess);

        // Act
        final result = await dataProtectionService.encrypt(
          SecurityTestFixtures.testPlaintext,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, equals(SecurityTestFixtures.testCiphertext));

        // Verify interactions
        verify(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).called(1);
        verify(
          mockCryptoService.encrypt(SecurityTestFixtures.testPlaintext, any),
        ).called(1);
      });

      test(
        'should encrypt successfully by creating new key storage when none exists',
        () async {
          // Arrange - No existing keys, create new structure
          when(
            mockAdaptiveStorageService.read(
              SecurityTestFixtures.masterKeysStorageKey,
            ),
          ).thenAnswer((_) async => null);
          when(
            mockCryptoService.generateMasterKey(),
          ).thenReturn(SecurityTestFixtures.testMasterKeyBytes);
          when(
            mockAdaptiveStorageService.write(any, any),
          ).thenAnswer((_) async => null);
          when(
            mockCryptoService.encrypt(SecurityTestFixtures.testPlaintext, any),
          ).thenAnswer((_) async => CryptoTestResults.encryptionSuccess);

          // Act
          final result = await dataProtectionService.encrypt(
            SecurityTestFixtures.testPlaintext,
          );

          // Assert
          expect(result.isSuccess, true);
          expect(result.value, equals(SecurityTestFixtures.testCiphertext));

          // Verify interactions
          verify(
            mockAdaptiveStorageService.read(
              SecurityTestFixtures.masterKeysStorageKey,
            ),
          ).called(1);
          verify(mockCryptoService.generateMasterKey()).called(1);
          verify(
            mockAdaptiveStorageService.write(
              SecurityTestFixtures.masterKeysStorageKey,
              any,
            ),
          ).called(1);
          verify(
            mockCryptoService.encrypt(SecurityTestFixtures.testPlaintext, any),
          ).called(1);
        },
      );

      test('should handle storage exception during key retrieval', () async {
        // Arrange - Storage throws exception
        when(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).thenThrow(
          const StorageException('Storage read failed', operation: 'read'),
        );

        // Act
        final result = await dataProtectionService.encrypt(
          SecurityTestFixtures.testPlaintext,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, isA<CryptographyException>());
        expect(
          result.error!.message,
          contains('Failed to retrieve master key from storage'),
        );
        expect(result.error!.operation, equals('encrypt'));
        expect(result.error!.algorithm, equals('AES-256-GCM'));

        // Verify interactions
        verify(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).called(1);
        verifyZeroInteractions(mockCryptoService);
      });

      test('should return error when cryptoService.encrypt fails', () async {
        // Arrange - Storage works but crypto service fails
        when(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).thenAnswer((_) async => SecurityTestFixtures.testKeyStorage);
        when(
          mockCryptoService.encrypt(SecurityTestFixtures.testPlaintext, any),
        ).thenAnswer((_) async => CryptoTestResults.encryptionFailure);

        // Act
        final result = await dataProtectionService.encrypt(
          SecurityTestFixtures.testPlaintext,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, isA<CryptographyException>());

        // Verify interactions
        verify(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).called(1);
        verify(
          mockCryptoService.encrypt(SecurityTestFixtures.testPlaintext, any),
        ).called(1);
      });
    });

    group('Decryption Tests', () {
      test('should decrypt successfully with existing master key', () async {
        // Arrange - Mock storage has existing key structure
        when(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).thenAnswer((_) async => SecurityTestFixtures.testKeyStorage);
        when(
          mockCryptoService.decrypt(SecurityTestFixtures.testCiphertext, any),
        ).thenAnswer((_) async => CryptoTestResults.decryptionSuccess);

        // Act
        final result = await dataProtectionService.decrypt(
          SecurityTestFixtures.testCiphertext,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, equals(SecurityTestFixtures.testPlaintext));

        // Verify interactions
        verify(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).called(1);
        verify(
          mockCryptoService.decrypt(SecurityTestFixtures.testCiphertext, any),
        ).called(1);
      });

      test('should return error when cryptoService.decrypt fails', () async {
        // Arrange - Storage works but crypto service fails
        when(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).thenAnswer((_) async => SecurityTestFixtures.testKeyStorage);
        when(
          mockCryptoService.decrypt(SecurityTestFixtures.testCiphertext, any),
        ).thenAnswer((_) async => CryptoTestResults.decryptionFailure);

        // Act
        final result = await dataProtectionService.decrypt(
          SecurityTestFixtures.testCiphertext,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, isA<CryptographyException>());

        // Verify interactions - May call decrypt multiple times due to fallback logic
        verify(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).called(1);
        verify(
          mockCryptoService.decrypt(SecurityTestFixtures.testCiphertext, any),
        ).called(greaterThan(0));
      });
    });

    group('Key Management Tests', () {
      test('should return true when master keys exist', () async {
        // Arrange
        when(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).thenAnswer((_) async => SecurityTestFixtures.testKeyStorage);

        // Act
        final result = await dataProtectionService.hasMasterKey();

        // Assert
        expect(result, true);
        verify(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).called(1);
      });

      test('should return false when master keys do not exist', () async {
        // Arrange
        when(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).thenAnswer((_) async => null);

        // Act
        final result = await dataProtectionService.hasMasterKey();

        // Assert
        expect(result, false);
        verify(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).called(1);
      });

      test('should rotate master key successfully (non-destructive)', () async {
        // Arrange - Existing key storage
        when(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).thenAnswer((_) async => SecurityTestFixtures.testKeyStorage);
        when(
          mockCryptoService.generateMasterKey(),
        ).thenReturn(SecurityTestFixtures.testMasterKeyBytes);
        when(
          mockAdaptiveStorageService.write(any, any),
        ).thenAnswer((_) async => null);

        // Act
        await dataProtectionService.rotateMasterKey();

        // Assert
        verify(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).called(1);
        verify(mockCryptoService.generateMasterKey()).called(1);
        verify(
          mockAdaptiveStorageService.write(
            SecurityTestFixtures.masterKeysStorageKey,
            any,
          ),
        ).called(1);
      });

      test('should get current key ID', () async {
        // Arrange
        when(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).thenAnswer((_) async => SecurityTestFixtures.testKeyStorage);

        // Act
        final keyId = await dataProtectionService.getCurrentKeyId();

        // Assert
        expect(keyId, equals(1));
        verify(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).called(1);
      });

      test('should get available key IDs', () async {
        // Arrange - Multiple keys
        final multiKeyStorage = jsonEncode({
          'currentKeyId': 2,
          'keys': {
            '1': base64Encode(SecurityTestFixtures.testMasterKeyBytes),
            '2': base64Encode(SecurityTestFixtures.testMasterKeyBytes),
          },
        });
        when(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).thenAnswer((_) async => multiKeyStorage);

        // Act
        final keyIds = await dataProtectionService.getAvailableKeyIds();

        // Assert
        expect(keyIds, equals([1, 2]));
        verify(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).called(1);
      });
    });

    group('Session Key Caching Tests', () {
      test('should cache key for performance on repeated operations', () async {
        // Arrange
        when(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).thenAnswer((_) async => SecurityTestFixtures.testKeyStorage);
        when(
          mockCryptoService.encrypt(SecurityTestFixtures.testPlaintext, any),
        ).thenAnswer((_) async => CryptoTestResults.encryptionSuccess);

        // Act - Multiple encrypt operations
        await dataProtectionService.encrypt(SecurityTestFixtures.testPlaintext);
        await dataProtectionService.encrypt(SecurityTestFixtures.testPlaintext);

        // Assert - Storage should only be read once (cached after first call)
        verify(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).called(1);
        verify(
          mockCryptoService.encrypt(SecurityTestFixtures.testPlaintext, any),
        ).called(2);
      });

      test('should clear cache after key rotation', () async {
        // Arrange
        when(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).thenAnswer((_) async => SecurityTestFixtures.testKeyStorage);
        when(
          mockCryptoService.generateMasterKey(),
        ).thenReturn(SecurityTestFixtures.testMasterKeyBytes);
        when(
          mockAdaptiveStorageService.write(any, any),
        ).thenAnswer((_) async => null);
        when(
          mockCryptoService.encrypt(SecurityTestFixtures.testPlaintext, any),
        ).thenAnswer((_) async => CryptoTestResults.encryptionSuccess);

        // Act - Encrypt, rotate, encrypt again
        await dataProtectionService.encrypt(SecurityTestFixtures.testPlaintext);
        await dataProtectionService.rotateMasterKey();
        await dataProtectionService.encrypt(SecurityTestFixtures.testPlaintext);

        // Assert - Storage should be read multiple times (before rotation and after)
        verify(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).called(greaterThanOrEqualTo(2));
      });
    });

    group('Error Handling Edge Cases', () {
      test('should handle storage write failure during key rotation', () async {
        // Arrange - Read works but write fails
        when(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).thenAnswer((_) async => SecurityTestFixtures.testKeyStorage);
        when(
          mockCryptoService.generateMasterKey(),
        ).thenReturn(SecurityTestFixtures.testMasterKeyBytes);
        when(
          mockAdaptiveStorageService.write(
            SecurityTestFixtures.masterKeysStorageKey,
            any,
          ),
        ).thenThrow(const StorageException('Write failed', operation: 'write'));

        // Act & Assert
        await expectLater(
          () => dataProtectionService.rotateMasterKey(),
          throwsA(isA<StorageException>()),
        );

        // Verify interactions
        verify(
          mockAdaptiveStorageService.read(
            SecurityTestFixtures.masterKeysStorageKey,
          ),
        ).called(1);
        verify(mockCryptoService.generateMasterKey()).called(1);
        verify(
          mockAdaptiveStorageService.write(
            SecurityTestFixtures.masterKeysStorageKey,
            any,
          ),
        ).called(1);
      });
    });
  });
}
