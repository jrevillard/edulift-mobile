// EduLift Mobile - Safe Type Casting Utilities
// Provides safe casting operations to prevent runtime type errors

/// Safe casting utilities for handling API response parsing
/// Prevents "List<dynamic> cannot be cast to List<Map<String,dynamic>>" errors
class SafeCastingUtils {
  /// Safely cast a dynamic list to a list of Maps
  static List<Map<String, dynamic>> safeCastToMapList(dynamic value) {
    if (value == null) return <Map<String, dynamic>>[];

    if (value is List<Map<String, dynamic>>) {
      return value;
    }

    if (value is List) {
      final result = <Map<String, dynamic>>[];
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          result.add(item);
        } else if (item is Map) {
          // Convert Map to Map<String, dynamic>
          result.add(Map<String, dynamic>.from(item));
        } else {
          // Skip invalid items, don't crash
          continue;
        }
      }
      return result;
    }

    // If it's not a List at all, return empty list
    return <Map<String, dynamic>>[];
  }

  /// Safely cast a dynamic list to a list of Strings
  static List<String> safeCastToStringList(dynamic value) {
    if (value == null) return <String>[];

    if (value is List<String>) {
      return value;
    }

    if (value is List) {
      return value.whereType<String>().toList();
    }

    return <String>[];
  }

  /// Safely cast a dynamic list to a list of integers
  static List<int> safeCastToIntList(dynamic value) {
    if (value == null) return <int>[];

    if (value is List<int>) {
      return value;
    }

    if (value is List) {
      final result = <int>[];
      for (final item in value) {
        if (item is int) {
          result.add(item);
        } else if (item is num) {
          result.add(item.toInt());
        }
      }
      return result;
    }

    return <int>[];
  }

  /// Safely convert a Map to Map<String, dynamic>
  static Map<String, dynamic> safeCastToStringDynamicMap(dynamic value) {
    if (value == null) return <String, dynamic>{};

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  /// Safely extract a string from dynamic value
  static String safeCastToString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;

    if (value is String) return value;

    return value.toString();
  }

  /// Safely extract an integer from dynamic value
  static int safeCastToInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;

    if (value is int) return value;

    if (value is num) return value.toInt();

    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? defaultValue;
    }

    return defaultValue;
  }

  /// Safely extract a double from dynamic value
  static double safeCastToDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;

    if (value is double) return value;

    if (value is num) return value.toDouble();

    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? defaultValue;
    }

    return defaultValue;
  }

  /// Safely extract a boolean from dynamic value
  static bool safeCastToBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;

    if (value is bool) return value;

    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }

    if (value is int) {
      return value == 1;
    }

    return defaultValue;
  }

  /// Safely extract a DateTime from dynamic value
  static DateTime? safeCastToDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Generic type-safe list casting with validation
  static List<T> safeCastToList<T>(
    dynamic value,
    T Function(dynamic) converter, {
    List<T> defaultValue = const [],
  }) {
    if (value == null) return List<T>.from(defaultValue);

    if (value is List) {
      final result = <T>[];
      for (final item in value) {
        try {
          final converted = converter(item);
          result.add(converted);
        } catch (e) {
          // Skip items that can't be converted
          continue;
        }
      }
      return result;
    }

    return List<T>.from(defaultValue);
  }

  /// Validate and safely parse JSON response data
  static Map<String, dynamic> validateApiResponse(dynamic response) {
    if (response == null) {
      throw ArgumentError('API response is null');
    }

    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw ArgumentError(
      'Invalid API response format: expected Map, got ${response.runtimeType}',
    );
  }

  /// Safely extract nested data from API response
  static T? safelyExtractFromResponse<T>(
    Map<String, dynamic> response,
    String key,
    T Function(dynamic) converter,
  ) {
    final value = response[key];
    if (value == null) return null;

    try {
      return converter(value);
    } catch (e) {
      return null;
    }
  }

  /// Helper for schedule slot casting (common operation)
  static List<Map<String, dynamic>> safeCastScheduleSlots(dynamic value) {
    return safeCastToMapList(value);
  }

  /// Helper for group members casting (common operation)
  static List<Map<String, dynamic>> safeCastGroupMembers(dynamic value) {
    return safeCastToMapList(value);
  }

  /// Helper for child IDs casting (common operation)
  static List<String> safeCastChildIds(dynamic value) {
    return safeCastToStringList(value);
  }

  /// Helper for member IDs casting (common operation)
  static List<String> safeCastMemberIds(dynamic value) {
    return safeCastToStringList(value);
  }
}

/// Extension methods for common casting operations
extension SafeCastingExtensions on dynamic {
  /// Extension method for safe Map casting
  Map<String, dynamic> get asMapStringDynamic {
    return SafeCastingUtils.safeCastToStringDynamicMap(this);
  }

  /// Extension method for safe List<Map> casting
  List<Map<String, dynamic>> get asMapList {
    return SafeCastingUtils.safeCastToMapList(this);
  }

  /// Extension method for safe String list casting
  List<String> get asStringList {
    return SafeCastingUtils.safeCastToStringList(this);
  }

  /// Extension method for safe int list casting
  List<int> get asIntList {
    return SafeCastingUtils.safeCastToIntList(this);
  }
}
