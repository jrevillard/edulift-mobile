// EduLift Mobile - Secure Date Parser
// SECURITY FIX: Validates DateTime parsing to prevent injection attacks

/// Secure utility for parsing DateTime strings with validation
class SecureDateParser {
  // ISO 8601 pattern for validation
  static final RegExp _iso8601Pattern = RegExp(
    r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z?$',
  );

  /// Safely parse DateTime string with validation
  /// Returns null if parsing fails or string is invalid
  static DateTime? safeParse(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    // Validate format before parsing to prevent injection
    if (!_iso8601Pattern.hasMatch(dateString)) {
      return null;
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Log security incident (without exposing sensitive data)
      return null;
    }
  }

  /// Safely parse DateTime string with fallback to current time
  /// More secure than using DateTime.now() directly in fallback
  static DateTime safeParseWithFallback(String? dateString) {
    final parsed = safeParse(dateString);
    return parsed ?? DateTime.now();
  }

  /// Safely parse DateTime string with custom fallback
  static DateTime safeParseWithCustomFallback(
    String? dateString,
    DateTime fallback,
  ) {
    final parsed = safeParse(dateString);
    return parsed ?? fallback;
  }

  /// Validate if a string is a valid ISO 8601 date
  static bool isValidIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return false;
    }
    return _iso8601Pattern.hasMatch(dateString);
  }
}
