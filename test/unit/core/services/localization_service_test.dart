import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/core/domain/services/localization_service.dart';
import 'package:edulift/core/services/localization_service.dart';
import 'package:edulift/core/domain/entities/locale_info.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../test_mocks/test_mocks.dart';

// Test data builder for localization tests
class LocalizationTestDataBuilder {
  static const englishLocale = LocaleInfo(
    languageCode: 'en',
    countryCode: 'US',
  );
  static const frenchLocale = LocaleInfo(languageCode: 'fr', countryCode: 'FR');

  static void setupStorageService(MockTieredStorageService mockStorageService) {
    // Setup default behavior that can be overridden in specific tests
    when(
      mockStorageService.read('app_locale', any),
    ).thenAnswer((_) async => null);
    when(
      mockStorageService.store('app_locale', any, any),
    ).thenAnswer((_) async {});
  }
}

void main() {
  group('LocalizationService Tests - TDD London', () {
    late LocalizationService localizationService;
    late MockTieredStorageService mockStorageService;

    const englishLocale = LocalizationTestDataBuilder.englishLocale;
    const frenchLocale = LocalizationTestDataBuilder.frenchLocale;

    setUp(() {
      mockStorageService = MockTieredStorageService();
      LocalizationTestDataBuilder.setupStorageService(mockStorageService);
      localizationService = LocalizationServiceImpl(mockStorageService);
    });

    group('Current Locale Operations', () {
      test('should return current locale successfully', () async {
        // Act
        final result = await localizationService.getCurrentLocale();

        // Assert
        expect(result, isA<Result<LocaleInfo, Failure>>());
        expect(
          result.when(ok: (locale) => locale.languageCode, err: (_) => null),
          equals('fr'),
        ); // Default French locale
      });

      test('should return supported locales list', () {
        // Act
        final supportedLocales = localizationService.getSupportedLocales();

        // Assert
        expect(supportedLocales, hasLength(2));
        expect(supportedLocales, contains(englishLocale));
        expect(supportedLocales, contains(frenchLocale));
      });
    });

    group('Locale Support Validation', () {
      test('should identify English as supported', () {
        // Act
        final isSupported = localizationService.isLocaleSupported(
          englishLocale,
        );

        // Assert
        expect(isSupported, isTrue);
      });

      test('should identify French as supported', () {
        // Act
        final isSupported = localizationService.isLocaleSupported(frenchLocale);

        // Assert
        expect(isSupported, isTrue);
      });

      test('should identify unsupported locale', () {
        // Arrange
        const spanishLocale = LocaleInfo(languageCode: 'es', countryCode: 'ES');

        // Act
        final isSupported = localizationService.isLocaleSupported(
          spanishLocale,
        );

        // Assert
        expect(isSupported, isFalse);
      });
    });

    group('Locale Change Operations', () {
      test('should successfully change to supported locale', () async {
        // Arrange
        when(
          mockStorageService.store('app_locale', 'en_US', any),
        ).thenAnswer((_) async {});

        // Act
        final result = await localizationService.setLocale(englishLocale);

        // Assert
        expect(result, isA<Result<LocaleInfo, Failure>>());
        expect(
          result.when(ok: (locale) => locale, err: (_) => null),
          equals(englishLocale),
        );

        // Verify storage was called with specific locale code
        verify(mockStorageService.store('app_locale', 'en_US', any)).called(1);
      });

      test('should fail to change to unsupported locale', () async {
        // Arrange
        const spanishLocale = LocaleInfo(languageCode: 'es', countryCode: 'ES');

        // Act
        final result = await localizationService.setLocale(spanishLocale);

        // Assert
        expect(result, isA<Result<LocaleInfo, Failure>>());
        expect(
          result.when(ok: (_) => null, err: (failure) => failure.message),
          contains('Unsupported locale'),
        );
      });

      test('should handle storage failures gracefully', () async {
        // Arrange
        when(
          mockStorageService.store('app_locale', 'en_US', any),
        ).thenThrow(Exception('Storage error'));

        // Act
        final result = await localizationService.setLocale(englishLocale);

        // Assert
        expect(result, isA<Result<LocaleInfo, Failure>>());
        expect(
          result.when(ok: (_) => null, err: (failure) => failure.message),
          contains('Failed to persist locale'),
        );

        // Verify the specific storage call was attempted
        verify(mockStorageService.store('app_locale', 'en_US', any)).called(1);
      });
    });

    group('Locale Persistence', () {
      test('should load persisted English locale', () async {
        // Arrange - Create fresh mock for this test
        final freshMockStorageService = MockTieredStorageService();
        when(
          freshMockStorageService.read('app_locale', any),
        ).thenAnswer((_) async => 'en_US');
        when(
          freshMockStorageService.store('app_locale', any, any),
        ).thenAnswer((_) async {});

        // Create new service instance to trigger initialization
        final newService = LocalizationServiceImpl(freshMockStorageService);

        // Allow time for async initialization
        await Future.delayed(const Duration(milliseconds: 10));

        // Act
        final result = await newService.getCurrentLocale();

        // Assert
        expect(result, isA<Result<LocaleInfo, Failure>>());
        expect(
          result.when(ok: (locale) => locale.languageCode, err: (_) => null),
          equals('en'),
        );

        // Verify specific read call was made
        verify(freshMockStorageService.read('app_locale', any)).called(1);
      });

      test('should use default locale when storage returns null', () async {
        // Arrange - Create fresh mock for this test
        final freshMockStorageService = MockTieredStorageService();
        when(
          freshMockStorageService.read('app_locale', any),
        ).thenAnswer((_) async => null);
        when(
          freshMockStorageService.store('app_locale', any, any),
        ).thenAnswer((_) async {});

        // Create new service instance to trigger initialization
        final newService = LocalizationServiceImpl(freshMockStorageService);

        // Allow time for async initialization
        await Future.delayed(const Duration(milliseconds: 10));

        // Act
        final result = await newService.getCurrentLocale();

        // Assert
        expect(result, isA<Result<LocaleInfo, Failure>>());
        expect(
          result.when(ok: (locale) => locale.languageCode, err: (_) => null),
          equals('fr'),
        ); // Default French

        // Verify read call was made
        verify(freshMockStorageService.read('app_locale', any)).called(1);
      });

      test('should handle invalid persisted locale format', () async {
        // Arrange - Create fresh mock for this test
        final freshMockStorageService = MockTieredStorageService();
        when(
          freshMockStorageService.read('app_locale', any),
        ).thenAnswer((_) async => 'invalid_format');
        when(
          freshMockStorageService.store('app_locale', any, any),
        ).thenAnswer((_) async {});

        // Create new service instance to trigger initialization
        final newService = LocalizationServiceImpl(freshMockStorageService);

        // Allow time for async initialization
        await Future.delayed(const Duration(milliseconds: 10));

        // Act
        final result = await newService.getCurrentLocale();

        // Assert - should fall back to default
        expect(result, isA<Result<LocaleInfo, Failure>>());
        expect(
          result.when(ok: (locale) => locale.languageCode, err: (_) => null),
          equals('fr'),
        ); // Default French

        // Verify read call was made
        verify(freshMockStorageService.read('app_locale', any)).called(1);
      });
    });

    group('Stream Operations', () {
      test('should emit locale changes via stream', () async {
        // Arrange - Setup specific storage calls
        when(
          mockStorageService.store('app_locale', 'en_US', any),
        ).thenAnswer((_) async {});
        when(
          mockStorageService.store('app_locale', 'fr_FR', any),
        ).thenAnswer((_) async {});

        final localeStream = localizationService.localeChanges;
        final receivedLocales = <LocaleInfo>[];

        // Listen to stream
        final subscription = localeStream.listen(receivedLocales.add);

        // Act - Change locale multiple times
        await localizationService.setLocale(englishLocale);
        await localizationService.setLocale(frenchLocale);
        await localizationService.setLocale(englishLocale);

        // Wait for stream emissions
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(receivedLocales, hasLength(3));
        expect(receivedLocales[0], equals(englishLocale));
        expect(receivedLocales[1], equals(frenchLocale));
        expect(receivedLocales[2], equals(englishLocale));

        // Verify storage calls were made for each locale change
        verify(mockStorageService.store('app_locale', 'en_US', any)).called(2);
        verify(mockStorageService.store('app_locale', 'fr_FR', any)).called(1);

        // Cleanup
        await subscription.cancel();
      });
    });

    group('Error Handling', () {
      test('should handle unexpected errors in getCurrentLocale', () async {
        // This test primarily validates the error handling structure
        // since getCurrentLocale is simple and unlikely to throw

        // Act
        final result = await localizationService.getCurrentLocale();

        // Assert - Should always succeed for this implementation
        expect(result, isA<Result<LocaleInfo, Failure>>());
      });

      test('should handle concurrent locale changes', () async {
        // Arrange - Setup specific storage calls
        when(
          mockStorageService.store('app_locale', 'en_US', any),
        ).thenAnswer((_) async {});
        when(
          mockStorageService.store('app_locale', 'fr_FR', any),
        ).thenAnswer((_) async {});

        // Act - Start multiple concurrent locale changes
        final futures = [
          localizationService.setLocale(englishLocale),
          localizationService.setLocale(frenchLocale),
          localizationService.setLocale(englishLocale),
        ];

        final results = await Future.wait(futures);

        // Assert - All should succeed
        for (final result in results) {
          expect(result, isA<Result<LocaleInfo, Failure>>());
        }

        // Verify specific storage calls were made
        verify(mockStorageService.store('app_locale', 'en_US', any)).called(2);
        verify(mockStorageService.store('app_locale', 'fr_FR', any)).called(1);
      });
    });
  });
}
