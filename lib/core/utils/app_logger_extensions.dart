import 'app_logger.dart';

/// Log levels for structured logging
enum LogLevel { debug, info, warning, error, fatal }

/// Extensions for AppLogger to provide structured, operation-based logging
extension AppLoggerExtensions on AppLogger {
  /// Operation-based logging with structured context
  ///
  /// Example:
  /// ```dart
  /// AppLogger.logOperation('get_families', 'FAMILY', LogLevel.info, 'Successfully loaded 5 families');
  /// AppLogger.logOperation('create_child', 'CHILDREN', LogLevel.error, 'Validation failed', error: validationError);
  /// ```
  static void logOperation(
    String operation,
    String feature,
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final logMessage = '[$feature] $operation: $message';
    final enrichedMetadata = {
      'feature': feature,
      'operation': operation,
      'timestamp': DateTime.now().toIso8601String(),
      ...?metadata,
    };

    // Include metadata in debug logs for better debugging
    final fullMessage = metadata != null
        ? '$logMessage | Metadata: $enrichedMetadata'
        : logMessage;

    switch (level) {
      case LogLevel.debug:
        AppLogger.debug(fullMessage, error, stackTrace);
        break;
      case LogLevel.info:
        AppLogger.info(logMessage, error, stackTrace);
        if (metadata != null) {
          AppLogger.debug('Operation metadata: $enrichedMetadata');
        }
        break;
      case LogLevel.warning:
        AppLogger.warning(logMessage, error, stackTrace);
        if (metadata != null) {
          AppLogger.debug('Warning metadata: $enrichedMetadata');
        }
        break;
      case LogLevel.error:
        AppLogger.error(logMessage, error, stackTrace);
        if (metadata != null) {
          AppLogger.debug('Error metadata: $enrichedMetadata');
        }
        break;
      case LogLevel.fatal:
        AppLogger.fatal(logMessage, error, stackTrace);
        if (metadata != null) {
          AppLogger.debug('Fatal metadata: $enrichedMetadata');
        }
        break;
    }
  }

  // ========== FEATURE-SPECIFIC LOGGING METHODS ==========

  /// Family feature logging
  static void logFamilyOperation(
    String operation,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) => logOperation(
    operation,
    'FAMILY',
    error != null ? LogLevel.error : LogLevel.info,
    message,
    error: error,
    stackTrace: stackTrace,
    metadata: metadata,
  );

  /// Authentication feature logging
  static void logAuthOperation(
    String operation,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) => logOperation(
    operation,
    'AUTH',
    error != null ? LogLevel.error : LogLevel.info,
    message,
    error: error,
    stackTrace: stackTrace,
    metadata: metadata,
  );

  /// Schedule feature logging
  static void logScheduleOperation(
    String operation,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) => logOperation(
    operation,
    'SCHEDULE',
    error != null ? LogLevel.error : LogLevel.info,
    message,
    error: error,
    stackTrace: stackTrace,
    metadata: metadata,
  );

  /// Children feature logging
  static void logChildrenOperation(
    String operation,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) => logOperation(
    operation,
    'CHILDREN',
    error != null ? LogLevel.error : LogLevel.info,
    message,
    error: error,
    stackTrace: stackTrace,
    metadata: metadata,
  );

  /// Vehicle feature logging
  static void logVehicleOperation(
    String operation,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) => logOperation(
    operation,
    'VEHICLE',
    error != null ? LogLevel.error : LogLevel.info,
    message,
    error: error,
    stackTrace: stackTrace,
    metadata: metadata,
  );

  // ========== PERFORMANCE LOGGING ==========

  /// Track operation performance
  ///
  /// Example:
  /// ```dart
  /// final stopwatch = Stopwatch()..start();
  /// final families = await loadFamilies();
  /// AppLogger.trackPerformance('load_families', stopwatch.elapsed, success: families.isNotEmpty);
  /// ```
  static void trackPerformance(
    String operation,
    Duration duration, {
    bool success = true,
    Map<String, dynamic>? metadata,
  }) {
    final status = success ? 'SUCCESS' : 'FAILED';
    final message =
        '⚡ Performance [$operation] $status in ${duration.inMilliseconds}ms';

    logOperation(
      operation,
      'PERFORMANCE',
      success ? LogLevel.info : LogLevel.warning,
      message,
      metadata: {
        'duration_ms': duration.inMilliseconds,
        'success': success,
        ...?metadata,
      },
    );
  }

  // ========== ERROR METRICS ==========

  /// Record error metrics for analytics
  static void recordErrorMetric(
    String errorCategory,
    String errorSeverity,
    String feature,
    String operation, {
    Map<String, dynamic>? metadata,
  }) {
    final message =
        '📊 Error Metric: $errorCategory/$errorSeverity in $feature/$operation';

    logOperation(
      'error_metric',
      'ANALYTICS',
      LogLevel.info,
      message,
      metadata: {
        'error_category': errorCategory,
        'error_severity': errorSeverity,
        'feature': feature,
        'operation': operation,
        ...?metadata,
      },
    );
  }

  // ========== USER ACTION LOGGING ==========

  /// Log user actions for debugging and analytics
  ///
  /// Example:
  /// ```dart
  /// AppLogger.logUserAction('button_tap', 'create_family_page', metadata: {'family_name': familyName});
  /// ```
  static void logUserAction(
    String action,
    String screen, {
    Map<String, dynamic>? metadata,
  }) {
    logOperation(
      action,
      'USER_ACTION',
      LogLevel.info,
      'User performed $action on $screen',
      metadata: {'screen': screen, 'action': action, ...?metadata},
    );
  }

  // ========== DATA FLOW LOGGING ==========

  /// Log data flow operations (API calls, cache operations, etc.)
  static void logDataFlow(
    String operation,
    String dataType,
    String source, // 'remote', 'cache', 'local'
    String result, {
    // 'success', 'failed', 'fallback'
    int? recordCount,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final message = '🔄 Data Flow [$dataType] $operation from $source: $result';

    logOperation(
      operation,
      'DATA_FLOW',
      result == 'failed' ? LogLevel.error : LogLevel.info,
      message,
      error: error,
      stackTrace: stackTrace,
      metadata: {
        'data_type': dataType,
        'source': source,
        'result': result,
        'record_count': recordCount,
        ...?metadata,
      },
    );
  }

  // ========== STATE CHANGE LOGGING ==========

  /// Log state changes for debugging
  static void logStateChange(
    String feature,
    String fromState,
    String toState, {
    String? trigger,
    Map<String, dynamic>? metadata,
  }) {
    final message = '🔄 State Change [$feature] $fromState → $toState';

    logOperation(
      'state_change',
      feature.toUpperCase(),
      LogLevel.debug,
      message,
      metadata: {
        'from_state': fromState,
        'to_state': toState,
        'trigger': trigger,
        ...?metadata,
      },
    );
  }

  // ========== NETWORK REQUEST LOGGING ==========

  /// Log network requests for debugging
  static void logNetworkRequest(
    String method,
    String url,
    int? statusCode, {
    Duration? duration,
    dynamic error,
    Map<String, dynamic>? metadata,
  }) {
    final success = statusCode != null && statusCode >= 200 && statusCode < 300;
    final message = '🌐 $method $url → ${statusCode ?? 'FAILED'}';

    logOperation(
      'network_request',
      'NETWORK',
      success ? LogLevel.info : LogLevel.error,
      message,
      error: error,
      metadata: {
        'method': method,
        'url': url,
        'status_code': statusCode,
        'duration_ms': duration?.inMilliseconds,
        'success': success,
        ...?metadata,
      },
    );
  }

  // ========== CACHE OPERATION LOGGING ==========

  /// Log cache operations
  static void logCacheOperation(
    String operation, // 'hit', 'miss', 'write', 'clear', 'error'
    String key, {
    dynamic error,
    Map<String, dynamic>? metadata,
  }) {
    final message = '💾 Cache $operation: $key';

    logOperation(
      'cache_$operation',
      'CACHE',
      operation == 'error' ? LogLevel.error : LogLevel.debug,
      message,
      error: error,
      metadata: {'cache_key': key, 'operation': operation, ...?metadata},
    );
  }

  // ========== SYNC OPERATION LOGGING ==========

  /// Log sync operations for offline/online data synchronization
  static void logSyncOperation(
    String operation, // 'start', 'success', 'conflict', 'failed'
    String dataType, {
    int? recordCount,
    int? conflictCount,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final message =
        '🔄 Sync $operation: $dataType${recordCount != null ? ' ($recordCount records)' : ''}';

    logOperation(
      'sync_$operation',
      'SYNC',
      operation == 'failed' ? LogLevel.error : LogLevel.info,
      message,
      error: error,
      stackTrace: stackTrace,
      metadata: {
        'data_type': dataType,
        'operation': operation,
        'record_count': recordCount,
        'conflict_count': conflictCount,
        ...?metadata,
      },
    );
  }
}

/// Helper class for tracking operation performance
class PerformanceTracker {
  final String operation;
  final Stopwatch _stopwatch;
  final Map<String, dynamic>? metadata;

  PerformanceTracker._(this.operation, this.metadata)
    : _stopwatch = Stopwatch()..start();

  /// Start tracking an operation
  ///
  /// Example:
  /// ```dart
  /// final tracker = PerformanceTracker.start('load_families');
  /// // ... do work ...
  /// tracker.finish(success: result.isOk());
  /// ```
  factory PerformanceTracker.start(
    String operation, {
    Map<String, dynamic>? metadata,
  }) {
    AppLogger.debug('🚀 Starting operation: $operation');
    return PerformanceTracker._(operation, metadata);
  }

  /// Finish tracking and log the result
  void finish({bool success = true}) {
    _stopwatch.stop();
    AppLoggerExtensions.trackPerformance(
      operation,
      _stopwatch.elapsed,
      success: success,
      metadata: metadata,
    );
  }

  /// Get current elapsed time without finishing
  Duration get elapsed => _stopwatch.elapsed;
}
