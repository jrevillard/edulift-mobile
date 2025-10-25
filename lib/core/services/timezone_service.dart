// EduLift Mobile - Timezone Service
// Handles device timezone detection and UTC/local time conversions
//
// This service ensures that all schedule times are properly handled in the user's
// local timezone while storing them as UTC in the backend.

import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../utils/app_logger.dart';
import '../domain/services/auth_service.dart';

/// Service for managing timezone operations in the EduLift app
///
/// Features:
/// - Gets device's current IANA timezone (e.g., "Europe/Paris")
/// - Converts between UTC and local time strings
/// - Caches timezone for performance
/// - Handles timezone database initialization
class TimezoneService {
  static String? _cachedTimezone;
  static bool _isInitialized = false;

  /// Initialize the timezone database
  ///
  /// This must be called once during app startup (in main.dart or bootstrap.dart)
  /// before any other timezone operations.
  ///
  /// Throws: Exception if initialization fails
  static Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.debug('[TimezoneService] Already initialized');
      return;
    }

    try {
      AppLogger.debug('[TimezoneService] Initializing timezone database...');

      // Initialize timezone database with all locations
      tz.initializeTimeZones();

      // Get and cache the device's timezone
      final deviceTimezone = await getCurrentTimezone();

      AppLogger.info(
        '[TimezoneService] Initialized successfully with timezone: $deviceTimezone',
      );

      _isInitialized = true;
    } catch (e, stackTrace) {
      AppLogger.error(
        '[TimezoneService] Failed to initialize timezone service',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Get the current device timezone as an IANA timezone string
  ///
  /// **NOTE**: This method returns UTC as fallback since we use the user profile
  /// timezone from the backend instead of the device timezone. The device timezone
  /// is only used for initial display before login.
  ///
  /// Returns the device's timezone (always 'UTC' as fallback)
  /// Results are cached for performance.
  static Future<String> getCurrentTimezone() async {
    // Return cached value if available
    if (_cachedTimezone != null) {
      return _cachedTimezone!;
    }

    try {
      AppLogger.debug('[TimezoneService] Getting device timezone...');

      // Use DateTime.now().timeZoneName for device timezone detection
      // This returns abbreviations like 'PST', 'CET', etc.
      final tzAbbreviation = DateTime.now().timeZoneName;

      AppLogger.debug(
        '[TimezoneService] Device timezone abbreviation: $tzAbbreviation',
      );

      // Map common timezone abbreviations to IANA format
      // This is a simple fallback - the real timezone comes from user profile
      const commonTimezones = {
        'PST': 'America/Los_Angeles',
        'PDT': 'America/Los_Angeles',
        'EST': 'America/New_York',
        'EDT': 'America/New_York',
        'CST': 'America/Chicago',
        'CDT': 'America/Chicago',
        'MST': 'America/Denver',
        'MDT': 'America/Denver',
        'CET': 'Europe/Paris',
        'CEST': 'Europe/Paris',
        'GMT': 'Europe/London',
        'BST': 'Europe/London',
        'JST': 'Asia/Tokyo',
        'AEST': 'Australia/Sydney',
        'AEDT': 'Australia/Sydney',
      };

      final timezone = commonTimezones[tzAbbreviation] ?? 'UTC';

      // Validate that the timezone exists in our database
      try {
        tz.getLocation(timezone);
      } catch (e) {
        AppLogger.warning(
          '[TimezoneService] Invalid timezone $timezone, using UTC',
        );
        _cachedTimezone = 'UTC';
        return 'UTC';
      }

      // Cache the result
      _cachedTimezone = timezone;

      AppLogger.debug('[TimezoneService] Device timezone: $timezone');

      return timezone;
    } catch (e, stackTrace) {
      AppLogger.error(
        '[TimezoneService] Failed to get device timezone',
        e,
        stackTrace,
      );

      // Fallback to UTC if we can't get the device timezone
      const fallbackTimezone = 'UTC';
      AppLogger.warning('[TimezoneService] Falling back to UTC timezone');

      _cachedTimezone = fallbackTimezone;
      return fallbackTimezone;
    }
  }

  /// Convert a UTC time string to local time string for display
  ///
  /// Parameters:
  /// - utcTime: ISO 8601 datetime string in UTC (e.g., "2025-10-19T07:30:00.000Z")
  /// - timezone: IANA timezone string (e.g., "Europe/Paris")
  ///
  /// Returns: ISO 8601 datetime string in the specified timezone
  ///
  /// Example:
  /// ```dart
  /// final local = convertUtcTimeToLocal(
  ///   "2025-10-19T07:30:00.000Z",
  ///   "Europe/Paris"
  /// );
  /// // Returns "2025-10-19T09:30:00.000+02:00" (Paris is UTC+2 in summer)
  /// ```
  static String convertUtcTimeToLocal(String utcTime, String timezone) {
    try {
      AppLogger.debug('[TimezoneService] Converting UTC to local', {
        'utcTime': utcTime,
        'timezone': timezone,
      });

      // Parse the UTC time
      final utcDateTime = DateTime.parse(utcTime).toUtc();

      // Get the timezone location
      final location = tz.getLocation(timezone);

      // Convert to the target timezone
      final localDateTime = tz.TZDateTime.from(utcDateTime, location);

      // Return as ISO 8601 string
      final result = localDateTime.toIso8601String();

      AppLogger.debug('[TimezoneService] Converted to local: $result');

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        '[TimezoneService] Failed to convert UTC time to local',
        e,
        stackTrace,
      );

      // Return original time as fallback
      return utcTime;
    }
  }

  /// Convert a local time string to UTC time string for API requests
  ///
  /// Parameters:
  /// - localTime: ISO 8601 datetime string in local time
  /// - timezone: IANA timezone string (e.g., "Europe/Paris")
  ///
  /// Returns: ISO 8601 datetime string in UTC
  ///
  /// Example:
  /// ```dart
  /// final utc = convertLocalTimeToUtc(
  ///   "2025-10-19T09:30:00",
  ///   "Europe/Paris"
  /// );
  /// // Returns "2025-10-19T07:30:00.000Z" (Paris is UTC+2 in summer)
  /// ```
  static String convertLocalTimeToUtc(String localTime, String timezone) {
    try {
      AppLogger.debug('[TimezoneService] Converting local to UTC', {
        'localTime': localTime,
        'timezone': timezone,
      });

      // Get the timezone location
      final location = tz.getLocation(timezone);

      // Parse the local time in the specified timezone
      // If the string already contains timezone info, parse it directly
      // Otherwise, treat it as being in the specified timezone
      DateTime utcDateTime;

      // Check if the string contains timezone offset info
      // Look for patterns like +05:00, -04:00, +0530, or trailing Z
      final hasTimezoneInfo = localTime.endsWith('Z') ||
          RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(localTime) ||
          RegExp(r'[+-]\d{4}$').hasMatch(localTime);

      if (hasTimezoneInfo) {
        // Already has timezone info - parse it and convert to UTC
        final parsedWithTz = DateTime.parse(localTime);
        utcDateTime = parsedWithTz.toUtc();
      } else {
        // No timezone info, parse as naive datetime and interpret in the specified timezone
        // We need to parse the string components directly to avoid DateTime.parse's
        // timezone-dependent behavior
        final dateTimeParts = RegExp(
          r'(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.(\d+))?',
        ).firstMatch(localTime);

        if (dateTimeParts == null) {
          throw FormatException('Invalid datetime format: $localTime');
        }

        final year = int.parse(dateTimeParts.group(1)!);
        final month = int.parse(dateTimeParts.group(2)!);
        final day = int.parse(dateTimeParts.group(3)!);
        final hour = int.parse(dateTimeParts.group(4)!);
        final minute = int.parse(dateTimeParts.group(5)!);
        final second = int.parse(dateTimeParts.group(6)!);
        final millisecondStr = dateTimeParts.group(7) ?? '0';
        final millisecond = millisecondStr.length >= 3
            ? int.parse(millisecondStr.substring(0, 3))
            : int.parse(millisecondStr.padRight(3, '0'));

        // Create TZDateTime in the target timezone with the wall-clock time
        final tzDateTime = tz.TZDateTime(
          location,
          year,
          month,
          day,
          hour,
          minute,
          second,
          millisecond,
        );
        utcDateTime = tzDateTime.toUtc();
      }

      // Return as ISO 8601 string
      final result = utcDateTime.toIso8601String();

      AppLogger.debug('[TimezoneService] Converted to UTC: $result');

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        '[TimezoneService] Failed to convert local time to UTC',
        e,
        stackTrace,
      );

      // Return original time as fallback
      return localTime;
    }
  }

  /// Clear the cached timezone
  ///
  /// Useful for testing or when the user's timezone changes
  static void clearCache() {
    AppLogger.debug('[TimezoneService] Clearing timezone cache');
    _cachedTimezone = null;
  }

  /// Check if the service is initialized
  static bool get isInitialized => _isInitialized;

  /// Reset the service (for testing purposes)
  static void reset() {
    AppLogger.debug('[TimezoneService] Resetting timezone service');
    _isInitialized = false;
    _cachedTimezone = null;
  }

  /// Check and sync timezone if auto-sync is enabled
  ///
  /// This method should be called on app startup and when the app resumes
  /// from background to detect timezone changes when traveling.
  ///
  /// Parameters:
  /// - authService: The auth service to update user timezone
  ///
  /// Returns: true if timezone was synced, false if not (disabled or same timezone)
  static Future<bool> checkAndSyncTimezone(AuthService authService) async {
    try {
      AppLogger.debug('[TimezoneService] Checking auto-sync preference...');

      // Check if auto-sync is enabled
      final prefs = await SharedPreferences.getInstance();
      final autoSyncEnabled = prefs.getBool('autoSyncTimezone') ?? false;

      if (!autoSyncEnabled) {
        AppLogger.debug('[TimezoneService] Auto-sync is disabled');
        return false;
      }

      // Get current user
      final userResult = await authService.getCurrentUser();
      if (userResult.isErr) {
        AppLogger.warning(
          '[TimezoneService] No authenticated user, skipping timezone sync',
        );
        return false;
      }

      final user = userResult.value!;
      final userTimezone = user.timezone ?? 'UTC';

      // Get device timezone
      final deviceTimezone = await getCurrentTimezone();

      // Only update if different
      if (deviceTimezone != userTimezone) {
        AppLogger.info(
          '[TimezoneService] Timezone mismatch detected - User: $userTimezone, Device: $deviceTimezone',
        );

        // Update user timezone
        final updateResult = await authService.updateUserTimezone(
          deviceTimezone,
        );

        if (updateResult.isOk) {
          AppLogger.info(
            '[TimezoneService] Timezone auto-synced successfully to $deviceTimezone',
          );
          return true;
        } else {
          AppLogger.warning(
            '[TimezoneService] Failed to auto-sync timezone: ${updateResult.error?.message}',
          );
          return false;
        }
      } else {
        AppLogger.debug('[TimezoneService] Timezone already in sync');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '[TimezoneService] Error during timezone auto-sync',
        e,
        stackTrace,
      );
      return false;
    }
  }
}
