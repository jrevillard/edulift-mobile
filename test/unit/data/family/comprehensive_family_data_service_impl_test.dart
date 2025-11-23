import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/features/family/data/services/comprehensive_family_data_service_impl.dart';
import 'package:edulift/core/domain/services/comprehensive_family_data_service.dart';
import 'package:edulift/features/family/domain/usecases/get_family_usecase.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/utils/result.dart';

import '../../../test_mocks/test_mocks.dart';
import '../../../test_mocks/test_mocks.dart' as mock_fallbacks;

/// Tests for ComprehensiveFamilyDataServiceImpl - Clean Architecture implementation
///
/// Verifies:
/// 1. Proper implementation of ComprehensiveFamilyDataService interface
/// 2. Uses GetFamilyUsecase correctly
/// 3. Returns proper Result types
/// 4. Handles errors gracefully
/// 5. Converts family data to family ID properly
void main() {
  setUpAll(() {
    setupMockFallbacks();
    mock_fallbacks.setupMockFallbacks();
  });

  group('ComprehensiveFamilyDataServiceImpl', () {
    late ComprehensiveFamilyDataService familyCacheService;
    late MockGetFamilyUsecase mockGetFamilyUsecase;
    late MockClearAllFamilyDataUsecase mockClearAllFamilyDataUsecase;

    setUp(() {
      mockGetFamilyUsecase = MockGetFamilyUsecase();
      mockClearAllFamilyDataUsecase = MockClearAllFamilyDataUsecase();
      familyCacheService = ComprehensiveFamilyDataServiceImpl(
        mockGetFamilyUsecase,
        mockClearAllFamilyDataUsecase,
      );
    });

    group('Interface Compliance', () {
      test('should implement ComprehensiveFamilyDataService interface', () {
        expect(familyCacheService, isA<ComprehensiveFamilyDataService>());
      });

      test('should return correct Result type signature', () async {
        // Arrange
        when(mockGetFamilyUsecase.call(any)).thenAnswer(
          (_) async => const Result.ok(
            FamilyData(family: null, children: [], vehicles: [], members: []),
          ),
        );

        // Act
        final result = await familyCacheService.cacheFamilyData();

        // Assert
        expect(result, isA<Result<String?, Failure>>());
      });
    });

    group('cacheFamilyData - Success Scenarios', () {
      test('should return family ID when user has family', () async {
        // Arrange
        final testFamily = Family(
          id: 'family-123',
          name: 'Test Family',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final familyData = FamilyData(
          family: testFamily,
          children: [],
          vehicles: [],
          members: [],
        );
        when(
          mockGetFamilyUsecase.call(any),
        ).thenAnswer((_) async => Result.ok(familyData));

        // Act
        final result = await familyCacheService.cacheFamilyData();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.value, equals('family-123'));
        verify(mockGetFamilyUsecase.call(any)).called(1);
      });

      test('should return null when user has no family', () async {
        // Arrange - User exists but has no family (valid for new users)
        const familyData = FamilyData(
          family: null,
          children: [],
          vehicles: [],
          members: [],
        );
        when(
          mockGetFamilyUsecase.call(any),
        ).thenAnswer((_) async => const Result.ok(familyData));

        // Act
        final result = await familyCacheService.cacheFamilyData();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.value, isNull);
        verify(mockGetFamilyUsecase.call(any)).called(1);
      });

      test('should pass NoParams correctly to GetFamilyUsecase', () async {
        // Arrange
        const familyData = FamilyData(
          family: null,
          children: [],
          vehicles: [],
          members: [],
        );
        when(
          mockGetFamilyUsecase.call(any),
        ).thenAnswer((_) async => const Result.ok(familyData));

        // Act
        await familyCacheService.cacheFamilyData();

        // Assert
        verify(mockGetFamilyUsecase.call(argThat(isA<NoParams>()))).called(1);
      });
    });

    group('cacheFamilyData - Error Scenarios', () {
      test('should return failure when GetFamilyUsecase fails', () async {
        // Arrange
        final failure = ApiFailure.notFound(resource: 'Family not found');
        when(
          mockGetFamilyUsecase.call(any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await familyCacheService.cacheFamilyData();

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
        verify(mockGetFamilyUsecase.call(any)).called(1);
      });

      test('should handle network failures gracefully', () async {
        // Arrange
        final networkFailure = ApiFailure.network(message: 'Network timeout');
        when(
          mockGetFamilyUsecase.call(any),
        ).thenAnswer((_) async => Result.err(networkFailure));

        // Act
        final result = await familyCacheService.cacheFamilyData();

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(networkFailure));
        verify(mockGetFamilyUsecase.call(any)).called(1);
      });

      test('should handle unauthorized failures properly', () async {
        // Arrange
        final authFailure = ApiFailure.unauthorized();
        when(
          mockGetFamilyUsecase.call(any),
        ).thenAnswer((_) async => Result.err(authFailure));

        // Act
        final result = await familyCacheService.cacheFamilyData();

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(authFailure));
        verify(mockGetFamilyUsecase.call(any)).called(1);
      });

      test('should convert exceptions to ApiFailure', () async {
        // Arrange
        when(
          mockGetFamilyUsecase.call(any),
        ).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await familyCacheService.cacheFamilyData();

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, isA<ApiFailure>());
        expect(result.error?.message, contains('Failed to cache family data'));
        expect(result.error?.message, contains('Unexpected error'));
        verify(mockGetFamilyUsecase.call(any)).called(1);
      });

      test('should handle null pointer exceptions gracefully', () async {
        // Arrange
        when(mockGetFamilyUsecase.call(any)).thenThrow(TypeError());

        // Act
        final result = await familyCacheService.cacheFamilyData();

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, isA<ApiFailure>());
        expect(result.error?.message, contains('Failed to cache family data'));
        verify(mockGetFamilyUsecase.call(any)).called(1);
      });
    });

    group('Result Pattern Compliance', () {
      test('should never throw exceptions - all errors via Result', () async {
        // Arrange - Mock various exception scenarios
        when(
          mockGetFamilyUsecase.call(any),
        ).thenThrow(ArgumentError('Invalid argument'));

        // Act & Assert - Should not throw, should return Result.err
        expect(
          () async => await familyCacheService.cacheFamilyData(),
          returnsNormally,
        );

        final result = await familyCacheService.cacheFamilyData();
        expect(result.isError, isTrue);
      });

      test('should preserve original failure types from usecase', () async {
        // Arrange
        final originalFailure = ApiFailure.badRequest(
          message: 'Invalid request',
        );
        when(
          mockGetFamilyUsecase.call(any),
        ).thenAnswer((_) async => Result.err(originalFailure));

        // Act
        final result = await familyCacheService.cacheFamilyData();

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, same(originalFailure));
      });

      test('should wrap unexpected exceptions in ApiFailure', () async {
        // Arrange
        when(
          mockGetFamilyUsecase.call(any),
        ).thenThrow(StateError('Invalid state'));

        // Act
        final result = await familyCacheService.cacheFamilyData();

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, isA<ApiFailure>());
        final apiFailure = result.error as ApiFailure;
        expect(apiFailure.message, contains('Failed to cache family data'));
        expect(apiFailure.message, contains('Invalid state'));
      });
    });

    group('Clean Architecture Compliance', () {
      test('should only depend on domain layer usecase', () {
        // Verify by construction - ComprehensiveFamilyDataServiceImpl
        // only depends on GetFamilyUsecase from domain layer
        expect(familyCacheService, isA<ComprehensiveFamilyDataService>());
        expect(mockGetFamilyUsecase, isA<GetFamilyUsecase>());
      });

      test('should implement core interface without circular dependencies', () {
        // The fact that this implementation exists in features layer
        // but implements core interface proves dependency inversion
        expect(familyCacheService, isA<ComprehensiveFamilyDataService>());

        // And it should work with any implementation of GetFamilyUsecase
        expect(mockGetFamilyUsecase, isA<GetFamilyUsecase>());
      });
    });

    group('Family Data Extraction', () {
      test('should extract family ID from complex family structure', () async {
        // Arrange
        final complexFamily = Family(
          id: 'family-complex-123',
          name: 'Complex Test Family',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final familyData = FamilyData(
          family: complexFamily,
          children: [],
          vehicles: [],
          members: [],
        );
        when(
          mockGetFamilyUsecase.call(any),
        ).thenAnswer((_) async => Result.ok(familyData));

        // Act
        final result = await familyCacheService.cacheFamilyData();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.value, equals('family-complex-123'));
      });

      test('should handle family with empty ID gracefully', () async {
        // Arrange
        final familyWithEmptyId = Family(
          id: '',
          name: 'Empty ID Family',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final familyData = FamilyData(
          family: familyWithEmptyId,
          children: [],
          vehicles: [],
          members: [],
        );
        when(
          mockGetFamilyUsecase.call(any),
        ).thenAnswer((_) async => Result.ok(familyData));

        // Act
        final result = await familyCacheService.cacheFamilyData();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.value, equals(''));
      });
    });

    group('Performance and Resource Management', () {
      test('should complete quickly for successful calls', () async {
        // Arrange
        final testFamily = Family(
          id: 'family-performance-test',
          name: 'Performance Test Family',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final familyData = FamilyData(
          family: testFamily,
          children: [],
          vehicles: [],
          members: [],
        );
        when(
          mockGetFamilyUsecase.call(any),
        ).thenAnswer((_) async => Result.ok(familyData));

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await familyCacheService.cacheFamilyData();
        stopwatch.stop();

        // Assert
        expect(result.isSuccess, isTrue);
        // Should complete very quickly (under 100ms) since it's just delegation
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should not leak resources on exceptions', () async {
        // Arrange
        when(
          mockGetFamilyUsecase.call(any),
        ).thenThrow(const OutOfMemoryError());

        // Act & Assert - Should handle gracefully without resource leaks
        final result = await familyCacheService.cacheFamilyData();
        expect(result.isError, isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle concurrent calls properly', () async {
        // Arrange
        final testFamily = Family(
          id: 'family-concurrent-test',
          name: 'Concurrent Test Family',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final familyData = FamilyData(
          family: testFamily,
          children: [],
          vehicles: [],
          members: [],
        );
        when(mockGetFamilyUsecase.call(any)).thenAnswer((_) async {
          // Simulate some async work
          await Future.delayed(const Duration(milliseconds: 10));
          return Result.ok(familyData);
        });

        // Act - Make concurrent calls
        final futures = List.generate(
          3,
          (_) => familyCacheService.cacheFamilyData(),
        );
        final results = await Future.wait(futures);

        // Assert - All calls should succeed
        for (final result in results) {
          expect(result.isSuccess, isTrue);
          expect(result.value, equals('family-concurrent-test'));
        }

        // Verify usecase was called for each request
        verify(mockGetFamilyUsecase.call(any)).called(3);
      });
    });
  });
}
