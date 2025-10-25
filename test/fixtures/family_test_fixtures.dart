import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/domain/entities/family.dart';

/// Test fixtures for family-related testing
/// Provides consistent test data across all family tests
class FamilyTestFixtures {
  // Private constructor to prevent instantiation
  FamilyTestFixtures._();

  /// Standard success result with default family
  static Result<Family, ApiFailure> get successResult => Result.ok(
    Family(
      id: 'test-family-id',
      name: 'Test Family',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    ),
  );

  /// Success result with custom family name
  static Result<Family, ApiFailure> successResultForFamily(String name) =>
      Result.ok(
        Family(
          id: 'test-family-${name.toLowerCase().replaceAll(' ', '-')}',
          name: name,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      );

  /// Integration test success result
  static Result<Family, ApiFailure> get integrationSuccessResult => Result.ok(
    Family(
      id: 'integration-test-family-id',
      name: 'Integration Test Family',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    ),
  );

  /// Server error result for testing error scenarios
  static Result<Family, ApiFailure> get serverErrorResult => Result.err(
    ApiFailure.serverError(message: 'Internal server error occurred'),
  );

  /// Creation failed result for testing creation failures
  static Result<Family, ApiFailure> get creationFailedResult => Result.err(
    ApiFailure.validationError(message: 'Family name already exists'),
  );

  /// Network error result
  static Result<Family, ApiFailure> get networkErrorResult =>
      Result.err(ApiFailure.network(message: 'Network connection failed'));

  /// Validation error result
  static Result<Family, ApiFailure> get validationErrorResult => Result.err(
    ApiFailure.validationError(message: 'Invalid family data provided'),
  );
}
