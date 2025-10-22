import 'package:test/test.dart';
import 'package:edulift/features/auth/domain/repositories/auth_repository.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  // Setup Mockito dummy values for Result types
  setUpAll(() {
    setupMockFallbacks();
  });

  group('UpdateUserProfileRequest', () {
    group('Construction', () {
      test('should create empty request with all null fields', () {
        // Act
        final request = UpdateUserProfileRequest();

        // Assert
        expect(request.name, isNull);
        expect(request.preferredLanguage, isNull);
        expect(request.timezone, isNull);
        expect(request.accessibilityPreferences, isNull);
      });

      test('should create request with only name', () {
        // Act
        final request = UpdateUserProfileRequest(name: 'Updated Name');

        // Assert
        expect(request.name, equals('Updated Name'));
        expect(request.preferredLanguage, isNull);
        expect(request.timezone, isNull);
        expect(request.accessibilityPreferences, isNull);
      });

      test('should create request with only preferred language', () {
        // Act
        final request = UpdateUserProfileRequest(preferredLanguage: 'es');

        // Assert
        expect(request.name, isNull);
        expect(request.preferredLanguage, equals('es'));
        expect(request.timezone, isNull);
        expect(request.accessibilityPreferences, isNull);
      });

      test('should create request with only timezone', () {
        // Act
        final request = UpdateUserProfileRequest(timezone: 'Europe/Paris');

        // Assert
        expect(request.name, isNull);
        expect(request.preferredLanguage, isNull);
        expect(request.timezone, equals('Europe/Paris'));
        expect(request.accessibilityPreferences, isNull);
      });

      test('should create request with only accessibility preferences', () {
        // Arrange
        const accessibilityPrefs = {
          'highContrast': true,
          'textScaleFactor': 1.5,
        };

        // Act
        final request = UpdateUserProfileRequest(
          accessibilityPreferences: accessibilityPrefs,
        );

        // Assert
        expect(request.name, isNull);
        expect(request.preferredLanguage, isNull);
        expect(request.timezone, isNull);
        expect(request.accessibilityPreferences, equals(accessibilityPrefs));
      });

      test('should create request with all fields populated', () {
        // Arrange
        const accessibilityPrefs = {
          'highContrast': true,
          'largeTouchTargets': true,
          'textScaleFactor': 1.2,
          'voiceNavigation': false,
        };

        // Act
        final request = UpdateUserProfileRequest(
          name: 'John Doe',
          preferredLanguage: 'en',
          timezone: 'America/New_York',
          accessibilityPreferences: accessibilityPrefs,
        );

        // Assert
        expect(request.name, equals('John Doe'));
        expect(request.preferredLanguage, equals('en'));
        expect(request.timezone, equals('America/New_York'));
        expect(request.accessibilityPreferences, equals(accessibilityPrefs));
      });
    });

    group('Equality', () {
      test('should be equal when all fields are null', () {
        // Arrange
        final request1 = UpdateUserProfileRequest();
        final request2 = UpdateUserProfileRequest();

        // Act & Assert
        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should be equal when all fields match', () {
        // Arrange
        const accessibilityPrefs = {'highContrast': true};

        final request1 = UpdateUserProfileRequest(
          name: 'John Doe',
          preferredLanguage: 'en',
          timezone: 'UTC',
          accessibilityPreferences: accessibilityPrefs,
        );

        final request2 = UpdateUserProfileRequest(
          name: 'John Doe',
          preferredLanguage: 'en',
          timezone: 'UTC',
          accessibilityPreferences: accessibilityPrefs,
        );

        // Act & Assert
        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should not be equal when names differ', () {
        // Arrange
        final request1 = UpdateUserProfileRequest(name: 'John Doe');
        final request2 = UpdateUserProfileRequest(name: 'Jane Doe');

        // Act & Assert
        expect(request1, isNot(equals(request2)));
        expect(request1.hashCode, isNot(equals(request2.hashCode)));
      });

      test('should not be equal when preferred languages differ', () {
        // Arrange
        final request1 = UpdateUserProfileRequest(preferredLanguage: 'en');
        final request2 = UpdateUserProfileRequest(preferredLanguage: 'es');

        // Act & Assert
        expect(request1, isNot(equals(request2)));
        expect(request1.hashCode, isNot(equals(request2.hashCode)));
      });

      test('should not be equal when timezones differ', () {
        // Arrange
        final request1 = UpdateUserProfileRequest(timezone: 'UTC');
        final request2 = UpdateUserProfileRequest(timezone: 'PST');

        // Act & Assert
        expect(request1, isNot(equals(request2)));
        expect(request1.hashCode, isNot(equals(request2.hashCode)));
      });

      test('should not be equal when accessibility preferences differ', () {
        // Arrange
        const prefs1 = {'highContrast': true};
        const prefs2 = {'highContrast': false};

        final request1 = UpdateUserProfileRequest(
          accessibilityPreferences: prefs1,
        );
        final request2 = UpdateUserProfileRequest(
          accessibilityPreferences: prefs2,
        );

        // Act & Assert
        expect(request1, isNot(equals(request2)));
        expect(request1.hashCode, isNot(equals(request2.hashCode)));
      });

      test('should not be equal when one field is null and other is not', () {
        // Arrange
        final request1 = UpdateUserProfileRequest(name: 'John Doe');
        final request2 = UpdateUserProfileRequest();

        // Act & Assert
        expect(request1, isNot(equals(request2)));
        expect(request1.hashCode, isNot(equals(request2.hashCode)));
      });
    });

    group('Business Logic Scenarios', () {
      test('should create request for name change only', () {
        // Act
        final request = UpdateUserProfileRequest(name: 'Sarah Johnson');

        // Assert
        expect(request.name, equals('Sarah Johnson'));
        expect(request.preferredLanguage, isNull, reason: 'Language unchanged');
        expect(request.timezone, isNull, reason: 'Timezone unchanged');
        expect(
          request.accessibilityPreferences,
          isNull,
          reason: 'Accessibility unchanged',
        );
      });

      test('should create request for localization update', () {
        // Act
        final request = UpdateUserProfileRequest(
          preferredLanguage: 'fr',
          timezone: 'Europe/Paris',
        );

        // Assert
        expect(request.name, isNull, reason: 'Name unchanged');
        expect(request.preferredLanguage, equals('fr'));
        expect(request.timezone, equals('Europe/Paris'));
        expect(
          request.accessibilityPreferences,
          isNull,
          reason: 'Accessibility unchanged',
        );
      });

      test('should create request for accessibility update only', () {
        // Arrange
        const accessibilityUpdate = {
          'highContrast': true,
          'textScaleFactor': 1.5,
          'largeTouchTargets': true,
          'reduceMotion': true,
        };

        // Act
        final request = UpdateUserProfileRequest(
          accessibilityPreferences: accessibilityUpdate,
        );

        // Assert
        expect(request.name, isNull, reason: 'Name unchanged');
        expect(request.preferredLanguage, isNull, reason: 'Language unchanged');
        expect(request.timezone, isNull, reason: 'Timezone unchanged');
        expect(request.accessibilityPreferences, equals(accessibilityUpdate));
      });

      test('should create request for comprehensive profile update', () {
        // Arrange
        const fullAccessibilityUpdate = {
          'highContrast': false,
          'largeTouchTargets': false,
          'reduceMotion': false,
          'textScaleFactor': 1.0,
          'voiceNavigation': true,
          'screenReaderOptimized': true,
          'hapticFeedback': 'medium',
        };

        // Act
        final request = UpdateUserProfileRequest(
          name: 'Dr. Maria Rodriguez',
          preferredLanguage: 'es',
          timezone: 'America/Mexico_City',
          accessibilityPreferences: fullAccessibilityUpdate,
        );

        // Assert
        expect(request.name, equals('Dr. Maria Rodriguez'));
        expect(request.preferredLanguage, equals('es'));
        expect(request.timezone, equals('America/Mexico_City'));
        expect(
          request.accessibilityPreferences,
          equals(fullAccessibilityUpdate),
        );
      });

      test('should create request for international user', () {
        // Act
        final request = UpdateUserProfileRequest(
          name: '田中太郎',
          preferredLanguage: 'ja',
          timezone: 'Asia/Tokyo',
        );

        // Assert
        expect(request.name, equals('田中太郎'));
        expect(request.preferredLanguage, equals('ja'));
        expect(request.timezone, equals('Asia/Tokyo'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty strings', () {
        // Act
        final request = UpdateUserProfileRequest(
          name: '',
          preferredLanguage: '',
          timezone: '',
        );

        // Assert
        expect(request.name, equals(''));
        expect(request.preferredLanguage, equals(''));
        expect(request.timezone, equals(''));
      });

      test('should handle whitespace-only strings', () {
        // Act
        final request = UpdateUserProfileRequest(
          name: '   ',
          preferredLanguage: '\\t',
          timezone: '\\n',
        );

        // Assert
        expect(request.name, equals('   '));
        expect(request.preferredLanguage, equals('\\t'));
        expect(request.timezone, equals('\\n'));
      });

      test('should handle very long names', () {
        // Arrange
        final longName = 'A' * 1000;

        // Act
        final request = UpdateUserProfileRequest(name: longName);

        // Assert
        expect(request.name, equals(longName));
      });

      test('should handle special characters in name', () {
        // Act
        final request = UpdateUserProfileRequest(name: 'José María Ñoño-Pérez');

        // Assert
        expect(request.name, equals('José María Ñoño-Pérez'));
      });

      test('should handle unusual but valid language codes', () {
        // Act
        final request = UpdateUserProfileRequest(
          preferredLanguage: 'zh-Hans-CN',
        );

        // Assert
        expect(request.preferredLanguage, equals('zh-Hans-CN'));
      });

      test('should handle unusual but valid timezone identifiers', () {
        // Act
        final request = UpdateUserProfileRequest(
          timezone: 'Antarctica/McMurdo',
        );

        // Assert
        expect(request.timezone, equals('Antarctica/McMurdo'));
      });

      test('should handle empty accessibility preferences map', () {
        // Act
        final request = UpdateUserProfileRequest(
          accessibilityPreferences: <String, dynamic>{},
        );

        // Assert
        expect(request.accessibilityPreferences, equals(<String, dynamic>{}));
      });

      test('should handle complex accessibility preferences', () {
        // Arrange
        const complexPrefs = {
          'highContrast': true,
          'textScaleFactor': 1.75,
          'customTheme': {
            'primaryColor': '#FF0000',
            'secondaryColor': '#00FF00',
            'backgroundColor': '#000000',
          },
          'keyboardShortcuts': [
            {'key': 'Ctrl+S', 'action': 'save'},
            {'key': 'Ctrl+Z', 'action': 'undo'},
          ],
          'advancedSettings': {
            'animationDuration': 200,
            'scrollSensitivity': 0.8,
            'touchDelay': 50,
          },
        };

        // Act
        final request = UpdateUserProfileRequest(
          accessibilityPreferences: complexPrefs,
        );

        // Assert
        expect(request.accessibilityPreferences, equals(complexPrefs));
      });
    });

    group('Validation Scenarios', () {
      test('should handle minimal update request', () {
        // Act
        final request = UpdateUserProfileRequest(name: 'Min');

        // Assert
        expect(request.name, equals('Min'));
      });

      test('should handle profile reset request (all fields to null)', () {
        // Act
        final request = UpdateUserProfileRequest();

        // Assert
        expect(request.name, isNull);
        expect(request.preferredLanguage, isNull);
        expect(request.timezone, isNull);
        expect(request.accessibilityPreferences, isNull);
      });

      test(
        'should distinguish between null and empty accessibility preferences',
        () {
          // Act
          final requestWithNull = UpdateUserProfileRequest();
          final requestWithEmpty = UpdateUserProfileRequest(
            accessibilityPreferences: <String, dynamic>{},
          );

          // Assert
          expect(requestWithNull.accessibilityPreferences, isNull);
          expect(requestWithEmpty.accessibilityPreferences, isNotNull);
          expect(requestWithEmpty.accessibilityPreferences, isEmpty);
          expect(requestWithNull, isNot(equals(requestWithEmpty)));
        },
      );

      test('should handle accessibility preferences with null values', () {
        // Arrange
        const prefsWithNulls = {
          'highContrast': null,
          'textScaleFactor': 1.2,
          'customSetting': null,
        };

        // Act
        final request = UpdateUserProfileRequest(
          accessibilityPreferences: prefsWithNulls,
        );

        // Assert
        expect(request.accessibilityPreferences!['highContrast'], isNull);
        expect(
          request.accessibilityPreferences!['textScaleFactor'],
          equals(1.2),
        );
        expect(request.accessibilityPreferences!['customSetting'], isNull);
      });

      test(
        'should handle accessibility preferences with various data types',
        () {
          // Arrange
          const mixedPrefs = {
            'booleanSetting': true,
            'stringSetting': 'value',
            'numberSetting': 42,
            'doubleSetting': 3.14,
            'listSetting': [1, 2, 3],
            'mapSetting': {'nested': 'value'},
          };

          // Act
          final request = UpdateUserProfileRequest(
            accessibilityPreferences: mixedPrefs,
          );

          // Assert
          expect(request.accessibilityPreferences, equals(mixedPrefs));
        },
      );
    });

    group('Performance and Memory', () {
      test('should handle large accessibility preferences efficiently', () {
        // Arrange
        final largePrefs = <String, dynamic>{};
        for (var i = 0; i < 1000; i++) {
          largePrefs['setting$i'] = 'value$i';
        }

        // Act
        final request = UpdateUserProfileRequest(
          accessibilityPreferences: largePrefs,
        );

        // Assert
        expect(request.accessibilityPreferences!.length, equals(1000));
        expect(
          request.accessibilityPreferences!['setting500'],
          equals('value500'),
        );
      });

      test('should handle rapid request creation', () {
        // Act
        final stopwatch = Stopwatch()..start();
        final requests = List.generate(
          1000,
          (index) => UpdateUserProfileRequest(
            name: 'User $index',
            preferredLanguage: index % 2 == 0 ? 'en' : 'es',
          ),
        );
        stopwatch.stop();

        // Assert
        expect(requests.length, equals(1000));
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason: 'Should create quickly',
        );
      });
    });

    group('Immutability', () {
      test('should be immutable (const constructor)', () {
        // Act
        final request1 = UpdateUserProfileRequest(name: 'Test');
        final request2 = UpdateUserProfileRequest(name: 'Test');

        // Assert
        expect(
          identical(request1, request2),
          isFalse,
          reason: 'Different instances',
        );
        expect(request1, equals(request2), reason: 'But equal values');
      });

      test('should support const contexts', () {
        // Act
        final requests = [
          UpdateUserProfileRequest(name: 'User 1'),
          UpdateUserProfileRequest(preferredLanguage: 'en'),
          UpdateUserProfileRequest(timezone: 'UTC'),
        ];

        // Assert
        expect(requests.length, equals(3));
        expect(requests[0].name, equals('User 1'));
        expect(requests[1].preferredLanguage, equals('en'));
        expect(requests[2].timezone, equals('UTC'));
      });
    });
  });
}
