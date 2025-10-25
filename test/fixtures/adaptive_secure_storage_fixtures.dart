/// Test fixtures for AdaptiveSecureStorage testing
///
/// Provides centralized test data following 2025 Flutter testing best practices.
/// All test data is immutable and covers various testing scenarios including
/// boundary conditions, edge cases, and common use cases.
class AdaptiveSecureStorageTestData {
  // Prevent instantiation
  AdaptiveSecureStorageTestData._();

  // Standard test data
  static const String validKey = 'test_token';
  static const String validValue = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';

  // Token test data (common use case)
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String accessTokenValue = 'eyJhbGciOiJIUzI1NiIs.access.token';
  static const String refreshTokenValue = 'eyJhbGciOiJSUzI1NiIs.refresh.token';

  // Edge case test data
  static const String emptyKey = '';
  static const String emptyValue = '';
  static const String nullKey = 'null_key';
  static String? nullValue;

  // Boundary value test data
  static const String maxLengthKey =
      'very_long_key_name_for_boundary_value_testing_that_approaches_maximum_reasonable_length_for_storage_keys_in_mobile_applications_and_should_be_handled_gracefully_by_the_adaptive_secure_storage_implementation_without_causing_any_errors_or_performance_issues';
  static const String specialCharsKey = 'special_!@#\$%^&*()_+-=[]{}|;:,.<>?';
  static const String unicodeKey = 'unicode_key_🔒🔑📱💾🛡️';
  static const String unicodeValue = 'unicode_value_with_emojis_🚀✨🎉🔐';

  // Large data test values
  static final String largeValue = 'x' * 10000; // 10KB
  static final String veryLargeValue = 'y' * 100000; // 100KB

  // Performance test data
  static const int concurrentOperationCount = 50;
  static const int performanceIterations = 100;
  static const Duration maxWriteTime = Duration(milliseconds: 100);
  static const Duration maxReadTime = Duration(milliseconds: 50);

  // Environment test data
  static const List<String> developmentEnvironments = [
    'DEVCONTAINER',
    'CI',
    'GITHUB_ACTIONS',
    'DOCKER_CONTAINER',
    'container',
    'TEST_ENV',
    'FLUTTER_TEST',
  ];

  // Test data builders for complex scenarios
  static Map<String, String> generateTestDataMap(int count) {
    return Map.fromIterables(
      List.generate(count, (index) => 'test_key_$index'),
      List.generate(count, (index) => 'test_value_$index'),
    );
  }

  static List<String> generateConcurrentKeys(int count) {
    return List.generate(count, (index) => 'concurrent_key_$index');
  }

  static List<String> generateConcurrentValues(int count) {
    return List.generate(count, (index) => 'concurrent_value_$index');
  }

  // Test scenario builders
  static Map<String, dynamic> buildWriteTestScenario({
    required String key,
    required String value,
    bool shouldSucceed = true,
  }) {
    return {
      'key': key,
      'value': value,
      'shouldSucceed': shouldSucceed,
      'description':
          'Write operation with key: "$key" and value length: ${value.length}',
    };
  }

  static Map<String, dynamic> buildReadTestScenario({
    required String key,
    String? expectedValue,
    bool shouldExist = true,
  }) {
    return {
      'key': key,
      'expectedValue': expectedValue,
      'shouldExist': shouldExist,
      'description':
          'Read operation for key: "$key" expecting ${shouldExist ? 'value' : 'null'}',
    };
  }

  // Validation helpers
  static bool isValidKey(String? key) {
    return key != null && key.isNotEmpty && key.length <= 255;
  }

  static bool isValidValue(String? value) {
    return value != null; // Allow empty strings, but not null
  }

  // Mock data for different storage states
  static Map<String, String> get emptyStorage => {};

  static Map<String, String> get populatedStorage => {
        validKey: validValue,
        accessTokenKey: accessTokenValue,
        refreshTokenKey: refreshTokenValue,
      };

  static Map<String, String> get largeStorage => generateTestDataMap(100);
}

/// Test data builder for creating AdaptiveSecureStorage test scenarios
class AdaptiveSecureStorageTestBuilder {
  String _key = AdaptiveSecureStorageTestData.validKey;
  String _value = AdaptiveSecureStorageTestData.validValue;
  bool _shouldSucceed = true;
  Duration _maxDuration = const Duration(milliseconds: 100);

  AdaptiveSecureStorageTestBuilder withKey(String key) {
    _key = key;
    return this;
  }

  AdaptiveSecureStorageTestBuilder withValue(String value) {
    _value = value;
    return this;
  }

  AdaptiveSecureStorageTestBuilder shouldSucceed([bool succeed = true]) {
    _shouldSucceed = succeed;
    return this;
  }

  AdaptiveSecureStorageTestBuilder withMaxDuration(Duration duration) {
    _maxDuration = duration;
    return this;
  }

  Map<String, dynamic> build() {
    return {
      'key': _key,
      'value': _value,
      'shouldSucceed': _shouldSucceed,
      'maxDuration': _maxDuration,
      'description':
          'Test scenario: key="$_key", value_length=${_value.length}, should_succeed=$_shouldSucceed',
    };
  }
}
