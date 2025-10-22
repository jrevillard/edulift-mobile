// =============================================================================
// REPOSITORY PROVIDERS - ALL REPOSITORY IMPLEMENTATIONS
// =============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository interfaces
import '../../../features/family/domain/repositories/family_repository.dart';
import '../../../features/family/domain/repositories/family_invitation_repository.dart';
// Note: Some repository interfaces don't exist yet, using stubs

// Repository implementations
import '../../../features/family/data/repositories/family_repository_impl.dart';
import '../../../features/family/data/repositories/family_invitation_repository_impl.dart';
import '../../../features/groups/domain/repositories/group_repository.dart';
import '../../../features/groups/data/repositories/groups_repository_impl.dart';
import '../../../features/schedule/data/repositories/schedule_repository_impl.dart';
import '../../../features/schedule/domain/repositories/schedule_repository.dart';

// Data providers
import 'foundation/network_providers.dart';
import 'data/datasource_providers.dart';

// Specific API clients removed - using providers from foundation/network_providers.dart

part 'repository_providers.g.dart';

// =============================================================================
// API CLIENT PROVIDERS
// =============================================================================

// BaseApiClient provider removed - use specific API clients instead
// @riverpod
// BaseApiClient baseApiClient(Ref ref) {
//   final dio = ref.watch(apiDioProvider);
//   return BaseApiClient.create(dio);
// }

// scheduleApiClient provider moved to foundation/network_providers.dart to avoid duplication

// Use validation service from storage providers

// =============================================================================
// AUTH REPOSITORIES
// =============================================================================

// Note: AuthRepository interface doesn't exist, using stub for now

// =============================================================================
// FAMILY REPOSITORIES
// =============================================================================

@riverpod
FamilyRepository familyRepository(Ref ref) {
  // Migrated to NetworkErrorHandler - networkInfo no longer needed
  return FamilyRepositoryImpl(
    remoteDataSource: ref.watch(familyRemoteDatasourceProvider),
    localDataSource: ref.watch(familyLocalDatasourceProvider),
    invitationsRepository: ref.watch(invitationRepositoryProvider),
    networkErrorHandler: ref.watch(networkErrorHandlerProvider),
  );
}

@riverpod
InvitationRepository invitationRepository(Ref ref) {
  // Migrated to NetworkErrorHandler - networkInfo no longer needed
  return InvitationRepositoryImpl(
    remoteDataSource: ref.watch(familyRemoteDatasourceProvider),
    localDataSource: ref.watch(familyLocalDatasourceProvider),
    networkErrorHandler: ref.watch(networkErrorHandlerProvider),
  );
}

// SeatOverrideRepository removed - was dead code (100% mock)
// Seat override functionality is now handled directly in Schedule feature

// =============================================================================
// GROUP REPOSITORIES
// =============================================================================

@riverpod
GroupRepository groupRepository(Ref ref) {
  // Migrated to NetworkErrorHandler - networkInfo no longer needed
  return GroupsRepositoryImpl(
    ref.watch(groupRemoteDatasourceProvider),
    ref.watch(groupLocalDatasourceProvider),
    ref.watch(networkErrorHandlerProvider),
  );
}

// Removed duplicate groupScheduleRepository - use scheduleRepository instead

// =============================================================================
// SCHEDULE REPOSITORIES
// =============================================================================

@riverpod
GroupScheduleRepository scheduleRepository(Ref ref) {
  // Migrated to NetworkErrorHandler - networkInfo no longer needed
  return ScheduleRepositoryImpl(
    remoteDataSource: ref.watch(scheduleRemoteDatasourceProvider),
    localDataSource: ref.watch(scheduleLocalDatasourceProvider),
    networkErrorHandler: ref.watch(networkErrorHandlerProvider),
  );
}

// =============================================================================
// STUB IMPLEMENTATIONS (MINIMAL - ONLY FOR MISSING DATASOURCES)
// =============================================================================
// All stubs removed - repositories use real implementations or are deleted
