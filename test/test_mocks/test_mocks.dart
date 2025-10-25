// CENTRALIZED TEST MOCKS - MOCKITO GENERATED
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// This file generates all mock classes used throughout the test suite using @GenerateNiceMocks.
// ALL missing mock classes are now included in this comprehensive specification.

// REMOVED: Direct export of test_mocks.mocks.dart to eliminate conflicts

// Typed API client mocks are now auto-generated in test_mocks.mocks.dart

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart' as dartz;

// Core imports for Result pattern and failures
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/errors/exceptions.dart';

// CRITICAL IMPORTS FOR MISSING DUMMY VALUES - ARCHITECTURAL REPAIR
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/domain/services/auth_service.dart';
import 'package:edulift/core/services/user_family_service.dart';
import 'package:edulift/core/interfaces/token_storage_interface.dart';

// Family domain entities
import 'package:edulift/core/domain/entities/family.dart';

// Core invitation entities

// Schedule domain entities (only those that actually exist)
import 'package:edulift/core/domain/entities/schedule.dart';

// External package imports for mocking
import 'package:connectivity_plus/connectivity_plus.dart';

// Typed API Clients - CRITICAL IMPORTS for test infrastructure fix
import 'package:edulift/core/network/auth_api_client.dart';
import 'package:edulift/core/network/family_api_client.dart';
import 'package:edulift/core/network/children_api_client.dart' as children_api;
import 'package:edulift/core/network/requests/index.dart' as api_requests;
import 'package:edulift/core/services/adaptive_storage_service.dart';
import 'package:edulift/core/security/biometric_service.dart';
import 'package:edulift/core/services/user_status_service.dart';
import 'package:edulift/core/domain/services/localization_service.dart';
import 'package:edulift/core/storage/adaptive_secure_storage.dart';
import 'package:edulift/core/security/secure_key_manager.dart';
import 'package:edulift/core/security/crypto_service.dart';
import 'package:edulift/core/storage/auth_local_datasource.dart';
// AuthUserProfile already imported above
import 'package:edulift/core/domain/services/magic_link_service.dart';
import 'package:edulift/core/domain/services/deep_link_service.dart';
import 'package:edulift/core/domain/services/comprehensive_family_data_service.dart';

// New service interfaces for mock generation
import 'package:edulift/features/groups/domain/services/group_service.dart';
import 'package:edulift/features/family/domain/services/children_service.dart';
import 'package:edulift/core/domain/entities/groups/group.dart';
import 'package:edulift/features/family/domain/requests/child_requests.dart'
    as domain_requests;

// Domain Repositories
import 'package:edulift/features/auth/domain/repositories/auth_repository.dart';
import 'package:edulift/features/family/domain/repositories/family_repository.dart';
// import 'package:edulift/features/family/domain/repositories/family_invitations_repository.dart'; - removed, use InvitationRepository
// REMOVED: family_offline_sync_repository - using Server First pattern
// Removed obsolete children_repository and vehicles_repository imports
import 'package:edulift/features/family/domain/repositories/family_invitation_repository.dart';
import 'package:edulift/features/groups/domain/repositories/group_repository.dart';
import 'package:edulift/features/groups/data/datasources/group_remote_datasource.dart';
// Removed duplicate group.dart import - already imported above
// Family schedule repository removed - moved to separate domain
import 'package:edulift/features/schedule/domain/repositories/schedule_repository.dart';

// Domain Use Cases
import 'package:edulift/features/family/domain/usecases/get_family_usecase.dart';
import 'package:edulift/features/family/domain/usecases/leave_family_usecase.dart';
import 'package:edulift/features/family/domain/usecases/create_family_usecase.dart';
import 'package:edulift/features/family/domain/usecases/clear_all_family_data_usecase.dart';

// Presentation Layer
import 'package:edulift/core/services/app_state_provider.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/features/family/presentation/providers/family_provider.dart';
import 'package:edulift/core/network/error_handler_service.dart';

// Data Sources
import 'package:edulift/features/family/data/datasources/family_remote_datasource.dart';
import 'package:edulift/features/family/data/datasources/family_local_datasource.dart';
import 'package:edulift/features/schedule/data/datasources/schedule_local_datasource.dart';
import 'package:edulift/features/schedule/data/datasources/schedule_remote_datasource.dart';
import 'package:edulift/core/network/network_info.dart';
import 'package:edulift/core/network/network_error_handler.dart';

// External Dependencies
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

// Schedule-specific API client
import 'package:edulift/core/network/schedule_api_client.dart' as schedule;

// Import ComprehensiveFamilyDataService for mock generation

// COMPREHENSIVE MOCK GENERATION SPECIFICATION
// This generates ALL mock classes needed by the test suite
@GenerateNiceMocks([
  // External Package Mocks
  MockSpec<Connectivity>(),

  // Core Infrastructure Service Mocks
  MockSpec<schedule.ScheduleApiClient>(),
  // CRITICAL: Typed API Client Mocks - fixes MockApiClient compatibility issues
  MockSpec<AuthApiClient>(),
  MockSpec<FamilyApiClient>(),
  MockSpec<children_api.ChildrenApiClient>(),
  MockSpec<AuthService>(),
  MockSpec<AdaptiveStorageService>(),
  MockSpec<BiometricService>(),
  MockSpec<UserStatusService>(),
  MockSpec<LocalizationService>(),
  MockSpec<AdaptiveSecureStorage>(),
  MockSpec<SecureKeyManager>(),
  MockSpec<ErrorHandlerService>(),
  MockSpec<UserMessageService>(),
  MockSpec<CryptoService>(),
  MockSpec<IMagicLinkService>(),
  MockSpec<DeepLinkService>(),
  MockSpec<ComprehensiveFamilyDataService>(),

  // Core Domain Service Mocks
  MockSpec<UserFamilyService>(),

  // NOTE: GroupService and ChildrenService use manual mocks below for backward compatibility

  // Token Storage Mocks - CRITICAL for MagicLinkService testing
  MockSpec<TokenStorageInterface>(),
  // Removed SecureTokenStorage - no longer auto-generated due to manual DI

  // Data Source Mocks
  MockSpec<IAuthLocalDatasource>(),
  MockSpec<FamilyRemoteDataSource>(),
  MockSpec<FamilyLocalDataSource>(),
  MockSpec<ScheduleLocalDataSource>(),
  MockSpec<ScheduleRemoteDataSource>(),
  MockSpec<NetworkInfo>(),
  MockSpec<NetworkErrorHandler>(),

  // Repository Mocks
  MockSpec<AuthRepository>(),
  MockSpec<FamilyRepository>(),
  // FamilyInvitationsRepository removed - use InvitationRepository
  // REMOVED: FamilyOfflineSyncRepository - using Server First pattern
  MockSpec<InvitationRepository>(),
  MockSpec<GroupRepository>(),
  MockSpec<GroupRemoteDataSource>(),
  // FamilyScheduleRepository mock removed - moved to separate domain
  MockSpec<GroupScheduleRepository>(),

  // Use Case Mocks - REMOVED: AddChildUsecase, UpdateChildUsecase, RemoveChildUsecase per consolidation plan
  MockSpec<GetFamilyUsecase>(),
  MockSpec<LeaveFamilyUsecase>(),
  MockSpec<CreateFamilyUsecase>(),
  MockSpec<ClearAllFamilyDataUsecase>(),

  // Presentation Layer Mocks
  MockSpec<AppStateNotifier>(),
  MockSpec<AuthNotifier>(),
  MockSpec<FamilyNotifier>(),
  // MockSpec<VehiclesNotifier>(), // Removed - consolidated into FamilyNotifier

  // External Dependency Mocks
  MockSpec<GoRouter>(),
  MockSpec<Dio>(),

  // NOTE: Manual mocks for GroupService and ChildrenService are defined below
  // to provide backward compatibility methods that tests expect
])
import 'test_mocks.mocks.dart';

// Export all generated mocks to make them available when importing this file
export 'test_mocks.mocks.dart';

// Manual mocks to supplement generated mocks with additional methods needed by tests
class MockGroupService extends Mock implements GroupService {
  // Implement interface methods
  @override
  Future<Result<List<Group>, ApiFailure>> getAll() => super.noSuchMethod(
    Invocation.method(#getAll, []),
    returnValue: Future.value(const Result<List<Group>, ApiFailure>.ok([])),
  );

  @override
  Future<Result<Group, ApiFailure>> getById(String id) => super.noSuchMethod(
    Invocation.method(#getById, [id]),
    returnValue: Future.value(
      Result<Group, ApiFailure>.ok(
        Group(
          id: 'test',
          name: 'Test Group',
          familyId: 'test-family',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
    ),
  );

  @override
  Future<Result<Group, ApiFailure>> create(CreateGroupCommand command) =>
      super.noSuchMethod(
        Invocation.method(#create, [command]),
        returnValue: Future.value(
          Result<Group, ApiFailure>.ok(
            Group(
              id: 'test',
              name: 'Test Group',
              familyId: 'test-family',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ),
        ),
      );

  @override
  Future<Result<Group, ApiFailure>> update(
    String id,
    Map<String, dynamic> updates,
  ) => super.noSuchMethod(
    Invocation.method(#update, [id, updates]),
    returnValue: Future.value(
      Result<Group, ApiFailure>.ok(
        Group(
          id: 'test',
          name: 'Test Group',
          familyId: 'test-family',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
    ),
  );

  @override
  Future<Result<void, ApiFailure>> delete(String id) => super.noSuchMethod(
    Invocation.method(#delete, [id]),
    returnValue: Future.value(const Result<void, ApiFailure>.ok(null)),
  );

  // Backward compatibility methods for tests
  Future<Result<List<Group>, ApiFailure>> getGroups() => getAll();
  Future<Result<Group, ApiFailure>> getGroup(String id) => getById(id);
  Future<Result<Group, ApiFailure>> createGroup(CreateGroupCommand command) =>
      create(command);
  Future<Result<Group, ApiFailure>> updateGroup(
    String id,
    Map<String, dynamic> updates,
  ) => update(id, updates);
  Future<Result<void, ApiFailure>> deleteGroup(String id) => delete(id);
}

class MockChildrenService extends Mock implements ChildrenService {
  // CRITICAL FIX: Return proper Result types with realistic test data

  @override
  Future<Result<Child, ApiFailure>> add({
    required String familyId,
    required domain_requests.CreateChildRequest request,
  }) => Future.value(
    Result.ok(
      Child(
        id: 'child-${DateTime.now().millisecondsSinceEpoch}',
        name: request.name,
        familyId: 'test-family-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ),
  );

  @override
  Future<Result<Child, ApiFailure>> update({
    required String familyId,
    required domain_requests.UpdateChildParams params,
  }) => Future.value(
    Result.ok(
      Child(
        id: params.childId,
        name: params.request.name ?? 'Updated Child',
        familyId: 'test-family-123',
        createdAt: DateTime(2024),
        updatedAt: DateTime.now(),
      ),
    ),
  );

  @override
  Future<Result<void, ApiFailure>> remove({
    required String familyId,
    required String childId,
  }) => Future.value(const Result.ok(null));

  // Backward compatibility methods for tests - FIXED return types
  Future<Result<Child, ApiFailure>> addChild(
    domain_requests.CreateChildRequest request,
  ) => add(familyId: 'test-family-123', request: request);
  Future<Result<Child, ApiFailure>> updateChild(
    domain_requests.UpdateChildParams params,
  ) => update(familyId: 'test-family-123', params: params);
  Future<Result<Child, ApiFailure>> updateChildFromRequest(
    domain_requests.UpdateChildParams params,
  ) => update(familyId: 'test-family-123', params: params);
  Future<Result<void, ApiFailure>> removeChild(String childId) =>
      remove(familyId: 'test-family-123', childId: childId);
}

/// NOTE: MockScheduleApiClient is auto-generated from the MockSpec annotation

// NOTE: MockGroupScheduleRepository is auto-generated from the MockSpec annotation

// NOTE: MockAdaptiveSecureStorage is now auto-generated - removed manual version to fix naming conflict

// =============================================================================
// MOCK SETUP UTILITIES
// =============================================================================

/// Sets up common fallback values for mockito
void setupMockFallbacks() {
  // Register fallback values for primitive types
  provideDummy('dummy-string');
  provideDummy(0);
  provideDummy(false);
  provideDummy(0.0);
  provideDummy(<String>[]);
  provideDummy(<int>[]);
  provideDummy(<Map<String, dynamic>>[]);
  provideDummy(<String, dynamic>{});

  // Register DateTime fallback
  provideDummy(DateTime.now());

  // Register Uri fallback
  provideDummy(Uri.parse('https://example.com'));

  // Register specific types that are commonly needed
  provideDummy('dummy-token-string');

  // Register CryptographyException dummy
  provideDummy(const CryptographyException('Dummy crypto error'));

  // Register Result<String, CryptographyException> dummy
  provideDummy(
    const Result<String, CryptographyException>.ok('dummy-encrypted'),
  );

  // Register Result<({String plaintext, int keyId}), CryptographyException> dummy
  provideDummy(
    const Result<({String plaintext, int keyId}), CryptographyException>.ok((
      plaintext: 'dummy-plaintext',
      keyId: 1,
    )),
  );

  // PHASE 1 FIX #2: Add missing Mockito dummy providers for MissingDummyValueError
  provideDummy<Result<Vehicle, ApiFailure>>(Result.ok(_createDummyVehicle()));
  provideDummy<Result<Family?, Failure>>(const Result.ok(null));
  provideDummy<Result<void, Failure>>(const Result.ok(null));

  // Register Result dummy values using provideDummy for proper generic support
  _setupResultDummies();

  // Register domain entity dummy values
  _setupDomainEntityDummies();

  // CRITICAL: Register entity dummies to prevent MissingDummyValueError
  provideDummy(_createDummyUser());
  provideDummy(_createDummyAuthUserProfile());
  provideDummy(_createDummyAuthResult());

  // Add dummies for group-related entities
  provideDummy(_createDummyCreateGroupCommand());
  provideDummy(_createDummyApiCreateChildRequest());
  provideDummy(_createDummyDomainCreateChildRequest());
}

/// Internal method to setup Result<T,E> dummy values
void _setupResultDummies() {
  // Core Result patterns used throughout the app - using provideDummy instead of provideDummyBuilder
  provideDummy(const Result<Unit, ApiFailure>.ok(Unit()));
  provideDummy(const Result<void, ApiFailure>.ok(null));
  provideDummy(const Result<String, ApiFailure>.ok('dummy-string'));
  provideDummy(const Result<int, ApiFailure>.ok(0));
  provideDummy(const Result<bool, ApiFailure>.ok(true));
  provideDummy(const Result<List<String>, ApiFailure>.ok([]));
  provideDummy(const Result<Map<String, dynamic>, ApiFailure>.ok({}));
  provideDummy(const Result<List<Map<String, dynamic>>, ApiFailure>.ok([]));

  // Family domain Results
  provideDummy(Result<Family, ApiFailure>.ok(_createDummyFamily()));
  provideDummy(const Result<List<Family>, ApiFailure>.ok([]));
  provideDummy(Result<Family, Failure>.ok(_createDummyFamily()));
  provideDummy(const Result<List<Family>, Failure>.ok([]));
  // CRITICAL FIX: Add nullable Family Result for getCurrentFamily()
  provideDummy(const Result<Family?, ApiFailure>.ok(null));

  // FamilyMember domain Results - CRITICAL FIX FOR MissingDummyValueError
  provideDummy(Result<FamilyMember, Failure>.ok(_createDummyFamilyMember()));
  provideDummy(const Result<List<FamilyMember>, Failure>.ok([]));
  provideDummy(Result<FamilyMember, ApiFailure>.ok(_createDummyFamilyMember()));
  provideDummy(const Result<List<FamilyMember>, ApiFailure>.ok([]));

  // FamilyInvitation domain Results - CRITICAL FIX FOR MissingDummyValueError
  provideDummy(
    Result<FamilyInvitation, Failure>.ok(_createDummyFamilyInvitation()),
  );
  provideDummy(const Result<List<FamilyInvitation>, Failure>.ok([]));
  provideDummy(
    Result<FamilyInvitation, ApiFailure>.ok(_createDummyFamilyInvitation()),
  );
  provideDummy(const Result<List<FamilyInvitation>, ApiFailure>.ok([]));

  // Child domain Results
  provideDummy(Result<Child, ApiFailure>.ok(_createDummyChild()));
  provideDummy(const Result<List<Child>, ApiFailure>.ok([]));
  provideDummy(Result<Child, Failure>.ok(_createDummyChild()));
  provideDummy(const Result<List<Child>, Failure>.ok([]));

  // ChildAssignment domain Results - FIX FOR MissingDummyValueError
  provideDummy(
    Result<ChildAssignment, ApiFailure>.ok(_createDummyChildAssignment()),
  );
  provideDummy(const Result<List<ChildAssignment>, ApiFailure>.ok([]));
  provideDummy(
    Result<ChildAssignment, Failure>.ok(_createDummyChildAssignment()),
  );
  provideDummy(const Result<List<ChildAssignment>, Failure>.ok([]));

  // Schedule domain Results (only for entities that actually exist)
  provideDummy(const Result<List<ScheduleSlot>, ApiFailure>.ok([]));
  provideDummy(Result<ScheduleSlot, ApiFailure>.ok(ScheduleSlot.empty()));
  provideDummy(
    Result<ScheduleConfig, ApiFailure>.ok(_createDummyScheduleConfig()),
  );
  provideDummy(
    Result<WeeklySchedule, Failure>.ok(_createDummyWeeklySchedule()),
  );
  provideDummy(Result<TimeSlot, Failure>.ok(_createDummyTimeSlot()));
  provideDummy(Result<Assignment, Failure>.ok(_createDummyAssignment()));
  provideDummy(const Result<List<ScheduleConflict>, Failure>.ok([]));
  provideDummy(const Result<List<Vehicle>, Failure>.ok([]));
  provideDummy(
    Result<OptimizedSchedule, Failure>.ok(_createDummyOptimizedSchedule()),
  );
  provideDummy(const Result<Map<String, int>, Failure>.ok({}));

  // Group Result patterns - CRITICAL FOR GROUP DOMAIN TESTS
  provideDummy(Result<Group, ApiFailure>.ok(_createDummyGroup()));
  provideDummy(const Result<List<Group>, ApiFailure>.ok([]));

  // VehicleAssignment Result patterns for schedule domain tests
  provideDummy(
    Result<VehicleAssignment, ApiFailure>.ok(_createDummyVehicleAssignment()),
  );
  provideDummy(const Result<List<VehicleAssignment>, ApiFailure>.ok([]));

  // ScheduleConflict Result patterns for schedule conflict checks - CRITICAL FIX
  provideDummy(const Result<List<ScheduleConflict>, ApiFailure>.ok([]));

  // Auth domain Results
  provideDummy(const Result<Unit, AuthFailure>.ok(Unit()));
  provideDummy(const Result<String, AuthFailure>.ok('dummy-token'));

  // User domain Results - CRITICAL FIX FOR MissingDummyValueError
  provideDummy(Result<User, ApiFailure>.ok(_createDummyUser()));
  provideDummy(const Result<List<User>, ApiFailure>.ok([]));
  provideDummy(Result<User, Failure>.ok(_createDummyUser()));
  provideDummy(const Result<List<User>, Failure>.ok([]));

  // CRITICAL MISSING DUMMY VALUES - ARCHITECTURAL REPAIR
  // These were causing 154 test failures with MissingDummyValueError
  provideDummy(const Result<AuthUserProfile?, ApiFailure>.ok(null));
  provideDummy(const Result<String?, ApiFailure>.ok(null));
  provideDummy(const Result<User?, Failure>.ok(null));
  provideDummy(Result<AuthResult, Failure>.ok(_createDummyAuthResult()));

  // CRITICAL FIX: Add missing ComprehensiveFamilyDataService result dummy
  provideDummy(const Result<String?, Failure>.ok(null));

  // CRYPTO SERVICE DUMMY VALUES - INTEGRATION TEST FIXES
  provideDummy(
    const Result<String, CryptographyException>.ok('dummy-encrypted-string'),
  );
  provideDummy(
    const Result<({String plaintext, int keyId}), CryptographyException>.ok((
      plaintext: 'dummy-plaintext',
      keyId: 1,
    )),
  );

  // NEW SERVICE ARCHITECTURE DUMMY VALUES - Service Result patterns
  // GroupService Results
  provideDummy(Result<Group, ApiFailure>.ok(_createDummyGroup()));
  provideDummy(const Result<List<Group>, ApiFailure>.ok([]));
  provideDummy(const Result<void, ApiFailure>.ok(null));

  // ChildrenService Results
  provideDummy(Result<Child, ApiFailure>.ok(_createDummyChild()));

  // Feature AuthService Results - Using AuthResult
  provideDummy(Result<AuthResult, ApiFailure>.ok(_createDummyAuthResult()));
  provideDummy(const Result<bool, ApiFailure>.ok(true));

  // Generic Failure Results
  provideDummy(const Result<Unit, Failure>.ok(Unit()));
  provideDummy(const Result<String, Failure>.ok('dummy-string'));
  provideDummy(const Result<bool, Failure>.ok(true));
}

/// Internal method to setup domain entity dummy values
void _setupDomainEntityDummies() {
  // Domain entities
  provideDummy(_createDummyFamily());
  provideDummy(_createDummyFamilyMember());
  provideDummy(_createDummyFamilyInvitation());
  provideDummy(_createDummyChild());
  provideDummy(_createDummyChildAssignment());
  provideDummy(_createDummyVehicle());
  provideDummy(_createDummyGroup());
  provideDummy(ScheduleSlot.empty());
  provideDummy(_createDummyScheduleConfig());
  provideDummy(_createDummyWeeklySchedule());
  provideDummy(_createDummyTimeSlot());
  provideDummy(_createDummyAssignment());
  provideDummy(_createDummyOptimizedSchedule());

  // Failure types
  provideDummy(const ApiFailure(message: 'Dummy API failure'));
  provideDummy(const AuthFailure(message: 'Dummy auth failure'));
  provideDummy(const UnknownFailure(message: 'Dummy failure'));
  provideDummy(const Unit());
}

// Dummy entity creators for consistent test data
Family _createDummyFamily() {
  return Family(
    id: 'dummy-family-id',
    name: 'Dummy Family',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: 'Dummy family for testing',
  );
}

FamilyMember _createDummyFamilyMember() {
  return FamilyMember(
    id: 'dummy-member-id',
    familyId: 'dummy-family-id',
    userId: 'dummy-user-id',
    role: FamilyRole.member,
    status: 'ACTIVE',
    joinedAt: DateTime.now(),
  );
}

FamilyInvitation _createDummyFamilyInvitation() {
  final now = DateTime.now();
  return FamilyInvitation(
    id: 'dummy-invitation-id',
    familyId: 'dummy-family-id',
    email: 'invitee@example.com',
    role: 'member',
    invitedBy: 'dummy-user-id',
    invitedByName: 'Dummy User',
    createdBy: 'dummy-user-id',
    createdAt: now,
    expiresAt: now.add(const Duration(days: 7)),
    status: InvitationStatus.pending,
    inviteCode: 'dummy-invite-code-123',
    updatedAt: now,
  );
}

Child _createDummyChild() {
  return Child(
    id: 'dummy-child-id',
    name: 'Dummy Child',
    familyId: 'dummy-family-id',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

Vehicle _createDummyVehicle() {
  return Vehicle(
    id: 'dummy-vehicle-id',
    name: 'Dummy Vehicle',
    familyId: 'dummy-family-id',
    capacity: 4,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

VehicleAssignment _createDummyVehicleAssignment() {
  final now = DateTime.now();
  return VehicleAssignment(
    id: 'dummy-vehicle-assignment-id',
    scheduleSlotId: 'dummy-schedule-slot-id',
    vehicleId: 'dummy-vehicle-id',
    assignedAt: now,
    assignedBy: 'dummy-user-id',
    vehicleName: 'Dummy Vehicle',
    capacity: 12,
    createdAt: now,
    updatedAt: now,
  );
}

Group _createDummyGroup() {
  return Group(
    id: 'dummy-group-id',
    name: 'Dummy Test Group',
    familyId: 'dummy-family-id',
    description: 'Dummy group for testing purposes',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    memberCount: 1,
    maxMembers: 10,
    userRole: GroupMemberRole.owner,
    familyCount: 1,
  );
}

ScheduleConfig _createDummyScheduleConfig() {
  return ScheduleConfig(
    id: 'dummy-config-id',
    groupId: 'dummy-group-id',
    scheduleHours: const {
      'MONDAY': ['08:00', '15:00'],
      'TUESDAY': ['08:00', '15:00'],
    },
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

WeeklySchedule _createDummyWeeklySchedule() {
  return WeeklySchedule(
    id: 'dummy-weekly-schedule-id',
    familyId: 'dummy-family-id',
    name: 'Dummy Weekly Schedule',
    weekStartDate: DateTime.now(),
    timeSlots: const [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

TimeSlot _createDummyTimeSlot() {
  return TimeSlot(
    id: 'dummy-time-slot-id',
    scheduleId: 'dummy-schedule-id',
    startTime: DateTime.now(),
    endTime: DateTime.now().add(const Duration(hours: 1)),
    title: 'Dummy Time Slot',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

Assignment _createDummyAssignment() {
  return Assignment(
    id: 'dummy-assignment-id',
    timeSlotId: 'dummy-time-slot-id',
    type: AssignmentType.vehicle,
    assignedAt: DateTime.now(),
    assignedBy: 'dummy-user-id',
  );
}

OptimizedSchedule _createDummyOptimizedSchedule() {
  final dummySchedule = WeeklySchedule(
    id: 'dummy-simple-schedule-id',
    familyId: 'dummy-family-id',
    name: 'Simple Dummy Schedule',
    weekStartDate: DateTime.now(),
    timeSlots: const [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  return OptimizedSchedule(
    id: 'dummy-optimized-schedule-id',
    originalSchedule: dummySchedule,
    optimizedSchedule: dummySchedule,
    criteria: OptimizationCriteria.efficiency,
    optimizationScore: 0.85,
    improvements: const [],
    resolvedConflicts: const [],
    optimizedAt: DateTime.now(),
    optimizationTime: const Duration(seconds: 5),
  );
}

// CRITICAL MISSING ENTITY FACTORY FUNCTIONS - ARCHITECTURAL REPAIR
// These were causing systematic test failures across the test suite

/// Create dummy User entity with all required fields
User _createDummyUser() {
  return User(
    id: 'dummy-user-id',
    email: 'dummy@example.com',
    name: 'Dummy User',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
    preferredLanguage: 'en',
    timezone: 'UTC',
  );
}

/// Create dummy AuthUserProfile entity with all required fields
AuthUserProfile _createDummyAuthUserProfile() {
  return AuthUserProfile(
    id: 'dummy-auth-user-id',
    email: 'dummy-auth@example.com',
    name: 'Dummy Auth User',
    role: 'member', // Default role but no family
    lastUpdated: DateTime(2024),
    timezone: 'America/New_York', // Default timezone for testing
  );
}

/// Create dummy AuthResult with User and token
AuthResult _createDummyAuthResult() {
  return AuthResult(
    user: _createDummyUser(),
    token: 'dummy-auth-token-1234567890',
  );
}

/// Create dummy ChildAssignment entity with all required fields
ChildAssignment _createDummyChildAssignment() {
  return ChildAssignment(
    id: 'dummy-child-assignment-id',
    childId: 'dummy-child-id',
    assignmentType: 'transportation',
    assignmentId: 'dummy-assignment-id',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
    metadata: const {'test': 'data'},
    groupId: 'dummy-group-id',
    scheduleSlotId: 'dummy-schedule-slot-id',
    vehicleAssignmentId: 'dummy-vehicle-assignment-id',
    childName: 'Dummy Child',
    familyId: 'dummy-family-id',
    familyName: 'Dummy Family',
  );
}

/// Gets a fresh instance of a specific mock type
/// ONLY INCLUDES ACTUALLY GENERATED MOCKS
T getFreshMock<T>() {
  switch (T) {
    // WORKING: Core Infrastructure Service Mocks
    // MockScheduleApiClient is auto-generated - use generated_mocks.mocks.dart instead
    case MockAuthService:
      final mock = MockAuthService();
      // Add default stubs for common methods
      when(mock.logout()).thenAnswer((_) async => const Result.ok(Unit()));
      when(mock.getCurrentUser()).thenAnswer(
        (_) async => const Result.err(AuthFailure(message: 'No current user')),
      );
      when(
        mock.sendMagicLink(any, name: anyNamed('name')),
      ).thenAnswer((_) async => const Result.ok(Unit()));
      when(mock.authenticateWithMagicLink(any)).thenAnswer(
        (_) async => const Result.err(AuthFailure(message: 'Invalid token')),
      );
      when(mock.authenticateWithBiometrics(any)).thenAnswer(
        (_) async => const Result.err(AuthFailure(message: 'Biometric failed')),
      );
      return mock as T;
    case MockAdaptiveStorageService:
      return MockAdaptiveStorageService() as T;
    case MockBiometricService:
      return MockBiometricService() as T;
    case MockUserStatusService:
      final mock = MockUserStatusService();
      // Add default stub for checkUserStatus
      when(mock.checkUserStatus(any)).thenAnswer(
        (_) async => const dartz.Right(
          UserStatus(
            exists: false,
            hasProfile: false,
            requiresName: true,
            email: 'test@example.com',
          ),
        ),
      );
      return mock as T;
    case MockLocalizationService:
      return MockLocalizationService() as T;
    case MockDeepLinkService:
      return MockDeepLinkService() as T;
    case MockIMagicLinkService:
      return MockIMagicLinkService() as T;

    // WORKING: Core Domain Service Mocks
    // MockComprehensiveFamilyDataService removed - Clean Architecture: Auth domain doesn't use family services

    // WORKING: Feature Service Mocks - New Service Architecture
    case MockGroupService:
      return MockGroupService() as T;

    case MockChildrenService:
      return MockChildrenService() as T;

    // WORKING: Data Source Mocks
    case MockIAuthLocalDatasource:
      return MockIAuthLocalDatasource() as T;

    // WORKING: Repository Mocks
    case MockAuthRepository:
      return MockAuthRepository() as T;
    case MockFamilyRepository:
      return MockFamilyRepository() as T;
    // MockFamilyMembersRepository removed - family members accessed via family.members
    // REMOVED: MockFamilyOfflineSyncRepository - using Server First pattern
    case MockInvitationRepository:
      return MockInvitationRepository() as T;
    case MockGroupRepository:
      return MockGroupRepository() as T;
    // MockFamilyScheduleRepository case removed - moved to separate domain
    case MockGroupScheduleRepository:
      return MockGroupScheduleRepository() as T;

    // WORKING: External Dependency Mocks
    case MockGoRouter:
      return MockGoRouter() as T;

    default:
      throw ArgumentError(
        'Unknown mock type: $T. Only generated mocks are supported.',
      );
  }
}

// Factory methods for dummy entities
CreateGroupCommand _createDummyCreateGroupCommand() {
  return const CreateGroupCommand(
    name: 'Test Group',
    description: 'Test group description',
    maxMembers: 10,
  );
}

// API CreateChildRequest is now imported from requests/index.dart

api_requests.CreateChildInlineRequest _createDummyApiCreateChildRequest() {
  return api_requests.CreateChildInlineRequest(name: 'Test Child');
}

domain_requests.CreateChildRequest _createDummyDomainCreateChildRequest() {
  return const domain_requests.CreateChildRequest(name: 'Test Child', age: 8);
}
