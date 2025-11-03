/// TLS/SSL Certificate Error Detection Utility
/// Detects and properly handles certificate validation errors to prevent ANR
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../utils/app_logger.dart';

class TLSErrorDetector {
  /// Detect if a DioException is caused by certificate validation issues
  static bool isCertificateError(DioException error) {
    if (error.type != DioExceptionType.connectionError) {
      return false;
    }

    final innerError = error.error;
    if (innerError is! HandshakeException) {
      return false;
    }

    // Check for specific certificate validation error indicators
    final message = innerError.message.toLowerCase();
    final osError = innerError.osError?.toString().toLowerCase() ?? '';

    return message.contains('certificate_verify_failed') ||
        message.contains('certificate verification failed') ||
        message.contains('certificate_expired') ||
        message.contains('certificate not yet valid') ||
        message.contains('self signed certificate') ||
        osError.contains('certificate_verify_failed') ||
        osError.contains('unable to get local issuer certificate');
  }

  /// Detect if an error should NOT be retried (certificate errors are deterministic)
  static bool isNonRetryableError(DioException error) {
    // Certificate errors should never be retried - they will always fail
    return isCertificateError(error);
  }

  /// Log certificate errors to Crashlytics for monitoring
  static Future<void> logCertificateError(
    DioException error,
    String operation,
  ) async {
    if (!isCertificateError(error)) return;

    final innerError = error.error as HandshakeException;

    await FirebaseCrashlytics.instance.recordError(
      'TLS Certificate Validation Failed: ${innerError.message}',
      null, // StackTrace
      information: [
        DiagnosticsProperty('operation', operation),
        DiagnosticsProperty('url', error.requestOptions.uri.toString()),
        DiagnosticsProperty('error_type', error.type.toString()),
        DiagnosticsProperty('handshake_message', innerError.message),
        DiagnosticsProperty('os_error', innerError.osError?.toString()),
        DiagnosticsProperty('timestamp', DateTime.now().toIso8601String()),
      ],
    );

    // Also log locally for debugging
    AppLogger.error(
      '🔴 TLS Certificate Error detected: $operation',
      null,
      StackTrace.current,
    );
    AppLogger.error(
      'URL: ${error.requestOptions.uri}',
      null,
      StackTrace.current,
    );
    AppLogger.error('Error: ${innerError.message}', null, StackTrace.current);
    AppLogger.error(
      'OS Error: ${innerError.osError}',
      null,
      StackTrace.current,
    );
  }

  /// Check if certificate pinning should be bypassed (temporary fix)
  static bool shouldBypassCertificatePinning(DioException error) {
    // Only bypass for certificate errors in development/debug builds
    return isCertificateError(error) && kDebugMode;
  }
}
