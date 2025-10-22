/// Family Permission Providers - Complete Riverpod implementation
///
/// This module provides a comprehensive family permission management system using
/// Riverpod state management following the existing codebase patterns.
///
/// Features:
/// - Role-based permissions (ADMIN/MEMBER)
/// - Member action management (promote, demote, remove)
/// - Native Riverpod caching (no manual cache layer)
/// - Orchestrated state management for UI integration
/// - Error handling following app patterns
///
/// Architecture compliance:
/// - StateNotifier pattern matching existing providers
/// - Dependency injection using Riverpod providers
/// - Domain error handling via failure classes
/// - Repository pattern integration
/// - Native Riverpod caching instead of manual layer
///
/// Usage:
/// ```dart
/// // Initialize permissions for a family
/// final orchestrator = ref.read(familyPermissionOrchestratorProvider(familyId).notifier
/// await orchestrator.initializePermissions(
///
/// // Check current user permissions
/// final canManage = ref.watch(canPerformMemberActionsProvider(familyId)
///
/// // Perform member actions
/// await orchestrator.promoteMemberToAdmin(memberId: id, memberName: name
///
/// // Get members with capabilities
/// final membersWithCaps = ref.watch(familyMembersWithCapabilitiesProvider(familyId)
/// ```

// Core permission management
export 'family_permission_provider.dart';

// Member actions (promote, demote, remove)
export 'family_member_actions_provider.dart';


// Orchestrated integration
export 'family_permission_orchestrator_provider.dart';

// Repository providers (dependency)
export 'repository_providers.dart';
