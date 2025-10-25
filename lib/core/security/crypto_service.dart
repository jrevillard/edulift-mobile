import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import '../errors/exceptions.dart';
import '../utils/result.dart';
import 'crypto_config.dart';

/// Production-grade cryptographic service
///
/// Provides AES-256-GCM authenticated encryption with PBKDF2 key derivation
/// following NIST recommendations and OWASP 2024 security standards.
///
/// Features:
/// - AES-256-GCM authenticated encryption
/// - PBKDF2-SHA256 key derivation with configurable iterations
/// - Cryptographically secure random number generation
/// - Memory-safe operations with secure disposal
/// - Versioned encrypted blob format for future compatibility
class CryptoService {
  // Security parameters (NIST compliant)
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 12; // 96 bits for GCM
  static const int _tagLength = 16; // 128 bits
  static const int _saltLength = 16; // 128 bits

  final CryptoConfig _config;
  final SecureRandom _secureRandom;

  // Constructor with dependency injection
  CryptoService(this._config) : _secureRandom = _createSecureRandom();

  // Test constructor for faster test execution
  CryptoService.forTesting()
      : _config = CryptoConfig.test,
        _secureRandom = _createSecureRandom();

  // Expose iterations for compatibility
  int get _pbkdf2Iterations => _config.pbkdf2Iterations;

  /// Create a cryptographically secure random number generator
  static SecureRandom _createSecureRandom() {
    final secureRandom = SecureRandom('Fortuna');
    final seedSource = Random.secure();
    final seed = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      seed[i] = seedSource.nextInt(256);
    }
    secureRandom.seed(KeyParameter(seed));
    return secureRandom;
  }

  /// Encrypt data using AES-256-GCM with PBKDF2 key derivation
  ///
  /// This method provides authenticated encryption with the following process:
  /// 1. Generate cryptographically secure salt and IV
  /// 2. Derive encryption key using PBKDF2-SHA256
  /// 3. Encrypt plaintext using AES-256-GCM
  /// 4. Return versioned blob: version(1) + keyId(4) + salt(16) + iv(12) + ciphertext + tag(16)
  ///
  /// The result is base64-encoded for safe string storage.
  Result<String, CryptographyException> encrypt(
    String plaintext,
    Uint8List masterKey, [
    int keyId = 1,
  ]) {
    try {
      // Generate cryptographically secure salt and IV
      final salt = _generateRandomBytes(_saltLength);
      final iv = _generateRandomBytes(_ivLength);

      // Derive encryption key using PBKDF2-SHA256
      final derivedKey = _deriveKey(masterKey, salt);
      final plaintextBytes = utf8.encode(plaintext);

      // Perform AES-256-GCM encryption
      final encryptionResult = _performAesGcmEncryption(
        plaintextBytes,
        derivedKey,
        iv,
      );

      if (encryptionResult.isSuccess) {
        final result = encryptionResult.value!;
        // Create versioned encrypted blob with key ID
        final blob = BytesBuilder()
          ..addByte(0x01) // Version for future compatibility
          ..add(_intToBytes(keyId, 4)) // Key ID (4 bytes)
          ..add(salt)
          ..add(iv)
          ..add(result.ciphertext)
          ..add(result.tag);

        // Securely clear derived key from memory
        _securelyZeroMemory(derivedKey);

        return Result.ok(base64Encode(blob.toBytes()));
      } else {
        _securelyZeroMemory(derivedKey);
        return Result.err(encryptionResult.error!);
      }
    } catch (e) {
      return Result.err(
        CryptographyException(
          'Encryption failed: ${e.toString()}',
          operation: 'encrypt',
          algorithm: 'AES-256-GCM',
        ),
      );
    }
  }

  /// Decrypt data using AES-256-GCM with authentication verification
  ///
  /// This method performs authenticated decryption with the following process:
  /// 1. Decode and validate the encrypted blob format
  /// 2. Extract version, key ID, salt, IV, ciphertext, and authentication tag
  /// 3. Derive decryption key using stored salt
  /// 4. Verify authentication tag and decrypt if valid
  /// 5. Return original plaintext, key ID, or detailed error
  Result<({String plaintext, int keyId}), CryptographyException> decrypt(
    String encryptedData,
    Uint8List masterKey,
  ) {
    try {
      // Decode base64 data
      final encryptedBlob = base64Decode(encryptedData);

      // Validate minimum blob length (including key ID)
      const minLength =
          1 + 4 + _saltLength + _ivLength + _tagLength; // 49 bytes
      if (encryptedBlob.length < minLength) {
        return const Result.err(
          CryptographyException(
            'Invalid encrypted data format: insufficient length',
            operation: 'decrypt',
            algorithm: 'AES-256-GCM',
          ),
        );
      }

      // Extract components
      final version = encryptedBlob[0];
      if (version != 0x01) {
        return Result.err(
          CryptographyException(
            'Unsupported encryption version: $version',
            operation: 'decrypt',
            algorithm: 'AES-256-GCM',
          ),
        );
      }

      final keyId = _bytesToInt(encryptedBlob.sublist(1, 5));
      final salt = encryptedBlob.sublist(5, 5 + _saltLength);
      final iv = encryptedBlob.sublist(
        5 + _saltLength,
        5 + _saltLength + _ivLength,
      );
      final ciphertextAndTag = encryptedBlob.sublist(
        5 + _saltLength + _ivLength,
      );

      if (ciphertextAndTag.length < _tagLength) {
        return const Result.err(
          CryptographyException(
            'Invalid encrypted data format: missing authentication tag',
            operation: 'decrypt',
            algorithm: 'AES-256-GCM',
          ),
        );
      }

      // Split ciphertext and authentication tag
      final ciphertext = ciphertextAndTag.sublist(
        0,
        ciphertextAndTag.length - _tagLength,
      );
      final tag = ciphertextAndTag.sublist(
        ciphertextAndTag.length - _tagLength,
      );

      // Derive decryption key using stored salt
      final derivedKey = _deriveKey(masterKey, salt);

      // Perform AES-256-GCM decryption with authentication
      final decryptionResult = _performAesGcmDecryption(
        ciphertext,
        derivedKey,
        iv,
        tag,
      );

      if (decryptionResult.isSuccess) {
        final plaintextBytes = decryptionResult.value!;
        _securelyZeroMemory(derivedKey);
        return Result.ok((
          plaintext: utf8.decode(plaintextBytes),
          keyId: keyId,
        ));
      } else {
        _securelyZeroMemory(derivedKey);
        return Result.err(decryptionResult.error!);
      }
    } catch (e) {
      return Result.err(
        CryptographyException(
          'Decryption failed: ${e.toString()}',
          operation: 'decrypt',
          algorithm: 'AES-256-GCM',
        ),
      );
    }
  }

  /// Generate a cryptographically secure master key
  ///
  /// This method generates a 256-bit master key using a cryptographically
  /// secure random number generator suitable for use as a root encryption key.
  Uint8List generateMasterKey() => _generateRandomBytes(_keyLength);

  /// Derive encryption key from master key using PBKDF2-SHA256
  ///
  /// Uses configurable iterations: 600,000 for production (OWASP 2024),
  /// 1,000 for testing to maintain reasonable test execution speed.
  Uint8List _deriveKey(Uint8List masterKey, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, _pbkdf2Iterations, _keyLength));
    return pbkdf2.process(masterKey);
  }

  /// Perform AES-256-GCM encryption with authentication
  Result<({Uint8List ciphertext, Uint8List tag}), CryptographyException>
      _performAesGcmEncryption(
          Uint8List plaintext, Uint8List key, Uint8List iv) {
    try {
      final cipher = GCMBlockCipher(AESEngine());
      final params = AEADParameters(
        KeyParameter(key),
        _tagLength * 8,
        iv,
        Uint8List(0),
      );

      cipher.init(true, params);

      final output = Uint8List(cipher.getOutputSize(plaintext.length));
      final len = cipher.processBytes(
        plaintext,
        0,
        plaintext.length,
        output,
        0,
      );
      final finalLen = cipher.doFinal(output, len);

      // GCM output includes both ciphertext and tag
      final totalLen = len + finalLen;
      final result = output.sublist(0, totalLen);

      // Split ciphertext and tag
      final actualCiphertext = result.sublist(0, plaintext.length);
      final tag = result.sublist(plaintext.length);

      return Result.ok((ciphertext: actualCiphertext, tag: tag));
    } catch (e) {
      return Result.err(
        CryptographyException(
          'AES-GCM encryption failed: ${e.toString()}',
          operation: 'encrypt',
          algorithm: 'AES-256-GCM',
        ),
      );
    }
  }

  /// Perform AES-256-GCM decryption with authentication verification
  Result<Uint8List, CryptographyException> _performAesGcmDecryption(
    Uint8List ciphertext,
    Uint8List key,
    Uint8List iv,
    Uint8List tag,
  ) {
    try {
      final cipher = GCMBlockCipher(AESEngine());
      final params = AEADParameters(
        KeyParameter(key),
        _tagLength * 8,
        iv,
        Uint8List(0),
      );

      cipher.init(false, params);

      // Combine ciphertext and tag for GCM processing
      final input = Uint8List.fromList([...ciphertext, ...tag]);
      final output = Uint8List(cipher.getOutputSize(input.length));

      final len = cipher.processBytes(input, 0, input.length, output, 0);
      final finalLen = cipher.doFinal(output, len);

      // Return the decrypted plaintext
      final totalLen = len + finalLen;
      return Result.ok(output.sublist(0, totalLen));
    } on InvalidCipherTextException {
      // GCM authentication failure - data may be tampered
      return const Result.err(
        CryptographyException(
          'Authentication tag verification failed - data may be tampered',
          operation: 'decrypt',
          algorithm: 'AES-256-GCM',
        ),
      );
    } catch (e) {
      return Result.err(
        CryptographyException(
          'AES-GCM decryption failed: ${e.toString()}',
          operation: 'decrypt',
          algorithm: 'AES-256-GCM',
        ),
      );
    }
  }

  /// Securely zero memory to prevent key material from remaining in memory
  void _securelyZeroMemory(Uint8List data) {
    for (var i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }

  /// Generate cryptographically secure random bytes
  Uint8List _generateRandomBytes(int length) {
    return _secureRandom.nextBytes(length);
  }

  /// Generate a cryptographically secure random salt
  Uint8List generateSalt() => _generateRandomBytes(_saltLength);

  /// Generate a cryptographically secure random IV
  Uint8List generateIV() => _generateRandomBytes(_ivLength);

  /// Get recommended PBKDF2 iteration count (can be increased for higher security)
  int get recommendedIterations => _pbkdf2Iterations;

  /// Convert integer to bytes (big-endian)
  Uint8List _intToBytes(int value, int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[length - 1 - i] = (value >> (i * 8)) & 0xFF;
    }
    return bytes;
  }

  /// Convert bytes to integer (big-endian)
  int _bytesToInt(Uint8List bytes) {
    var result = 0;
    for (var i = 0; i < bytes.length; i++) {
      result = (result << 8) | bytes[i];
    }
    return result;
  }

  /// Benchmark encryption performance for the given data size
  /// Returns encryption time in microseconds
  Future<int> benchmarkEncryption(int dataSize) async {
    final testData = String.fromCharCodes(
      List.generate(dataSize, (i) => 65 + (i % 26)),
    );
    final testKey = generateMasterKey();

    final stopwatch = Stopwatch()..start();
    encrypt(testData, testKey);
    stopwatch.stop();

    _securelyZeroMemory(testKey);

    return stopwatch.elapsedMicroseconds;
  }
}
