// EduLift Mobile - Secure Error Handler
// SECURITY: Prevents information leakage through error messages

import 'dart:developer' as dev;

/// Secure error handler that sanitizes error messages and prevents data leakage
class SecureErrorHandler {
  static const bool _isDebugMode = false; // Set to false in production

  /// Sanitize error message for user display
  /// Removes sensitive information while preserving useful error context
  static String sanitizeErrorMessage(dynamic error) {
    if (error == null) return 'Une erreur est survenue';

    final errorString = error.toString().toLowerCase();

    // Remove sensitive patterns
    final sensitivePatterns = [
      'token',
      'password',
      'secret',
      'key',
      'auth',
      'credential',
      'session',
      'cookie',
      'bearer',
      'authorization',
      'api_key',
      'access_token',
      'refresh_token',
    ];

    var sanitized = error.toString();

    for (final pattern in sensitivePatterns) {
      if (errorString.contains(pattern)) {
        sanitized = 'Erreur d\'authentification';
        break;
      }
    }

    // Generic error messages for common cases
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Erreur de connexion. Vérifiez votre connexion internet.';
    }

    if (errorString.contains('timeout')) {
      return 'La requête a expiré. Veuillez réessayer.';
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Service non disponible. Veuillez réessayer plus tard.';
    }

    if (errorString.contains('500') || errorString.contains('server error')) {
      return 'Erreur serveur. Veuillez réessayer plus tard.';
    }

    // For debug mode, return more detailed errors
    if (_isDebugMode) {
      return sanitized;
    }

    // Default generic error for production
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  /// Log error securely (without sensitive information)
  static void logError(
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
  }) {
    final sanitizedError = sanitizeErrorMessage(error);
    final logMessage = context != null
        ? 'Security Error [$context]: $sanitizedError'
        : 'Security Error: $sanitizedError';

    // Use developer log in debug mode
    if (_isDebugMode) {
      dev.log(logMessage, error: error, stackTrace: stackTrace);
    } else {
      // In production, only log generic error markers
      dev.log('Error occurred', name: 'Security');
    }
  }

  /// Check if error contains sensitive information
  static bool containsSensitiveInfo(dynamic error) {
    if (error == null) return false;

    final errorString = error.toString().toLowerCase();
    final sensitivePatterns = [
      'token',
      'password',
      'secret',
      'key',
      'credential',
      'session',
      'bearer',
      'authorization',
    ];

    return sensitivePatterns.any((pattern) => errorString.contains(pattern));
  }

  /// Create a secure error response for API errors
  static Map<String, dynamic> createSecureErrorResponse(dynamic error) {
    return {
      'success': false,
      'message': sanitizeErrorMessage(error),
      'timestamp': DateTime.now().toIso8601String(),
      'code': 'GENERIC_ERROR',
    };
  }
}
