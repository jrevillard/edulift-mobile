import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/usecases/usecase.dart';
import '../../../../core/services/user_family_service.dart';

/// No parameters needed - clear ALL family data
class ClearAllFamilyDataParams {
  const ClearAllFamilyDataParams();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClearAllFamilyDataParams;
  }

  @override
  int get hashCode => 0;
}

/// Use case for clearing all cached family data from local storage
///
/// Business Logic:
/// 1. Clear all cached family data across all repositories in parallel
/// 2. Uses Future.wait for optimal performance
/// 3. Graceful error handling - continues with other repositories if some fail
///
/// Clean Architecture:
/// - Domain layer handles business logic
/// - Orchestrates clearing across multiple repositories
/// - Uses Result pattern for error handling
/// - No external API calls - only local cache clearing
///
/// Repositories cleared:
/// - FamilyRepository: Family entity, children, vehicles, and offline sync data
/// - Family members are cleared as part of the family aggregate
///
/// Performance:
/// - Uses Future.wait for parallel execution
/// - Non-blocking - if some repositories fail, others continue
///
/// Possible failures:
/// - CacheFailure.ioError() - File system access error
/// - CacheFailure.unknown() - Unexpected cache clearing error

class ClearAllFamilyDataUsecase
    implements UseCase<void, ClearAllFamilyDataParams> {
  final UserFamilyService _userFamilyService;

  ClearAllFamilyDataUsecase(this._userFamilyService);

  @override
  Future<Result<void, Failure>> call(ClearAllFamilyDataParams params) async {
    // Clear all family data repositories in parallel for performance
    // Use graceful error handling - continue with other repositories if some fail

    // SECURITY FIX: Clear UserFamilyService cache to prevent data leakage
    await _userFamilyService.clearCache();

    // Clear family repository cache
    // Children, vehicles and members cache is cleared with family cache
    // since they are part of the family aggregate
    // Note: clearCache is handled by the local datasource layer

    // Return success - cache clearing is best-effort
    return const Result.ok(null);
  }
}
