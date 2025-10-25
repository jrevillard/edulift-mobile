// Feature-level composition root for Family feature
// This file acts as the composition root according to Clean Architecture principles.
// Presentation layer imports ONLY from this file, never directly from data layer.

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ALLOWED: Composition root can import from data and domain layers
import 'package:edulift/core/domain/entities/family.dart' as entities;
import 'data/providers/repository_providers.dart';
// REMOVED: data/providers/family_provider.dart - was obsolete with stub implementations
import 'presentation/providers/family_provider.dart';
import 'domain/usecases/create_family_usecase.dart';
import 'domain/usecases/get_family_usecase.dart';
// REMOVED: All children use cases and services per dependency cleanup

// PRESENTATION PROVIDERS: Import from presentation layer for composition
import 'presentation/providers/family_permission_orchestrator_provider.dart';
import 'presentation/providers/family_permission_provider.dart';
import 'presentation/providers/family_invitation_provider.dart';
// REMOVED: seat_override_provider - dead code (100% mock)
import 'presentation/providers/create_family_provider.dart';

// === TYPE EXPORTS ===
// Re-export commonly used types from presentation layer
export 'presentation/providers/family_provider.dart' show FamilyState;

// === REPOSITORY PROVIDERS ===
// Re-export repository providers with clean names for presentation layer
final familyRepositoryComposedProvider = familyRepositoryProvider;
final invitationRepositoryComposedProvider = invitationRepositoryProvider;

// === SERVICE PROVIDERS ===
// REMOVED: childrenServiceProvider - dependency eliminated
// Use service providers from core providers instead

// === USE CASE PROVIDERS ===
final createFamilyUsecaseProvider = Provider<CreateFamilyUsecase>((ref) {
  final repository = ref.watch(familyRepositoryProvider);
  return CreateFamilyUsecase(repository);
});
final getFamilyUsecaseProvider = Provider<GetFamilyUsecase>((ref) {
  final familyRepository = ref.watch(familyRepositoryProvider);
  return GetFamilyUsecase(familyRepository);
});
// REMOVED: All children use case providers per consolidation plan
// Use childrenServiceProvider directly with methods: add(), update(), remove()

// === STATE PROVIDERS ===
// CRITICAL FIX: Use working providers instead of obsolete data layer stubs
// The data layer providers were placeholder implementations that always return false/empty

// Use main family provider that returns proper AsyncValue<FamilyState>
// Then extract family from it for backward compatibility
final currentFamilyComposedProvider = Provider<AsyncValue<entities.Family?>>((
  ref,
) {
  final familyState = ref.watch(familyProvider);
  // Convert FamilyState to AsyncValue<Family?> for backward compatibility
  if (familyState.isLoading && familyState.family == null) {
    return const AsyncValue.loading();
  } else if (familyState.error != null) {
    return AsyncValue.error(Exception(familyState.error!), StackTrace.current);
  } else {
    return AsyncValue.data(familyState.family);
  }
});
// REMOVED: familyMembersComposedProvider - was obsolete stub returning empty list
// Use familyPermissionProvider or familyMembersWithCapabilitiesProvider(familyId) directly

// REMOVED: isAdminComposedProvider - was obsolete stub always returning false
// Use isCurrentUserAdminProvider or canPerformMemberActionsComposedProvider(familyId) directly

// REMOVED: familyStatsComposedProvider - was obsolete stub from data layer
// Implement proper stats logic if needed in presentation layer

// Re-export presentation layer providers
final familyComposedProvider = familyProvider;

// === PERMISSION PROVIDERS ===
// Following composition root pattern - encapsulate low-level permission providers
// Presentation layer should ONLY import from this composition root

// Re-export orchestrated permission provider with clean name for presentation layer
final familyPermissionOrchestratorComposedProvider =
    familyPermissionOrchestratorProvider;

// Re-export convenience providers for member action permissions
final canPerformMemberActionsComposedProvider = canPerformMemberActionsProvider;
// Famille members with capabilities provider
final familyMembersWithCapabilitiesComposedProvider =
    Provider.family<AsyncValue<List<Map<String, dynamic>>>, String>((
  ref,
  familyId,
) {
  final familyState = ref.watch(familyProvider);
  // Simple implementation returning empty list for now - implement if needed
  if (familyState.isLoading) {
    return const AsyncValue.loading();
  } else if (familyState.error != null) {
    return AsyncValue.error(
      Exception(familyState.error!),
      StackTrace.current,
    );
  } else {
    return const AsyncValue.data([]);
  }
});
final permissionSyncStatusComposedProvider = permissionSyncStatusProvider;

// Re-export low-level permission provider (for internal orchestrator use only)
final familyPermissionComposedProvider = familyPermissionProvider;

// === ADDITIONAL PRESENTATION PROVIDERS ===
// Re-export commonly used presentation providers with clean names
final familyInvitationComposedProvider = familyInvitationProvider;
// REMOVED: seatOverrideComposedProvider - dead code (100% mock)
final createFamilyComposedProvider = createFamilyProvider;
