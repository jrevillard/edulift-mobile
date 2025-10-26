// =============================================================================
// API EXCEPTION - TYPED ERROR FOR BACKEND RESPONSES
// =============================================================================

/// Custom exception for API errors extracted from backend response wrappers
///
/// This exception is thrown when the backend returns errors or when HTTP errors occur.
/// It provides typed error information for ErrorHandlerService to classify properly.
class ApiException implements Exception {
  /// The human-readable error message from the backend
  final String message;

  /// HTTP status code (if available)
  final int? statusCode;

  /// Backend error code (if provided)
  final String? errorCode;

  /// Additional error details from the backend
  final Map<String, dynamic>? details;

  /// Original API endpoint that failed
  final String? endpoint;

  /// HTTP method used (GET, POST, etc.)
  final String? method;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.details,
    this.endpoint,
    this.method,
  });

  /// Factory constructor for backend wrapper errors
  /// { success: false, error: "message", code?: "CODE" }
  factory ApiException.fromBackendWrapper(
    Map<String, dynamic> responseData, {
    int? statusCode,
    String? endpoint,
    String? method,
  }) {
    final message = responseData['error']?.toString() ?? 'Unknown API error';
    final errorCode = responseData['code']?.toString();

    return ApiException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      details: responseData,
      endpoint: endpoint,
      method: method,
    );
  }

  /// Factory constructor for HTTP errors with body
  factory ApiException.fromHttpError(
    int statusCode,
    String message, {
    String? endpoint,
    String? method,
    Map<String, dynamic>? details,
  }) {
    return ApiException(
      message: message,
      statusCode: statusCode,
      endpoint: endpoint,
      method: method,
      details: details,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('ApiException: $message');

    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }

    if (errorCode != null) {
      buffer.write(' (Code: $errorCode)');
    }

    if (endpoint != null) {
      buffer.write(' [${method ?? 'UNKNOWN'} $endpoint]');
    }

    return buffer.toString();
  }

  /// Check if this is a validation error (400, 422 or validation-related code)
  bool get isValidationError {
    return statusCode == 400 ||
        statusCode == 422 ||
        errorCode?.toUpperCase().contains('VALIDATION') == true ||
        errorCode?.toUpperCase().contains('INVALID') == true;
  }

  /// Check if this is an authentication error (401)
  bool get isAuthenticationError {
    return statusCode == 401 ||
        errorCode?.toUpperCase().contains('UNAUTHORIZED') == true ||
        errorCode?.toUpperCase().contains('AUTH') == true;
  }

  /// Check if this is an authorization error (403)
  bool get isAuthorizationError {
    return statusCode == 403 ||
        errorCode?.toUpperCase().contains('FORBIDDEN') == true ||
        errorCode?.toUpperCase().contains('PERMISSION') == true;
  }

  /// Check if this error is retryable (5xx errors)
  bool get isRetryable {
    return statusCode != null && statusCode! >= 500;
  }

  /// Check if this requires user action (4xx errors)
  bool get requiresUserAction {
    return statusCode != null && statusCode! >= 400 && statusCode! < 500;
  }
}
