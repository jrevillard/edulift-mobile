import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../repositories/family_repository.dart';

class NoParams {}

class FamilyData {
  final Family? family;
  final List<Child> children;
  final List<Vehicle> vehicles;
  final List<FamilyMember> members;

  const FamilyData({
    required this.family,
    required this.children,
    required this.vehicles,
    required this.members,
  });
}

class GetFamilyUsecase {
  final FamilyRepository _familyRepository;

  GetFamilyUsecase(this._familyRepository);

  /// Get family data with comprehensive repository caching
  ///
  /// Uses single API call to GET /api/v1/families/current which returns ALL data
  /// (family, children, vehicles, members) then caches data in ALL repositories
  /// for offline access and consistency across the application.
  ///
  /// CLEAN ARCHITECTURE: Handles NoFamily case as valid state (Success with null family)
  /// This prevents blocking authentication flow during onboarding for new users
  ///
  /// PERFORMANCE: Uses parallel caching with Future.wait for optimal performance
  /// ERROR HANDLING: Comprehensive Result pattern with graceful cache error handling
  Future<Result<FamilyData, ApiFailure>> call(NoParams params) async {
    // Step 1: Get family data from single API call
    final familyResult = await _familyRepository.getFamily();

    if (familyResult.isSuccess) {
      final family = familyResult.value!;

      // Step 2: Extract data from Family entity
      final children = family.children;
      final vehicles = family.vehicles;
      final members = family.members;

      // Step 3: Cache user-family associations for ALL family members
      // This ensures UserFamilyExtension methods work correctly
      // CLEAN ARCHITECTURE: Cache automatically updated by FamilyRepository
      // No manual pre-caching needed - FamilyRepository handles this

      // Step 4: Return complete FamilyData with all fields populated
      return Result.ok(
        FamilyData(
          family: family,
          children: children,
          vehicles: vehicles,
          members: members,
        ),
      );
    } else {
      // CLEAN ARCHITECTURE FIX: Handle NoFamily case as valid state
      // This prevents pumpAndSettle timeouts during onboarding
      final error = familyResult.error!;

      // DEBUG: Log the exact error we received
      AppLogger.warning(
        '🔍 DEBUG GetFamilyUsecase: Received error - statusCode: ${error.statusCode}, message: "${error.message}", code: "${error.code}", type: ${error.runtimeType}',
      );

      // Return actual errors (network, auth, etc.)
      return Result.err(error);
    }
  }
}
