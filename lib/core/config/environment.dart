// EduLift Mobile - Environment Enum
// Centralized environment definitions to avoid inconsistencies

/// Supported application environments
///
/// This enum centralizes all environment names and their aliases
/// to ensure consistency across the application.
enum Environment {
  /// Development environment (localhost services)
  development('development', ['dev']),

  /// Staging environment (staging services)
  staging('staging', ['stage']),

  /// End-to-End testing environment (Docker services via 10.0.2.2)
  e2e('e2e', ['test']),

  /// Production environment (live services)
  production('production', ['prod']);

  const Environment(this.name, this.aliases);

  /// The canonical name for this environment
  final String name;

  /// Alternative names/aliases for this environment
  final List<String> aliases;

  /// Get all valid names for this environment (canonical + aliases)
  List<String> get allNames => [name, ...aliases];

  /// Get environment from string name (case-insensitive)
  ///
  /// Supports both canonical names and aliases:
  /// - 'development', 'dev' → Environment.development
  /// - 'staging', 'stage' → Environment.staging
  /// - 'e2e', 'test' → Environment.e2e
  /// - 'production', 'prod' → Environment.production
  static Environment? fromString(String name) {
    final lowercaseName = name.toLowerCase();

    for (final env in Environment.values) {
      if (env.allNames.map((n) => n.toLowerCase()).contains(lowercaseName)) {
        return env;
      }
    }

    return null;
  }

  /// Check if a string is a valid environment name
  static bool isSupported(String name) {
    return fromString(name) != null;
  }

  /// Get all supported environment names (canonical + aliases)
  static List<String> get allSupportedNames {
    return Environment.values.expand((env) => env.allNames).toList();
  }

  /// Get all canonical environment names
  static List<String> get canonicalNames {
    return Environment.values.map((env) => env.name).toList();
  }

  @override
  String toString() => name;
}
