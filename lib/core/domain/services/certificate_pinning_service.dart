// EduLift Mobile - Certificate Pinning Service Interface (Domain Layer)
// Abstract interface for SSL certificate pinning

/// Abstract interface for SSL certificate pinning
/// This belongs in the domain layer as it defines security business rules
abstract class CertificatePinningService {
  /// Initialize certificate pinning with the configured certificates
  Future<void> initialize();

  /// Validate a certificate against the pinned certificates
  Future<bool> validateCertificate(String host, String certificate);

  /// Check if certificate pinning is enabled
  bool get isEnabled;

  /// Get pinned certificate fingerprints for a host
  List<String> getCertificateFingerprints(String host);
}

/// Configuration for certificate pinning
/// This belongs in the domain layer as it defines security business rules
abstract class CertificatePinningConfig {
  /// Map of hostnames to their pinned certificate fingerprints
  Map<String, List<String>> get pinnedCertificates;

  /// Whether to fail open (allow connection) on pinning failure
  bool get failOpen;

  /// Timeout for certificate validation
  Duration get validationTimeout;
}
