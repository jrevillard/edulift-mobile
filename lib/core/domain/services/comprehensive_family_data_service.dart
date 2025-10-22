import '../../utils/result.dart';
import '../../errors/failures.dart';

/// Comprehensive service for managing all family-related data caching
/// This interface provides centralized access to family, children, vehicles, and member data
/// Implemented in the family layer following Clean Architecture dependency inversion principle
abstract class ComprehensiveFamilyDataService {
  /// Cache comprehensive family data for the authenticated user
  /// Returns the family ID if user has a family, null if no family (new user)
  /// This method caches data across ALL family repositories (family, children, vehicles, members)
  /// This method should not throw exceptions - all errors handled via Result
  Future<Result<String?, Failure>> cacheFamilyData();

  /// Clear all cached family data (for leave family, logout, etc.)
  /// Clears data across ALL family repositories (family, children, vehicles, members)
  /// This method should not throw exceptions - all errors handled via Result
  Future<Result<void, Failure>> clearFamilyData();
}
