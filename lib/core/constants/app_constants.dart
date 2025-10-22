/// Application-wide constants for EduLift mobile app
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ========================================
  // APPLICATION CONSTANTS
  // ========================================

  /// Application name
  static const String appName = 'EduLift';

  /// Application version
  static const String appVersion = '1.0.0';

  // ========================================
  // AUTHENTICATION CONSTANTS
  // ========================================

  /// JWT token key for secure storage (single token architecture)
  static const String tokenKey = 'jwt_token';

  /// User ID key for secure storage
  static const String userIdKey = 'user_id';

  /// User data key for secure storage
  static const String userDataKey = 'user_data';

  /// Remember login preference key
  static const String rememberLoginKey = 'remember_login';

  /// Last login timestamp key
  static const String lastLoginKey = 'last_login';

  // ========================================
  // BIOMETRIC AUTHENTICATION
  // ========================================

  /// Biometric enabled preference key
  static const String biometricEnabledKey = 'biometric_enabled';

  /// Biometric type preference key
  static const String biometricTypeKey = 'biometric_type';

  /// Biometric last used timestamp
  static const String biometricLastUsedKey = 'biometric_last_used';

  // ========================================
  // HIVE BOX CONSTANTS
  // ========================================

  /// Main application settings box
  static const String settingsBox = 'settings';

  /// Offline sync data box
  static const String offlineSyncBox = 'offline_sync';

  /// Cache data box
  static const String cacheBox = 'cache';

  /// Secure data box (encrypted)
  static const String secureBox = 'secure_data';

  // Schedule Configuration Constants
  static const int maxTimeSlotsPerDay = 20; // Max departure hours per day
  static const int minTimeSlotIntervalMinutes =
      15; // Min interval between departure hours
  static const int defaultMaxVehiclesPerSlot =
      2; // Default max vehicles per departure hour

  static const List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  // API Configuration
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration websocketReconnectDelay = Duration(seconds: 5);
  static const int maxRetryAttempts = 3;

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration longSnackBarDuration = Duration(seconds: 5);

  // Validation Constants
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxGroupNameLength = 100;
  static const int maxVehicleNameLength = 50;

  // Time Slot Validation
  static const List<int> validMinutes = [0, 15, 30, 45];
  static const int minHour = 0;
  static const int maxHour = 23;

  // File Size Limits
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSizeBytes = 10 * 1024 * 1024; // 10MB

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Configuration
  static const Duration cacheValidityDuration = Duration(minutes: 30);
  static const Duration offlineCacheValidityDuration = Duration(hours: 24);

  // Biometric Authentication
  static const Duration biometricCacheTimeout = Duration(minutes: 5);
  static const int maxBiometricAttempts = 3;

  // Real-time Updates
  static const Duration realTimeUpdateInterval = Duration(seconds: 30);
  static const Duration heartbeatInterval = Duration(minutes: 1);

  // Error Messages
  static const String genericErrorMessage =
      'An unexpected error occurred. Please try again.';
  static const String networkErrorMessage =
      'Unable to connect. Please check your internet connection.';
  static const String timeoutErrorMessage =
      'Request timed out. Please try again.';
  static const String authErrorMessage =
      'Authentication failed. Please log in again.';
  static const String permissionErrorMessage =
      'You do not have permission to perform this action.';

  // Schedule Configuration Validation Messages
  static const String noActiveDaysError =
      'At least one active day must be selected';
  static const String noActiveTimeSlotsError =
      'At least one departure hour must be configured';
  static const String maxTimeSlotsExceededError =
      'Maximum $maxTimeSlotsPerDay departure hours allowed per weekday';
  static const String minIntervalError =
      'Minimum $minTimeSlotIntervalMinutes minutes required between departure hours';
  static const String duplicateTimeSlotsError =
      'Duplicate departure hours are not allowed';
  static const String invalidTimeFormatError =
      'Invalid time format. Use HH:MM (24-hour)';
  static const String invalidMinuteIntervalError =
      'Time must be in 15-minute intervals (00, 15, 30, 45)';

  // Success Messages
  static const String configSavedSuccessMessage =
      'Schedule configuration saved successfully';
  static const String configResetSuccessMessage =
      'Configuration reset to defaults';
  static const String timeSlotAddedMessage =
      'Departure hour added successfully';
  static const String timeSlotUpdatedMessage =
      'Departure hour updated successfully';
  static const String timeSlotDeletedMessage =
      'Departure hour deleted successfully';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableBiometricAuth = true;
  static const bool enableRealTimeUpdates = true;
  static const bool enableAdvancedScheduling = true;
  static const bool enableConflictDetection = true;

  // Development Configuration
  static const bool debugNetworkCalls = false;
  static const bool debugMemoryUsage = false;
  static const bool enablePerformanceLogging = false;

  // Helper Methods

  /// Check if a time string is valid (HH:MM format)
  static bool isValidTimeFormat(String time) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  /// Check if minutes are valid (15-minute intervals)
  static bool isValidMinuteInterval(int minutes) {
    return validMinutes.contains(minutes);
  }

  /// Parse time string to minutes from midnight
  static int? parseTimeToMinutes(String time) {
    if (!isValidTimeFormat(time)) return null;

    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (hour < minHour || hour > maxHour) return null;
    if (!isValidMinuteInterval(minute)) return null;

    return hour * 60 + minute;
  }

  /// Convert minutes from midnight to time string
  static String minutesToTimeString(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Calculate time difference in minutes
  static int? getTimeDifferenceMinutes(String time1, String time2) {
    final minutes1 = parseTimeToMinutes(time1);
    final minutes2 = parseTimeToMinutes(time2);

    if (minutes1 == null || minutes2 == null) return null;

    return (minutes2 - minutes1).abs();
  }

  /// Check if two departure hours have sufficient interval
  static bool hasSufficientInterval(String time1, String time2) {
    final diff = getTimeDifferenceMinutes(time1, time2);
    return diff != null && diff >= minTimeSlotIntervalMinutes;
  }
}
