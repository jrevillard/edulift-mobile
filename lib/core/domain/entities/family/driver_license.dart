// EduLift Mobile - Driver License Entity
// Represents driver license information for family members

import 'package:equatable/equatable.dart';

/// Driver license status enumeration
enum DriverLicenseStatus {
  valid('valid', 'Valid', 'License is currently valid'),
  expired('expired', 'Expired', 'License has expired'),
  suspended('suspended', 'Suspended', 'License is suspended'),
  revoked('revoked', 'Revoked', 'License has been revoked'),
  provisional('provisional', 'Provisional', 'Provisional/learner license'),
  pending('pending', 'Pending', 'License application pending');

  const DriverLicenseStatus(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;

  /// Get status from string value
  static DriverLicenseStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'valid':
        return DriverLicenseStatus.valid;
      case 'expired':
        return DriverLicenseStatus.expired;
      case 'suspended':
        return DriverLicenseStatus.suspended;
      case 'revoked':
        return DriverLicenseStatus.revoked;
      case 'provisional':
        return DriverLicenseStatus.provisional;
      case 'pending':
        return DriverLicenseStatus.pending;
      default:
        return DriverLicenseStatus.pending;
    }
  }

  /// Check if license allows driving
  bool get allowsDriving =>
      this == DriverLicenseStatus.valid ||
      this == DriverLicenseStatus.provisional;

  @override
  String toString() => label;
}

/// Driver license information
class DriverLicense extends Equatable {
  /// License number
  final String licenseNumber;

  /// License status
  final DriverLicenseStatus status;

  /// Issue date
  final DateTime issuedDate;

  /// Expiration date
  final DateTime expirationDate;

  /// Issuing state/province
  final String issuingState;

  /// License class (e.g., 'Class C', 'CDL')
  final String licenseClass;

  /// Any restrictions on the license
  final List<String> restrictions;

  /// Any endorsements on the license
  final List<String> endorsements;

  const DriverLicense({
    required this.licenseNumber,
    required this.status,
    required this.issuedDate,
    required this.expirationDate,
    required this.issuingState,
    this.licenseClass = 'Class C',
    this.restrictions = const [],
    this.endorsements = const [],
  });

  /// Create from JSON

  /// Convert to JSON

  /// Copy with new values
  DriverLicense copyWith({
    String? licenseNumber,
    DriverLicenseStatus? status,
    DateTime? issuedDate,
    DateTime? expirationDate,
    String? issuingState,
    String? licenseClass,
    List<String>? restrictions,
    List<String>? endorsements,
  }) {
    return DriverLicense(
      licenseNumber: licenseNumber ?? this.licenseNumber,
      status: status ?? this.status,
      issuedDate: issuedDate ?? this.issuedDate,
      expirationDate: expirationDate ?? this.expirationDate,
      issuingState: issuingState ?? this.issuingState,
      licenseClass: licenseClass ?? this.licenseClass,
      restrictions: restrictions ?? this.restrictions,
      endorsements: endorsements ?? this.endorsements,
    );
  }

  /// Check if license is currently valid (not expired and status allows driving)
  bool get isValid {
    if (!status.allowsDriving) return false;
    return DateTime.now().isBefore(expirationDate);
  }

  /// Check if license is expired
  bool get isExpired => DateTime.now().isAfter(expirationDate);

  /// Check if license expires soon (within 30 days)
  bool get expiresSoon {
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return expirationDate.isBefore(thirtyDaysFromNow) && !isExpired;
  }

  /// Get days until expiration (negative if expired)
  int get daysUntilExpiration =>
      expirationDate.difference(DateTime.now()).inDays;

  /// Check if license has specific restriction
  bool hasRestriction(String restriction) => restrictions.any(
    (r) => r.toLowerCase().contains(restriction.toLowerCase()),
  );

  /// Check if license has specific endorsement
  bool hasEndorsement(String endorsement) => endorsements.any(
    (e) => e.toLowerCase().contains(endorsement.toLowerCase()),
  );

  /// Get formatted license display text
  String get displayText => '$licenseClass - $licenseNumber ($issuingState)';

  @override
  List<Object?> get props => [
    licenseNumber,
    status,
    issuedDate,
    expirationDate,
    issuingState,
    licenseClass,
    restrictions,
    endorsements,
  ];

  @override
  String toString() {
    return 'DriverLicense(number: $licenseNumber, status: $status, expires: ${expirationDate.toString().split(' ')[0]})';
  }
}
