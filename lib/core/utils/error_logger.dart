/// Utility for comprehensive error logging throughout the application
/// Provides consistent error logging with context and stack traces

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'app_logger.dart';

class ErrorLogger {
  /// Log an error with full context and stack trace
  ///
  /// [context] - Description of where/what was happening when error occurred
  /// [error] - The actual error object
  /// [stackTrace] - Optional stack trace, will be captured if not provided
  /// [additionalData] - Any additional context data
  static void logError({
    required String context,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    // Capture current stack trace if not provided
    stackTrace ??= StackTrace.current;

    final buffer = StringBuffer();
    buffer.writeln('❌ ERROR CONTEXT: $context');
    buffer.writeln('🔍 ERROR TYPE: ${error.runtimeType}');
    buffer.writeln('📝 ERROR MESSAGE: $error');

    if (additionalData != null && additionalData.isNotEmpty) {
      buffer.writeln('📊 ADDITIONAL DATA:');
      additionalData.forEach((key, value) {
        buffer.writeln('   $key: $value');
      });
    }

    AppLogger.error(buffer.toString(), error, stackTrace);

    // In debug mode, also print to console for immediate visibility
    if (kDebugMode) {
      // ignore: avoid_print
      print('🚨 ERROR LOGGED: $context - $error');
    }
  }

  /// Log a caught error in a try-catch block
  ///
  /// [operation] - What operation was being performed
  /// [error] - The caught error
  /// [stackTrace] - Stack trace from catch block
  /// [category] - Category of operation (e.g., 'API', 'Storage', 'UI')
  static void logCaughtError({
    required String operation,
    required dynamic error,
    StackTrace? stackTrace,
    String category = 'General',
  }) {
    logError(
      context: '[$category] $operation',
      error: error,
      stackTrace: stackTrace,
      additionalData: {
        'category': category,
        'operation': operation,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log API-related errors with request context
  ///
  /// [endpoint] - API endpoint that failed
  /// [method] - HTTP method (GET, POST, etc.)
  /// [error] - The error that occurred
  /// [statusCode] - HTTP status code if available
  static void logApiError({
    required String endpoint,
    required String method,
    required dynamic error,
    int? statusCode,
    StackTrace? stackTrace,
  }) {
    logError(
      context: 'API Request Failed',
      error: error,
      stackTrace: stackTrace,
      additionalData: {
        'endpoint': endpoint,
        'method': method,
        'statusCode': statusCode,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log provider state errors
  ///
  /// [providerName] - Name of the provider
  /// [operation] - What the provider was doing
  /// [error] - The error that occurred
  static void logProviderError({
    required String providerName,
    required String operation,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? state,
  }) {
    final additionalData = <String, dynamic>{
      'provider': providerName,
      'operation': operation,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (state != null) {
      additionalData['state'] = state;
    }

    logError(
      context: 'Provider Error: $providerName',
      error: error,
      stackTrace: stackTrace,
      additionalData: additionalData,
    );
  }

  /// Wrap a Future with automatic error logging
  ///
  /// [future] - The future to wrap
  /// [context] - Context description for logging
  /// [onError] - Optional custom error handler
  static Future<T> wrapFuture<T>(
    Future<T> future, {
    required String context,
    void Function(dynamic error, StackTrace stackTrace)? onError,
  }) async {
    try {
      return await future;
    } catch (error, stackTrace) {
      logError(context: context, error: error, stackTrace: stackTrace);

      onError?.call(error, stackTrace);
      rethrow;
    }
  }

  /// Log zone errors (for comprehensive error catching)
  static void logZoneError(dynamic error, StackTrace stackTrace) {
    logError(
      context: 'Unhandled Zone Error',
      error: error,
      stackTrace: stackTrace,
      additionalData: {
        'source': 'Zone Error Handler',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}

/// ParseErrorLogger - Workaround for Retrofit generator bug
///
/// The retrofit_generator 9.7.0 generates code that calls logError with 3 arguments,
/// but retrofit 4.9+ expects 4 arguments. This class provides a compatible implementation.
///
/// This is a known issue in retrofit_generator and should be removed when fixed upstream.
class ParseErrorLogger {
  /// Log error from generated API clients (3-argument version)
  ///
  /// Note: Retrofit's abstract class expects 4 arguments (error, stack, options, response)
  /// but the generator produces code calling with only 3 (error, stack, options).
  void logError(Object error, StackTrace stackTrace, RequestOptions options) {
    ErrorLogger.logApiError(
      endpoint: options.path,
      method: options.method,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
