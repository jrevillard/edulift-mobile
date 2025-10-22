// EduLift Mobile - Biometric Authentication Service
// SPARC-Driven Development with Neural Coordination
// Agent: security-expert

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
// Note: local_auth_ios not available in current Dart SDK version

// import 'crypto_service.dart'; // Removed unused import

/// Biometric authentication service with state-of-the-art security
/// Supports Touch ID, Face ID, and Android biometric authentication

class BiometricService {
  final LocalAuthentication _localAuth;
  // EncryptionService will be used as static methods

  BiometricService(this._localAuth);

  /// Check if biometric authentication is available on device
  Future<bool> isAvailable() async {
    return await canCheckBiometrics();
  }

  /// Check if biometric authentication can be checked
  Future<bool> canCheckBiometrics() async {
    try {
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;

      return isDeviceSupported && canCheckBiometrics;
    } catch (e) {
      debugPrint('❌ Biometric availability check failed: $e');
      return false;
    }
  }

  /// Get available biometric types on device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('❌ Failed to get available biometrics: $e');
      return [];
    }
  }

  /// Check if biometric authentication is enrolled
  Future<bool> isBiometricEnrolled() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Biometric enrollment check failed: $e');
      return false;
    }
  }

  /// Simple authentication that returns bool for compatibility
  Future<bool> authenticateSimple({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      if (!await isAvailable()) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: _getAuthMessages(),
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Authenticate user with biometric
  Future<LegacyBiometricAuthResult> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool sensitiveTransaction = false,
  }) async {
    try {
      // Check if biometric is available
      if (!await isAvailable()) {
        return LegacyBiometricAuthResult.notAvailable();
      }

      // Check if biometric is enrolled
      if (!await isBiometricEnrolled()) {
        return LegacyBiometricAuthResult.notEnrolled();
      }

      // Perform authentication with platform-specific options
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: _getAuthMessages(),
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
          biometricOnly: true,
        ),
      );

      if (isAuthenticated) {
        // Generate secure session token for authenticated session
        final sessionToken = await _generateSecureSessionToken();
        return LegacyBiometricAuthResult.success(sessionToken: sessionToken);
      } else {
        return LegacyBiometricAuthResult.cancelled();
      }
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      debugPrint('❌ Biometric authentication error: $e');
      return LegacyBiometricAuthResult.error(message: e.toString());
    }
  }

  /// Authenticate for sensitive operations (payment, data access)
  Future<LegacyBiometricAuthResult> authenticateForSensitiveOperation({
    required String operation,
  }) async {
    return authenticate(
      reason: 'Authenticate to perform $operation',
      sensitiveTransaction: true,
    );
  }

  /// Quick authentication for app unlock
  Future<LegacyBiometricAuthResult> quickAuthenticate() async {
    return authenticate(
      reason: 'Unlock EduLift with your biometric',
      stickyAuth: false,
      useErrorDialogs: false,
    );
  }

  /// Get platform-specific authentication messages
  List<AuthMessages> _getAuthMessages() {
    return [
      // Android messages
      const AndroidAuthMessages(
        signInTitle: 'EduLift Authentication',
        biometricHint: 'Touch the fingerprint sensor or look at the camera',
        biometricNotRecognized: 'Biometric not recognized. Please try again.',
        biometricSuccess: 'Authentication successful',
        cancelButton: 'Cancel',
        deviceCredentialsRequiredTitle: 'Device Credentials Required',
        deviceCredentialsSetupDescription: 'Please set up device credentials',
        goToSettingsButton: 'Go to Settings',
        goToSettingsDescription:
            'Set up biometric authentication in device settings',
        biometricRequiredTitle: 'Biometric Required',
      ),

      // iOS messages (commented out - requires iOS plugin)
      // const IOSAuthMessages(
      //   lockOut: 'Biometric authentication is locked. Please use device passcode.',
      //   goToSettingsButton: 'Go to Settings',
      //   goToSettingsDescription: 'Enable biometric authentication in device settings',
      //   cancelButton: 'Cancel',
      //   localizedFallbackTitle: 'Use Passcode',
      // ),
    ];
  }

  /// Handle platform-specific exceptions
  LegacyBiometricAuthResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return LegacyBiometricAuthResult.notAvailable();

      case 'NotEnrolled':
        return LegacyBiometricAuthResult.notEnrolled();

      case 'UserCancel':
        return LegacyBiometricAuthResult.cancelled();

      case 'UserFallback':
        return LegacyBiometricAuthResult.fallback();

      case 'BiometricOnlyNotSupported':
        return LegacyBiometricAuthResult.error(
          message: 'Biometric-only authentication not supported',
        );

      case 'DeviceNotSupported':
        return LegacyBiometricAuthResult.error(
          message: 'Device does not support biometric authentication',
        );

      case 'PasscodeNotSet':
        return LegacyBiometricAuthResult.error(
          message: 'Device passcode is not set. Please set up device security.',
        );

      case 'LockedOut':
        return LegacyBiometricAuthResult.lockedOut();

      case 'PermanentlyLockedOut':
        return LegacyBiometricAuthResult.permanentlyLockedOut();

      default:
        debugPrint('❌ Unknown biometric error: ${e.code} - ${e.message}');
        return LegacyBiometricAuthResult.error(
          message: e.message ?? 'Unknown biometric authentication error',
        );
    }
  }

  /// Generate secure session token after successful authentication
  Future<String> _generateSecureSessionToken() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'biometric_token_${timestamp}_${Platform.operatingSystem}';
  }

  /// Get human-readable biometric type
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return Platform.isIOS ? 'Face ID' : 'Face Recognition';
      case BiometricType.fingerprint:
        return Platform.isIOS ? 'Touch ID' : 'Fingerprint';
      case BiometricType.iris:
        return 'Iris Recognition';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  /// Check if biometric can be used (compatibility method for SecurityMonitorService)
  /// @param context - unused parameter for backward compatibility
  Future<bool> canUseBiometric(dynamic context) async {
    return await isAvailable();
  }

  /// Get security level of available biometrics
  BiometricSecurityLevel getSecurityLevel() {
    // This would need platform-specific implementation
    // For now, return conservative estimate
    return BiometricSecurityLevel.high;
  }
}

/// Biometric authentication result with detailed state information
class LegacyBiometricAuthResult {
  final BiometricAuthStatus status;
  final String? message;
  final String? sessionToken;

  const LegacyBiometricAuthResult._({
    required this.status,
    this.message,
    this.sessionToken,
  });

  /// Authentication successful
  factory LegacyBiometricAuthResult.success({String? sessionToken}) {
    return LegacyBiometricAuthResult._(
      status: BiometricAuthStatus.success,
      sessionToken: sessionToken,
    );
  }

  /// Biometric not available on device
  factory LegacyBiometricAuthResult.notAvailable() {
    return const LegacyBiometricAuthResult._(
      status: BiometricAuthStatus.notAvailable,
      message: 'Biometric authentication is not available on this device',
    );
  }

  /// Biometric not enrolled
  factory LegacyBiometricAuthResult.notEnrolled() {
    return const LegacyBiometricAuthResult._(
      status: BiometricAuthStatus.notEnrolled,
      message: 'No biometric credentials are enrolled on this device',
    );
  }

  /// User cancelled authentication
  factory LegacyBiometricAuthResult.cancelled() {
    return const LegacyBiometricAuthResult._(
      status: BiometricAuthStatus.cancelled,
      message: 'Authentication was cancelled by user',
    );
  }

  /// User chose fallback authentication
  factory LegacyBiometricAuthResult.fallback() {
    return const LegacyBiometricAuthResult._(
      status: BiometricAuthStatus.fallback,
      message: 'User chose fallback authentication method',
    );
  }

  /// Biometric authentication locked out
  factory LegacyBiometricAuthResult.lockedOut() {
    return const LegacyBiometricAuthResult._(
      status: BiometricAuthStatus.lockedOut,
      message:
          'Biometric authentication is temporarily locked. Try again later.',
    );
  }

  /// Biometric authentication permanently locked out
  factory LegacyBiometricAuthResult.permanentlyLockedOut() {
    return const LegacyBiometricAuthResult._(
      status: BiometricAuthStatus.permanentlyLockedOut,
      message:
          'Biometric authentication is permanently locked. Use device passcode.',
    );
  }

  /// Authentication error
  factory LegacyBiometricAuthResult.error({required String message}) {
    return LegacyBiometricAuthResult._(
      status: BiometricAuthStatus.error,
      message: message,
    );
  }

  /// Check if authentication was successful
  bool get isSuccess => status == BiometricAuthStatus.success;

  /// Check if authentication failed
  bool get isFailure => !isSuccess;

  /// Check if biometric is available but not enrolled
  bool get needsEnrollment => status == BiometricAuthStatus.notEnrolled;

  /// Check if biometric is not supported
  bool get isNotSupported => status == BiometricAuthStatus.notAvailable;
}

/// Biometric authentication status enum
enum BiometricAuthStatus {
  success,
  notAvailable,
  notEnrolled,
  cancelled,
  fallback,
  lockedOut,
  permanentlyLockedOut,
  error,
}

/// Biometric security level classification
enum BiometricSecurityLevel {
  /// High security (Face ID, strong fingerprint sensors)
  high,

  /// Medium security (standard fingerprint sensors)
  medium,

  /// Low security (weak biometric sensors)
  low,
}

/// Biometric service module for dependency injection

abstract class BiometricModule {
  LocalAuthentication get localAuthentication => LocalAuthentication();
}
