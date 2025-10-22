import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:dio/dio.dart';

import '../utils/app_logger.dart';
import '../errors/failures.dart';
import '../errors/exceptions.dart';
import '../errors/api_exception.dart';

/// Error categories for classification and user messaging
enum ErrorCategory {
  network, // Network connectivity, timeouts
  server, // Backend API errors (4xx, 5xx)
  validation, // Input validation, business rules
  authentication, // Auth failures, token issues
  authorization, // Permission denied, role issues
  storage, // Local storage, cache failures
  sync, // Data synchronization conflicts
  biometric, // Fingerprint, face recognition
  offline, // Offline mode limitations
  unexpected, // Unexpected runtime errors
  permission, // System permissions (camera, etc.)
  conflict, // Data conflicts, race conditions
}

/// Error severity levels for prioritization
enum ErrorSeverity {
  fatal, // App-breaking errors requiring restart
  critical, // Feature-breaking errors requiring intervention
  major, // Functionality impaired but recoverable
  minor, // Minor issues with fallback available
  warning, // Potential issues, non-blocking
  info, // Informational messages
}

/// Context information for error occurrence
class ErrorContext extends Equatable {
  final String operation; // What was being attempted
  final String feature; // Which feature (family, auth, etc.)
  final String? userId; // User context (if available)
  final Map<String, dynamic> metadata; // Additional context
  final DateTime timestamp;
  final String sessionId;

  const ErrorContext({
    required this.operation,
    required this.feature,
    this.userId,
    required this.metadata,
    required this.timestamp,
    required this.sessionId,
  });

  /// Factory constructor for family operations
  factory ErrorContext.familyOperation(
    String operation, {
    Map<String, dynamic>? metadata,
    String? userId,
  }) {
    return ErrorContext(
      operation: operation,
      feature: 'FAMILY',
      userId: userId,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
      sessionId: _generateSessionId(),
    );
  }

  /// Factory constructor for authentication operations
  factory ErrorContext.authOperation(
    String operation, {
    Map<String, dynamic>? metadata,
    String? userId,
  }) {
    return ErrorContext(
      operation: operation,
      feature: 'AUTH',
      userId: userId,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
      sessionId: _generateSessionId(),
    );
  }

  /// Factory constructor for schedule operations
  factory ErrorContext.scheduleOperation(
    String operation, {
    Map<String, dynamic>? metadata,
    String? userId,
  }) {
    return ErrorContext(
      operation: operation,
      feature: 'SCHEDULE',
      userId: userId,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
      sessionId: _generateSessionId(),
    );
  }

  /// Factory constructor for children operations
  factory ErrorContext.childrenOperation(
    String operation, {
    Map<String, dynamic>? metadata,
    String? userId,
  }) {
    return ErrorContext(
      operation: operation,
      feature: 'CHILDREN',
      userId: userId,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
      sessionId: _generateSessionId(),
    );
  }

  /// Factory constructor for vehicle operations
  factory ErrorContext.vehicleOperation(
    String operation, {
    Map<String, dynamic>? metadata,
    String? userId,
  }) {
    return ErrorContext(
      operation: operation,
      feature: 'VEHICLE',
      userId: userId,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
      sessionId: _generateSessionId(),
    );
  }

  /// Factory constructor for invitation operations (family and group)
  factory ErrorContext.invitationOperation(
    String operation, {
    Map<String, dynamic>? metadata,
    String? userId,
  }) {
    return ErrorContext(
      operation: operation,
      feature: 'INVITATION',
      userId: userId,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
      sessionId: _generateSessionId(),
    );
  }

  /// Factory constructor for generic operations - ADDED for mixin compatibility
  factory ErrorContext.genericOperation(
    String operation, {
    Map<String, dynamic>? metadata,
    String? userId,
  }) {
    return ErrorContext(
      operation: operation,
      feature: 'GENERAL',
      userId: userId,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
      sessionId: _generateSessionId(),
    );
  }

  static String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Create a copy with updated properties - ADDED for mixin compatibility
  ErrorContext copyWith({
    String? operation,
    String? feature,
    String? userId,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    String? sessionId,
  }) {
    return ErrorContext(
      operation: operation ?? this.operation,
      feature: feature ?? this.feature,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  List<Object?> get props => [
    operation,
    feature,
    userId,
    metadata,
    timestamp,
    sessionId,
  ];

  @override
  String toString() =>
      'ErrorContext(feature: $feature, operation: $operation, timestamp: $timestamp)';
}

/// Classification result for errors
class ErrorClassification extends Equatable {
  final ErrorCategory category;
  final ErrorSeverity severity;
  final bool isRetryable;
  final bool requiresUserAction;
  final Map<String, dynamic> analysisData;

  const ErrorClassification({
    required this.category,
    required this.severity,
    required this.isRetryable,
    required this.requiresUserAction,
    required this.analysisData,
  });

  @override
  List<Object?> get props => [
    category,
    severity,
    isRetryable,
    requiresUserAction,
    analysisData,
  ];
}

/// User-friendly error message
class UserErrorMessage extends Equatable {
  final String titleKey;
  final String messageKey;
  final List<String> actionableSteps;
  final bool canRetry;
  final ErrorSeverity severity;
  final Map<String, dynamic>? debugInfo;

  const UserErrorMessage({
    required this.titleKey,
    required this.messageKey,
    this.actionableSteps = const [],
    this.canRetry = false,
    this.severity = ErrorSeverity.major,
    this.debugInfo,
  });

  @override
  List<Object?> get props => [
    titleKey,
    messageKey,
    actionableSteps,
    canRetry,
    severity,
    debugInfo,
  ];
}

/// Result of error handling process
class ErrorHandlingResult extends Equatable {
  final ErrorClassification classification;
  final UserErrorMessage userMessage;
  final bool wasLogged;
  final bool wasReported;

  const ErrorHandlingResult({
    required this.classification,
    required this.userMessage,
    required this.wasLogged,
    required this.wasReported,
  });

  @override
  List<Object?> get props => [
    classification,
    userMessage,
    wasLogged,
    wasReported,
  ];
}

/// Centralized error handling service

class ErrorHandlerService {
  final UserMessageService _messageService;

  ErrorHandlerService(this._messageService);

  /// Main error handling method
  Future<ErrorHandlingResult> handleError(
    dynamic error,
    ErrorContext context, {
    StackTrace? stackTrace,
  }) async {
    try {
      // 1. Classify the error
      final classification = classifyError(error);

      // 2. Log the error with full context
      logError(classification, context, error, stackTrace);

      // 3. Generate user-friendly message
      final userMessage = _messageService.generateMessage(
        classification,
        context,
      );

      // 4. Report if necessary (critical errors) - pass stackTrace for full context
      final wasReported = await _reportErrorIfNecessary(
        classification,
        context,
        error,
        stackTrace: stackTrace,
      );

      return ErrorHandlingResult(
        classification: classification,
        userMessage: userMessage,
        wasLogged: true,
        wasReported: wasReported,
      );
    } catch (e, st) {
      // Fallback error handling
      AppLogger.fatal('Error in ErrorHandlerService.handleError', e, st);

      return const ErrorHandlingResult(
        classification: ErrorClassification(
          category: ErrorCategory.unexpected,
          severity: ErrorSeverity.critical,
          isRetryable: false,
          requiresUserAction: true,
          analysisData: {},
        ),
        userMessage: UserErrorMessage(
          titleKey: 'errorSystemTitle',
          messageKey: 'errorSystemMessage',
        ),
        wasLogged: true,
        wasReported: false,
      );
    }
  }

  /// Classify error into category and severity
  ErrorClassification classifyError(dynamic error) {
    // Handle ApiException from backend responses
    if (error is ApiException) {
      return ErrorClassification(
        category: error.isValidationError
            ? ErrorCategory.validation
            : error.isAuthenticationError
            ? ErrorCategory.authentication
            : error.isAuthorizationError
            ? ErrorCategory.authorization
            : error.isRetryable
            ? ErrorCategory.server
            : ErrorCategory.server,
        severity: error.requiresUserAction
            ? ErrorSeverity.major
            : error.isRetryable
            ? ErrorSeverity.critical
            : ErrorSeverity.major,
        isRetryable: error.isRetryable,
        requiresUserAction: error.requiresUserAction,
        analysisData: {
          'type': 'api_exception',
          'status_code': error.statusCode,
          'error_code': error.errorCode,
          'endpoint': error.endpoint,
          'method': error.method,
          'original_message': error.message,
        },
      );
    }

    if (error is NetworkFailure || error is NetworkException) {
      return const ErrorClassification(
        category: ErrorCategory.network,
        severity: ErrorSeverity.major,
        isRetryable: true,
        requiresUserAction: false,
        analysisData: {'type': 'network'},
      );
    }

    if (error is ServerFailure || error is ServerException) {
      final statusCode = error is ServerFailure
          ? error.statusCode
          : error is ServerException
          ? error.statusCode
          : null;

      // CRITICAL FIX: Capture original message for ServerFailure like we do for ValidationFailure
      final originalMessage = error is ServerFailure
          ? error.message
          : error is ServerException
          ? error.toString()
          : null;

      // CRITICAL FIX: Extract user-friendly message from complex nested error strings
      String? extractedMessage;
      if (originalMessage != null) {
        extractedMessage = _extractUserFriendlyMessage(originalMessage);
      }

      final severity = (statusCode != null && statusCode >= 500)
          ? ErrorSeverity.critical
          : ErrorSeverity.major;

      return ErrorClassification(
        category: ErrorCategory.server,
        severity: severity,
        isRetryable: statusCode != null && statusCode >= 500,
        requiresUserAction: statusCode != null && statusCode < 500,
        analysisData: {
          'type': 'server',
          'status_code': statusCode,
          // CRITICAL FIX: Add both original message and extracted user-friendly message
          if (originalMessage != null) 'original_message': originalMessage,
          if (extractedMessage != null) 'extracted_message': extractedMessage,
        },
      );
    }

    if (error is ValidationFailure || error is ValidationException) {
      // Capture original message for validation errors
      final originalMessage = error is ValidationFailure
          ? error.message
          : error is ValidationException
          ? error.toString()
          : null;

      return ErrorClassification(
        category: ErrorCategory.validation,
        severity: ErrorSeverity.minor,
        isRetryable: true,
        requiresUserAction: true,
        analysisData: {
          'type': 'validation',
          if (originalMessage != null) 'original_message': originalMessage,
        },
      );
    }

    if (error is AuthFailure ||
        error is AuthenticationException ||
        error is AuthorizationException) {
      final isAuth = error is AuthFailure || error is AuthenticationException;
      return ErrorClassification(
        category: isAuth
            ? ErrorCategory.authentication
            : ErrorCategory.authorization,
        severity: ErrorSeverity.major,
        isRetryable: isAuth,
        requiresUserAction: true,
        analysisData: {'type': isAuth ? 'authentication' : 'authorization'},
      );
    }

    if (error is StorageFailure ||
        error is StorageException ||
        error is CacheFailure ||
        error is CacheException) {
      return const ErrorClassification(
        category: ErrorCategory.storage,
        severity: ErrorSeverity.major,
        isRetryable: true,
        requiresUserAction: false,
        analysisData: {'type': 'storage'},
      );
    }

    if (error is SyncException) {
      return const ErrorClassification(
        category: ErrorCategory.sync,
        severity: ErrorSeverity.major,
        isRetryable: true,
        requiresUserAction: false,
        analysisData: {'type': 'sync'},
      );
    }

    if (error is ConflictFailure) {
      return const ErrorClassification(
        category: ErrorCategory.conflict,
        severity: ErrorSeverity.major,
        isRetryable: true,
        requiresUserAction: true,
        analysisData: {'type': 'conflict'},
      );
    }

    if (error is OfflineFailure) {
      return const ErrorClassification(
        category: ErrorCategory.offline,
        severity: ErrorSeverity.minor,
        isRetryable: true,
        requiresUserAction: false,
        analysisData: {'type': 'offline'},
      );
    }

    if (error is ApiFailure) {
      return ErrorClassification(
        category: _mapApiFailureCategory(error),
        severity: _mapApiFailureSeverity(error),
        isRetryable: error.isRetryable,
        requiresUserAction: !error.isRetryable,
        analysisData: {
          'type': 'api',
          'status_code': error.statusCode,
          'url': error.requestUrl,
          'method': error.requestMethod,
          // CRITICAL: Capture original API error message
          if (error.message != null) 'original_message': error.message!,
        },
      );
    }

    // Handle DioException (Dio HTTP client errors)
    if (error is DioException) {
      final statusCode = error.response?.statusCode;

      // DEBUG: Let's see what type response.data actually is
      if (kDebugMode) {
        AppLogger.debug(
          '🔍 DioException response.data type: ${error.response?.data.runtimeType}',
        );
        AppLogger.debug(
          '🔍 DioException response.data content: ${error.response?.data}',
        );
      }

      // Extract error message from response data if available
      String? originalMessage;
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        // Case 1: The data is already a parsed map
        originalMessage = responseData['error'] as String?;
        if (kDebugMode) {
          AppLogger.debug(
            '🔍 Extracted originalMessage from Map: $originalMessage',
          );
        }
      } else if (responseData is String && responseData.isNotEmpty) {
        // Case 2: The data is a raw JSON string
        try {
          final decodedData = jsonDecode(responseData) as Map<String, dynamic>;
          originalMessage = decodedData['error'] as String?;
          if (kDebugMode) {
            AppLogger.debug(
              '🔍 Extracted originalMessage from JSON String: $originalMessage',
            );
          }
        } catch (e) {
          // The string was not valid JSON, or didn't match the expected structure
          if (kDebugMode) {
            AppLogger.debug(
              '🔍 Failed to parse error response body as JSON: $e',
            );
          }
        }
      }

      // Classify based on status code
      if (statusCode == 422) {
        return ErrorClassification(
          category: ErrorCategory.validation,
          severity: ErrorSeverity.minor,
          isRetryable: true,
          requiresUserAction: true,
          analysisData: {
            'type': 'dio_validation',
            'status_code': statusCode,
            'url': error.requestOptions.uri.toString(),
            'method': error.requestOptions.method,
            if (originalMessage != null) 'original_message': originalMessage,
          },
        );
      } else if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        return ErrorClassification(
          category: statusCode == 401
              ? ErrorCategory.authentication
              : statusCode == 403
              ? ErrorCategory.authorization
              : ErrorCategory.server,
          severity: ErrorSeverity.major,
          isRetryable: false,
          requiresUserAction: true,
          analysisData: {
            'type': 'dio_client_error',
            'status_code': statusCode,
            'url': error.requestOptions.uri.toString(),
            'method': error.requestOptions.method,
            if (originalMessage != null) 'original_message': originalMessage,
          },
        );
      } else if (statusCode != null && statusCode >= 500) {
        return ErrorClassification(
          category: ErrorCategory.server,
          severity: ErrorSeverity.critical,
          isRetryable: true,
          requiresUserAction: false,
          analysisData: {
            'type': 'dio_server_error',
            'status_code': statusCode,
            'url': error.requestOptions.uri.toString(),
            'method': error.requestOptions.method,
            if (originalMessage != null) 'original_message': originalMessage,
          },
        );
      } else {
        // Network-related DioException (timeout, no connection, etc.)
        return ErrorClassification(
          category: ErrorCategory.network,
          severity: ErrorSeverity.major,
          isRetryable: true,
          requiresUserAction: false,
          analysisData: {
            'type': 'dio_network_error',
            'dio_type': error.type.toString(),
            'url': error.requestOptions.uri.toString(),
            'method': error.requestOptions.method,
          },
        );
      }
    }

    // Unexpected errors
    return const ErrorClassification(
      category: ErrorCategory.unexpected,
      severity: ErrorSeverity.critical,
      isRetryable: false,
      requiresUserAction: true,
      analysisData: {'type': 'unexpected'},
    );
  }

  /// Log error with full context
  void logError(
    ErrorClassification classification,
    ErrorContext context,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    final contextInfo = '${context.feature}/${context.operation}';
    final errorMsg = _extractErrorMessage(error);
    final logMessage =
        '${classification.category.name.toUpperCase()} error in $contextInfo: $errorMsg';

    // Log metadata for debugging
    final metadata = {
      'error_category': classification.category.name,
      'error_severity': classification.severity.name,
      'is_retryable': classification.isRetryable,
      'context': {
        'feature': context.feature,
        'operation': context.operation,
        'user_id': context.userId,
        'session_id': context.sessionId,
        'timestamp': context.timestamp.toIso8601String(),
        'metadata': context.metadata,
      },
      'classification_data': classification.analysisData,
    };

    switch (classification.severity) {
      case ErrorSeverity.fatal:
        AppLogger.fatal(logMessage, error, stackTrace);
        AppLogger.debug('Error metadata: $metadata');
        break;
      case ErrorSeverity.critical:
        AppLogger.error(logMessage, error, stackTrace);
        AppLogger.debug('Error metadata: $metadata');
        break;
      case ErrorSeverity.major:
        AppLogger.error(logMessage, error, stackTrace);
        AppLogger.debug('Error metadata: $metadata');
        break;
      case ErrorSeverity.minor:
        AppLogger.warning(logMessage, error, stackTrace);
        AppLogger.debug('Error metadata: $metadata');
        break;
      case ErrorSeverity.warning:
        AppLogger.warning(logMessage, error, stackTrace);
        break;
      case ErrorSeverity.info:
        AppLogger.info(logMessage, error, stackTrace);
        break;
    }
  }

  ErrorCategory _mapApiFailureCategory(ApiFailure failure) {
    // Check status code first for standard HTTP error classification
    if (failure.statusCode != null) {
      switch (failure.statusCode!) {
        case 400:
          return ErrorCategory.validation; // FIX: Add explicit 400 handling
        case 401:
          return ErrorCategory.authentication;
        case 403:
          return ErrorCategory.authorization;
        case 422:
          return ErrorCategory.validation;
      }
    }

    final details = failure.details;
    if (details != null && details['type'] != null) {
      switch (details['type']) {
        case 'timeout':
        case 'no_connection':
        case 'network_error':
          return ErrorCategory.network;
        case 'unauthorized':
          return ErrorCategory.authentication;
        case 'validation_error':
          return ErrorCategory.validation;
        case 'server_error':
          return ErrorCategory.server;
        case 'cache_error':
          return ErrorCategory.storage;
        default:
          return ErrorCategory.server;
      }
    }
    return ErrorCategory.server;
  }

  ErrorSeverity _mapApiFailureSeverity(ApiFailure failure) {
    if (failure.statusCode != null) {
      if (failure.statusCode! >= 500) return ErrorSeverity.critical;
      if (failure.statusCode! == 401 || failure.statusCode! == 403) {
        return ErrorSeverity.major;
      }
      if (failure.statusCode! == 400) {
        return ErrorSeverity.minor; // FIX: 400 should be minor
      }
      if (failure.statusCode! == 422) return ErrorSeverity.minor;
      return ErrorSeverity.major;
    }
    return ErrorSeverity.major;
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString();
    }
    if (error is Failure) {
      return error.message ?? error.toString();
    }
    return error?.toString() ?? 'Unknown error';
  }

  /// Extract user-friendly message from complex nested error strings
  /// Example: "ApiException: ServerException(500): Failed to join family: ApiException: This invitation was sent to a different email address (Status: 400)"
  /// Should extract: "This invitation was sent to a different email address"
  String? _extractUserFriendlyMessage(String complexErrorMessage) {
    if (complexErrorMessage.trim().isEmpty) {
      return null;
    }

    // Pattern 1: Look for the actual user message at the end before "(Status: xxx)"
    final statusPattern = RegExp(r':?\s*([^:]+?)\s*\(Status:\s*\d+\)\s*$');
    final statusMatch = statusPattern.firstMatch(complexErrorMessage);
    if (statusMatch != null) {
      final extracted = statusMatch.group(1)?.trim();
      if (extracted != null && _isCleanUserMessage(extracted)) {
        return extracted;
      }
    }

    // Pattern 2: Look for messages after the last ": " that don't contain technical terms
    final parts = complexErrorMessage.split(': ');
    if (parts.length > 1) {
      // Start from the end and work backwards to find the most user-friendly message
      for (var i = parts.length - 1; i >= 0; i--) {
        var candidate = parts[i].trim();

        // Remove any trailing status codes or technical suffixes
        candidate = candidate.replaceAll(
          RegExp(r'\s*\(Status:\s*\d+\)\s*$'),
          '',
        );
        candidate = candidate.replaceAll(RegExp(r'\s*\(Code:\s*\w+\)\s*$'), '');

        if (_isCleanUserMessage(candidate)) {
          return candidate;
        }
      }
    }

    return null;
  }

  /// Check if a message is clean and user-friendly (no technical jargon)
  bool _isCleanUserMessage(String message) {
    if (message.trim().isEmpty || message.length < 5 || message.length > 200) {
      return false;
    }

    // Must start with a capital letter and be a proper sentence (check early)
    if (!RegExp(r'^[A-Z]').hasMatch(message)) {
      return false;
    }

    final lowercaseMessage = message.toLowerCase();

    // First, check for definitely technical terms (more specific)
    final strongTechnicalTerms = [
      'apiexception',
      'serverexception',
      'stacktrace',
      'error:',
      'null pointer',
      'segmentation fault',
      'buffer overflow',
      'http status',
      'dio error',
      'json parse',
      'serialization',
      'deserialization',
      'authentication token',
      'authorization header',
      'middleware',
      'interceptor',
      'gateway timeout',
      'internal server error',
      'bad gateway',
      'service unavailable',
      'database connection',
      'sql',
      'orm',
      'thread',
      'mutex',
      'semaphore',
      'deadlock',
      'race condition',
    ];

    for (final term in strongTechnicalTerms) {
      if (lowercaseMessage.contains(term)) {
        return false;
      }
    }

    // Check for contextual technical patterns (more nuanced)
    if (_hasContextualTechnicalPattern(lowercaseMessage)) {
      return false;
    }

    // Check for user-friendly patterns that should be allowed
    if (_hasUserFriendlyPattern(lowercaseMessage)) {
      return true; // Override other checks for clearly user-friendly messages
    }

    // Check for remaining broad technical terms with context
    final contextualTechnicalTerms = [
      'exception',
      'stack',
      'trace',
      'undefined',
      'debug',
      'fatal',
      'abort',
      'crash',
      'buffer',
      'dio',
      'http',
      'request',
      'response',
      'status:',
      'code:',
    ];

    for (final term in contextualTechnicalTerms) {
      if (lowercaseMessage.contains(term)) {
        return false;
      }
    }

    return true;
  }

  /// Check for contextual technical patterns that indicate technical jargon
  bool _hasContextualTechnicalPattern(String lowercaseMessage) {
    // Technical "failed to" patterns (more specific than user actions)
    if (lowercaseMessage.contains('failed to') && (
        lowercaseMessage.contains('failed to connect to server') ||
        lowercaseMessage.contains('failed to authenticate user') ||
        lowercaseMessage.contains('failed to initialize') ||
        lowercaseMessage.contains('failed to parse') ||
        lowercaseMessage.contains('failed to serialize') ||
        lowercaseMessage.contains('failed to deserialize') ||
        lowercaseMessage.contains('failed to establish') ||
        lowercaseMessage.contains('failed to resolve') ||
        lowercaseMessage.contains('failed to bind') ||
        lowercaseMessage.contains('failed to allocate')
    )) {
      return true;
    }

    // Technical timeout patterns
    if (lowercaseMessage.contains('timeout') && (
        lowercaseMessage.contains('socket timeout') ||
        lowercaseMessage.contains('read timeout') ||
        lowercaseMessage.contains('write timeout') ||
        lowercaseMessage.contains('gateway timeout') ||
        lowercaseMessage.contains('request timeout occurred') ||
        lowercaseMessage.contains('operation timed out')
    )) {
      return true;
    }

    // Technical error patterns
    if (lowercaseMessage.contains('null') && (
        lowercaseMessage.contains('null reference') ||
        lowercaseMessage.contains('null pointer') ||
        lowercaseMessage.contains('null value') ||
        lowercaseMessage.contains('null object')
    )) {
      return true;
    }

    return false;
  }

  /// Check for user-friendly patterns that should be allowed
  bool _hasUserFriendlyPattern(String lowercaseMessage) {
    // User action patterns that should be allowed
    final userActionPatterns = [
      'failed to join',
      'failed to create',
      'failed to send',
      'failed to save',
      'failed to load',
      'failed to update',
      'failed to delete',
      'failed to add',
      'failed to remove',
      'failed to invite',
      'failed to accept',
      'unable to join',
      'unable to create',
      'unable to send',
      'could not join',
      'could not create',
      'could not send',
      'request failed',
      'operation failed',
      'action failed',
    ];

    for (final pattern in userActionPatterns) {
      if (lowercaseMessage.contains(pattern)) {
        return true;
      }
    }

    // Simple user-friendly timeout messages (but not if they contain technical prefixes)
    if (lowercaseMessage.contains('timeout') &&
        !lowercaseMessage.contains('dioexception') &&
        !lowercaseMessage.contains('exception') &&
        (lowercaseMessage.contains('connection timeout') ||
         lowercaseMessage.contains('request timeout') ||
         lowercaseMessage.contains('operation timeout') ||
         lowercaseMessage.length < 50 // Short timeout messages are usually user-friendly
        )) {
      return true;
    }

    // Common user-friendly phrases
    final userFriendlyPhrases = [
      'please try again',
      'check your connection',
      'something went wrong',
      'temporarily unavailable',
      'service is busy',
      'too many requests',
      'invalid email',
      'invalid password',
      'email already exists',
      'account not found',
      'permission denied',
      'access denied',
      'not authorized',
      'session expired',
      'login required',
    ];

    for (final phrase in userFriendlyPhrases) {
      if (lowercaseMessage.contains(phrase)) {
        return true;
      }
    }

    return false;
  }

  /// Get user-friendly error message (simplified interface for backward compatibility)
  /// This method provides a quick way to get an error message without full error handling
  String getErrorMessage(dynamic error) {
    try {
      // Classify the error
      final classification = classifyError(error);
      
      // Check if we have an extracted user-friendly message
      final extractedMessage = classification.analysisData['extracted_message'] as String?;
      if (extractedMessage != null && extractedMessage.isNotEmpty) {
        return extractedMessage;
      }
      
      // Check if we have an original message
      final originalMessage = classification.analysisData['original_message'] as String?;
      if (originalMessage != null && originalMessage.isNotEmpty) {
        // Try to extract user-friendly message from original
        final friendlyMessage = _extractUserFriendlyMessage(originalMessage);
        if (friendlyMessage != null && friendlyMessage.isNotEmpty) {
          return friendlyMessage;
        }
      }
      
      // Fall back to raw error message extraction
      return _extractErrorMessage(error);
    } catch (e) {
      // If anything goes wrong, fall back to basic error extraction
      return _extractErrorMessage(error);
    }
  }

  Future<bool> _reportErrorIfNecessary(
    ErrorClassification classification,
    ErrorContext context,
    dynamic error, {
    StackTrace? stackTrace,
  }) async {
    // Report critical and fatal errors
    if (classification.severity == ErrorSeverity.fatal ||
        classification.severity == ErrorSeverity.critical) {
      try {
        // Only report to Firebase in release mode for production monitoring
        if (kReleaseMode) {
          // Set user context for better error tracking
          if (context.userId != null) {
            await FirebaseCrashlytics.instance.setUserIdentifier(
              context.userId!,
            );
          }

          // Set custom keys for better error classification
          await FirebaseCrashlytics.instance.setCustomKey(
            'error_category',
            classification.category.name,
          );
          await FirebaseCrashlytics.instance.setCustomKey(
            'error_severity',
            classification.severity.name,
          );
          await FirebaseCrashlytics.instance.setCustomKey(
            'feature',
            context.feature,
          );
          await FirebaseCrashlytics.instance.setCustomKey(
            'operation',
            context.operation,
          );
          await FirebaseCrashlytics.instance.setCustomKey(
            'session_id',
            context.sessionId,
          );
          await FirebaseCrashlytics.instance.setCustomKey(
            'is_retryable',
            classification.isRetryable,
          );

          // Add metadata as custom keys
          for (final entry in context.metadata.entries) {
            await FirebaseCrashlytics.instance.setCustomKey(
              'ctx_${entry.key}',
              entry.value.toString(),
            );
          }

          // Record the error with proper context
          await FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace,
            fatal: classification.severity == ErrorSeverity.fatal,
            information: [
              'Error occurred in ${context.feature}/${context.operation}',
              'Category: ${classification.category.name}',
              'Severity: ${classification.severity.name}',
              'Retryable: ${classification.isRetryable}',
              'User Action Required: ${classification.requiresUserAction}',
              'Session ID: ${context.sessionId}',
              'Metadata: ${context.metadata}',
            ],
          );

          AppLogger.info(
            '✅ Error reported to Firebase: ${classification.category}/${classification.severity} in ${context.feature}/${context.operation}',
          );
        } else {
          // Debug mode: only log locally
          AppLogger.info(
            '🔧 Debug mode: Error logged locally (not reported to Firebase): ${classification.category}/${classification.severity} in ${context.feature}/${context.operation}',
          );
        }

        return kReleaseMode; // Only report as "reported" if actually sent to Firebase
      } catch (e) {
        AppLogger.warning('Failed to report error to Firebase Crashlytics', e);
        return false;
      }
    }
    return false;
  }

  /// Check if error indicates name is required for new users
  bool isNameRequiredError(dynamic error) {
    // Only check ValidationFailure types
    if (error is ValidationFailure) {
      // Check the message content first
      final message = error.message?.toLowerCase() ?? '';
      if (message.contains('name is required for new users') ||
          message.contains('name required')) {
        return true;
      }

      // Check the original message stored in details from ErrorHandlerService
      if (error.details != null) {
        final originalMessage = error.details!['original_message'] as String?;
        if (originalMessage != null) {
          final originalLowercase = originalMessage.toLowerCase();
          return originalLowercase.contains('name is required for new users') ||
                 originalLowercase.contains('name required');
        }
      }
    }

    return false;
  }

  // REMOVED: getErrorMessage method with extensive hardcoded fallback messages
  // All error messages are now handled through localization keys in UserMessageService

  /// Test helper method to access private _isCleanUserMessage for validation
  /// This should only be used in tests
  @visibleForTesting
  bool testIsCleanUserMessage(String message) {
    return _isCleanUserMessage(message);
  }

  /// Test helper method to access private _extractUserFriendlyMessage for validation
  /// This should only be used in tests
  @visibleForTesting
  String? testExtractUserFriendlyMessage(String message) {
    return _extractUserFriendlyMessage(message);
  }
}

/// Service for generating user-friendly error messages

class UserMessageService {

  static const Map<ErrorCategory, String> _titleKeys = {
    ErrorCategory.network: 'errorNetworkTitle',
    ErrorCategory.server: 'errorServerTitle',
    ErrorCategory.validation: 'errorValidationTitle',
    ErrorCategory.authentication: 'errorAuthTitle',
    ErrorCategory.authorization: 'errorAuthorizationTitle',
    ErrorCategory.storage: 'errorStorageTitle',
    ErrorCategory.sync: 'errorSyncTitle',
    ErrorCategory.offline: 'errorOfflineTitle',
    ErrorCategory.conflict: 'errorConflictTitle',
    ErrorCategory.unexpected: 'errorUnexpectedTitle',
    ErrorCategory.permission: 'errorPermissionTitle',
    ErrorCategory.biometric: 'errorBiometricTitle',
  };

  static const Map<ErrorCategory, String> _messageKeys = {
    ErrorCategory.network: 'errorNetworkMessage',
    ErrorCategory.server: 'errorServerMessage',
    ErrorCategory.validation: 'errorValidationMessage',
    ErrorCategory.authentication: 'errorAuthMessage',
    ErrorCategory.authorization: 'errorAuthorizationMessage',
    ErrorCategory.storage: 'errorStorageMessage',
    ErrorCategory.sync: 'errorSyncMessage',
    ErrorCategory.offline: 'errorOfflineMessage',
    ErrorCategory.conflict: 'errorConflictMessage',
    ErrorCategory.unexpected: 'errorUnexpectedMessage',
    ErrorCategory.permission: 'errorPermissionMessage',
    ErrorCategory.biometric: 'errorBiometricMessage',
  };

  UserErrorMessage generateMessage(
    ErrorClassification classification,
    ErrorContext context,
  ) {
    final titleKey = _titleKeys[classification.category] ??
                     _titleKeys[ErrorCategory.unexpected]!;
    final messageKey = _messageKeys[classification.category] ??
                       _messageKeys[ErrorCategory.unexpected]!;

    // Contextualize the message key based on operation
    final contextualMessageKey = _contextualizeMessageKey(
      messageKey,
      classification,
      context,
    );

    // Prepare debug info with extracted messages if available
    final debugInfo = <String, dynamic>{};
    if (_shouldIncludeDebugInfo()) {
      debugInfo.addAll({
        'category': classification.category.name,
        'context': '${context.feature}/${context.operation}',
        'timestamp': context.timestamp.toIso8601String(),
      });
    }

    // Add extracted message for raw_message key handling
    final extractedMessage = classification.analysisData['extracted_message'] as String?;
    if (extractedMessage != null) {
      debugInfo['raw_message'] = extractedMessage;
    }

    return UserErrorMessage(
      titleKey: titleKey,
      messageKey: contextualMessageKey,
      actionableSteps: _getActionableSteps(classification, context),
      canRetry: classification.isRetryable,
      severity: classification.severity,
      debugInfo: debugInfo.isNotEmpty ? debugInfo : null,
    );
  }

  // REMOVED: _getTitleForCategory method that returned hardcoded titles
  // All titles are now provided via localization keys in _titleKeys map

  String _contextualizeMessageKey(
    String baseMessageKey,
    ErrorClassification classification,
    ErrorContext context,
  ) {
    // Return context-specific message keys for certain operations
    switch (context.operation) {
      case 'create_family':
        if (classification.category == ErrorCategory.validation) {
          return 'errorFamilyCreateInvalidName';
        }
        if (classification.category == ErrorCategory.conflict) {
          return 'errorFamilyCreateNameExists';
        }
        break;
      case 'invite_member':
        if (classification.category == ErrorCategory.validation) {
          // CRITICAL: Check for extracted user-friendly message first
          final extractedMessage =
              classification.analysisData['extracted_message'] as String?;
          if (extractedMessage != null) {
            // Return a special key that the UI can use to display the raw message
            return 'errorRawMessage'; // UI will use debugInfo['raw_message']
          }
          return 'errorFamilyInviteInvalidEmail';
        }
        if (classification.category == ErrorCategory.authorization) {
          return 'errorFamilyInviteAdminRequired';
        }
        break;
      case 'process_invitation':
        if (classification.category == ErrorCategory.server) {
          // CRITICAL: Check for extracted user-friendly message first
          final extractedMessage =
              classification.analysisData['extracted_message'] as String?;
          if (extractedMessage != null) {
            return 'errorRawMessage'; // UI will use debugInfo['raw_message']
          }
          return 'errorInvitationProcessFailed';
        }
        if (classification.category == ErrorCategory.validation) {
          return 'errorInvitationInvalidCode';
        }
        if (classification.category == ErrorCategory.conflict) {
          return 'errorInvitationAlreadyMember';
        }
        break;
      case 'validateFamilyInvitation':
        if (classification.category == ErrorCategory.validation) {
          return 'errorInvitationFamilyInvalid';
        }
        if (classification.category == ErrorCategory.conflict) {
          return 'errorInvitationFamilyAlreadyMember';
        }
        break;
      case 'validateGroupInvitation':
        if (classification.category == ErrorCategory.validation) {
          return 'errorInvitationGroupInvalid';
        }
        if (classification.category == ErrorCategory.conflict) {
          return 'errorInvitationGroupAlreadyMember';
        }
        break;
      case 'add_child':
        if (classification.category == ErrorCategory.validation) {
          return 'errorChildAddInvalidInfo';
        }
        if (classification.category == ErrorCategory.authorization) {
          return 'errorChildAddAdminRequired';
        }
        break;
      case 'assign_vehicle':
        if (classification.category == ErrorCategory.validation) {
          return 'errorVehicleAssignInvalidSelection';
        }
        if (classification.category == ErrorCategory.conflict) {
          return 'errorVehicleAssignAlreadyAssigned';
        }
        break;
    }

    return baseMessageKey;
  }

  // REMOVED: _isUserFriendlyMessage method - no longer needed for localization key approach

  List<String> _getActionableSteps(
    ErrorClassification classification,
    ErrorContext context,
  ) {
    switch (classification.category) {
      case ErrorCategory.network:
        return [
          'actionCheckConnection',
          'actionTryAgain',
          'actionSwitchNetwork',
        ];
      case ErrorCategory.authentication:
        return [
          'actionSignOutSignIn',
          'actionCheckEmail',
        ];
      case ErrorCategory.validation:
        return [
          'actionReviewInfo',
          'actionFillRequired',
        ];
      case ErrorCategory.storage:
        return ['actionTryAgain', 'actionRestartApp'];
      default:
        return classification.isRetryable ? ['actionTryAgain'] : [];
    }
  }

  bool _shouldIncludeDebugInfo() {
    // Include debug info in debug mode or if explicitly enabled
    return kDebugMode;
  }

  // REMOVED: _getCurrentLocale method that referenced undefined _localizationService
  // Locale handling is now done at the UI layer
}
