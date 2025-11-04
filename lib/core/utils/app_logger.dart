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

  static void debug(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) async {
    final logger = await appLogger;
    logger.d(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.INFO, error, stackTrace);

    // BREADCRUMBS: Add to Crashlytics timeline (with intelligent filtering)
    _addBreadcrumbIfRelevant('DEBUG', message);
  }

  static void info(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) async {
    final logger = await appLogger;
    logger.i(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.INFO, error, stackTrace);

    // BREADCRUMBS: Add to Crashlytics timeline (with intelligent filtering)
    _addBreadcrumbIfRelevant('INFO', message);
  }

  static void warning(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) async {
    final logger = await appLogger;
    logger.w(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.WARNING, error, stackTrace);

    // BREADCRUMBS: Add to Crashlytics timeline (with intelligent filtering)
    _addBreadcrumbIfRelevant('WARNING', message);
  }

  static void error(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) async {
    final logger = await appLogger;
    logger.e(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.ERROR, error, stackTrace);

    // BREADCRUMBS: Add to Crashlytics timeline BEFORE reporting error
    _addBreadcrumbIfRelevant('ERROR', message);

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

    // BREADCRUMBS: Add to Crashlytics timeline BEFORE reporting error
    _addBreadcrumbIfRelevant('FATAL', message);

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

  /// Add breadcrumbs to Crashlytics with intelligent filtering to respect quotas
  /// Only relevant logs (WARNING, ERROR, FATAL + selective INFO/DEBUG)
  static void _addBreadcrumbIfRelevant(String level, String message) {
    // Only if crash reporting is enabled
    if (!FeatureFlags.crashReporting) return;

    try {
      // Get current config
      final config = EnvironmentConfig.getConfig();

      // Intelligent filtering by environment and level
      var shouldLog = false;

      switch (level) {
        case 'DEBUG':
          // DEBUG logs only in development and staging (not in production)
          shouldLog =
              config.environmentName == 'development' ||
              config.environmentName == 'staging';
          break;
        case 'INFO':
          // INFO logs always, but limit verbosity
          shouldLog =
              !message.contains('⚡') && // Avoid frequent logs
              !message.contains('Timer:') &&
              !message.contains('Frame:') &&
              message.length < 200; // Avoid long logs
          break;
        case 'WARNING':
        case 'ERROR':
        case 'FATAL':
          // ALWAYS log errors and warnings
          shouldLog = true;
          break;
      }

      if (shouldLog) {
        // Format for Crashlytics: level + message (truncated if too long)
        const maxLength = 800; // Stay under 1024 chars with margin
        final truncatedMessage = message.length > maxLength
            ? '${message.substring(0, maxLength - 3)}...'
            : message;

        FirebaseCrashlytics.instance.log('[$level] $truncatedMessage');
      }
    } catch (e) {
      // Failsafe to avoid recursive errors
      if (kDebugMode) {
        print('❌ Failed to add breadcrumb: $e');
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
