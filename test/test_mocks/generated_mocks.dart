// CONSOLIDATED MOCK GENERATION - EduLift Mobile App
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// This file consolidates ALL mock classes used throughout the test suite using @GenerateNiceMocks.
// Following 2025 Flutter testing standards - TDD London School Pattern
// Consolidation reduces build time and ensures consistency across all tests.

import 'package:mockito/annotations.dart';
// Core imports for Result pattern and failures (removed unused imports)

// Core Domain Services
import 'package:edulift/core/domain/services/auth_service.dart';
import 'package:edulift/core/domain/services/deep_link_service.dart';
import 'package:edulift/core/domain/services/secure_storage_service.dart';
import 'package:edulift/core/domain/services/localization_service.dart';
import 'package:edulift/core/domain/services/comprehensive_family_data_service.dart';
import 'package:edulift/core/domain/services/magic_link_service.dart';

// Core Implementation Services
import 'package:edulift/core/services/deep_link_service.dart';
import 'package:edulift/core/services/adaptive_storage_service.dart';
import 'package:edulift/core/services/user_status_service.dart';
import 'package:edulift/core/services/app_state_provider.dart';
import 'package:edulift/core/services/providers/auth_provider.dart' as auth;

// Core Security Services
import 'package:edulift/core/security/biometric_service.dart';
import 'package:edulift/core/storage/auth_local_datasource.dart';
import 'package:edulift/core/storage/adaptive_secure_storage.dart';
import 'package:edulift/core/security/secure_key_manager.dart';
import 'package:edulift/core/security/crypto_service.dart';

// Core Infrastructure
import 'package:edulift/core/network/error_handler_service.dart';
import 'package:edulift/core/interfaces/token_storage_interface.dart';

// Network Layer - API Clients
import 'package:edulift/core/network/auth_api_client.dart';
import 'package:edulift/core/network/family_api_client.dart';
import 'package:edulift/core/network/children_api_client.dart' as children_api;
import 'package:edulift/core/network/schedule_api_client.dart';
import 'package:edulift/core/network/network_info.dart';

// Domain Repositories
import 'package:edulift/features/auth/domain/repositories/auth_repository.dart';
import 'package:edulift/features/family/domain/repositories/family_repository.dart';
import 'package:edulift/features/family/domain/repositories/family_invitation_repository.dart';
// REMOVED: family_offline_sync_repository - using Server First pattern
// REMOVED: seat_override_repository - dead code (100% mock)
import 'package:edulift/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:edulift/features/groups/domain/repositories/group_repository.dart';

// Domain Services
import 'package:edulift/features/groups/domain/services/group_service.dart';
import 'package:edulift/features/family/domain/services/children_service.dart';

// Data Sources
import 'package:edulift/features/family/data/datasources/family_remote_datasource.dart';
import 'package:edulift/features/family/data/datasources/family_local_datasource.dart';
import 'package:edulift/features/groups/data/datasources/group_remote_datasource.dart';

// Use Cases
import 'package:edulift/features/family/domain/usecases/get_family_usecase.dart';
import 'package:edulift/features/family/domain/usecases/leave_family_usecase.dart';
import 'package:edulift/features/family/domain/usecases/create_family_usecase.dart';
import 'package:edulift/features/family/domain/usecases/clear_all_family_data_usecase.dart';

// Presentation Layer
import 'package:edulift/features/family/presentation/providers/family_provider.dart';

// External Dependencies
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Import domain entities needed by generated mocks
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/domain/entities/family.dart';
// REMOVED: seat_override entity - dead code
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/domain/entities/groups/group.dart';

// CONSOLIDATED MOCK GENERATION - ALL SERVICES, REPOSITORIES, AND DEPENDENCIES
@GenerateNiceMocks([
  // External Package Mocks
  MockSpec<Connectivity>(),
  MockSpec<GoRouter>(),
  MockSpec<Dio>(),

  // Core Domain Services
  MockSpec<AuthService>(),
  MockSpec<DeepLinkService>(),
  MockSpec<DeepLinkServiceImpl>(),
  MockSpec<SecureStorageService>(),
  MockSpec<LocalizationService>(),
  MockSpec<ComprehensiveFamilyDataService>(),
  MockSpec<IMagicLinkService>(),

  // Core Implementation Services
  MockSpec<AdaptiveStorageService>(),
  MockSpec<UserStatusService>(),
  MockSpec<AppStateNotifier>(),
  MockSpec<auth.AuthNotifier>(),

  // Core Security Services
  MockSpec<BiometricService>(),
  MockSpec<IAuthLocalDatasource>(),
  MockSpec<AdaptiveSecureStorage>(),
  MockSpec<SecureKeyManager>(),
  MockSpec<CryptoService>(),

  // Core Infrastructure
  MockSpec<ErrorHandlerService>(),
  MockSpec<TokenStorageInterface>(),
  MockSpec<NetworkInfo>(),

  // Network Layer - API Clients
  MockSpec<AuthApiClient>(),
  MockSpec<FamilyApiClient>(),
  MockSpec<children_api.ChildrenApiClient>(),
  MockSpec<ScheduleApiClient>(),

  // Domain Repositories
  MockSpec<AuthRepository>(),
  MockSpec<FamilyRepository>(),
  MockSpec<InvitationRepository>(),
  // REMOVED: FamilyOfflineSyncRepository - using Server First pattern
  // REMOVED: SeatOverrideRepository - dead code (100% mock)
  MockSpec<GroupScheduleRepository>(),
  MockSpec<GroupRepository>(),

  // Domain Services
  MockSpec<GroupService>(),
  MockSpec<ChildrenService>(),

  // Data Sources
  MockSpec<FamilyRemoteDataSource>(),
  MockSpec<FamilyLocalDataSource>(),
  MockSpec<GroupRemoteDataSource>(),

  // Use Cases
  MockSpec<GetFamilyUsecase>(),
  MockSpec<LeaveFamilyUsecase>(),
  MockSpec<CreateFamilyUsecase>(),
  MockSpec<ClearAllFamilyDataUsecase>(),

  // Presentation Layer
  MockSpec<FamilyNotifier>(),
])
// Export generated mocks for use in tests
export 'generated_mocks.mocks.dart';

// Factory classes for creating test instances with controlled states
class TestUserFactory {
  /// Creates an authenticated user without a family (needs onboarding)
  static User createUserWithoutFamily({
    String id = 'test-user-1',
    String email = 'test@example.com',
    String name = 'Test User',
  }) {
    return User(
      id: id,
      email: email,
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates an authenticated user with a family (full access)
  static User createUserWithFamily({
    String id = 'test-user-2',
    String email = 'family-user@example.com',
    String name = 'Family User',
    String familyId = 'test-family-123',
    String familyRole = 'parent',
  }) {
    return User(
      id: id,
      email: email,
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      hasCompletedOnboarding: true,
      /* familyId removed - use FamilyMember entity */
      /* familyRole removed - use FamilyMember entity */
    );
  }
}

/// Mock factory for AuthState configurations used in router testing
class AuthStateMockFactory {
  /// Creates uninitialized auth state (should show splash)
  static auth.AuthState createUninitialized() {
    return const auth.AuthState(isLoading: true);
  }

  /// Creates unauthenticated state (should redirect to login)
  static auth.AuthState createUnauthenticated() {
    return const auth.AuthState(isInitialized: true);
  }

  /// Creates authenticated state without family (should redirect to onboarding)
  static auth.AuthState createAuthenticatedWithoutFamily() {
    return auth.AuthState(
      isInitialized: true,
      user: TestUserFactory.createUserWithoutFamily(),
    );
  }

  /// Creates authenticated state with family (full access)
  static auth.AuthState createAuthenticatedWithFamily() {
    return auth.AuthState(
      isInitialized: true,
      user: TestUserFactory.createUserWithFamily(),
    );
  }
}

/// Consolidated test data factories
class TestDataFactory {
  static Family createTestFamily({
    String id = 'test-family-1',
    String name = 'Test Family',
  }) {
    return Family(
      id: id,
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static Child createTestChild({
    String id = 'test-child-1',
    String name = 'Test Child',
    String familyId = 'test-family-id',
  }) {
    return Child(
      id: id,
      name: name,
      familyId: familyId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static Vehicle createTestVehicle({
    String id = 'test-vehicle-1',
    String name = 'Test Vehicle',
    int capacity = 4,
    String familyId = 'test-family-id',
  }) {
    return Vehicle(
      id: id,
      name: name,
      familyId: familyId,
      capacity: capacity,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static Group createTestGroup({
    String id = 'test-group-1',
    String name = 'Test Group',
    String familyId = 'test-family-id',
  }) {
    return Group(
      id: id,
      name: name,
      familyId: familyId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      familyCount: 1,
    );
  }

  static FamilyInvitation createTestInvitation({
    String id = 'test-invitation-1',
    String inviterEmail = 'inviter@example.com',
    String recipientEmail = 'recipient@example.com',
    String familyId = 'test-family-1',
  }) {
    return FamilyInvitation(
      id: id,
      familyId: familyId,
      email: recipientEmail,
      role: 'member',
      invitedBy: 'test-user-1',
      invitedByName: 'Test Inviter',
      createdBy: 'test-user-1',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      status: InvitationStatus.pending,
      inviteCode: 'TEST-CODE-123',
      updatedAt: DateTime.now(),
    );
  }

  static ScheduleConfig createTestScheduleConfig({
    String id = 'test-config-1',
    String groupId = 'test-group-1',
  }) {
    return ScheduleConfig(
      id: id,
      groupId: groupId,
      scheduleHours: const {
        'MONDAY': ['08:00', '16:00'],
        'TUESDAY': ['08:00', '16:00'],
        'WEDNESDAY': ['08:00', '16:00'],
        'THURSDAY': ['08:00', '16:00'],
        'FRIDAY': ['08:00', '16:00'],
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static ScheduleSlot createTestScheduleSlot({
    String id = 'test-slot-1',
    String groupId = 'test-group-1',
  }) {
    return ScheduleSlot(
      id: id,
      groupId: groupId,
      dayOfWeek: DayOfWeek.monday,
      timeOfDay: const TimeOfDayValue(8, 0),
      week: '2025-W01',
      vehicleAssignments: const [],
      maxVehicles: 4,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // OnboardingState factory removed - onboarding feature simplified without domain entities
  // SeatOverride factory removed - dead code (100% mock, no backend API)
}

// MOCK FACTORIES - To be added after successful generation
// Factory methods will be added in a separate file that imports the generated mocks
