/// Configuration for cryptographic operations
/// Allows customization of security parameters for different environments
class CryptoConfig {
  final int pbkdf2Iterations;
  final int saltLength;
  final int keyLength;
  final int tagLength;

  const CryptoConfig({
    required this.pbkdf2Iterations,
    this.saltLength = 16,
    this.keyLength = 32,
    this.tagLength = 16,
  });

  /// Production configuration with high security
  static const CryptoConfig production = CryptoConfig(
    pbkdf2Iterations: 600000, // OWASP recommended for 2023
  );

  /// Test configuration with lower iterations for performance
  static const CryptoConfig test = CryptoConfig(
    pbkdf2Iterations: 1000, // Much faster for testing
  );

  /// Factory for dependency injection - uses production config by default

  static CryptoConfig createDefault() => production;
}
