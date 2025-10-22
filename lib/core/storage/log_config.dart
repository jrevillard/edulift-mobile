import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Dynamic log level configuration
class LogConfig {
  static const String _logLevelKey = 'app_log_level';

  // Directory configuration for flutter_logs integration
  static const String logsWriteDirectoryName = 'EduLiftLogs';
  static const String logsExportDirectoryName = 'EduLiftLogs/Exported';

  /// Get configured log level with fallback to default
  static Future<Level> getLogLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final levelString = prefs.getString(_logLevelKey);

      if (levelString != null) {
        return _stringToLevel(levelString);
      }
    } catch (e) {
      debugPrint('Failed to get log level: $e');
    }

    // Default: debug in development, warning in production
    return kDebugMode ? Level.debug : Level.warning;
  }

  /// Set log level and persist to storage
  static Future<void> setLogLevel(Level level) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_logLevelKey, _levelToString(level));
    } catch (e) {
      debugPrint('Failed to set log level: $e');
    }
  }

  /// Available log levels for UI selection
  static const Map<String, Level> availableLevels = {
    'Trace (Most Verbose)': Level.trace,
    'Debug': Level.debug,
    'Info': Level.info,
    'Warning': Level.warning,
    'Error': Level.error,
    'Fatal (Least Verbose)': Level.fatal,
  };

  static Level _stringToLevel(String levelString) {
    switch (levelString.toLowerCase()) {
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
        return kDebugMode ? Level.debug : Level.warning;
    }
  }

  static String _levelToString(Level level) {
    switch (level) {
      case Level.trace:
        return 'trace';
      case Level.debug:
        return 'debug';
      case Level.info:
        return 'info';
      case Level.warning:
        return 'warning';
      case Level.error:
        return 'error';
      case Level.fatal:
        return 'fatal';
      case Level.all:
        return 'all';
      case Level.off:
        return 'off';
      // Handle deprecated enum values by mapping to their replacements
      default:
        // Map any deprecated values to their modern equivalents
        if (level.toString() == 'Level.verbose') return 'trace';
        if (level.toString() == 'Level.wtf') return 'fatal';
        if (level.toString() == 'Level.nothing') return 'off';
        return 'debug'; // fallback for unknown values
    }
  }
}
