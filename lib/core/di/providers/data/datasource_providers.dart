// =============================================================================
// DATA LAYER DATASOURCE PROVIDERS
// =============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/family/data/datasources/family_remote_datasource_impl.dart';
import '../../../../features/family/data/datasources/persistent_local_datasource.dart';
// REMOVED: children_remote_datasource.dart - children are now handled via FamilyRemoteDataSourceImpl
// REMOVED: family_members_remote_datasource.dart - was obsolete stub implementation
import '../../../../features/schedule/data/datasources/schedule_remote_datasource_impl.dart';
import '../../../../features/schedule/data/datasources/schedule_local_datasource_impl.dart';
import '../../../../features/groups/data/datasources/group_remote_datasource_impl.dart';
import '../../../../features/groups/data/datasources/group_local_datasource_impl.dart';
// Dashboard data sources are now handled via API client directly
import '../../../../core/storage/auth_local_datasource.dart';
import '../foundation/network_providers.dart';
import '../foundation/storage_providers.dart';

part 'datasource_providers.g.dart';

// =============================================================================
// AUTH DATASOURCES
// =============================================================================

/// AuthLocalDatasource provider
@riverpod
AuthLocalDatasource authLocalDatasource(Ref ref) {
  final adaptiveStorageService = ref.watch(adaptiveStorageServiceProvider);
  return AuthLocalDatasource(adaptiveStorageService);
}

// =============================================================================
// FAMILY DATASOURCES
// =============================================================================

/// FamilyRemoteDataSource provider
@riverpod
FamilyRemoteDataSourceImpl familyRemoteDatasource(Ref ref) {
  final familyApiClient = ref.watch(familyApiClientProvider);
  return FamilyRemoteDataSourceImpl(familyApiClient);
}

/// FamilyLocalDataSource provider
@riverpod
PersistentLocalDataSource familyLocalDatasource(Ref ref) {
  return PersistentLocalDataSource();
}

// REMOVED: ChildrenRemoteDataSourceImpl provider - children are now handled via FamilyRemoteDataSourceImpl.getFamilyChildren()

// REMOVED: FamilyMembersRemoteDataSourceImpl providers - were obsolete stub implementations
// Family members are now handled through FamilyRemoteDataSourceImpl.getFamilyMembers()
// which extracts members from the family object returned by /families/current

// SeatOverrideRemoteDataSource removed - not implemented yet

/// ScheduleRemoteDataSource provider
@riverpod
ScheduleRemoteDataSourceImpl scheduleRemoteDatasource(Ref ref) {
  final scheduleApiClient = ref.watch(scheduleApiClientProvider);
  return ScheduleRemoteDataSourceImpl(scheduleApiClient);
}

/// ScheduleLocalDataSource provider
@riverpod
ScheduleLocalDataSourceImpl scheduleLocalDatasource(Ref ref) {
  return ScheduleLocalDataSourceImpl();
}

/// GroupRemoteDataSource provider
@riverpod
GroupRemoteDataSourceImpl groupRemoteDatasource(Ref ref) {
  final groupApiClient = ref.watch(groupApiClientProvider);
  return GroupRemoteDataSourceImpl(groupApiClient);
}

/// GroupLocalDataSource provider
@riverpod
GroupLocalDataSourceImpl groupLocalDatasource(Ref ref) {
  return GroupLocalDataSourceImpl();
}

// REMOVED: DashboardRemoteDataSource provider - dashboard data is now handled via API client directly

// REMOVED: ValidationService provider - toxic system eliminated in PHASE 5
// Validation is now handled by domain-specific validators (FamilyFormValidator, VehicleFormValidator, ChildFormValidator, etc.)

// =============================================================================
// USER-FAMILY SERVICE
// =============================================================================

/// UserFamilyService provider - bridges User and Family domains
/// CLEAN ARCHITECTURE: Maintains domain separation while providing coordination
/// SIMPLIFIED: Delegates to FamilyRepository while maintaining API compatibility
