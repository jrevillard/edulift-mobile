// EduLift Mobile - FamilyRepositoryImpl FamilyDataExtractor Integration Tests
// Following FLUTTER_TESTING_RESEARCH_2025.md - Data Layer Testing
// TRUTH: Tests REAL integration with FamilyDataExtractor utility
// FOCUS: Core integration behavior without mocking fake implementations

@Skip('Test obsolete: getFamilyChildren/cacheChildren/getFamilyVehicles/cacheVehicles methods were intentionally removed from FamilyLocalDataSource interface during cleanup. This test suite relied on these methods for integration testing but the architecture has been refactored to use getCurrentFamily() as the single source of truth for family data, including children and vehicles.')

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/errors/exceptions.dart';
import 'package:edulift/core/network/models/family/family_dto.dart';
import 'package:edulift/core/network/models/child/child_dto.dart';
import 'package:edulift/core/network/models/vehicle/vehicle_dto.dart';
import 'package:edulift/core/domain/entities/family/child.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/features/family/data/repositories/family_repository_impl.dart';
import 'package:edulift/features/family/data/utils/family_data_extractor.dart';

// Use centralized mocks for architecture compliance
import '../../../../test_mocks/generated_mocks.dart';

void main() {
  setUpAll(() {
    // Provide dummy values for Result types - REQUIRED for mockito
    provideDummy<Result<List<Child>, ApiFailure>>(const Result.ok(<Child>[]));
    provideDummy<Result<List<Vehicle>, ApiFailure>>(const Result.ok(<Vehicle>[]));
  });

  group('FamilyRepositoryImpl - FamilyDataExtractor Integration', () {
    late FamilyRepositoryImpl repository;
    late MockFamilyRemoteDataSource mockRemoteDataSource;
    late MockFamilyLocalDataSource mockLocalDataSource;
    late MockNetworkInfo mockNetworkInfo;
    late MockInvitationRepository mockInvitationRepository;
    late MockFamilyOfflineSyncRepository mockSyncRepository;

    setUp(() {
      mockRemoteDataSource = MockFamilyRemoteDataSource();
      mockLocalDataSource = MockFamilyLocalDataSource();
      mockNetworkInfo = MockNetworkInfo();
      mockInvitationRepository = MockInvitationRepository();
      mockSyncRepository = MockFamilyOfflineSyncRepository();

      repository = FamilyRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
        networkInfo: mockNetworkInfo,
        invitationsRepository: mockInvitationRepository,
        syncRepository: mockSyncRepository,
      );
    });

    group('getFamilyChildren - FamilyDataExtractor Integration', () {
      test('should extract children from family DTO using FamilyDataExtractor', () async {
        // ARRANGE
        final now = DateTime.now();
        final childDto1 = ChildDto(
          id: 'child-1',
          name: 'Alice',
          age: 8,
          familyId: 'test-family-id',
          createdAt: now,
          updatedAt: now,
        );
        final childDto2 = ChildDto(
          id: 'child-2',
          name: 'Bob',
          age: 10,
          familyId: 'test-family-id',
          createdAt: now,
          updatedAt: now,
        );

        final familyDto = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          children: [childDto1, childDto2], // Children in family DTO
        );

        // Mock network connected
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

        // Mock local datasource returns empty (offline-first pattern)
        when(mockLocalDataSource.getFamilyChildren()).thenAnswer((_) async => []);

        // CRITICAL: Mock remote returns full family DTO (NEW BEHAVIOR)
        when(mockRemoteDataSource.getCurrentFamily()).thenAnswer((_) async => familyDto);

        // Mock local caching
        when(mockLocalDataSource.cacheChildren(any)).thenAnswer((_) async {
          return null;
        });

        // ACT
        final result = await repository.getCurrentFamily();

        // ASSERT
        expect(result.isOk, isTrue);
        final children = result.unwrap().children;
        expect(children, hasLength(2));
        expect(children[0].name, equals('Alice'));
        expect(children[1].name, equals('Bob'));

        // VERIFY: Repository calls getCurrentFamily (NEW BEHAVIOR)
        verify(mockRemoteDataSource.getCurrentFamily()).called(1);

        // VERIFY: Extracted children are cached as domain entities
        verify(mockLocalDataSource.cacheChildren(any)).called(1);
      });

      test('should handle family DTO with null children using FamilyDataExtractor', () async {
        // ARRANGE
        const familyDto = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          // children: null, // NULL CHILDREN - EDGE CASE
        );

        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.getFamilyChildren()).thenAnswer((_) async => []);
        when(mockRemoteDataSource.getCurrentFamily()).thenAnswer((_) async => familyDto);
        when(mockLocalDataSource.cacheChildren(any)).thenAnswer((_) async {
          return null;
        });

        // ACT
        final result = await repository.getCurrentFamily();

        // ASSERT
        expect(result.isOk, isTrue);
        final children = result.unwrap().children;
        expect(children, isEmpty); // FamilyDataExtractor returns empty list for null

        verify(mockRemoteDataSource.getCurrentFamily()).called(1);
        verify(mockLocalDataSource.cacheChildren([])).called(1); // Empty list cached
      });

      test('should handle family DTO with empty children list using FamilyDataExtractor', () async {
        // ARRANGE
        const familyDto = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          children: [], // EMPTY CHILDREN - EDGE CASE
        );

        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.getFamilyChildren()).thenAnswer((_) async => []);
        when(mockRemoteDataSource.getCurrentFamily()).thenAnswer((_) async => familyDto);
        when(mockLocalDataSource.cacheChildren(any)).thenAnswer((_) async {
          return null;
        });

        // ACT
        final result = await repository.getCurrentFamily();

        // ASSERT
        expect(result.isOk, isTrue);
        final children = result.unwrap().children;
        expect(children, isEmpty);

        verify(mockRemoteDataSource.getCurrentFamily()).called(1);
        verify(mockLocalDataSource.cacheChildren([])).called(1);
      });

      test('should fallback to local data when remote fails', () async {
        // ARRANGE
        final now = DateTime.now();
        final localChildren = [
          Child(
            id: 'child-1',
            name: 'Local Alice',
            age: 8,
            familyId: 'test-family-id',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.getFamilyChildren()).thenAnswer((_) async => localChildren);
        when(mockRemoteDataSource.getCurrentFamily()).thenThrow(Exception('Network error'));

        // ACT
        final result = await repository.getCurrentFamily();

        // ASSERT
        expect(result.isOk, isTrue);
        final children = result.unwrap().children;
        expect(children, hasLength(1));
        expect(children[0].name, equals('Local Alice'));

        // VERIFY: Remote was attempted but local fallback used
        verify(mockRemoteDataSource.getCurrentFamily()).called(1);
        verify(mockLocalDataSource.getFamilyChildren()).called(1);
      });

      test('should work offline using cached data', () async {
        // ARRANGE
        final now = DateTime.now();
        final localChildren = [
          Child(
            id: 'child-1',
            name: 'Cached Alice',
            age: 8,
            familyId: 'test-family-id',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false); // OFFLINE
        when(mockLocalDataSource.getFamilyChildren()).thenAnswer((_) async => localChildren);

        // ACT
        final result = await repository.getCurrentFamily();

        // ASSERT
        expect(result.isOk, isTrue);
        final children = result.unwrap().children;
        expect(children, hasLength(1));
        expect(children[0].name, equals('Cached Alice'));

        // VERIFY: No remote calls when offline
        verifyNever(mockRemoteDataSource.getCurrentFamily());
        verify(mockLocalDataSource.getFamilyChildren()).called(1);
      });
    });

    group('getFamilyVehicles - FamilyDataExtractor Integration', () {
      test('should extract vehicles from family DTO using FamilyDataExtractor', () async {
        // ARRANGE
        final now = DateTime.now();
        final vehicleDto1 = VehicleDto(
          id: 'vehicle-1',
          name: 'Family Van',
          capacity: 8,
          familyId: 'test-family-id',
          createdAt: now,
          updatedAt: now,
        );
        final vehicleDto2 = VehicleDto(
          id: 'vehicle-2',
          name: 'Sedan',
          capacity: 5,
          familyId: 'test-family-id',
          createdAt: now,
          updatedAt: now,
        );

        final familyDto = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          vehicles: [vehicleDto1, vehicleDto2], // Vehicles in family DTO
        );

        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.getFamilyVehicles()).thenAnswer((_) async => []);
        when(mockRemoteDataSource.getCurrentFamily()).thenAnswer((_) async => familyDto);
        when(mockLocalDataSource.cacheVehicles(any)).thenAnswer((_) async {
          return null;
        });

        // ACT
        final result = await repository.getCurrentFamily();

        // ASSERT
        expect(result.isOk, isTrue);
        final vehicles = result.unwrap().vehicles;
        expect(vehicles, hasLength(2));
        expect(vehicles[0].name, equals('Family Van'));
        expect(vehicles[1].name, equals('Sedan'));

        // VERIFY: Repository calls getCurrentFamily (NEW BEHAVIOR)
        verify(mockRemoteDataSource.getCurrentFamily()).called(1);

        // VERIFY: Extracted vehicles are cached as domain entities
        verify(mockLocalDataSource.cacheVehicles(any)).called(1);
      });

      test('should handle family DTO with null vehicles using FamilyDataExtractor', () async {
        // ARRANGE
        const familyDto = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          // vehicles: null, // NULL VEHICLES - EDGE CASE
        );

        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.getFamilyVehicles()).thenAnswer((_) async => []);
        when(mockRemoteDataSource.getCurrentFamily()).thenAnswer((_) async => familyDto);
        when(mockLocalDataSource.cacheVehicles(any)).thenAnswer((_) async {
          return null;
        });

        // ACT
        final result = await repository.getCurrentFamily();

        // ASSERT
        expect(result.isOk, isTrue);
        final vehicles = result.unwrap().vehicles;
        expect(vehicles, isEmpty); // FamilyDataExtractor returns empty list for null

        verify(mockRemoteDataSource.getCurrentFamily()).called(1);
        verify(mockLocalDataSource.cacheVehicles([])).called(1);
      });

      test('should handle family DTO with empty vehicles list using FamilyDataExtractor', () async {
        // ARRANGE
        const familyDto = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          vehicles: [], // EMPTY VEHICLES - EDGE CASE
        );

        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.getFamilyVehicles()).thenAnswer((_) async => []);
        when(mockRemoteDataSource.getCurrentFamily()).thenAnswer((_) async => familyDto);
        when(mockLocalDataSource.cacheVehicles(any)).thenAnswer((_) async {
          return null;
        });

        // ACT
        final result = await repository.getCurrentFamily();

        // ASSERT
        expect(result.isOk, isTrue);
        final vehicles = result.unwrap().vehicles;
        expect(vehicles, isEmpty);

        verify(mockRemoteDataSource.getCurrentFamily()).called(1);
        verify(mockLocalDataSource.cacheVehicles([])).called(1);
      });

      test('should fallback to local data when remote fails', () async {
        // ARRANGE
        final now = DateTime.now();
        final localVehicles = [
          Vehicle(
            id: 'vehicle-1',
            name: 'Local Van',
            capacity: 8,
            familyId: 'test-family-id',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.getFamilyVehicles()).thenAnswer((_) async => localVehicles);
        when(mockRemoteDataSource.getCurrentFamily()).thenThrow(Exception('Network error'));

        // ACT
        final result = await repository.getCurrentFamily();

        // ASSERT
        expect(result.isOk, isTrue);
        final vehicles = result.unwrap().vehicles;
        expect(vehicles, hasLength(1));
        expect(vehicles[0].name, equals('Local Van'));

        verify(mockRemoteDataSource.getCurrentFamily()).called(1);
        verify(mockLocalDataSource.getFamilyVehicles()).called(1);
      });

      test('should work offline using cached data', () async {
        // ARRANGE
        final now = DateTime.now();
        final localVehicles = [
          Vehicle(
            id: 'vehicle-1',
            name: 'Cached Van',
            capacity: 8,
            familyId: 'test-family-id',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false); // OFFLINE
        when(mockLocalDataSource.getFamilyVehicles()).thenAnswer((_) async => localVehicles);

        // ACT
        final result = await repository.getCurrentFamily();

        // ASSERT
        expect(result.isOk, isTrue);
        final vehicles = result.unwrap().vehicles;
        expect(vehicles, hasLength(1));
        expect(vehicles[0].name, equals('Cached Van'));

        verifyNever(mockRemoteDataSource.getCurrentFamily());
        verify(mockLocalDataSource.getFamilyVehicles()).called(1);
      });
    });

    group('Integration Tests - Complete Family Data Flow', () {
      test('should handle complete family data extraction with all collections', () async {
        // ARRANGE - COMPREHENSIVE INTEGRATION TEST
        final now = DateTime.now();
        final familyDto = FamilyDto(
          id: 'full-family-id',
          name: 'Complete Family',
          createdAt: now,
          updatedAt: now,
          children: [
            ChildDto(
              id: 'child-1',
              name: 'Alice',
              age: 8,
              familyId: 'full-family-id',
              createdAt: now,
              updatedAt: now,
            ),
            ChildDto(
              id: 'child-2',
              name: 'Bob',
              age: 10,
              familyId: 'full-family-id',
              createdAt: now,
              updatedAt: now,
            ),
          ],
          vehicles: [
            VehicleDto(
              id: 'vehicle-1',
              name: 'Van',
              capacity: 8,
              familyId: 'full-family-id',
              createdAt: now,
              updatedAt: now,
            ),
          ],
        );

        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.getFamilyChildren()).thenAnswer((_) async => []);
        when(mockLocalDataSource.getFamilyVehicles()).thenAnswer((_) async => []);
        when(mockRemoteDataSource.getCurrentFamily()).thenAnswer((_) async => familyDto);
        when(mockLocalDataSource.cacheChildren(any)).thenAnswer((_) async {
          return null;
        });
        when(mockLocalDataSource.cacheVehicles(any)).thenAnswer((_) async {
          return null;
        });

        // ACT - Test both extraction methods
        final familyResult = await repository.getCurrentFamily();

        // ASSERT - Verify both methods work with same family DTO
        expect(familyResult.isOk, isTrue);

        final family = familyResult.unwrap();
        final children = family.children;
        final vehicles = family.vehicles;

        expect(children, hasLength(2));
        expect(vehicles, hasLength(1));

        // VERIFY: Both methods use same remote call (optimization)
        verify(mockRemoteDataSource.getCurrentFamily()).called(2); // Once per method call
        verify(mockLocalDataSource.cacheChildren(any)).called(1);
        verify(mockLocalDataSource.cacheVehicles(any)).called(1);
      });
    });

    group('Error Handling Integration', () {
      test('should handle extraction errors gracefully when no local fallback', () async {
        // ARRANGE
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.getFamilyChildren()).thenAnswer((_) async => []); // Empty local cache
        when(mockRemoteDataSource.getCurrentFamily()).thenThrow(const NoFamilyException('No family found'));

        // ACT
        final result = await repository.getCurrentFamily();

        // ASSERT - TRUTH: With empty local cache and NoFamilyException, returns error
        expect(result.isErr, isTrue);
        expect(result.unwrapErr().message, contains('Failed to get children'));

        verify(mockRemoteDataSource.getCurrentFamily()).called(1);
        verify(mockLocalDataSource.getFamilyChildren()).called(1);
      });

      test('should handle local cache failures gracefully', () async {
        // ARRANGE
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(mockLocalDataSource.getFamilyChildren()).thenThrow(Exception('Cache error'));

        // ACT
        final result = await repository.getCurrentFamily();

        // ASSERT
        expect(result.isErr, isTrue);
        expect(result.unwrapErr().message, contains('Failed to get children from cache'));
      });
    });

    group('Unit Test - FamilyDataExtractor Direct Usage', () {
      test('should demonstrate FamilyDataExtractor being used by repository', () {
        // ARRANGE - Create test family DTO
        final now = DateTime.now();
        final familyDto = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          children: [
            ChildDto(
              id: 'child-1',
              name: 'Test Child',
              age: 8,
              familyId: 'test-family-id',
              createdAt: now,
              updatedAt: now,
            ),
          ],
          vehicles: [
            VehicleDto(
              id: 'vehicle-1',
              name: 'Test Vehicle',
              capacity: 5,
              familyId: 'test-family-id',
              createdAt: now,
              updatedAt: now,
            ),
          ],
        );

        // ACT - Test direct extractor usage (what repository does internally)
        final extractedChildren = FamilyDataExtractor.extractChildren(familyDto);
        final extractedVehicles = FamilyDataExtractor.extractVehicles(familyDto);

        // ASSERT - Verify extractor behavior
        expect(extractedChildren, hasLength(1));
        expect(extractedChildren[0].name, equals('Test Child'));
        expect(extractedVehicles, hasLength(1));
        expect(extractedVehicles[0].name, equals('Test Vehicle'));

        // TRUTH: This demonstrates the exact pattern used by the repository
        // Repository gets familyDto from remote, then calls FamilyDataExtractor.extract*()
      });
    });
  });
}