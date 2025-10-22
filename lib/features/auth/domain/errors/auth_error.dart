/// Domain-level errors for auth operations
/// These represent business logic errors, NOT validation errors
enum AuthError {
  // Authentication errors
  invalidToken,
  tokenExpired,
  tokenMissing,
  sessionExpired,

  // Account errors
  accountNotFound,
  accountDisabled,
  accountLocked,
  emailNotVerified,

  // Security errors
  invalidCredentials,
  securityValidationFailed,
  crossUserTokenAttempt,
  pkceVerificationFailed,
  magicLinkExpired,
  magicLinkInvalid,

  // Biometric errors
  biometricNotAvailable,
  biometricNotEnabled,
  biometricAuthFailed,

  // Storage errors
  storageError,
  tokenStorageError,
  userDataStorageError,

  // Network/API errors
  networkError,
  serverError,
  apiError,

  // Unknown/unexpected errors
  unknownError,

  // Additional errors from requirements
  tokenRefreshFailed,
  magicLinkAlreadyUsed,
  invalidVerificationCode,
  emailAlreadyExists,
  invalidEmail,
  userAlreadyInFamily,
  multipleSessionsDetected,
  suspiciousActivity,
  tooManyAttempts,
  ipBlocked,
  deviceNotRecognized,
  insufficientPermissions,
  accessDenied,
  resourceNotFound,
  biometricNotEnrolled,
  biometricLockout,
  secureStorageUnavailable,
  encryptionError,
  decryptionError,
  timeout,
  connectionLost,
  invalidRequest,
  configurationError,
  operationCancelled,
}

/// Extension to provide localization keys for auth errors
extension AuthErrorLocalization on AuthError {
  String get localizationKey {
    switch (this) {
      // Authentication Errors
      case AuthError.invalidCredentials:
        return 'errorAuthInvalidCredentials';
      case AuthError.invalidToken:
        return 'errorAuthInvalidToken';
      case AuthError.tokenExpired:
        return 'errorAuthTokenExpired';
      case AuthError.tokenRefreshFailed:
        return 'errorAuthTokenRefreshFailed';
      case AuthError.magicLinkInvalid:
        return 'errorAuthInvalidMagicLink';
      case AuthError.magicLinkExpired:
        return 'errorAuthMagicLinkExpired';
      case AuthError.magicLinkAlreadyUsed:
        return 'errorAuthMagicLinkAlreadyUsed';
      case AuthError.invalidVerificationCode:
        return 'errorAuthInvalidVerificationCode';

      // Account Errors
      case AuthError.accountNotFound:
        return 'errorAuthAccountNotFound';
      case AuthError.accountDisabled:
        return 'errorAuthAccountDisabled';
      case AuthError.accountLocked:
        return 'errorAuthAccountLocked';
      case AuthError.emailAlreadyExists:
        return 'errorAuthEmailAlreadyExists';
      case AuthError.invalidEmail:
        return 'errorAuthInvalidEmail';
      case AuthError.userAlreadyInFamily:
        return 'errorAuthUserAlreadyInFamily';
      case AuthError.emailNotVerified:
        return 'errorAuthEmailNotVerified';

      // Security Errors
      case AuthError.sessionExpired:
        return 'errorAuthSessionExpired';
      case AuthError.multipleSessionsDetected:
        return 'errorAuthMultipleSessions';
      case AuthError.suspiciousActivity:
        return 'errorAuthSuspiciousActivity';
      case AuthError.tooManyAttempts:
        return 'errorAuthTooManyAttempts';
      case AuthError.ipBlocked:
        return 'errorAuthIpBlocked';
      case AuthError.deviceNotRecognized:
        return 'errorAuthDeviceNotRecognized';
      case AuthError.securityValidationFailed:
        return 'errorAuthSecurityValidationFailed';
      case AuthError.crossUserTokenAttempt:
        return 'errorAuthCrossUserTokenAttempt';
      case AuthError.pkceVerificationFailed:
        return 'errorAuthPkceVerificationFailed';
      case AuthError.tokenMissing:
        return 'errorAuthTokenMissing';

      // Permission Errors
      case AuthError.insufficientPermissions:
        return 'errorAuthInsufficientPermissions';
      case AuthError.accessDenied:
        return 'errorAuthAccessDenied';
      case AuthError.resourceNotFound:
        return 'errorAuthResourceNotFound';

      // Biometric Errors
      case AuthError.biometricNotAvailable:
        return 'errorAuthBiometricNotAvailable';
      case AuthError.biometricNotEnabled:
        return 'errorAuthBiometricNotEnabled';
      case AuthError.biometricNotEnrolled:
        return 'errorAuthBiometricNotEnrolled';
      case AuthError.biometricLockout:
        return 'errorAuthBiometricLockout';
      case AuthError.biometricAuthFailed:
        return 'errorAuthBiometricAuthFailed';

      // Storage Errors
      case AuthError.storageError:
        return 'errorAuthStorageError';
      case AuthError.secureStorageUnavailable:
        return 'errorAuthSecureStorageUnavailable';
      case AuthError.encryptionError:
        return 'errorAuthEncryptionError';
      case AuthError.decryptionError:
        return 'errorAuthDecryptionError';
      case AuthError.tokenStorageError:
        return 'errorAuthTokenStorageError';
      case AuthError.userDataStorageError:
        return 'errorAuthUserDataStorageError';

      // Network Errors
      case AuthError.networkError:
        return 'errorAuthNetworkError';
      case AuthError.serverError:
        return 'errorAuthServerError';
      case AuthError.timeout:
        return 'errorAuthTimeout';
      case AuthError.connectionLost:
        return 'errorAuthConnectionLost';
      case AuthError.apiError:
        return 'errorAuthApiError';

      // Generic Errors
      case AuthError.invalidRequest:
        return 'errorAuthInvalidRequest';
      case AuthError.configurationError:
        return 'errorAuthConfigurationError';
      case AuthError.operationCancelled:
        return 'errorAuthOperationCancelled';
      case AuthError.unknownError:
        return 'errorAuthUnknown';
    }
  }
}