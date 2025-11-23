/// Certificate Error Monitoring Service
/// Centralized monitoring for TLS certificate errors
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// Simplified certificate error monitoring service
/// Only keeps the essential recordError functionality that is actually used
class CertificateErrorMonitor {
  /// Record a certificate error and send to Crashlytics
  /// PERFORMANCE FIX: Use Future.wait() to parallelize Crashlytics calls
  static Future<void> recordError({
    required String operation,
    required Uri url,
    required String errorMessage,
    String? osError,
    Map<String, dynamic>? context,
  }) async {
    try {
      final crashlytics = FirebaseCrashlytics.instance;

      // Execute recordError and setCustomKey calls in parallel
      await Future.wait([
        // Send error to Crashlytics with rich context
        crashlytics.recordError(
          'Certificate Validation Error: $errorMessage',
          null,
          information: [
            DiagnosticsProperty('operation', operation),
            // Sanitized URL - remove query parameters to prevent PII leak
            DiagnosticsProperty('url_origin', url.origin),
            DiagnosticsProperty('url_path', url.path),
            DiagnosticsProperty('host', url.host),
            DiagnosticsProperty('error_message', errorMessage),
            if (osError != null) DiagnosticsProperty('os_error', osError),
            DiagnosticsProperty('timestamp', DateTime.now().toIso8601String()),
            if (context != null && context.isNotEmpty)
              ...context.entries.map(
                (e) => DiagnosticsProperty(e.key, e.value),
              ),
          ],
        ),
        // Set custom keys for better filtering in Crashlytics dashboard
        crashlytics.setCustomKey('certificate_error_operation', operation),
        crashlytics.setCustomKey('certificate_error_host', url.host),
      ]);

      // Log locally for debugging (use warning to avoid duplicate Crashlytics report)
      AppLogger.warning(
        '🔴 Certificate error: $operation on ${url.host}',
        null,
        StackTrace.current,
      );
      AppLogger.warning('   Error: $errorMessage', null, StackTrace.current);
      if (osError != null) {
        AppLogger.warning('   OS Error: $osError', null, StackTrace.current);
      }
    } catch (e) {
      AppLogger.error('Failed to send certificate error to Crashlytics', e);
    }
  }
}
