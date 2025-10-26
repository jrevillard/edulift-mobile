import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/services/comprehensive_family_data_service.dart';
import '../../../../core/domain/usecases/usecase.dart';
import '../repositories/family_repository.dart';

/// Parameters for leaving family
class LeaveFamilyParams {
  final String familyId;

  const LeaveFamilyParams({required this.familyId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaveFamilyParams && other.familyId == familyId;
  }

  @override
  int get hashCode => familyId.hashCode;
}

/// Result of leaving family operation
class LeaveFamilyResult {
  /// Whether user needs to be redirected to onboarding
  final bool requiresOnboarding;

  const LeaveFamilyResult({required this.requiresOnboarding});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaveFamilyResult &&
        other.requiresOnboarding == requiresOnboarding;
  }

  @override
  int get hashCode => requiresOnboarding.hashCode;
}

/// Use case for leaving a family (current user leaves their family)
///
/// Business Logic:
/// 1. Call leave family API (removes current user from family)
/// 2. Clear all cached family data locally
/// 3. Return result indicating user needs onboarding
///
/// Clean Architecture:
/// - Domain layer handles business logic
/// - No presentation concerns (navigation handled by presentation layer)
/// - Uses ComprehensiveFamilyDataService for data clearing
///
/// Possible failures:
/// - ApiFailure.unauthorized() - User not authenticated
/// - ApiFailure.notFound() - User not in a family
/// - ApiFailure.validationError() - Cannot leave (e.g., last admin)
/// - ApiFailure.serverError() - Backend processing error

class LeaveFamilyUsecase
    implements UseCase<LeaveFamilyResult, LeaveFamilyParams> {
  final FamilyRepository _familyRepository;
  final ComprehensiveFamilyDataService _familyDataService;

  LeaveFamilyUsecase(this._familyRepository, this._familyDataService);

  @override
  Future<Result<LeaveFamilyResult, Failure>> call(
    LeaveFamilyParams params,
  ) async {
    // OPTIMIZATION FIX: Use provided familyId
    // Step 1: Call leave family API
    final leaveResult = await _familyRepository.leaveFamily(
      familyId: params.familyId,
    );

    if (leaveResult.isOk) {
      // Step 2: Clear all cached family data locally
      final clearResult = await _familyDataService.clearFamilyData();

      if (clearResult.isOk) {
        // Step 3: Return result indicating user needs onboarding
        return const Result.ok(LeaveFamilyResult(requiresOnboarding: true));
      } else {
        return Result.err(clearResult.error!);
      }
    } else {
      return Result.err(leaveResult.error!);
    }
  }
}
