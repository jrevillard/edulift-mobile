import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/features/family/domain/usecases/create_family_usecase.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
  });
  group('CreateFamilyUsecase - Comprehensive Tests', () {
    late CreateFamilyUsecase usecase;
    late MockFamilyRepository mockRepository;
    late Family testFamily;
    late DateTime testDate;

    setUp(() {
      mockRepository = MockFamilyRepository();
      usecase = CreateFamilyUsecase(mockRepository);
      testDate = DateTime.parse('2024-01-10T08:00:00.000Z');

      testFamily = Family(
        id: 'family-123',
        name: 'Test Family',
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    group('Input Validation - Business Rules', () {
      test('should reject empty family name', () async {
        // Arrange
        const params = CreateFamilyParams(name: '');

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isErr, isTrue);
        result.when(
          ok: (family) => fail('Expected error but got success'),
          err: (failure) {
            expect(failure, isA<ApiFailure>());
            expect(failure.message, contains('fieldRequired'));
          },
        );

        // Verify repository was never called
        verifyNever(mockRepository.createFamily(name: anyNamed('name')));
      });

      test('should reject whitespace-only family name', () async {
        // Test various whitespace scenarios
        final whitespaceNames = [
          '   ', // Spaces only
          '\t\t', // Tabs only
          '\n\n', // Newlines only
          ' \t\n ', // Mixed whitespace
        ];

        for (final name in whitespaceNames) {
          // Arrange
          final params = CreateFamilyParams(name: name);

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isErr, isTrue, reason: 'Should reject "$name"');
          result.when(
            ok: (family) => fail('Expected error for whitespace name: "$name"'),
            err: (failure) {
              expect(failure.message, contains('fieldRequired'));
            },
          );

          // Verify repository was never called
          verifyNever(mockRepository.createFamily(name: anyNamed('name')));
          reset(mockRepository);
        }
      });

      test('should trim family name and validate trimmed version', () async {
        // Arrange - Name with leading/trailing whitespace
        const params = CreateFamilyParams(name: '  Valid Family Name  ');
        when(mockRepository.createFamily(name: 'Valid Family Name')).thenAnswer(
          (_) async =>
              Result.ok(testFamily.copyWith(name: 'Valid Family Name')),
        );

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isOk, isTrue);
        verify(
          mockRepository.createFamily(name: 'Valid Family Name'),
        ).called(1);
      });

      test(
        'should reject names that are too short (less than 2 characters)',
        () async {
          // Test single character names
          final shortNames = ['A', '1', ' ', '-', '\''];

          for (final name in shortNames) {
            // Arrange
            final params = CreateFamilyParams(name: name);

            // Act
            final result = await usecase.call(params);

            // Assert
            expect(
              result.isErr,
              isTrue,
              reason: 'Should reject short name: "$name"',
            );
            result.when(
              ok: (family) => fail('Expected error for short name: "$name"'),
              err: (failure) {
                expect(
                  failure.message,
                  anyOf([
                    contains('minimum 2 characters'),
                    contains('errorInvalidData'),
                    contains('fieldRequired'),
                  ]),
                );
              },
            );

            verifyNever(mockRepository.createFamily(name: anyNamed('name')));
            reset(mockRepository);
          }
        },
      );

      test(
        'should reject names that are too long (over 100 characters)',
        () async {
          // Arrange - 101 character name
          final longName = 'A' * 101;
          final params = CreateFamilyParams(name: longName);

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isErr, isTrue);
          result.when(
            ok: (family) => fail('Expected error for long name'),
            err: (failure) {
              expect(
                failure.message,
                anyOf([
                  contains('maximum 100 characters'),
                  contains('errorInvalidData'),
                ]),
              );
            },
          );

          verifyNever(mockRepository.createFamily(name: anyNamed('name')));
        },
      );

      test('should accept names at boundary lengths', () async {
        // Test 2-character name (minimum)
        const params2Char = CreateFamilyParams(name: 'AB');
        when(
          mockRepository.createFamily(name: 'AB'),
        ).thenAnswer((_) async => Result.ok(testFamily.copyWith(name: 'AB')));

        final result2Char = await usecase.call(params2Char);
        expect(result2Char.isOk, isTrue);
        verify(mockRepository.createFamily(name: 'AB')).called(1);

        reset(mockRepository);

        // Test 100-character name (maximum)
        final name100Char = 'A' * 100;
        final params100Char = CreateFamilyParams(name: name100Char);
        when(mockRepository.createFamily(name: name100Char)).thenAnswer(
          (_) async => Result.ok(testFamily.copyWith(name: name100Char)),
        );

        final result100Char = await usecase.call(params100Char);
        expect(result100Char.isOk, isTrue);
        verify(mockRepository.createFamily(name: name100Char)).called(1);
      });

      test('should accept names with valid characters', () async {
        final validNames = [
          'Smith Family', // Letters and space
          'The O\'Connor Family', // Apostrophe
          'Smith-Johnson Family', // Hyphen
          'Family123', // Numbers
          'ABC123 Family', // Mixed letters and numbers
          'Rodriguez-O\'Malley', // Multiple special chars
          'Family Name 2024', // Numbers at end
          'A B', // Minimal valid
        ];

        for (final name in validNames) {
          // Arrange
          final params = CreateFamilyParams(name: name);
          when(
            mockRepository.createFamily(name: name),
          ).thenAnswer((_) async => Result.ok(testFamily.copyWith(name: name)));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(
            result.isOk,
            isTrue,
            reason: 'Should accept valid name: "$name"',
          );
          result.when(
            ok: (family) => expect(family.name, equals(name)),
            err: (failure) => fail(
              'Expected success for valid name: "$name", got error: ${failure.message}',
            ),
          );

          verify(mockRepository.createFamily(name: name)).called(1);
          reset(mockRepository);
        }
      });
    });

    group('Repository Integration', () {
      test(
        'should call repository with trimmed name when validation passes',
        () async {
          // Arrange
          const params = CreateFamilyParams(name: '  Smith Family  ');
          when(
            mockRepository.createFamily(name: 'Smith Family'),
          ).thenAnswer((_) async => Result.ok(testFamily));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isOk, isTrue);
          verify(mockRepository.createFamily(name: 'Smith Family')).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test('should return family when repository succeeds', () async {
        // Arrange
        const params = CreateFamilyParams(name: 'Smith Family');
        final expectedFamily = testFamily.copyWith(name: 'Smith Family');
        when(
          mockRepository.createFamily(name: 'Smith Family'),
        ).thenAnswer((_) async => Result.ok(expectedFamily));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isOk, isTrue);
        result.when(
          ok: (family) {
            expect(family.id, equals(expectedFamily.id));
            expect(family.name, equals('Smith Family'));
          },
          err: (failure) =>
              fail('Expected success but got failure: ${failure.message}'),
        );
      });

      test('should propagate repository errors correctly', () async {
        // Test different types of repository failures
        final repositoryErrors = [
          ApiFailure.serverError(message: 'Database connection failed'),
          ApiFailure.network(message: 'No internet connection'),
          ApiFailure.validationError(message: 'Name already exists'),
          ApiFailure.unauthorized(),
          ApiFailure.validationError(message: 'Insufficient permissions'),
          ApiFailure.notFound(resource: 'Resource'),
          ApiFailure.validationError(message: 'Family name conflict'),
          ApiFailure.validationError(message: 'Too many requests'),
        ];

        for (final error in repositoryErrors) {
          // Arrange
          const params = CreateFamilyParams(name: 'Smith Family');
          when(
            mockRepository.createFamily(name: 'Smith Family'),
          ).thenAnswer((_) async => Result.err(error));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(
            result.isErr,
            isTrue,
            reason: 'Should propagate error: ${error.message}',
          );
          result.when(
            ok: (family) =>
                fail('Expected error but got success for: ${error.message}'),
            err: (failure) {
              expect(failure.runtimeType, equals(error.runtimeType));
              expect(failure.message, equals(error.message));
            },
          );

          verify(mockRepository.createFamily(name: 'Smith Family')).called(1);
          reset(mockRepository);
        }
      });

      test('should handle repository timeout gracefully', () async {
        // Arrange - Simulate timeout
        const params = CreateFamilyParams(name: 'Smith Family');
        when(mockRepository.createFamily(name: 'Smith Family')).thenAnswer((
          _,
        ) async {
          await Future.delayed(const Duration(seconds: 1));
          return Result.err(ApiFailure.serverError(message: 'Request timeout'));
        });

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isErr, isTrue);
        result.when(
          ok: (family) => fail('Expected timeout error'),
          err: (failure) {
            expect(failure.message, contains('timeout'));
          },
        );
      });
    });

    group('Business Logic Validation', () {
      test('should enforce business rules consistently', () async {
        // Test business rule consistency across different scenarios
        final businessRuleTests = [
          {
            'name': '',
            'shouldFail': true,
            'reason': 'Empty name violates business rule',
          },
          {
            'name': 'A',
            'shouldFail': true,
            'reason': 'Too short violates business rule',
          },
          {
            'name': 'AB',
            'shouldFail': false,
            'reason': 'Minimum length meets business rule',
          },
          {
            'name': 'Valid Family',
            'shouldFail': false,
            'reason': 'Standard name meets business rule',
          },
          {
            'name': '  Valid Name  ',
            'shouldFail': false,
            'reason': 'Trimmed name meets business rule',
          },
        ];

        for (final test in businessRuleTests) {
          final name = test['name'] as String;
          final shouldFail = test['shouldFail'] as bool;
          final reason = test['reason'] as String;

          // Arrange
          final params = CreateFamilyParams(name: name);
          if (!shouldFail) {
            final trimmedName = name.trim();
            when(mockRepository.createFamily(name: trimmedName)).thenAnswer(
              (_) async => Result.ok(testFamily.copyWith(name: trimmedName)),
            );
          }

          // Act
          final result = await usecase.call(params);

          // Assert
          if (shouldFail) {
            expect(result.isErr, isTrue, reason: reason);
          } else {
            expect(result.isOk, isTrue, reason: reason);
          }

          reset(mockRepository);
        }
      });

      test('should be a pure function (no side effects)', () async {
        // Arrange - Call with same params multiple times
        const params = CreateFamilyParams(name: 'Test Family');
        when(
          mockRepository.createFamily(name: 'Test Family'),
        ).thenAnswer((_) async => Result.ok(testFamily));

        // Act - Multiple calls should be identical
        final result1 = await usecase.call(params);
        final result2 = await usecase.call(params);
        final result3 = await usecase.call(params);

        // Assert - Results should be consistent (pure function behavior)
        expect(result1.isOk, isTrue);
        expect(result2.isOk, isTrue);
        expect(result3.isOk, isTrue);

        // All calls should produce same result type
        expect(result1.runtimeType, equals(result2.runtimeType));
        expect(result2.runtimeType, equals(result3.runtimeType));

        // Repository should be called each time (no caching side effects)
        verify(mockRepository.createFamily(name: 'Test Family')).called(3);
      });

      test('should maintain referential transparency', () async {
        // Same input should always produce same output type (referential transparency)
        const params = CreateFamilyParams(name: 'Consistent Family');

        // Test with success scenario
        when(
          mockRepository.createFamily(name: 'Consistent Family'),
        ).thenAnswer((_) async => Result.ok(testFamily));

        final successResult1 = await usecase.call(params);
        final successResult2 = await usecase.call(params);

        expect(successResult1.isOk, equals(successResult2.isOk));

        reset(mockRepository);

        // Test with failure scenario
        when(mockRepository.createFamily(name: 'Consistent Family')).thenAnswer(
          (_) async => Result.err(ApiFailure.serverError(message: 'Error')),
        );

        final failureResult1 = await usecase.call(params);
        final failureResult2 = await usecase.call(params);

        expect(failureResult1.isErr, equals(failureResult2.isErr));
      });
    });

    group('Edge Cases and Robustness', () {
      test('should be stateless across multiple calls', () async {
        // Arrange - Multiple params
        const params1 = CreateFamilyParams(name: 'Smith Family');
        const params2 = CreateFamilyParams(name: 'Johnson Family');
        const params3 = CreateFamilyParams(name: 'Brown Family');

        when(mockRepository.createFamily(name: anyNamed('name'))).thenAnswer((
          invocation,
        ) async {
          final name =
              invocation.namedArguments[const Symbol('name')] as String;
          return Result.ok(testFamily.copyWith(name: name));
        });

        // Act - Call multiple times
        final result1 = await usecase.call(params1);
        final result2 = await usecase.call(params2);
        final result3 = await usecase.call(params3);

        // Assert - All should succeed independently
        expect(result1.isOk, isTrue);
        expect(result2.isOk, isTrue);
        expect(result3.isOk, isTrue);

        result1.when(
          ok: (family) => expect(family.name, equals('Smith Family')),
          err: (_) {},
        );
        result2.when(
          ok: (family) => expect(family.name, equals('Johnson Family')),
          err: (_) {},
        );
        result3.when(
          ok: (family) => expect(family.name, equals('Brown Family')),
          err: (_) {},
        );

        // Verify each call was made
        verify(mockRepository.createFamily(name: 'Smith Family')).called(1);
        verify(mockRepository.createFamily(name: 'Johnson Family')).called(1);
        verify(mockRepository.createFamily(name: 'Brown Family')).called(1);
      });

      test('should handle concurrent calls correctly', () async {
        // Arrange
        final params = List.generate(
          10,
          (i) => CreateFamilyParams(name: 'Family $i'),
        );

        when(mockRepository.createFamily(name: anyNamed('name'))).thenAnswer((
          invocation,
        ) async {
          final name =
              invocation.namedArguments[const Symbol('name')] as String;
          // Simulate some processing time
          await Future.delayed(const Duration(milliseconds: 10));
          return Result.ok(testFamily.copyWith(name: name));
        });

        // Act - Call concurrently
        final futures = params.map((param) => usecase.call(param));
        final results = await Future.wait(futures);

        // Assert - All should succeed
        for (var i = 0; i < results.length; i++) {
          expect(results[i].isOk, isTrue, reason: 'Call $i should succeed');
          results[i].when(
            ok: (family) => expect(family.name, equals('Family $i')),
            err: (_) => fail('Call $i should not fail'),
          );
        }

        // Verify all calls were made
        for (var i = 0; i < 10; i++) {
          verify(mockRepository.createFamily(name: 'Family $i')).called(1);
        }
      });

      test('should handle memory pressure scenarios', () async {
        // Test with large valid name (stress test)
        final largeName = 'A' * 99; // Max valid length
        final params = CreateFamilyParams(name: largeName);
        when(mockRepository.createFamily(name: largeName)).thenAnswer(
          (_) async => Result.ok(testFamily.copyWith(name: largeName)),
        );

        // Act - Multiple calls with large data
        final futures = List.generate(100, (_) => usecase.call(params));

        final stopwatch = Stopwatch()..start();
        final results = await Future.wait(futures);
        stopwatch.stop();

        // Assert - Should handle without issues
        expect(results.every((r) => r.isOk), isTrue);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
        ); // Should be reasonably fast

        // Each call should succeed
        for (final result in results) {
          result.when(
            ok: (family) => expect(family.name, equals(largeName)),
            err: (failure) => fail('Should not fail: ${failure.message}'),
          );
        }
      });
    });
  });
}
