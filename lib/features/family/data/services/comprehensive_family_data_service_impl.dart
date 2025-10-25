import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/services/comprehensive_family_data_service.dart';
import '../../../../core/domain/usecases/usecase.dart';
import '../../domain/usecases/get_family_usecase.dart' as get_family_usecase;
import '../../domain/usecases/clear_all_family_data_usecase.dart';

/// Implementation of ComprehensiveFamilyDataService that orchestrates family data operations
/// This follows Clean Architecture by implementing core interface in features layer
/// Provides comprehensive caching and clearing across ALL family repositories via use cases

class ComprehensiveFamilyDataServiceImpl
    implements ComprehensiveFamilyDataService {
  final get_family_usecase.GetFamilyUsecase _getFamilyUsecase;
  final ClearAllFamilyDataUsecase _clearAllFamilyDataUsecase;

  ComprehensiveFamilyDataServiceImpl(
    this._getFamilyUsecase,
    this._clearAllFamilyDataUsecase,
  );

  @override
  Future<Result<String?, Failure>> cacheFamilyData() async {
    try {
      // Use GetFamilyUsecase to fetch and cache family data
      final familyDataResult = await _getFamilyUsecase.call(
        get_family_usecase.NoParams(),
      );

      if (familyDataResult.isOk) {
        // Successfully cached family data
        final family = familyDataResult.value!;
        return Result.ok(family.family?.id);
      } else {
        // Handle the case where no family is found
        final error = familyDataResult.error!;
        if (error.code == 'family.not_found') {
          // No family found - this is valid for new users
          return const Result.ok(null);
        } else {
          return Result.err(error);
        }
      }
    } catch (e) {
      // Convert any unexpected exceptions to ApiFailure
      return Result.err(
        ApiFailure.serverError(
          message: 'Failed to cache family data: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void, Failure>> clearFamilyData() async {
    try {
      // OPTIMIZATION FIX: Clear family data WITHOUT fetching it first
      // This prevents API calls with expired tokens during logout
      // Just clear all local caches - no familyId needed for local cleanup
      final clearResult = await _clearAllFamilyDataUsecase.call(
        NoParams(), // Clear all cached data without API calls
      );

      if (clearResult.isOk) {
        return const Result.ok(null);
      } else {
        return Result.err(clearResult.error!);
      }
    } catch (e) {
      // Convert any unexpected exceptions to ApiFailure
      return Result.err(
        ApiFailure.serverError(
          message: 'Failed to clear family data: ${e.toString()}',
        ),
      );
    }
  }
}
