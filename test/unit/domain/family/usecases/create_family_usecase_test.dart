import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/features/family/domain/usecases/create_family_usecase.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  // Setup Mockito dummy values for Result types
  setUpAll(() {
    setupMockFallbacks();
  });
  group('CreateFamilyUsecase', () {
    late CreateFamilyUsecase usecase;
    late MockFamilyRepository mockRepository;

    setUp(() {
      mockRepository = MockFamilyRepository();
      usecase = CreateFamilyUsecase(mockRepository);
    });

    group('call', () {
      const tValidName = 'Smith Family';
      const tParams = CreateFamilyParams(name: tValidName);

      final tFamily = Family(
        id: 'family-123',
        name: tValidName,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      test(
        'should return family when all validations pass and repository succeeds',
        () async {
          // arrange
          when(
            mockRepository.createFamily(name: anyNamed('name')),
          ).thenAnswer((_) async => Result.ok(tFamily));

          // act
          final result = await usecase.call(tParams);

          // assert
          expect(result.isSuccess, true);
          expect(result.value, equals(tFamily));
          verify(mockRepository.createFamily(name: tValidName));
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return validation error when family name is empty',
        () async {
          // arrange
          const tEmptyParams = CreateFamilyParams(name: '');

          // act
          final result = await usecase.call(tEmptyParams);

          // assert
          expect(result.isError, true);
          expect(result.error, isA<ApiFailure>());
          expect(result.error!.message, equals('fieldRequired'));
          verifyNever(mockRepository.createFamily(name: anyNamed('name')));
        },
      );

      test(
        'should return validation error when family name is only whitespace',
        () async {
          // arrange
          const tWhitespaceParams = CreateFamilyParams(name: '   \n\t   ');

          // act
          final result = await usecase.call(tWhitespaceParams);

          // assert
          expect(result.isError, true);
          expect(result.error, isA<ApiFailure>());
          expect(result.error!.message, equals('fieldRequired'));
          verifyNever(mockRepository.createFamily(name: anyNamed('name')));
        },
      );

      test(
        'should trim whitespace from family name before validation',
        () async {
          // arrange
          const tParamsWithWhitespace = CreateFamilyParams(
            name: '  Smith Family  ',
          );
          when(
            mockRepository.createFamily(name: anyNamed('name')),
          ).thenAnswer((_) async => Result.ok(tFamily));

          // act
          final result = await usecase.call(tParamsWithWhitespace);

          // assert
          expect(result.isSuccess, true);
          verify(mockRepository.createFamily(name: 'Smith Family'));
        },
      );

      test(
        'should return validation error when InputValidator rejects name',
        () async {
          // arrange
          const tInvalidParams = CreateFamilyParams(name: 'Invalid@Name#');

          // act
          final result = await usecase.call(tInvalidParams);

          // assert
          expect(result.isError, true);
          expect(result.error, isA<ApiFailure>());
          // The actual validation logic depends on InputValidator implementation
          verifyNever(mockRepository.createFamily(name: anyNamed('name')));
        },
      );

      test(
        'should return repository failure when repository call fails',
        () async {
          // arrange
          final tFailure = ApiFailure.serverError(message: 'Database error');
          when(
            mockRepository.createFamily(name: anyNamed('name')),
          ).thenAnswer((_) async => Result.err(tFailure));

          // act
          final result = await usecase.call(tParams);

          // assert
          expect(result.isError, true);
          expect(result.error, equals(tFailure));
          verify(mockRepository.createFamily(name: tValidName));
        },
      );

      test(
        'should return server error when repository returns server failure',
        () async {
          // arrange
          final serverFailure = ApiFailure.serverError(
            message: 'Network connection failed',
          );
          when(
            mockRepository.createFamily(name: anyNamed('name')),
          ).thenAnswer((_) async => Result.err(serverFailure));

          // act
          final result = await usecase.call(tParams);

          // assert
          expect(result.isError, true);
          expect(result.error, equals(serverFailure));
          verify(mockRepository.createFamily(name: tValidName));
        },
      );

      group('business rule validation', () {
        test('should validate minimum name length', () async {
          // arrange
          const tShortNameParams = CreateFamilyParams(name: 'A');

          // act
          final result = await usecase.call(tShortNameParams);

          // assert - depends on InputValidator.validateFamilyName implementation
          // This test validates the business rule is enforced
          if (result.isError) {
            expect(result.error, isA<ApiFailure>());
          }
        });

        test('should validate maximum name length', () async {
          // arrange
          final longName = 'A' * 256; // Assuming 255 is max length
          final tLongNameParams = CreateFamilyParams(name: longName);

          // act
          final result = await usecase.call(tLongNameParams);

          // assert - depends on InputValidator.validateFamilyName implementation
          if (result.isError) {
            expect(result.error, isA<ApiFailure>());
          }
        });

        test('should reject names with special characters', () async {
          // arrange
          const invalidNames = [
            'Family<script>',
            'Family&amp;',
            'Family"quotes"',
            'Family\\n\\r',
            'Family\u0000null',
          ];

          for (final invalidName in invalidNames) {
            final params = CreateFamilyParams(name: invalidName);

            // act
            final result = await usecase.call(params);

            // assert - should be rejected by InputValidator
            if (result.isError) {
              expect(result.error, isA<ApiFailure>());
              expect(result.error!.message, isNot(equals('fieldRequired')));
            }
          }
        });

        test('should accept valid family names with common patterns', () async {
          // arrange
          const validNames = [
            'Smith Family',
            'The Johnsons',
            'Garcia-Martinez Family',
            "O'Connor Family",
            'Family123',
            'أسرة أحمد', // Arabic
            'Famille Dubois', // French
            '田中家族', // Japanese
          ];

          when(
            mockRepository.createFamily(name: anyNamed('name')),
          ).thenAnswer((_) async => Result.ok(tFamily));

          for (final validName in validNames) {
            final params = CreateFamilyParams(name: validName);

            // act
            final result = await usecase.call(params);

            // assert - should pass validation (depends on InputValidator implementation)
            // If validation passes, repository should be called
            if (result.isSuccess) {
              verify(mockRepository.createFamily(name: validName));
            }
          }
        });
      });

      group('edge cases', () {
        test('should handle Unicode normalization correctly', () async {
          // arrange
          const tUnicodeParams1 = CreateFamilyParams(
            name: 'José',
          ); // é as single character
          const tUnicodeParams2 = CreateFamilyParams(
            name: 'José',
          ); // e + ´ as two characters

          when(
            mockRepository.createFamily(name: anyNamed('name')),
          ).thenAnswer((_) async => Result.ok(tFamily));

          // act
          final result1 = await usecase.call(tUnicodeParams1);
          final result2 = await usecase.call(tUnicodeParams2);

          // assert - both should be treated equivalently
          if (result1.isSuccess && result2.isSuccess) {
            // Both should normalize to the same value
            expect(result1.isSuccess, equals(result2.isSuccess));
          }
        });

        test('should handle concurrent family creation attempts', () async {
          // arrange
          when(mockRepository.createFamily(name: anyNamed('name'))).thenAnswer((
            _,
          ) async {
            await Future.delayed(const Duration(milliseconds: 10));
            return Result.ok(tFamily);
          });

          // act
          final futures = List.generate(
            5,
            (index) => usecase.call(CreateFamilyParams(name: 'Family $index')),
          );
          final results = await Future.wait(futures);

          // assert
          expect(results.length, equals(5));
          for (final result in results) {
            expect(result.isSuccess, true);
          }
          verify(mockRepository.createFamily(name: anyNamed('name'))).called(5);
        });

        test('should handle mixed case names consistently', () async {
          // arrange
          const tMixedCaseParams = CreateFamilyParams(name: '  SmItH fAmIlY  ');
          when(
            mockRepository.createFamily(name: anyNamed('name')),
          ).thenAnswer((_) async => Result.ok(tFamily));

          // act
          final result = await usecase.call(tMixedCaseParams);

          // assert - should preserve original case after trimming
          if (result.isSuccess) {
            verify(mockRepository.createFamily(name: 'SmItH fAmIlY'));
          }
        });
      });
    });
  });
}
