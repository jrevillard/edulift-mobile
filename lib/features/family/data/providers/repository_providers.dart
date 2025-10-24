// Repository providers for Family feature
// These providers re-export the core repository providers for convenience

/// Re-exports of core repository providers for family feature
/// This allows family-specific imports while maintaining single source of truth in core

export 'package:edulift/core/di/providers/repository_providers.dart'
    show familyRepositoryProvider, invitationRepositoryProvider;

// Note: familyProviderProvider is not needed as familyProvider already provides the notifier
// Tests should use familyProvider.notifier directly
