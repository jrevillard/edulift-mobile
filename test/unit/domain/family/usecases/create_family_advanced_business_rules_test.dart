// EduLift Mobile - CreateFamilyUsecase Business Rules Test
// Focus: Validation and error scenarios matching actual implementation

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/features/family/domain/usecases/create_family_usecase.dart';
import 'package:edulift/core/domain/entities/family.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
    _provideFamilyDummyValues();
  });

  group('CreateFamilyUsecase - Business Rules & Error Propagation', () {
    late CreateFamilyUsecase usecase;
    late MockFamilyRepository mockRepository;
    late DateTime testDateTime;

    setUp(() {
      mockRepository = MockFamilyRepository();
      usecase = CreateFamilyUsecase(mockRepository);
      testDateTime = DateTime(2024, 1, 15, 10, 30);
    });

    group('Input Validation Tests', () {
      test('should reject empty family name', () async {
        // Arrange
        const params = CreateFamilyParams(name: '');

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: Must enforce business rules
        expect(result.isErr, isTrue);
        result.when(
          ok: (_) => fail('Expected error but got success'),
          err: (failure) {
            expect(failure, isA<ApiFailure>());
            expect(failure.message, contains('fieldRequired'));
          },
        );

        // Verify repository was never called
        verifyNever(mockRepository.createFamily(name: anyNamed('name')));
      });

      test('should reject whitespace-only names', () async {
        final whitespaceNames = ['   ', '\t\t', '\n\n', ' \t\n '];

        for (final name in whitespaceNames) {
          // Arrange
          final params = CreateFamilyParams(name: name);

          // Act
          final result = await usecase.call(params);

          // Assert - TRUTH: Whitespace-only names must be rejected
          expect(result.isErr, isTrue, reason: 'Should reject "$name"');
          result.when(
            ok: (_) => fail('Expected error for whitespace name: "$name"'),
            err: (failure) {
              expect(failure.message, contains('fieldRequired'));
            },
          );

          verifyNever(mockRepository.createFamily(name: anyNamed('name')));
          reset(mockRepository);
        }
      });

      test('should validate name length constraints', () async {
        // Test various invalid lengths based on InputValidator rules
        final invalidNames = [
          'A', // Too short
          'A' * 101, // Too long (assuming 100 char limit)
        ];

        for (final name in invalidNames) {
          // Arrange
          final params = CreateFamilyParams(name: name);

          // Act
          final result = await usecase.call(params);

          // Assert - TRUTH: Length constraints must be enforced
          expect(result.isErr, isTrue, reason: 'Should reject "$name"');
          result.when(
            ok: (_) => fail('Expected error for invalid length: "$name"'),
            err: (failure) {
              expect(failure, isA<ApiFailure>());
              expect(
                failure.message,
                anyOf([
                  contains('minimum'),
                  contains('maximum'),
                  contains('errorInvalidData'),
                ]),
              );
            },
          );

          verifyNever(mockRepository.createFamily(name: anyNamed('name')));
          reset(mockRepository);
        }
      });

      test('should trim names before validation and repository call', () async {
        // Arrange
        const params = CreateFamilyParams(name: '  Smith Family  ');
        when(mockRepository.createFamily(name: 'Smith Family')).thenAnswer(
          (_) async => Result.ok(
            Family(
              id: 'family-123',
              name: 'Smith Family',
              createdAt: testDateTime,
              updatedAt: testDateTime,
            ),
          ),
        );

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: Names must be trimmed before processing
        expect(result.isOk, isTrue);
        verify(mockRepository.createFamily(name: 'Smith Family')).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('Repository Error Propagation', () {
      test('should propagate server errors correctly', () async {
        // Arrange
        const params = CreateFamilyParams(name: 'Test Family');
        when(mockRepository.createFamily(name: 'Test Family')).thenAnswer(
          (_) async => Result.err(
            ApiFailure.serverError(message: 'Database connection failed'),
          ),
        );

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: Repository errors must be propagated
        expect(result.isErr, isTrue);
        result.when(
          ok: (_) => fail('Expected error but got success'),
          err: (failure) {
            expect(failure, isA<ApiFailure>());
            expect(failure.message, equals('Database connection failed'));
          },
        );

        verify(mockRepository.createFamily(name: 'Test Family')).called(1);
      });

      test('should propagate network errors correctly', () async {
        // Arrange
        const params = CreateFamilyParams(name: 'Network Test');
        when(mockRepository.createFamily(name: 'Network Test')).thenAnswer(
          (_) async =>
              Result.err(ApiFailure.network(message: 'No internet connection')),
        );

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: Network errors must be propagated
        expect(result.isErr, isTrue);
        result.when(
          ok: (_) => fail('Expected error but got success'),
          err: (failure) {
            expect(failure, isA<ApiFailure>());
            expect(failure.message, equals('No internet connection'));
          },
        );
      });

      test('should handle timeout errors', () async {
        // Arrange
        const params = CreateFamilyParams(name: 'Timeout Test');
        when(mockRepository.createFamily(name: 'Timeout Test')).thenAnswer(
          (_) async =>
              Result.err(ApiFailure.timeout(url: 'family-creation-endpoint')),
        );

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: Timeout errors must be properly categorized
        expect(result.isErr, isTrue);
        result.when(
          ok: (_) => fail('Expected error but got success'),
          err: (failure) {
            expect(failure, isA<ApiFailure>());
            expect(failure.message, contains('timed out'));
          },
        );
      });

      test('should handle validation errors from repository', () async {
        // Arrange
        const params = CreateFamilyParams(name: 'Duplicate Family');
        when(mockRepository.createFamily(name: 'Duplicate Family')).thenAnswer(
          (_) async => Result.err(
            ApiFailure.validationError(message: 'Family name already exists'),
          ),
        );

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: Repository validation errors must be propagated
        expect(result.isErr, isTrue);
        result.when(
          ok: (_) => fail('Expected error but got success'),
          err: (failure) {
            expect(failure, isA<ApiFailure>());
            expect(failure.message, equals('Family name already exists'));
          },
        );
      });
    });

    group('Success Scenarios', () {
      test('should create family successfully with valid input', () async {
        // Arrange
        const params = CreateFamilyParams(name: 'Smith Family');
        final expectedFamily = Family(
          id: 'family-123',
          name: 'Smith Family',
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        when(
          mockRepository.createFamily(name: 'Smith Family'),
        ).thenAnswer((_) async => Result.ok(expectedFamily));

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: Valid input must create family successfully
        expect(result.isOk, isTrue);
        result.when(
          ok: (family) {
            expect(family.id, equals('family-123'));
            expect(family.name, equals('Smith Family'));
            expect(family.createdAt, equals(testDateTime));
          },
          err: (failure) =>
              fail('Expected success but got error: ${failure.message}'),
        );

        verify(mockRepository.createFamily(name: 'Smith Family')).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should handle ASCII-only family names correctly', () async {
        // Arrange - Valid ASCII names only (validator restricts to a-zA-Z0-9\s\-')
        final validNames = [
          'Smith Family',
          'The O\'Connor Family',
          'Johnson-Brown Family',
          'Family123',
          'ABC Family',
        ];

        for (final name in validNames) {
          final params = CreateFamilyParams(name: name);
          final expectedFamily = Family(
            id: 'family-${name.hashCode}',
            name: name,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          when(
            mockRepository.createFamily(name: name),
          ).thenAnswer((_) async => Result.ok(expectedFamily));

          // Act
          final result = await usecase.call(params);

          // Assert - TRUTH: Valid ASCII names must be handled correctly
          expect(
            result.isOk,
            isTrue,
            reason: 'Valid ASCII name should be accepted: $name',
          );
          result.when(
            ok: (family) => expect(family.name, equals(name)),
            err: (failure) => fail(
              'Valid ASCII name should be accepted: $name, error: ${failure.message}',
            ),
          );

          verify(mockRepository.createFamily(name: name)).called(1);
          reset(mockRepository);
        }
      });

      test('should reject Unicode characters as per validator rules', () async {
        // Arrange - Unicode names that should be rejected by validator
        final unicodeNames = [
          'José García',
          'Familie Müller',
          '李家庭',
          'Семья Иванов',
        ];

        for (final name in unicodeNames) {
          // Act
          final result = await usecase.call(CreateFamilyParams(name: name));

          // Assert - TRUTH: Unicode names must be rejected by validator
          expect(
            result.isErr,
            isTrue,
            reason: 'Unicode name should be rejected: $name',
          );
          result.when(
            ok: (family) => fail('Unicode name should be rejected: $name'),
            err: (failure) {
              expect(
                failure.message,
                anyOf([
                  contains('invalid characters'),
                  contains('errorInvalidData'),
                ]),
              );
            },
          );

          verifyNever(mockRepository.createFamily(name: anyNamed('name')));
          reset(mockRepository);
        }
      });
    });

    group('Use Case Purity and Consistency', () {
      test('should be stateless across multiple calls', () async {
        // Arrange
        const params1 = CreateFamilyParams(name: 'Family 1');
        const params2 = CreateFamilyParams(name: 'Family 2');

        when(mockRepository.createFamily(name: anyNamed('name'))).thenAnswer((
          invocation,
        ) async {
          final name =
              invocation.namedArguments[const Symbol('name')] as String;
          return Result.ok(
            Family(
              id: 'family-${name.hashCode}',
              name: name,
              createdAt: testDateTime,
              updatedAt: testDateTime,
            ),
          );
        });

        // Act - Multiple calls should be independent
        final result1 = await usecase.call(params1);
        final result2 = await usecase.call(params2);

        // Assert - TRUTH: Use case must be stateless
        expect(result1.isOk, isTrue);
        expect(result2.isOk, isTrue);

        result1.when(
          ok: (family) => expect(family.name, equals('Family 1')),
          err: (_) => fail('First call should succeed'),
        );

        result2.when(
          ok: (family) => expect(family.name, equals('Family 2')),
          err: (_) => fail('Second call should succeed'),
        );

        verify(mockRepository.createFamily(name: 'Family 1')).called(1);
        verify(mockRepository.createFamily(name: 'Family 2')).called(1);
      });

      test('should handle concurrent calls correctly', () async {
        // Arrange
        final params = List.generate(
          5,
          (i) => CreateFamilyParams(name: 'Family $i'),
        );

        when(mockRepository.createFamily(name: anyNamed('name'))).thenAnswer((
          invocation,
        ) async {
          final name =
              invocation.namedArguments[const Symbol('name')] as String;
          await Future.delayed(
            const Duration(milliseconds: 10),
          ); // Simulate work
          return Result.ok(
            Family(
              id: 'family-${name.hashCode}',
              name: name,
              createdAt: testDateTime,
              updatedAt: testDateTime,
            ),
          );
        });

        // Act - Concurrent calls
        final futures = params.map((param) => usecase.call(param));
        final results = await Future.wait(futures);

        // Assert - TRUTH: Concurrent calls must all succeed independently
        for (var i = 0; i < results.length; i++) {
          expect(results[i].isOk, isTrue, reason: 'Call $i should succeed');
          results[i].when(
            ok: (family) => expect(family.name, equals('Family $i')),
            err: (_) => fail('Concurrent call $i should not fail'),
          );
        }

        // Verify all calls were made
        for (var i = 0; i < 5; i++) {
          verify(mockRepository.createFamily(name: 'Family $i')).called(1);
        }
      });
    });
  });
}

/// Provide dummy values for Family domain entities
void _provideFamilyDummyValues() {
  final testDateTime = DateTime(2024, 1, 15, 10, 30);

  provideDummy<Family>(
    Family(
      id: 'dummy-family-id',
      name: 'Dummy Family',
      createdAt: testDateTime,
      updatedAt: testDateTime,
    ),
  );

  provideDummy<CreateFamilyParams>(
    const CreateFamilyParams(name: 'Dummy Family Params'),
  );

  provideDummy<Result<Family, ApiFailure>>(
    Result.ok(
      Family(
        id: 'dummy-result-family',
        name: 'Dummy Result Family',
        createdAt: testDateTime,
        updatedAt: testDateTime,
      ),
    ),
  );
}
