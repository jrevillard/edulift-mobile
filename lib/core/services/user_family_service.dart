// =============================================================================
// USER-FAMILY SERVICE - CLEAN ARCHITECTURE BRIDGE (SIMPLIFIED)
// =============================================================================
// Bridge service between User and Family domains
// Maintains clean architecture by providing user-centric family status checks
// Delegates to FamilyRepository for offline-first family data

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/providers/repository_providers.dart';
import 'package:edulift/core/domain/entities/family.dart' as entities;
import '../utils/app_logger.dart';

part 'user_family_service.g.dart';

/// Service that bridges User and Family domains while maintaining clean architecture
/// Provides user-centric view of family status without violating domain boundaries
/// SIMPLIFIED: Delegates all operations to FamilyRepository
class UserFamilyService {
  final Ref _ref;

  UserFamilyService(this._ref);

  /// Check if user has a family (offline-first)
  /// Delegates to FamilyRepository which handles offline/online strategy
  ///
  /// FIX: Removed read(familyProvider) optimization to avoid circular dependency
  /// Repository already has its own cache (offline-first pattern)
  ///
  /// BUGFIX: Throws exception for auth errors (401/403) so router knows
  /// it's token expiry, not "no family". Router will redirect to login.
  Future<bool> hasFamily(String? userId) async {
    if (userId == null) return false;

    // ✅ FIX: Removed read(familyProvider) - causes circular dependency
    // Repository already handles caching internally (offline-first)
    AppLogger.debug('[UserFamilyService] hasFamily: Fetching from repository (offline-first with cache)');

    // Delegate to FamilyRepository (offline-first pattern with built-in cache)
    final familyResult = await _ref.read(familyRepositoryProvider).getCurrentFamily();

    // BUGFIX: Check if this is an auth error (token expired/invalid)
    // If so, throw exception so router knows to redirect to login, not onboarding
    if (familyResult.isErr) {
      final error = familyResult.error!;
      if (error.code == 'family.auth_failed' ||
          (error.statusCode == 401 || error.statusCode == 403)) {
        // This is an auth error - let it bubble up
        // Router will detect this and redirect to login instead of onboarding
        throw Exception('Authentication failed: ${error.code}');
      }
      // Other errors (like "not found") mean user genuinely has no family
      return false;
    }

    return familyResult.value != null;
  }

  /// Get user's role in current family (if any)
  /// Returns null if no family or user not authenticated
  ///
  /// FIX: Removed read(familyProvider) optimization to avoid circular dependency
  Future<String?> getUserFamilyRole(String? userId) async {
    if (userId == null) return null;

    // ✅ FIX: Removed read(familyProvider) - causes circular dependency
    // Repository already handles caching internally (offline-first)
    AppLogger.debug('[UserFamilyService] getUserFamilyRole: Fetching from repository (offline-first with cache)');

    final familyResult = await _ref.read(familyRepositoryProvider).getCurrentFamily();
    if (familyResult.isErr || familyResult.value == null) return null;

    final family = familyResult.value!;
    try {
      final member = family.members.firstWhere((m) => m.userId == userId);
      return member.role.toString().split('.').last;
    } catch (e) {
      return null; // User not in family
    }
  }

  /// Get user's family member object (if any)
  /// Returns null if no family or user not authenticated
  ///
  /// FIX: Removed read(familyProvider) optimization to avoid circular dependency
  Future<entities.FamilyMember?> getUserFamilyMember(String? userId) async {
    if (userId == null) return null;

    // ✅ FIX: Removed read(familyProvider) - causes circular dependency
    // Repository already handles caching internally (offline-first)
    AppLogger.debug('[UserFamilyService] getUserFamilyMember: Fetching from repository (offline-first with cache)');

    final familyResult = await _ref.read(familyRepositoryProvider).getCurrentFamily();
    if (familyResult.isErr || familyResult.value == null) return null;

    final family = familyResult.value!;
    try {
      return family.members.firstWhere((m) => m.userId == userId);
    } catch (e) {
      return null; // User not in family
    }
  }


  /// Clear cache to force fresh data on next request
  Future<void> clearCache([String? userId]) async {
    // Delegate to FamilyRepository cache clear if needed
    // This method exists for API compatibility
  }
}

/// Provider for UserFamilyService
/// Maintains existing API surface while delegating to FamilyRepository internally
@riverpod
UserFamilyService userFamilyService(Ref ref) {
  return UserFamilyService(ref);
}

/// Cached user family status provider
/// Provides the same API as before but now delegates to FamilyRepository
@riverpod
Future<bool> cachedUserFamilyStatus(Ref ref, String? userId) async {
  if (userId == null) return false;

  final service = ref.watch(userFamilyServiceProvider);
  return await service.hasFamily(userId);
}