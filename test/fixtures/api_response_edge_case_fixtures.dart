// API Response Edge Case Test Fixtures
// Comprehensive test fixtures for API response edge cases and data scenarios
// Following FLUTTER_TESTING_RESEARCH_2025.md fixture management patterns

/// Centralized fixture data for API response edge case testing
class ApiResponseEdgeCaseFixtures {
  // ========================================
  // EMPTY ARRAY RESPONSE FIXTURES
  // ========================================

  /// Empty array response that commonly causes type casting errors
  static const Map<String, dynamic> emptyArrayResponse = {
    'success': true,
    'data': <dynamic>[],
    'message': 'Success with empty array',
  };

  /// Response with multiple empty arrays in nested structure
  static const Map<String, dynamic> nestedEmptyArraysResponse = {
    'success': true,
    'data': {
      'id': 'family-123',
      'name': 'Test Family',
      'members': <dynamic>[],
      'children': <dynamic>[],
      'vehicles': <dynamic>[],
      'groups': <dynamic>[],
      'invitations': <dynamic>[],
      'settings': {'notifications': <dynamic>[], 'preferences': <dynamic>[]},
      'stats': {'activities': <dynamic>[], 'metrics': <dynamic>[]},
    },
  };

  /// Array containing empty objects
  static const Map<String, dynamic> arrayWithEmptyObjectsResponse = {
    'success': true,
    'data': [<String, dynamic>{}, <String, dynamic>{}, <String, dynamic>{}],
  };

  // ========================================
  // NULL DATA RESPONSE FIXTURES
  // ========================================

  /// Response with null data field (common API edge case)
  static const Map<String, dynamic> nullDataResponse = {
    'success': true,
    'data': null,
    'message': 'Operation completed successfully',
  };

  /// Response with null nested fields
  static const Map<String, dynamic> nullNestedFieldsResponse = {
    'success': true,
    'data': {
      'id': 'family-123',
      'name': null,
      'members': null,
      'children': null,
      'vehicles': null,
      'settings': null,
      'stats': null,
      'permissions': null,
    },
  };

  /// Response with mixed null and valid fields
  static const Map<String, dynamic> mixedNullValidResponse = {
    'success': true,
    'data': {
      'id': 'family-123',
      'name': 'Valid Family Name',
      'members': null,
      'children': [
        {'id': 'child-1', 'name': 'Valid Child', 'age': null},
      ],
      'vehicles': null,
    },
  };

  /// Completely null response fields
  static const Map<String, dynamic> completelyNullResponse = {
    'success': null,
    'data': null,
    'message': null,
    'error': null,
    'statusCode': null,
  };

  // ========================================
  // TYPE MISMATCH RESPONSE FIXTURES
  // ========================================

  /// String data when Map<String, dynamic> expected
  static const Map<String, dynamic> stringDataResponse = {
    'success': true,
    'data': 'This should be an object but is a string',
  };

  /// Numeric data when object expected
  static const Map<String, dynamic> numericDataResponse = {
    'success': true,
    'data': 42,
  };

  /// Boolean data when object expected
  static const Map<String, dynamic> booleanDataResponse = {
    'success': true,
    'data': false,
  };

  /// Array data when object expected
  static const Map<String, dynamic> arrayDataResponse = {
    'success': true,
    'data': [1, 2, 3, 'mixed', true, null],
  };

  /// Wrong field types in nested objects
  static const Map<String, dynamic> wrongNestedTypesResponse = {
    'success': true,
    'data': {
      'id': 123, // Should be string
      'name': ['Test', 'Family'], // Should be string
      'members': 'not an array', // Should be array
      'children': {
        'count': 'two', // Should be number
        'list': 'not an array', // Should be array
      },
      'vehicles': true, // Should be array
    },
  };

  // ========================================
  // MALFORMED JSON RESPONSE FIXTURES
  // ========================================

  /// Missing required fields
  static const Map<String, dynamic> missingFieldsResponse = {
    'success': true,
    // Missing 'data' field entirely
    'message': 'Success but no data field',
  };

  /// Wrong field names
  static const Map<String, dynamic> wrongFieldNamesResponse = {
    'isSuccessful': true, // Should be 'success'
    'payload': {
      // Should be 'data'
      'id': 'family-123',
      'title': 'Test Family', // Should be 'name'
    },
    'msg': 'Success', // Should be 'message'
  };

  /// Empty JSON object
  static const Map<String, dynamic> emptyJsonResponse = <String, dynamic>{};

  /// Extra unexpected fields
  static const Map<String, dynamic> extraFieldsResponse = {
    'success': true,
    'data': {'id': 'family-123', 'name': 'Test Family'},
    'message': 'Success',
    'deprecated_field': 'Should be ignored',
    'internal_debug': {'query_time': '50ms', 'cache_hit': true},
    'api_version': '2.1.0',
    'server_timestamp': '2024-01-15T10:30:00Z',
  };

  // ========================================
  // ERROR RESPONSE FIXTURES
  // ========================================

  /// Error response with null error message
  static const Map<String, dynamic> nullErrorMessageResponse = {
    'success': false,
    'data': null,
    'error': null,
    'statusCode': 400,
  };

  /// Conflicting success and error indicators
  static const Map<String, dynamic> conflictingSuccessErrorResponse = {
    'success': true,
    'data': {'id': 'family-123', 'name': 'Test Family'},
    'error': 'Warning: This API endpoint is deprecated',
    'statusCode': 200,
  };

  /// Multiple error fields
  static const Map<String, dynamic> multipleErrorFieldsResponse = {
    'success': false,
    'data': null,
    'error': 'Primary error message',
    'errorCode': 'VALIDATION_FAILED',
    'errorDetails': {'field': 'name', 'reason': 'Name cannot be empty'},
    'errors': ['Name is required', 'Name must be at least 2 characters'],
    'statusCode': 400,
  };

  // ========================================
  // REALISTIC API SCENARIOS
  // ========================================

  /// Family response with all empty collections (realistic API scenario)
  static const Map<String, dynamic> familyWithEmptyCollectionsResponse = {
    'success': true,
    'data': {
      'id': 'family-123',
      'name': 'New Family',
      'createdAt': '2024-01-15T10:30:00Z',
      'updatedAt': '2024-01-15T10:30:00Z',
      'ownerId': 'user-456',
      'members': <dynamic>[],
      'children': <dynamic>[],
      'vehicles': <dynamic>[],
      'groups': <dynamic>[],
      'invitations': <dynamic>[],
      'settings': {
        'timezone': 'America/New_York',
        'language': 'en',
        'notifications': <dynamic>[],
      },
      'stats': {
        'memberCount': 1,
        'childrenCount': 0,
        'vehicleCount': 0,
        'activities': <dynamic>[],
      },
    },
  };

  /// Child response with minimal data (realistic API scenario)
  static const Map<String, dynamic> childWithMinimalDataResponse = {
    'success': true,
    'data': {
      'id': 'child-123',
      'name': 'John',
      'familyId': 'family-123',
      'createdAt': '2024-01-15T10:30:00Z',
      'updatedAt': '2024-01-15T10:30:00Z',
      // Optional fields are missing (not null, missing entirely)
      'assignments': <dynamic>[],
      'schedules': <dynamic>[],
    },
  };

  /// Server error response with detailed error info
  static const Map<String, dynamic> serverErrorDetailedResponse = {
    'success': false,
    'data': null,
    'error': 'Internal server error',
    'statusCode': 500,
    'message': 'An unexpected error occurred while processing your request',
    'errorId': 'err_1234567890',
    'timestamp': '2024-01-15T10:30:00Z',
    'details': {
      'service': 'family-api',
      'endpoint': '/api/v1/families/current',
      'requestId': 'req_abcdef123456',
    },
  };

  // ========================================
  // NETWORK ERROR SIMULATION DATA
  // ========================================

  /// Network timeout simulation
  static const Map<String, dynamic> networkTimeoutResponse = {
    'success': false,
    'error': 'Request timeout',
    'statusCode': 0, // Network error code
    'message': 'The request timed out after 30 seconds',
  };

  /// Connection refused simulation
  static const Map<String, dynamic> connectionRefusedResponse = {
    'success': false,
    'error': 'Connection refused',
    'statusCode': 0,
    'message': 'Could not connect to the server',
  };

  /// DNS resolution failure simulation
  static const Map<String, dynamic> dnsFailureResponse = {
    'success': false,
    'error': 'DNS resolution failed',
    'statusCode': 0,
    'message': 'Could not resolve server hostname',
  };

  // ========================================
  // PERFORMANCE EDGE CASES
  // ========================================

  /// Large response with many empty arrays (performance test)
  static Map<String, dynamic> largeResponseWithEmptyArrays() {
    return {
      'success': true,
      'data': {
        'id': 'family-123',
        'name': 'Large Family',
        'members': List.generate(100, (i) => <String, dynamic>{}),
        'children': <dynamic>[],
        'vehicles': <dynamic>[],
        'groups': List.generate(
          50,
          (i) => {
            'id': 'group-$i',
            'name': 'Group $i',
            'members': <dynamic>[],
            'schedules': <dynamic>[],
          },
        ),
        'history': List.generate(
          1000,
          (i) => {
            'id': 'event-$i',
            'timestamp': '2024-01-${(i % 30) + 1}T10:30:00Z',
            'data': <dynamic>[],
          },
        ),
      },
    };
  }

  /// Deeply nested empty structures
  static const Map<String, dynamic> deeplyNestedEmptyResponse = {
    'success': true,
    'data': {
      'level1': {
        'level2': {
          'level3': {
            'level4': {
              'level5': {
                'data': <dynamic>[],
                'items': <dynamic>[],
                'children': <dynamic>[],
              },
            },
          },
        },
      },
    },
  };
}

/// Helper class for creating test scenarios with fixtures
class ApiResponseTestScenarios {
  /// Create a scenario that tests all empty array edge cases
  static List<Map<String, dynamic>> allEmptyArrayScenarios() {
    return [
      ApiResponseEdgeCaseFixtures.emptyArrayResponse,
      ApiResponseEdgeCaseFixtures.nestedEmptyArraysResponse,
      ApiResponseEdgeCaseFixtures.arrayWithEmptyObjectsResponse,
      ApiResponseEdgeCaseFixtures.familyWithEmptyCollectionsResponse,
    ];
  }

  /// Create a scenario that tests all null data edge cases
  static List<Map<String, dynamic>> allNullDataScenarios() {
    return [
      ApiResponseEdgeCaseFixtures.nullDataResponse,
      ApiResponseEdgeCaseFixtures.nullNestedFieldsResponse,
      ApiResponseEdgeCaseFixtures.mixedNullValidResponse,
      ApiResponseEdgeCaseFixtures.completelyNullResponse,
    ];
  }

  /// Create a scenario that tests all type mismatch cases
  static List<Map<String, dynamic>> allTypeMismatchScenarios() {
    return [
      ApiResponseEdgeCaseFixtures.stringDataResponse,
      ApiResponseEdgeCaseFixtures.numericDataResponse,
      ApiResponseEdgeCaseFixtures.booleanDataResponse,
      ApiResponseEdgeCaseFixtures.arrayDataResponse,
      ApiResponseEdgeCaseFixtures.wrongNestedTypesResponse,
    ];
  }

  /// Create a scenario that tests all malformed JSON cases
  static List<Map<String, dynamic>> allMalformedJsonScenarios() {
    return [
      ApiResponseEdgeCaseFixtures.missingFieldsResponse,
      ApiResponseEdgeCaseFixtures.wrongFieldNamesResponse,
      ApiResponseEdgeCaseFixtures.emptyJsonResponse,
      ApiResponseEdgeCaseFixtures.extraFieldsResponse,
    ];
  }

  /// Create a scenario that tests all error response cases
  static List<Map<String, dynamic>> allErrorResponseScenarios() {
    return [
      ApiResponseEdgeCaseFixtures.nullErrorMessageResponse,
      ApiResponseEdgeCaseFixtures.conflictingSuccessErrorResponse,
      ApiResponseEdgeCaseFixtures.multipleErrorFieldsResponse,
      ApiResponseEdgeCaseFixtures.serverErrorDetailedResponse,
    ];
  }

  /// Create a scenario with realistic API responses
  static List<Map<String, dynamic>> realisticApiScenarios() {
    return [
      ApiResponseEdgeCaseFixtures.familyWithEmptyCollectionsResponse,
      ApiResponseEdgeCaseFixtures.childWithMinimalDataResponse,
      ApiResponseEdgeCaseFixtures.serverErrorDetailedResponse,
    ];
  }

  /// Create a scenario that tests network error simulations
  static List<Map<String, dynamic>> networkErrorScenarios() {
    return [
      ApiResponseEdgeCaseFixtures.networkTimeoutResponse,
      ApiResponseEdgeCaseFixtures.connectionRefusedResponse,
      ApiResponseEdgeCaseFixtures.dnsFailureResponse,
    ];
  }

  /// Get all edge case scenarios combined
  static List<Map<String, dynamic>> allEdgeCaseScenarios() {
    return [
      ...allEmptyArrayScenarios(),
      ...allNullDataScenarios(),
      ...allTypeMismatchScenarios(),
      ...allMalformedJsonScenarios(),
      ...allErrorResponseScenarios(),
      ...networkErrorScenarios(),
    ];
  }
}
