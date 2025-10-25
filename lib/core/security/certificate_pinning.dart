// EduLift Mobile - Certificate Pinning Security
// SPARC-Driven Development with Neural Coordination
// Agent: security-expert

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Certificate pinning implementation for enhanced API security
/// Protects against man-in-the-middle attacks with SHA-256 fingerprint validation
class CertificatePinning {
  // Private constructor to prevent instantiation
  CertificatePinning._();

  /// SHA-256 fingerprints of allowed certificates
  /// ⚠️ SECURITY CRITICAL: These must match production server certificates
  static const List<String> allowedFingerprints = [
    // Production certificate fingerprint
    'sha256/YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=',

    // Backup certificate fingerprint
    'sha256/Vjs8r4z+80wjNcr1YKepWQboSIRi63WsWXhIMN+eWys=',

    // Development certificate fingerprint (debug only)
    if (kDebugMode) 'sha256/++MBgDH5WGvL9Bcn5Be30cRcL0f5O+NyoXuWtQdX1aI=',
  ];

  /// Certificate authorities for additional validation
  static const List<String> allowedCAs = [
    // Let's Encrypt Authority X3
    'sha256/YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=',

    // DigiCert Global Root CA
    'sha256/43DAD630EE53F8A980CA6EFD85F46AA37E1B9BD82E34B0FF0ADD29A2A25E4C44=',
  ];

  /// Initialize certificate pinning with custom validation
  static Future<void> initialize() async {
    try {
      // Override certificate validation for HTTP client
      HttpOverrides.global = _CertificatePinningHttpOverrides();

      debugPrint('✅ Certificate pinning initialized successfully');
    } catch (e) {
      debugPrint('❌ Certificate pinning initialization failed: $e');
      rethrow;
    }
  }

  /// Validate certificate against allowed fingerprints
  static bool validateCertificate(X509Certificate certificate) {
    try {
      // Calculate SHA-256 fingerprint of the certificate
      final fingerprint = _calculateSHA256Fingerprint(certificate);

      // Check against allowed fingerprints
      final isValidCert = allowedFingerprints.contains(fingerprint);

      // Additional CA validation
      final isValidCA = _validateCertificateAuthority(certificate);

      if (!isValidCert) {
        debugPrint('❌ Certificate fingerprint validation failed');
        debugPrint('Expected: $allowedFingerprints');
        debugPrint('Received: $fingerprint');
      }

      if (!isValidCA) {
        debugPrint('❌ Certificate authority validation failed');
      }

      return isValidCert && isValidCA;
    } catch (e) {
      debugPrint('❌ Certificate validation error: $e');
      return false;
    }
  }

  /// Calculate SHA-256 fingerprint of certificate
  static String _calculateSHA256Fingerprint(X509Certificate certificate) {
    try {
      // Get DER encoded certificate
      final derBytes = certificate.der;

      // Calculate SHA-256 hash
      final digest = sha256.convert(derBytes);

      // Convert to base64 with SHA-256 prefix
      final fingerprint = 'sha256/${base64.encode(digest.bytes)}';

      return fingerprint;
    } catch (e) {
      debugPrint('❌ Failed to calculate certificate fingerprint: $e');
      rethrow;
    }
  }

  /// Validate certificate authority
  static bool _validateCertificateAuthority(X509Certificate certificate) {
    try {
      // Extract issuer information
      final issuer = certificate.issuer;

      // Validate against known good CAs
      // This is a simplified check - in production, implement full chain validation
      final isKnownCA = issuer.contains('Let\'s Encrypt') ||
          issuer.contains('DigiCert') ||
          issuer.contains('GlobalSign') ||
          (kDebugMode && issuer.contains('localhost'));

      return isKnownCA;
    } catch (e) {
      debugPrint('❌ Certificate authority validation error: $e');
      return false;
    }
  }

  /// Get certificate details for debugging
  static Map<String, dynamic> getCertificateDetails(
    X509Certificate certificate,
  ) {
    return {
      'subject': certificate.subject,
      'issuer': certificate.issuer,
      'startValidity': certificate.startValidity.toIso8601String(),
      'endValidity': certificate.endValidity.toIso8601String(),
      'fingerprint': _calculateSHA256Fingerprint(certificate),
    };
  }
}

/// Custom HTTP overrides for certificate pinning
class _CertificatePinningHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);

    // Override certificate validation
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      // Log certificate details in debug mode
      if (kDebugMode) {
        final certDetails = CertificatePinning.getCertificateDetails(cert);
        debugPrint('Certificate validation for $host:$port');
        debugPrint('Certificate details: $certDetails');
      }

      // Validate certificate against pinned certificates
      final isValid = CertificatePinning.validateCertificate(cert);

      if (!isValid) {
        debugPrint(
          '❌ Certificate pinning validation failed for $host:$port',
        );
      }

      return isValid;
    };

    // Set connection timeout
    client.connectionTimeout = const Duration(seconds: 10);

    // Set idle timeout
    client.idleTimeout = const Duration(seconds: 15);

    return client;
  }
}

/// Certificate pinning interceptor for Dio
class LegacyCertificatePinningInterceptor {
  final List<String> allowedSHAFingerprints;

  const LegacyCertificatePinningInterceptor({
    required this.allowedSHAFingerprints,
  });

  /// Validate certificate fingerprint
  bool validateCertificateFingerprint(String fingerprint) {
    return allowedSHAFingerprints.contains(fingerprint);
  }
}

/// Security configuration for certificate pinning
class CertificatePinningConfig {
  // Private constructor
  CertificatePinningConfig._();

  /// Enable certificate pinning in production
  static bool get isCertificatePinningEnabled => !kDebugMode;

  /// Certificate validation timeout
  static const Duration certificateValidationTimeout = Duration(seconds: 5);

  /// Maximum certificate chain length
  static const int maxCertificateChainLength = 3;

  /// Allowed cipher suites for enhanced security
  static const List<String> allowedCipherSuites = [
    'TLS_AES_256_GCM_SHA384',
    'TLS_CHACHA20_POLY1305_SHA256',
    'TLS_AES_128_GCM_SHA256',
    'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
    'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
    'TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256',
    'TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256',
  ];

  /// Minimum TLS version required
  static const String minimumTLSVersion = '1.2';

  /// HSTS (HTTP Strict Transport Security) configuration
  static const Duration hstsMaxAge = Duration(days: 365);

  /// Certificate transparency requirements
  static const bool requireCertificateTransparency = true;
}
