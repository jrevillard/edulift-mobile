import 'package:edulift/core/config/environment_config.dart';
import 'package:edulift/core/config/base_config.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../storage/log_config.dart';
import '../config/feature_flags.dart';

Logger? _appLogger;
BaseConfig? _cachedConfig;

Future<Logger> get appLogger async {
  if (_appLogger == null) {
    final level = await _getLogLevel();
    _appLogger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        printEmojis: false,
        noBoxingByDefault: true,
      ),
      level: level,
    );
  }
  return _appLogger!;
}

/// Get log level with proper priority handling (async)
/// PRIORITÉ 1: Configuration utilisateur (SharedPreferences)
/// PRIORITÉ 2: Configuration JSON (EnvironmentConfig)
/// PRIORITÉ 3: Variables d'environnement directes
/// PRIORITÉ 4: Fallback kDebugMode
Future<Level> _getLogLevel() async {
  try {
    // PRIORITÉ 1: Configuration utilisateur
    try {
      final userLevel = await LogConfig.getLogLevel();
      return userLevel;
    } catch (e) {
      // Continue with next priority if user level fails
    }

    // PRIORITÉ 2: Configuration JSON (cached for performance)
    final config = _cachedConfig ??= EnvironmentConfig.getConfig();
    return config.loggerLogLevel;
  } catch (e) {
    // PRIORITÉ 3: Variables d'environnement directes
    const logLevelString = String.fromEnvironment('LOG_LEVEL');

    if (logLevelString.isNotEmpty) {
      switch (logLevelString.toLowerCase()) {
        case 'trace':
          return Level.trace;
        case 'debug':
          return Level.debug;
        case 'info':
          return Level.info;
        case 'warning':
          return Level.warning;
        case 'error':
          return Level.error;
        case 'fatal':
          return Level.fatal;
        default:
          break; // Fall through to kDebugMode fallback
      }
    }

    // PRIORITÉ 4: Fallback kDebugMode
    return kDebugMode ? Level.debug : Level.warning;
  }
}

class AppLogger {
  static bool _initialized = false;

  // Application context for enhanced error reporting
  static String? _currentRoute;
  static Map<String, dynamic>? _currentContext;
  static List<Map<String, dynamic>> _breadcrumbs = [];
  static const int _maxBreadcrumbs = 50;

  /// Initialize AppLogger with user preference priority
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // PRIORITÉ 1: Charger la préférence utilisateur si disponible
      try {
        await LogConfig.getLogLevel();
        // Force la recréation du logger pour qu'il utilise _getLogLevel() avec la priorité utilisateur
        _appLogger = null;
      } catch (e) {
        // Continue avec la configuration par défaut si la préférence utilisateur échoue
      }

      final config = EnvironmentConfig.getConfig();
      if (config.environmentName == 'staging' ||
          config.environmentName == 'production') {
        await FlutterLogs.initLogs(
          logLevelsEnabled: [
            LogLevel.INFO,
            LogLevel.WARNING,
            LogLevel.ERROR,
            LogLevel.SEVERE,
          ],
          timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
          directoryStructure: DirectoryStructure.FOR_DATE,
          logTypesEnabled: [
            'device',
            'network',
            'database',
            'navigation',
            'auth',
            'general',
          ],
          logFileExtension: LogFileExtension.LOG,
          logsWriteDirectoryName: LogConfig.logsWriteDirectoryName,
          logsExportDirectoryName: LogConfig.logsExportDirectoryName,
        );
      }
      _initialized = true;
      info(
        'AppLogger initialized successfully with log level: ${config.loggerLogLevel}',
      );
    } catch (e) {
      // Failsafe logging if configuration fails
      if (kDebugMode) {
        print('Failed to initialize AppLogger: $e');
      }
    }
  }

  /// Update log level dynamically (useful for testing or runtime changes)
  static void updateLogLevel(Level newLevel) {
    _appLogger = null; // Force recreation
    // Clear cached config to ensure fresh read with new priority
    _cachedConfig = null;
  }

  /// Get current log level (async for proper priority handling)
  static Future<Level> get currentLogLevel => _getLogLevel();

  /// Update current navigation context for enhanced error reporting
  static void updateNavigationContext(
    String route,
    Map<String, dynamic>? context,
  ) {
    _currentRoute = route;
    _currentContext = context;

    // Add navigation breadcrumb
    _addBreadcrumb('NAVIGATION', 'Route changed to: $route');
  }

  /// Add custom context data (e.g., user actions, widget states)
  static void updateContext(String key, dynamic value) {
    _currentContext ??= {};
    _currentContext![key] = value;
  }

  /// Add enriched breadcrumb with metadata
  static void _addBreadcrumb(
    String category,
    String message, {
    String level = 'INFO',
    Map<String, dynamic>? data,
  }) {
    final breadcrumb = {
      'timestamp': DateTime.now().toIso8601String(),
      'category': category,
      'level': level,
      'message': message,
      if (data != null) ...data,
    };

    _breadcrumbs.add(breadcrumb);

    // Keep only the last N breadcrumbs
    if (_breadcrumbs.length > _maxBreadcrumbs) {
      _breadcrumbs = _breadcrumbs.sublist(
        _breadcrumbs.length - _maxBreadcrumbs,
      );
    }

    // Add to Crashlytics with SMARTER filtering
    _addBreadcrumbToCrashlytics(category, level, message, data);
  }

  /// Get device and app context for error reporting
  static Map<String, dynamic> _getDeviceContext() {
    final context = <String, dynamic>{};

    try {
      // Add current route and context
      if (_currentRoute != null) {
        context['current_route'] = _currentRoute!;
      }

      if (_currentContext != null) {
        context.addAll(_currentContext!);
      }

      // Add device info
      context['build_mode'] = kDebugMode
          ? 'debug'
          : (kReleaseMode ? 'release' : 'profile');

      // Add recent breadcrumbs (last 10)
      if (_breadcrumbs.isNotEmpty) {
        context['recent_breadcrumbs'] = _breadcrumbs
            .skip(_breadcrumbs.length > 10 ? _breadcrumbs.length - 10 : 0)
            .toList();
      }

      // Add memory info if available
      context['timestamp'] = DateTime.now().toIso8601String();
    } catch (e) {
      // Failsafe - don't let context collection fail
      if (kDebugMode) {
        print('❌ Failed to collect device context: $e');
      }
    }

    return context;
  }

  /// Specialized method for Flutter/UI errors (like RenderFlex overflow)
  static void logFlutterError({
    required String message,
    required String errorType,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? widgetContext,
  }) {
    // Enhanced context for Flutter errors
    final context = _getDeviceContext();

    // Add widget-specific context
    if (widgetContext != null) {
      context['widget_context'] = widgetContext;
    }

    // Add Flutter-specific info
    context['error_type'] = errorType;
    context['is_flutter_error'] = true;

    // Add detailed analysis for layout errors
    if (errorType.contains('overflow') || message.contains('overflow')) {
      context['error_category'] = 'layout_overflow';
      context['requires_ui_review'] = true;

      // Extract overflow details from message
      final overflowMatch = RegExp(
        r'overflowed by (\d+) pixels',
      ).firstMatch(message);
      if (overflowMatch != null) {
        context['overflow_pixels'] = int.tryParse(
          overflowMatch.group(1) ?? '0',
        );
      }
    }

    // Log with enhanced context
    AppLogger.error('Flutter Error: $message', error, stackTrace);

    // Send to Crashlytics with enhanced context
    _sendFlutterErrorToCrashlytics(
      message,
      errorType: errorType,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  static void debug(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) async {
    final logger = await appLogger;
    logger.d(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.INFO, error, stackTrace);

    // BREADCRUMBS: Add to local breadcrumbs (general category)
    _addBreadcrumb('GENERAL', message, level: 'DEBUG');
  }

  static void info(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) async {
    final logger = await appLogger;
    logger.i(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.INFO, error, stackTrace);

    // BREADCRUMBS: Add to local breadcrumbs (general category)
    _addBreadcrumb('GENERAL', message);
  }

  static void warning(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) async {
    final logger = await appLogger;
    logger.w(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.WARNING, error, stackTrace);

    // BREADCRUMBS: Add to local breadcrumbs (general category)
    _addBreadcrumb('GENERAL', message, level: 'WARNING');
  }

  static void error(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) async {
    final logger = await appLogger;
    logger.e(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.ERROR, error, stackTrace);

    // BREADCRUMBS: Add to local breadcrumbs (general category)
    _addBreadcrumb('GENERAL', message, level: 'ERROR');

    // Send ERROR level logs to Crashlytics (non-fatal)
    await _sendToCrashlytics(
      message,
      error: error,
      stackTrace: stackTrace,
      fatal: false,
    );
  }

  static void trace(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) async {
    final logger = await appLogger;
    logger.t(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.INFO, error, stackTrace);
  }

  static void fatal(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) async {
    final logger = await appLogger;
    logger.f(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.SEVERE, error, stackTrace);

    // BREADCRUMBS: Add to local breadcrumbs (general category)
    _addBreadcrumb('GENERAL', message, level: 'FATAL');

    // Send FATAL level logs to Crashlytics (marked as fatal)
    await _sendToCrashlytics(
      message,
      error: error,
      stackTrace: stackTrace,
      fatal: true,
    );
  }

  static void _persistLog(
    String message,
    String type,
    LogLevel level, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (!_initialized) return;

    // CRITICAL FIX: Only use FlutterLogs in staging/production environments
    // In development/debug, FlutterLogs is not initialized to avoid MissingPluginException
    final config = EnvironmentConfig.getConfig();
    if (!(config.environmentName == 'staging' ||
        config.environmentName == 'production')) {
      return; // Skip FlutterLogs in development
    }

    try {
      var fullMessage = message;
      if (error != null) {
        fullMessage += ' | Error: $error';
      }
      if (stackTrace != null) {
        fullMessage +=
            ' | StackTrace: ${stackTrace.toString().split('\n').take(10).join('\\n')}';
      }

      // Use correct flutter_logs method based on severity level
      switch (level) {
        case LogLevel.WARNING:
          FlutterLogs.logWarn(type, 'AppLogger', fullMessage);
          break;
        case LogLevel.ERROR:
          FlutterLogs.logError(type, 'AppLogger', fullMessage);
          break;
        case LogLevel.SEVERE:
          FlutterLogs.logError(type, 'AppLogger', '[SEVERE] $fullMessage');
          break;
        default:
          FlutterLogs.logInfo(type, 'AppLogger', fullMessage);
          break;
      }
    } catch (e, stackTrace) {
      // Failsafe: prevent recursive logging errors
      if (kDebugMode) {
        print('❌ AppLogger FlutterLogs error: $e');
        print('📍 StackTrace: $stackTrace');
      }
    }
  }

  static void secureToken(String prefix, String token) {
    if (token.isEmpty) {
      debug('$prefix: [EMPTY TOKEN]');
      return;
    }

    final preview = token.length > 20
        ? '${token.substring(0, 20)}...'
        : token.substring(0, token.length);

    debug('$prefix: $preview (${token.length} chars)');
  }

  static void secureKey(String prefix, dynamic key) {
    if (key == null) {
      debug('$prefix: [NULL KEY]');
      return;
    }

    if (key is String) {
      debug('$prefix: [KEY LENGTH: ${key.length}]');
    } else if (key is List<int>) {
      debug('$prefix: [KEY BYTES: ${key.length}]');
    } else {
      debug('$prefix: [KEY TYPE: ${key.runtimeType}]');
    }
  }

  static void secureUser(String prefix, Map<String, dynamic>? userData) {
    if (userData == null) {
      debug('$prefix: [NULL USER DATA]');
      return;
    }

    final safeData = <String, dynamic>{};

    if (userData.containsKey('id')) {
      safeData['id'] = userData['id'];
    }

    if (userData.containsKey('email')) {
      final email = userData['email'] as String?;
      if (email != null && email.contains('@')) {
        final parts = email.split('@');
        safeData['email'] = '${parts[0].substring(0, 1)}***@${parts[1]}';
      }
    }

    if (userData.containsKey('role')) {
      safeData['role'] = userData['role'];
    }

    debug('$prefix: $safeData');
  }

  /// Initialize Flutter error handling for automatic capture
  static void initializeFlutterErrorHandling() {
    // Override the default Flutter error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorType = details.exception.runtimeType.toString();
      final message = details.toString();

      // Extract widget context if available
      final widgetContext = <String, dynamic>{};

      if (details.context != null) {
        widgetContext['flutter_context'] = details.context.toString();
      }

      // Add specific context for different error types
      if (errorType == 'RenderFlex overflowed' ||
          message.contains('overflowed by')) {
        widgetContext['layout_type'] = 'Row/Column';
        widgetContext['issue_type'] = 'overflow';

        // Try to extract more specific information
        if (message.contains('horizontal')) {
          widgetContext['overflow_direction'] = 'horizontal';
        } else if (message.contains('vertical')) {
          widgetContext['overflow_direction'] = 'vertical';
        }

        // Extract overflow amount
        final overflowMatch = RegExp(
          r'overflowed by (\d+) pixels',
        ).firstMatch(message);
        if (overflowMatch != null) {
          widgetContext['overflow_amount'] = overflowMatch.group(1);
        }
      }

      // Add library information if available
      if (details.library != null) {
        widgetContext['flutter_library'] = details.library;
      }

      // Log with enhanced Flutter error handling
      logFlutterError(
        message: message,
        errorType: errorType,
        error: details.exception,
        stackTrace: details.stack,
        widgetContext: widgetContext,
      );
    };
  }

  /// Add user action breadcrumb for better context
  static void logUserAction(String action, {Map<String, dynamic>? data}) {
    _addBreadcrumb('USER_ACTION', 'User action: $action', data: data);
  }

  /// Add widget state breadcrumb for UI debugging
  static void logWidgetState(String widgetName, Map<String, dynamic> state) {
    _addBreadcrumb(
      'WIDGET_STATE',
      'Widget state changed: $widgetName',
      level: 'DEBUG',
      data: {'widget_name': widgetName, ...state},
    );
  }

  /// SMARTER: Add breadcrumbs to Crashlytics with context-aware filtering
  static void _addBreadcrumbToCrashlytics(
    String category,
    String level,
    String message,
    Map<String, dynamic>? data,
  ) {
    // Only if crash reporting is enabled
    if (!FeatureFlags.crashReporting) return;

    try {
      // SMART filtering based on category and context
      final shouldLog = _shouldLogBreadcrumb(category, level, message, data);

      if (shouldLog) {
        // Enhanced format for Crashlytics with context
        var logMessage = '[$level] $category: $message';

        // Add key context data for important categories
        if (category == 'USER_ACTION' && data != null) {
          final action = data['action'] ?? 'unknown';
          logMessage += ' | Action: $action';
        } else if (category == 'NAVIGATION' && data != null) {
          final route = data['route'] ?? 'unknown';
          logMessage += ' | Route: $route';
        } else if (category == 'WIDGET_STATE' && data != null) {
          final widget = data['widget_name'] ?? 'unknown';
          logMessage += ' | Widget: $widget';
        }

        // Truncate if too long (keep more margin for context)
        const maxLength = 900; // Stay under 1024 chars with margin
        if (logMessage.length > maxLength) {
          logMessage = '${logMessage.substring(0, maxLength - 3)}...';
        }

        // CRITICAL ANR FIX: Use microtask to prevent blocking main thread during startup
        // See commit 649dbaf for similar pattern in network_error_handler.dart
        Future.microtask(() {
          FirebaseCrashlytics.instance.log(logMessage);
        });
      }
    } catch (e) {
      // Failsafe to avoid recursive errors
      if (kDebugMode) {
        print('❌ Failed to add breadcrumb: $e');
      }
    }
  }

  /// Context-aware filtering for breadcrumbs
  static bool _shouldLogBreadcrumb(
    String category,
    String level,
    String message,
    Map<String, dynamic>? data,
  ) {
    // ALWAYS log important categories regardless of level
    const importantCategories = {
      'USER_ACTION',
      'NAVIGATION',
      'WIDGET_STATE',
      'AUTH_EVENT',
      'NETWORK_ERROR',
      'API_CALL',
      'LAYOUT_ERROR',
    };

    if (importantCategories.contains(category)) {
      return true;
    }

    // ALWAYS log errors and warnings
    if (level == 'WARNING' || level == 'ERROR' || level == 'FATAL') {
      return true;
    }

    // Get current config for environment-specific filtering
    try {
      final config = EnvironmentConfig.getConfig();

      switch (level) {
        case 'DEBUG':
          // DEBUG logs in development and staging, plus important ones in production
          if (config.environmentName == 'development' ||
              config.environmentName == 'staging') {
            return true;
          }
          // In production, only allow DEBUG for specific important cases
          return category == 'WIDGET_STATE' || message.contains('layout');

        case 'INFO':
          // INFO logs: filter out noise but keep important ones
          // Avoid frequent/performance logs
          if (message.contains('⚡') ||
              message.contains('Timer:') ||
              message.contains('Frame:') ||
              message.contains('performance tick')) {
            return false;
          }

          // Keep INFO logs that are meaningful
          return message.length < 300; // Allow longer but still reasonable

        default:
          return false;
      }
    } catch (e) {
      // If config fails, be conservative and log
      return true;
    }
  }

  /// Send Flutter-specific errors to Crashlytics with enhanced context
  static Future<void> _sendFlutterErrorToCrashlytics(
    String message, {
    required String errorType,
    dynamic error,
    StackTrace? stackTrace,
    required Map<String, dynamic> context,
  }) async {
    // Only send to Crashlytics if crash reporting is enabled
    if (!FeatureFlags.crashReporting) {
      return;
    }

    try {
      // Capture stack trace if not provided
      final effectiveStackTrace = stackTrace ?? StackTrace.current;

      // Create error object if not provided
      final effectiveError = error ?? Exception(message);

      // Build enhanced information array with context
      final information = <String>[
        'Flutter Error: $message',
        'Error Type: $errorType',
        'Level: ERROR',
        'Timestamp: ${DateTime.now().toIso8601String()}',
        'Current Route: ${context['current_route'] ?? 'Unknown'}',
        if (context.containsKey('widget_context'))
          'Widget Context: ${context['widget_context']}',
        if (context.containsKey('error_category'))
          'Error Category: ${context['error_category']}',
        if (context.containsKey('overflow_pixels'))
          'Overflow Pixels: ${context['overflow_pixels']}',
        if (context.containsKey('recent_breadcrumbs'))
          'Recent Breadcrumbs: ${context['recent_breadcrumbs']}',
      ];

      // Set custom keys for better filtering
      await FirebaseCrashlytics.instance.setCustomKey(
        'error_type',
        'flutter_error',
      );
      await FirebaseCrashlytics.instance.setCustomKey(
        'flutter_error_subtype',
        errorType,
      );
      await FirebaseCrashlytics.instance.setCustomKey(
        'current_route',
        context['current_route'] ?? 'unknown',
      );

      if (context.containsKey('error_category')) {
        await FirebaseCrashlytics.instance.setCustomKey(
          'error_category',
          context['error_category'],
        );
      }

      if (context.containsKey('overflow_pixels')) {
        await FirebaseCrashlytics.instance.setCustomKey(
          'overflow_pixels',
          context['overflow_pixels'],
        );
      }

      // Send to Crashlytics as non-fatal
      await FirebaseCrashlytics.instance.recordError(
        effectiveError,
        effectiveStackTrace,
        information: information,
      );
    } catch (e) {
      // Failsafe: prevent recursive errors in Crashlytics reporting
      if (kDebugMode) {
        print('❌ Failed to send Flutter error to Crashlytics: $e');
      }
    }
  }

  /// Send logs to Firebase Crashlytics based on severity level
  /// Only sends ERROR and FATAL level logs to avoid noise
  static Future<void> _sendToCrashlytics(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    required bool fatal,
  }) async {
    // Only send to Crashlytics if crash reporting is enabled
    if (!FeatureFlags.crashReporting) {
      return;
    }

    try {
      // Capture stack trace if not provided
      final effectiveStackTrace = stackTrace ?? StackTrace.current;

      // Create error object if not provided
      final effectiveError = error ?? Exception(message);

      // Send to Crashlytics with fatal flag
      await FirebaseCrashlytics.instance.recordError(
        effectiveError,
        effectiveStackTrace,
        fatal: fatal,
        information: [
          'Message: $message',
          'Level: ${fatal ? "FATAL" : "ERROR"}',
          'Timestamp: ${DateTime.now().toIso8601String()}',
        ],
      );
    } catch (e) {
      // Failsafe: prevent recursive errors in Crashlytics reporting
      if (kDebugMode) {
        print('❌ Failed to send to Crashlytics: $e');
      }
    }
  }
}
