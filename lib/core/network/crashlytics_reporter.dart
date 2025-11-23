/// Enhanced Crashlytics Error Reporter with Rate Limiting
/// Prevents quota exhaustion while capturing important errors
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';
import '../config/feature_flags.dart';
import 'error_handler_service.dart';

class CrashlyticsReporter {
  static final _errorCounts = <String, int>{};
  static DateTime _resetTime = DateTime.now();

  // Rate limiting configuration
  static const int MAX_ERRORS_PER_TYPE_PER_HOUR = 50;
  static const int MAX_TOTAL_ERRORS_PER_HOUR = 200;

  // Errors we intentionally don't report
  static const Set<int> LEGITIMATE_STATUS_CODES = {
    404, // Not found - often legitimate (optional resources)
  };

  /// Report error to Crashlytics with intelligent filtering and rate limiting
  static Future<bool> reportError({
    required ErrorClassification classification,
    required ErrorContext context,
    required dynamic error,
    StackTrace? stackTrace,
  }) async {
    // Check if crash reporting is enabled
    if (!FeatureFlags.crashReporting) {
      AppLogger.info(
        '🔧 Debug mode: Error not reported to Crashlytics (crash reporting disabled)',
      );
      return false;
    }

    // Filter: Only report fatal, critical, and major errors
    if (!_shouldReportBySeverity(classification.severity)) {
      AppLogger.debug(
        'Skipping Crashlytics report - severity too low: ${classification.severity}',
      );
      return false;
    }

    // Filter: Don't report legitimate 404s and other expected errors
    if (_isLegitimateError(classification, context)) {
      AppLogger.debug(
        'Skipping Crashlytics report - legitimate error: ${classification.category}',
      );
      return false;
    }

    // Rate limiting: Check if we've hit the limit
    if (!_shouldReportByRateLimit(classification, context)) {
      AppLogger.warning(
        '⚠️ Rate limit exceeded for ${classification.category} - not reporting to Crashlytics',
      );
      return false;
    }

    try {
      // Set user context
      if (context.userId != null) {
        await FirebaseCrashlytics.instance.setUserIdentifier(context.userId!);
      }

      // Set custom keys for filtering
      await _setCustomKeys(classification, context);

      // Record the error
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: classification.severity == ErrorSeverity.fatal,
        information: _buildInformation(classification, context),
      );

      // Update rate limit counter
      _incrementErrorCount(classification);

      AppLogger.info(
        '✅ Error reported to Crashlytics: ${classification.category}/${classification.severity}',
      );

      return true;
    } catch (e) {
      AppLogger.warning('Failed to report error to Crashlytics', e);
      return false;
    }
  }

  /// Check if error should be reported based on severity
  static bool _shouldReportBySeverity(ErrorSeverity severity) {
    return severity == ErrorSeverity.fatal ||
        severity == ErrorSeverity.critical ||
        severity == ErrorSeverity.major;
  }

  /// Check if error is a legitimate/expected error that shouldn't be reported
  static bool _isLegitimateError(
    ErrorClassification classification,
    ErrorContext context,
  ) {
    // Don't report validation errors (user input errors)
    // These are expected when users enter invalid data
    if (classification.category == ErrorCategory.validation) {
      return true;
    }

    // Don't report offline mode (user's intentional choice)
    if (classification.category == ErrorCategory.offline) {
      return true;
    }

    // Note: We deliberately DON'T filter specific status codes like 404
    // because that requires business logic knowledge.
    // Instead, errors should be classified correctly in ErrorHandlerService.
    // If a 404 is expected/legitimate, it should have severity 'minor' or 'warning',
    // not 'major', and thus won't be reported anyway.

    return false;
  }

  /// Check if error should be reported based on rate limiting
  static bool _shouldReportByRateLimit(
    ErrorClassification classification,
    ErrorContext context,
  ) {
    final now = DateTime.now();

    // Reset counters every hour
    if (now.difference(_resetTime).inHours >= 1) {
      _errorCounts.clear();
      _resetTime = now;
      return true; // First error after reset
    }

    // Check total errors across all types
    final totalErrors = _errorCounts.values.fold(
      0,
      (sum, count) => sum + count,
    );
    if (totalErrors >= MAX_TOTAL_ERRORS_PER_HOUR) {
      return false;
    }

    // Check errors for this specific type
    final errorKey =
        '${classification.category.name}_${classification.severity.name}';
    final count = _errorCounts[errorKey] ?? 0;
    if (count >= MAX_ERRORS_PER_TYPE_PER_HOUR) {
      return false;
    }

    return true;
  }

  /// Increment error count for rate limiting
  static void _incrementErrorCount(ErrorClassification classification) {
    final errorKey =
        '${classification.category.name}_${classification.severity.name}';
    _errorCounts[errorKey] = (_errorCounts[errorKey] ?? 0) + 1;
  }

  /// Set custom keys for better filtering in Crashlytics dashboard
  /// PERFORMANCE FIX: Use Future.wait() to parallelize all setCustomKey calls
  /// instead of sequential awaits that block the main thread
  static Future<void> _setCustomKeys(
    ErrorClassification classification,
    ErrorContext context,
  ) async {
    final crashlytics = FirebaseCrashlytics.instance;

    // Build list of all setCustomKey futures to execute in parallel
    final futures = <Future<void>>[
      crashlytics.setCustomKey('error_category', classification.category.name),
      crashlytics.setCustomKey('error_severity', classification.severity.name),
      crashlytics.setCustomKey('feature', context.feature),
      crashlytics.setCustomKey('operation', context.operation),
      crashlytics.setCustomKey('is_retryable', classification.isRetryable),
      crashlytics.setCustomKey(
        'requires_user_action',
        classification.requiresUserAction,
      ),
    ];

    // Add metadata keys to the parallel batch
    for (final entry in context.metadata.entries) {
      futures.add(
        crashlytics.setCustomKey('ctx_${entry.key}', entry.value.toString()),
      );
    }

    // Execute all setCustomKey calls in parallel
    await Future.wait(futures);
  }

  /// Build information array for Crashlytics
  static List<String> _buildInformation(
    ErrorClassification classification,
    ErrorContext context,
  ) {
    return [
      'Error occurred in ${context.feature}/${context.operation}',
      'Category: ${classification.category.name}',
      'Severity: ${classification.severity.name}',
      'Retryable: ${classification.isRetryable}',
      'User Action Required: ${classification.requiresUserAction}',
      'Session ID: ${context.sessionId}',
      'Timestamp: ${context.timestamp.toIso8601String()}',
      if (context.metadata.isNotEmpty) 'Metadata: ${context.metadata}',
      if (classification.analysisData.isNotEmpty)
        'Analysis Data: ${classification.analysisData}',
    ];
  }

  /// Get current rate limit status (useful for debugging/monitoring)
  static Map<String, dynamic> getRateLimitStatus() {
    final now = DateTime.now();
    final minutesUntilReset = 60 - now.difference(_resetTime).inMinutes;
    final totalErrors = _errorCounts.values.fold(
      0,
      (sum, count) => sum + count,
    );

    return {
      'total_errors_this_hour': totalErrors,
      'max_total_per_hour': MAX_TOTAL_ERRORS_PER_HOUR,
      'remaining_capacity': MAX_TOTAL_ERRORS_PER_HOUR - totalErrors,
      'minutes_until_reset': minutesUntilReset,
      'error_counts_by_type': Map<String, int>.from(_errorCounts),
      'reset_time': _resetTime.toIso8601String(),
    };
  }

  /// Clear rate limit counters (useful for testing)
  @visibleForTesting
  static void clearRateLimitCounters() {
    _errorCounts.clear();
    _resetTime = DateTime.now();
  }
}
