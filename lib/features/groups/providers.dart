// Feature-level composition root for Groups feature
// This file acts as the composition root according to Clean Architecture principles.
// Presentation layer imports ONLY from this file, never directly from data layer.

// PRESENTATION PROVIDERS: Import from presentation layer for composition
import 'data/providers/groups_provider.dart';

// === TYPE EXPORTS ===
// Re-export commonly used types from presentation layer
export 'presentation/providers/group_invitation_provider.dart'
    show GroupInvitationState, groupInvitationProvider;

// Re-export groups provider and state
export 'data/providers/groups_provider.dart'
    show
        GroupsState,
        groupsProvider,
        GroupDetailState,
        groupDetailProvider,
        groupFamiliesProvider;

// === PROVIDER ALIASES ===
// Alias for backward compatibility with existing pages
final groupsComposedProvider = groupsProvider;
