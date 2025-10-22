import 'package:edulift/core/config/environment_config.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:flutter_logs/flutter_logs.dart';
import '../storage/log_config.dart';

final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    printEmojis: false,
    noBoxingByDefault: true,
  ),
  level: kDebugMode ? Level.debug : Level.warning,
);

class AppLogger {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
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
      info('AppLogger initialized successfully');
    } catch (e) {
      appLogger.e('Failed to initialize AppLogger: $e');
    }
  }

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    appLogger.d(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.INFO, error, stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    appLogger.i(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.INFO, error, stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    appLogger.w(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.WARNING, error, stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    appLogger.e(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.ERROR, error, stackTrace);
  }

  static void trace(String message, [dynamic error, StackTrace? stackTrace]) {
    appLogger.t(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.INFO, error, stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    appLogger.f(message, error: error, stackTrace: stackTrace);
    _persistLog(message, 'general', LogLevel.SEVERE, error, stackTrace);
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
            ' | StackTrace: ${stackTrace.toString().split('\n').take(5).join('\\n')}';
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
}
