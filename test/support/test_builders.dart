// Test Builders and Fixtures (2025 Best Practices)
//
// Provides comprehensive test data builders following the Builder pattern:
// - Domain entity builders
// - API response builders
// - State builders
// - Error scenario builders
// - Performance test data builders

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/domain/entities/family.dart';

/// Base builder class for test data creation
abstract class TestBuilder<T> {
  T build();

  /// Reset builder to default values
  void reset();
}

/// User entity builder for tests
class UserTestBuilder implements TestBuilder<User> {
  String _id = 'test-user-123';
  String _email = 'test@example.com';
  String _name = 'Test User';
  DateTime? _createdAt;
  DateTime? _updatedAt;

  /// Set user ID
  UserTestBuilder withId(String id) {
    _id = id;
    return this;
  }

  /// Set user email
  UserTestBuilder withEmail(String email) {
    _email = email;
    return this;
  }

  /// Set user name
  UserTestBuilder withName(String name) {
    _name = name;
    return this;
  }

  /// Set creation date
  UserTestBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  /// Set update date
  UserTestBuilder withUpdatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  /// Build authenticated admin user
  UserTestBuilder asAdmin() {
    return withId(
      'admin-user-123',
    ).withEmail('admin@example.com').withName('Admin User');
  }

  /// Build regular family member
  UserTestBuilder asFamilyMember() {
    return withId(
      'member-user-123',
    ).withEmail('member@example.com').withName('Family Member');
  }

  /// Build user with validation issues
  UserTestBuilder withValidationIssues() {
    return withEmail('invalid-email').withName('');
  }

  @override
  User build() {
    final now = DateTime.now();
    return User(
      id: _id,
      email: _email,
      name: _name,
      timezone: 'UTC',
      createdAt: _createdAt ?? now,
      updatedAt: _updatedAt ?? now,
    );
  }

  @override
  void reset() {
    _id = 'test-user-123';
    _email = 'test@example.com';
    _name = 'Test User';
    _createdAt = null;
    _updatedAt = null;
  }
}

/// Family entity builder for tests
class FamilyTestBuilder implements TestBuilder<Family> {
  String _id = 'test-family-123';
  String _name = 'Test Family';
  DateTime? _createdAt;
  DateTime? _updatedAt;
  String? _description;

  /// Set family ID
  FamilyTestBuilder withId(String id) {
    _id = id;
    return this;
  }

  /// Set family name
  FamilyTestBuilder withName(String name) {
    _name = name;
    return this;
  }

  /// Set creation date
  FamilyTestBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  /// Set update date
  FamilyTestBuilder withUpdatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  /// Set family description
  FamilyTestBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  /// Build large family for performance testing
  FamilyTestBuilder asLargeFamily() {
    return withName(
      'Large Test Family',
    ).withDescription('Family with many members for testing');
  }

  /// Build family with description
  FamilyTestBuilder withComplexSettings() {
    return withDescription(
      'Family with complex configuration for testing various scenarios',
    );
  }

  @override
  Family build() {
    return Family(
      id: _id,
      name: _name,
      createdAt: _createdAt ?? DateTime.now(),
      updatedAt: _updatedAt ?? DateTime.now(),
      description: _description,
    );
  }

  @override
  void reset() {
    _id = 'test-family-123';
    _name = 'Test Family';
    _createdAt = null;
    _updatedAt = null;
    _description = null;
  }
}

/// Result builder for success/failure scenarios
class ResultTestBuilder<T, E extends Exception> {
  T? _successValue;
  E? _errorValue;

  /// Build successful result
  ResultTestBuilder<T, E> withSuccess(T value) {
    _successValue = value;
    _errorValue = null;
    return this;
  }

  /// Build error result
  ResultTestBuilder<T, E> withError(E error) {
    _errorValue = error;
    _successValue = null;
    return this;
  }

  /// Build result
  Result<T, E> build() {
    if (_successValue != null) {
      return Result.ok(_successValue!);
    }
    if (_errorValue != null) {
      return Result.err(_errorValue!);
    }
    throw StateError(
      'ResultTestBuilder must have either success or error value',
    );
  }
}

/// Failure builder for error scenarios
class FailureTestBuilder {
  String _message = 'Test error';
  int _statusCode = 400;
  Map<String, dynamic> _details = {};

  /// Set error message
  FailureTestBuilder withMessage(String message) {
    _message = message;
    return this;
  }

  /// Set status code
  FailureTestBuilder withStatusCode(int statusCode) {
    _statusCode = statusCode;
    return this;
  }

  /// Set error details
  FailureTestBuilder withDetails(Map<String, dynamic> details) {
    _details = Map.from(details);
    return this;
  }

  /// Build network failure
  NoConnectionFailure buildNetworkFailure() {
    return NoConnectionFailure(
      message: _message,
      statusCode: _statusCode,
      details: _details,
    );
  }

  /// Build API failure
  ApiFailure buildApiFailure() {
    return ApiFailure(
      message: _message,
      statusCode: _statusCode,
      details: _details,
    );
  }

  /// Build validation failure
  ValidationFailure buildValidationFailure() {
    return ValidationFailure(
      message: _message,
      statusCode: _statusCode,
      details: _details,
    );
  }

  /// Build server error (500)
  FailureTestBuilder asServerError() {
    return withStatusCode(500).withMessage('Internal server error');
  }

  /// Build not found error (404)
  FailureTestBuilder asNotFound() {
    return withStatusCode(404).withMessage('Resource not found');
  }

  /// Build unauthorized error (401)
  FailureTestBuilder asUnauthorized() {
    return withStatusCode(401).withMessage('Unauthorized access');
  }

  /// Build validation error (422)
  FailureTestBuilder asValidationError() {
    return withStatusCode(422).withMessage('Validation failed').withDetails({
      'field_errors': {
        'name': ['Name is required'],
        'email': ['Invalid email format'],
      },
    });
  }
}

/// Performance test data builder
class PerformanceTestDataBuilder {
  /// Generate large list of users for performance testing
  static List<User> generateUsers(int count) {
    return List.generate(count, (index) {
      return UserTestBuilder()
          .withId('user-$index')
          .withEmail('user$index@example.com')
          .withName('User $index')
          .build();
    });
  }

  /// Generate large list of families for performance testing
  static List<Family> generateFamilies(int count) {
    return List.generate(count, (index) {
      return FamilyTestBuilder()
          .withId('family-$index')
          .withName('Family $index')
          .withDescription('Generated family $index for performance testing')
          .build();
    });
  }

  /// Generate complex nested data structure
  static Map<String, dynamic> generateComplexData(int depth) {
    if (depth == 0) {
      return {'value': 'leaf-data'};
    }

    return {
      'level': depth,
      'nested': generateComplexData(depth - 1),
      'list': List.generate(5, (index) => 'item-$depth-$index'),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Convenience functions for quick test data creation
class TestBuilders {
  /// Quick user builder
  static UserTestBuilder user() => UserTestBuilder();

  /// Quick family builder
  static FamilyTestBuilder family() => FamilyTestBuilder();

  /// Quick success result builder
  static ResultTestBuilder<T, E> success<T, E extends Exception>(T value) {
    return ResultTestBuilder<T, E>().withSuccess(value);
  }

  /// Quick error result builder
  static ResultTestBuilder<T, E> error<T, E extends Exception>(E error) {
    return ResultTestBuilder<T, E>().withError(error);
  }

  /// Quick failure builder
  static FailureTestBuilder failure() => FailureTestBuilder();
}

void main() {
  // Test builders are support utilities - no direct tests needed
  // These builders are used by other test files
  group('Test Builders', () {
    test('should be available for import', () {
      // This test just verifies the file compiles correctly
      expect(TestBuilders.user, isA<Function>());
      expect(TestBuilders.family, isA<Function>());
    });
  });
}
