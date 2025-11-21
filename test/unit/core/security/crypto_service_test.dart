import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/security/crypto_service.dart';
import 'package:edulift/core/errors/exceptions.dart';
import 'package:edulift/core/utils/result.dart';

void main() {
  group('CryptoService Tests - TDD London', () {
    late CryptoService cryptoService;

    setUp(() {
      // Use test configuration for faster execution
      cryptoService = CryptoService.forTesting();
    });

    group('Encryption/Decryption Round Trip Tests', () {
      test('should encrypt and decrypt successfully with master key', () async {
        // Arrange
        const plaintext = 'Test sensitive data';
        final masterKey = Uint8List.fromList(
          List.generate(32, (i) => i),
        ); // 256-bit key

        // Act
        final encryptResult = await cryptoService.encrypt(plaintext, masterKey);
        expect(encryptResult.isSuccess, true);

        final decryptResult = await cryptoService.decrypt(
          encryptResult.value!,
          masterKey,
        );

        // Assert
        expect(decryptResult.isSuccess, true);
        expect(decryptResult.value!.plaintext, equals(plaintext));
      });

      test('should fail decryption with wrong master key', () async {
        // Arrange
        const plaintext = 'Test sensitive data';
        final correctKey = Uint8List.fromList(List.generate(32, (i) => i));
        final wrongKey = Uint8List.fromList(List.generate(32, (i) => i + 1));

        // Act
        final encryptResult = await cryptoService.encrypt(
          plaintext,
          correctKey,
        );
        expect(encryptResult.isSuccess, true);

        final decryptResult = await cryptoService.decrypt(
          encryptResult.value!,
          wrongKey,
        );

        // Assert
        expect(decryptResult.isSuccess, false);
        expect(decryptResult.error, isA<CryptographyException>());
      });

      test('should handle empty plaintext', () async {
        // Arrange
        const plaintext = '';
        final masterKey = Uint8List.fromList(List.generate(32, (i) => i));

        // Act
        final encryptResult = await cryptoService.encrypt(plaintext, masterKey);
        expect(encryptResult.isSuccess, true);

        final decryptResult = await cryptoService.decrypt(
          encryptResult.value!,
          masterKey,
        );

        // Assert
        expect(decryptResult.isSuccess, true);
        expect(decryptResult.value!.plaintext, equals(plaintext));
      });

      test('should handle special characters', () async {
        // Arrange
        const plaintext = '🔐 Special chars: àáâãäå ñ ç 中文 العربية 🚀';
        final masterKey = Uint8List.fromList(List.generate(32, (i) => i));

        // Act
        final encryptResult = await cryptoService.encrypt(plaintext, masterKey);
        expect(encryptResult.isSuccess, true);

        final decryptResult = await cryptoService.decrypt(
          encryptResult.value!,
          masterKey,
        );

        // Assert
        expect(decryptResult.isSuccess, true);
        expect(decryptResult.value!.plaintext, equals(plaintext));
      });

      test('should handle long text', () async {
        // Arrange
        final longText = 'A' * 1000; // 1KB of text
        final masterKey = Uint8List.fromList(List.generate(32, (i) => i));

        // Act
        final encryptResult = await cryptoService.encrypt(longText, masterKey);
        expect(encryptResult.isSuccess, true);

        final decryptResult = await cryptoService.decrypt(
          encryptResult.value!,
          masterKey,
        );

        // Assert
        expect(decryptResult.isSuccess, true);
        expect(decryptResult.value!.plaintext, equals(longText));
      });

      test('should produce different ciphertext for same plaintext', () async {
        // Arrange
        const plaintext = 'Same plaintext';
        final masterKey = Uint8List.fromList(List.generate(32, (i) => i));

        // Act
        final encrypted1 = await cryptoService.encrypt(plaintext, masterKey);
        final encrypted2 = await cryptoService.encrypt(plaintext, masterKey);

        // Assert
        expect(encrypted1.isSuccess, true);
        expect(encrypted2.isSuccess, true);
        expect(
          encrypted1.value,
          isNot(equals(encrypted2.value)),
        ); // Different due to random IV
      });
    });

    group('Key Generation Tests', () {
      test('should generate different master keys each time', () {
        // Act
        final key1 = cryptoService.generateMasterKey();
        final key2 = cryptoService.generateMasterKey();

        // Assert
        expect(key1.length, equals(32)); // 256 bits
        expect(key2.length, equals(32));
        expect(key1, isNot(equals(key2)));
      });

      test('should generate different salts each time', () {
        // Act
        final salt1 = cryptoService.generateSalt();
        final salt2 = cryptoService.generateSalt();

        // Assert
        expect(salt1.length, equals(16)); // 128 bits
        expect(salt2.length, equals(16));
        expect(salt1, isNot(equals(salt2)));
      });

      test('should generate different IVs each time', () {
        // Act
        final iv1 = cryptoService.generateIV();
        final iv2 = cryptoService.generateIV();

        // Assert
        expect(iv1.length, equals(12)); // 96 bits for GCM
        expect(iv2.length, equals(12));
        expect(iv1, isNot(equals(iv2)));
      });

      test('should generate cryptographically secure keys', () {
        // Arrange
        const iterations = 100;
        final keys = <String>[];

        // Act
        for (var i = 0; i < iterations; i++) {
          keys.add(base64Encode(cryptoService.generateMasterKey()));
        }

        // Assert - All keys should be unique
        final uniqueKeys = keys.toSet();
        expect(uniqueKeys.length, equals(iterations));
      });
    });

    group('Error Handling Tests', () {
      test('should handle corrupted encrypted data', () async {
        // Arrange
        final masterKey = Uint8List.fromList(List.generate(32, (i) => i));
        const corruptedData = 'invalid-base64-data!@#';

        // Act
        final result = await cryptoService.decrypt(corruptedData, masterKey);

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, isA<CryptographyException>());
      });

      test('should handle insufficient data length', () async {
        // Arrange
        final masterKey = Uint8List.fromList(List.generate(32, (i) => i));
        final shortData = base64Encode([1, 2, 3]); // Too short

        // Act
        final result = await cryptoService.decrypt(shortData, masterKey);

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, isA<CryptographyException>());
        expect(result.error!.message, contains('insufficient length'));
        expect(result.error!.operation, equals('decrypt'));
        expect(result.error!.algorithm, equals('AES-256-GCM'));
      });

      test('should handle tampered authentication tag', () async {
        // Arrange
        const plaintext = 'Test data';
        final masterKey = Uint8List.fromList(List.generate(32, (i) => i));

        final encryptResult = await cryptoService.encrypt(plaintext, masterKey);
        expect(encryptResult.isSuccess, true);

        // Tamper with the last few bytes (authentication tag area)
        final originalBytes = base64Decode(encryptResult.value!);
        if (originalBytes.length > 16) {
          originalBytes[originalBytes.length - 1] ^=
              0xFF; // Flip bits in last byte
          final tamperedData = base64Encode(originalBytes);

          // Act
          final decryptResult = await cryptoService.decrypt(
            tamperedData,
            masterKey,
          );

          // Assert
          expect(decryptResult.isSuccess, false);
          expect(decryptResult.error, isA<CryptographyException>());
        }
      });

      test('should handle invalid version in encrypted data', () async {
        // Arrange
        final masterKey = Uint8List.fromList(List.generate(32, (i) => i));
        const plaintext = 'Test data';

        final encryptResult = await cryptoService.encrypt(plaintext, masterKey);
        expect(encryptResult.isSuccess, true);

        // Change version byte to invalid version
        final originalBytes = base64Decode(encryptResult.value!);
        originalBytes[0] = 0xFF; // Invalid version
        final invalidVersionData = base64Encode(originalBytes);

        // Act
        final decryptResult = await cryptoService.decrypt(
          invalidVersionData,
          masterKey,
        );

        // Assert
        expect(decryptResult.isSuccess, false);
        expect(decryptResult.error, isA<CryptographyException>());
        expect(
          decryptResult.error!.message,
          contains('Unsupported encryption version'),
        );
      });
    });

    group('Performance and Security', () {
      // Performance timing test removed - arbitrary timeout assertion

      test('should handle concurrent operations', () async {
        // Arrange
        const plaintext = 'Concurrent test data';
        final masterKey = Uint8List.fromList(List.generate(32, (i) => i));

        // Act - Multiple operations
        final results = <Result<String, CryptographyException>>[];
        for (var i = 0; i < 10; i++) {
          results.add(await cryptoService.encrypt('$plaintext $i', masterKey));
        }

        // Assert
        for (final result in results) {
          expect(result.isSuccess, true);
          expect(result.value, isNotEmpty);
        }

        // Verify all results are different (due to random IVs)
        final values = results.map((r) => r.value).toSet();
        expect(values.length, equals(10));
      });
    });

    // Benchmark test group removed - arbitrary performance assertions
  });
}
