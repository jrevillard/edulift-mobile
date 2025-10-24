import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/features/family/domain/usecases/leave_family_usecase.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
  });

  group('LeaveFamilyUsecase', () {
    late LeaveFamilyUsecase usecase;
    late MockFamilyRepository mockFamilyRepository;
    late MockComprehensiveFamilyDataService mockFamilyDataService;

    setUp(() {
      mockFamilyRepository = MockFamilyRepository();
      mockFamilyDataService = MockComprehensiveFamilyDataService();
      usecase = LeaveFamilyUsecase(mockFamilyRepository, mockFamilyDataService);
    });

    group('Successful leave family', () {
      test('should leave family and clear data successfully', () async {
        // Arrange
        // Mock getCurrentFamily first
        when(mockFamilyRepository.getCurrentFamily()).thenAnswer(
          (_) async => Result.ok(
            Family(
              id: 'test-family-123',
              name: 'Test Family',
              createdAt: DateTime(2024),
              updatedAt: DateTime(2024),
            ),
          ),
        );
        when(
          mockFamilyRepository.leaveFamily(familyId: anyNamed('familyId')),
        ).thenAnswer((_) async => const Result.ok(null));
        when(
          mockFamilyDataService.clearFamilyData(),
        ).thenAnswer((_) async => const Result.ok(null));

        // Act
        final result = await usecase.call(
          const LeaveFamilyParams(familyId: 'test-family-123'),
        );

        // Assert
        expect(result.isOk, isTrue);
        expect(result.unwrap().requiresOnboarding, isTrue);

        verify(mockFamilyRepository.getCurrentFamily()).called(1);
        verify(
          mockFamilyRepository.leaveFamily(familyId: 'test-family-123'),
        ).called(1);
        verify(mockFamilyDataService.clearFamilyData()).called(1);
      });

      test('should succeed even if data clearing fails', () async {
        // Arrange - API succeeds but cache clearing fails
        // Mock getCurrentFamily first
        when(mockFamilyRepository.getCurrentFamily()).thenAnswer(
          (_) async => Result.ok(
            Family(
              id: 'test-family-123',
              name: 'Test Family',
              createdAt: DateTime(2024),
              updatedAt: DateTime(2024),
            ),
          ),
        );
        when(
          mockFamilyRepository.leaveFamily(familyId: anyNamed('familyId')),
        ).thenAnswer((_) async => const Result.ok(null));
        when(mockFamilyDataService.clearFamilyData()).thenAnswer(
          (_) async =>
              Result.err(ApiFailure.serverError(message: 'Cache clear failed')),
        );

        // Act
        final result = await usecase.call(
          const LeaveFamilyParams(familyId: 'test-family-123'),
        );

        // Assert - Should still succeed since API call worked
        expect(result.isOk, isTrue);
        expect(result.unwrap().requiresOnboarding, isTrue);

        verify(mockFamilyRepository.getCurrentFamily()).called(1);
        verify(
          mockFamilyRepository.leaveFamily(familyId: 'test-family-123'),
        ).called(1);
        verify(mockFamilyDataService.clearFamilyData()).called(1);
      });
    });

    group('Failed leave family', () {
      test('should return failure when API call fails', () async {
        // Arrange
        final apiFailure = ApiFailure.unauthorized();
        // Mock getCurrentFamily first
        when(mockFamilyRepository.getCurrentFamily()).thenAnswer(
          (_) async => Result.ok(
            Family(
              id: 'test-family-123',
              name: 'Test Family',
              createdAt: DateTime(2024),
              updatedAt: DateTime(2024),
            ),
          ),
        );
        when(
          mockFamilyRepository.leaveFamily(familyId: anyNamed('familyId')),
        ).thenAnswer((_) async => Result.err(apiFailure));

        // Act
        final result = await usecase.call(
          const LeaveFamilyParams(familyId: 'test-family-123'),
        );

        // Assert
        expect(result.isErr, isTrue);
        expect(result.unwrapErr(), equals(apiFailure));

        verify(mockFamilyRepository.getCurrentFamily()).called(1);
        verify(
          mockFamilyRepository.leaveFamily(familyId: 'test-family-123'),
        ).called(1);
        // clearFamilyData should not be called if API fails
        verifyNever(mockFamilyDataService.clearFamilyData());
      });

      test('should handle not found error', () async {
        // Arrange
        final notFoundFailure = ApiFailure.notFound(
          resource: 'User not in family',
        );
        // Mock getCurrentFamily first
        when(mockFamilyRepository.getCurrentFamily()).thenAnswer(
          (_) async => Result.ok(
            Family(
              id: 'test-family-123',
              name: 'Test Family',
              createdAt: DateTime(2024),
              updatedAt: DateTime(2024),
            ),
          ),
        );
        when(
          mockFamilyRepository.leaveFamily(familyId: anyNamed('familyId')),
        ).thenAnswer((_) async => Result.err(notFoundFailure));

        // Act
        final result = await usecase.call(
          const LeaveFamilyParams(familyId: 'test-family-123'),
        );

        // Assert
        expect(result.isErr, isTrue);
        expect(result.unwrapErr(), equals(notFoundFailure));

        verify(mockFamilyRepository.getCurrentFamily()).called(1);
        verify(
          mockFamilyRepository.leaveFamily(familyId: 'test-family-123'),
        ).called(1);
        verifyNever(mockFamilyDataService.clearFamilyData());
      });

      test('should handle validation error (e.g., last admin)', () async {
        // Arrange
        final validationFailure = ApiFailure.validationError(
          message: 'Cannot leave - last admin',
        );
        // Mock getCurrentFamily first
        when(mockFamilyRepository.getCurrentFamily()).thenAnswer(
          (_) async => Result.ok(
            Family(
              id: 'test-family-123',
              name: 'Test Family',
              createdAt: DateTime(2024),
              updatedAt: DateTime(2024),
            ),
          ),
        );
        when(
          mockFamilyRepository.leaveFamily(familyId: anyNamed('familyId')),
        ).thenAnswer((_) async => Result.err(validationFailure));

        // Act
        final result = await usecase.call(
          const LeaveFamilyParams(familyId: 'test-family-123'),
        );

        // Assert
        expect(result.isErr, isTrue);
        expect(result.unwrapErr(), equals(validationFailure));

        verify(mockFamilyRepository.getCurrentFamily()).called(1);
        verify(
          mockFamilyRepository.leaveFamily(familyId: 'test-family-123'),
        ).called(1);
        verifyNever(mockFamilyDataService.clearFamilyData());
      });
    });

    group('LeaveFamilyParams', () {
      test('should be equal instances', () {
        // Arrange
        const params1 = LeaveFamilyParams(familyId: 'test-family-123');
        const params2 = LeaveFamilyParams(familyId: 'test-family-123');

        // Assert
        expect(params1, equals(params2));
        expect(params1.hashCode, equals(params2.hashCode));
      });
    });

    group('LeaveFamilyResult', () {
      test('should be equal when requiresOnboarding is same', () {
        // Arrange
        const result1 = LeaveFamilyResult(requiresOnboarding: true);
        const result2 = LeaveFamilyResult(requiresOnboarding: true);
        const result3 = LeaveFamilyResult(requiresOnboarding: false);

        // Assert
        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
        expect(result1, isNot(equals(result3)));
      });
    });
  });
}
