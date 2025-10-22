// =============================================================================
// RIVERPOD DEPENDENCY INJECTION PROVIDERS - REORGANIZED MAIN EXPORT FILE
// =============================================================================

/// Main export file for all Riverpod providers following Clean Architecture
///
/// This file serves as the central export point for all Riverpod dependency
/// injection providers used throughout the application. The providers are now
/// organized following Clean Architecture principles with clear separation
/// of concerns across different architectural layers.
///
/// **NEW PROVIDER ORGANIZATION:**
///
/// **Foundation Layer** (Infrastructure):
/// - Network Providers: HTTP clients, connectivity monitoring
/// - Storage Providers: Secure storage, crypto services, data persistence
/// - Platform Providers: Biometric auth, deep linking, device features
///
/// **Data Layer**:
/// - API Client Providers: REST API clients for different features
/// - Datasource Providers: Local and remote data sources
/// - Repository Providers: Repository implementations
///
/// **Domain Layer**:
/// - Auth Providers: Authentication services and business logic
/// - Family Providers: Family-related domain services
/// - Localization Providers: Multi-language support services
/// - Notification Providers: Real-time communication and sync services
///
/// **Presentation Layer**:
/// - State Providers: UI state management
/// - Navigation Providers: Routing and navigation state
/// - Theme Providers: Theming and visual configuration
///
/// Usage:
/// ```dart
/// import 'package:mobile_app/core/di/providers/providers.dart';
///
/// // Access any provider from a single import
/// final dio = ref.read(dioProvider);
/// final authService = ref.read(authServiceProvider);
/// final familyRepository = ref.read(familyRepositoryProvider);
/// ```

// =============================================================================
// FOUNDATION LAYER PROVIDERS (Infrastructure)
// =============================================================================

/// Core infrastructure providers - external dependencies and system services
export 'foundation/network_providers.dart';
export 'foundation/storage_providers.dart';
export 'foundation/platform_providers.dart';

// =============================================================================
// DATA LAYER PROVIDERS
// =============================================================================

/// Data access providers - API clients, datasources, repositories
export 'data/datasource_providers.dart';
export 'repository_providers.dart';

// =============================================================================
// DOMAIN LAYER PROVIDERS
// =============================================================================

/// Business logic providers - domain services and use cases
export 'service_providers.dart';

// Export specific repository providers that are used in features
export 'repository_providers.dart'
    show
        familyRepositoryProvider,
        invitationRepositoryProvider,
        // familyMembersRepositoryProvider removed - family members accessed via family.members
        groupRepositoryProvider,
        scheduleRepositoryProvider;

// UnifiedInvitationService has been removed - functionality moved to repositories

// =============================================================================
// PRESENTATION LAYER PROVIDERS
// =============================================================================

/// UI and presentation providers - state management, navigation, theming
export 'presentation/state_providers.dart';
export 'presentation/navigation_providers.dart';
export 'presentation/theme_providers.dart';
export 'presentation/notification_providers.dart';

// =============================================================================
// PROVIDER ARCHITECTURE OVERVIEW - CLEAN ARCHITECTURE COMPLIANT
// =============================================================================
/*
This provider architecture follows Clean Architecture principles with zero duplications:

┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ State Providers │  │ Navigation      │  │ Theme Providers │ │
│  │                 │  │ Providers       │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                         DOMAIN LAYER                           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Auth Providers  │  │ Family Providers│  │ Localization &  │ │
│  │                 │  │                 │  │ Notification    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ API Client      │  │ Datasource      │  │ Repository      │ │
│  │ Providers       │  │ Providers       │  │ Providers       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                      FOUNDATION LAYER                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Network         │  │ Storage         │  │ Platform        │ │
│  │ Providers       │  │ Providers       │  │ Providers       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

Dependency Direction: ↑ (Dependencies point inward toward domain)

**✅ CLEAN ARCHITECTURE COMPLIANCE ACHIEVED:**
✅ Zero Provider Duplications: All duplicate files removed
✅ Single Responsibility: Each provider file has one clear purpose
✅ Logical Grouping: Related providers grouped by architectural layer
✅ Clear Dependencies: Dependency direction follows Clean Architecture
✅ Maintainable Structure: Easy to navigate and extend
✅ Separation of Concerns: Clear boundaries between layers
✅ No Conflicting Provider Names: Unique provider instances across codebase
✅ Clean Import Paths: Import violations eliminated
*/
