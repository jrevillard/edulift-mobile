// EduLift Mobile - User Entity Tests
// SPARC-Driven Development with Neural Coordination
// Agent: qa-automation-lead

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/user.dart';

/// SPARC Phase R: TDD Unit Tests for User Entity
/// Following Test-Driven Development principles with comprehensive coverage
void main() {
  group('User Entity Tests', () {
    late User testUser;

    setUp(() {
      testUser = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'John Doe',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024, 1, 2),
        preferredLanguage: 'en',
        timezone: 'America/New_York',
        hasCompletedOnboarding: true,
      );
    });

    group('Construction', () {
      test('should create User with required fields only', () {
        // Arrange & Act
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          name: 'John Doe',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
        );

        // Assert
        expect(user.id, equals('user123'));
        expect(user.email, equals('test@example.com'));
        expect(user.name, equals('John Doe'));
        expect(user.role, equals(UserRole.user));
        expect(user.hasCompletedOnboarding, isFalse);
        expect(user.accessibilityPreferences, isA<AccessibilityPreferences>());
      });

      test('should create User with all fields', () {
        // Arrange & Act
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          name: 'John Doe',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
          preferredLanguage: 'fr',
          timezone: 'Europe/Paris',
          role: UserRole.admin,
          hasCompletedOnboarding: true,
          accessibilityPreferences: const AccessibilityPreferences(
            highContrast: true,
          ),
        );

        // Assert
        expect(user.preferredLanguage, equals('fr'));
        expect(user.timezone, equals('Europe/Paris'));
        expect(user.role, equals(UserRole.admin));
        expect(user.hasCompletedOnboarding, isTrue);
        expect(user.accessibilityPreferences.highContrast, isTrue);
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final user1 = User(
          id: 'user123',
          email: 'test@example.com',
          name: 'John Doe',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
        );

        final user2 = User(
          id: 'user123',
          email: 'test@example.com',
          name: 'John Doe',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
        );

        // Act & Assert
        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final user1 = testUser;
        final user2 = testUser.copyWith(name: 'Jane Doe');

        // Act & Assert
        expect(user1, isNot(equals(user2)));
      });
    });

    group('copyWith', () {
      test('should return same instance when no parameters provided', () {
        // Act
        final copied = testUser.copyWith();

        // Assert
        expect(copied, equals(testUser));
      });

      test('should update only specified fields', () {
        // Act
        final copied = testUser.copyWith(
          name: 'Jane Doe',
          role: UserRole.admin,
        );

        // Assert
        expect(copied.name, equals('Jane Doe'));
        expect(copied.role, equals(UserRole.admin));
        expect(copied.id, equals(testUser.id));
        expect(copied.email, equals(testUser.email));
      });

      test('should preserve values when copying', () {
        // Act
        final copied = testUser.copyWith();

        // Assert
        expect(copied.preferredLanguage, equals(testUser.preferredLanguage));
        expect(copied.timezone, equals(testUser.timezone));
      });
    });

    group('Computed Properties', () {
      test('initials should return first letter for single name', () {
        // Arrange
        final user = testUser.copyWith(name: 'John');

        // Act & Assert
        expect(user.initials, equals('J'));
      });

      test('initials should return first letters for full name', () {
        // Arrange
        final user = testUser.copyWith(name: 'John Doe');

        // Act & Assert
        expect(user.initials, equals('JD'));
      });

      test('initials should return first letters for multiple names', () {
        // Arrange
        final user = testUser.copyWith(name: 'John Michael Doe');

        // Act & Assert
        expect(user.initials, equals('JM'));
      });

      test('initials should handle empty name', () {
        // Arrange
        final user = testUser.copyWith(name: '');

        // Act & Assert
        expect(user.initials, equals(''));
      });

      test('initials should handle whitespace-only name', () {
        // Arrange
        final user = testUser.copyWith(name: '   ');

        // Act & Assert
        expect(user.initials, equals(''));
      });

      test('isAdmin should return true for admin role', () {
        // Arrange
        final adminUser = testUser.copyWith(role: UserRole.admin);

        // Act & Assert
        expect(adminUser.isAdmin, isTrue);
      });

      test('isAdmin should return false for user role', () {
        // Arrange
        final regularUser = testUser.copyWith(role: UserRole.user);

        // Act & Assert
        expect(regularUser.isAdmin, isFalse);
      });

      test('isSetupComplete should return onboarding status', () {
        // Arrange
        final completedUser = testUser.copyWith(hasCompletedOnboarding: true);
        final incompleteUser = testUser.copyWith(hasCompletedOnboarding: false);

        // Act & Assert
        expect(completedUser.isSetupComplete, isTrue);
        expect(incompleteUser.isSetupComplete, isFalse);
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        // Act
        final result = testUser.toString();

        // Assert
        expect(
          result,
          equals(
            'User(id: user123, email: test@example.com, name: John Doe, role: UserRole.user)',
          ),
        );
      });
    });
  });

  group('AccessibilityPreferences Tests', () {
    group('Construction', () {
      test('should create with default values', () {
        // Act
        const preferences = AccessibilityPreferences();

        // Assert
        expect(preferences.highContrast, isFalse);
        expect(preferences.largeTouchTargets, isFalse);
        expect(preferences.reduceMotion, isFalse);
        expect(preferences.textScaleFactor, equals(1.0));
        expect(preferences.voiceNavigation, isFalse);
        expect(preferences.screenReaderOptimized, isFalse);
        expect(preferences.hapticFeedback, equals(HapticFeedbackLevel.medium));
      });

      test('should create with custom values', () {
        // Act
        const preferences = AccessibilityPreferences(
          highContrast: true,
          largeTouchTargets: true,
          textScaleFactor: 1.5,
          hapticFeedback: HapticFeedbackLevel.strong,
        );

        // Assert
        expect(preferences.highContrast, isTrue);
        expect(preferences.largeTouchTargets, isTrue);
        expect(preferences.textScaleFactor, equals(1.5));
        expect(preferences.hapticFeedback, equals(HapticFeedbackLevel.strong));
      });
    });

    group('copyWith', () {
      test('should update specified fields only', () {
        // Arrange
        const original = AccessibilityPreferences();

        // Act
        final updated = original.copyWith(
          highContrast: true,
          textScaleFactor: 1.2,
        );

        // Assert
        expect(updated.highContrast, isTrue);
        expect(updated.textScaleFactor, equals(1.2));
        expect(updated.largeTouchTargets, isFalse); // unchanged
        expect(updated.reduceMotion, isFalse); // unchanged
      });
    });

    group('hasAccessibilityFeatures', () {
      test('should return false for default preferences', () {
        // Arrange
        const preferences = AccessibilityPreferences();

        // Act & Assert
        expect(preferences.hasAccessibilityFeatures, isFalse);
      });

      test('should return true when high contrast is enabled', () {
        // Arrange
        const preferences = AccessibilityPreferences(highContrast: true);

        // Act & Assert
        expect(preferences.hasAccessibilityFeatures, isTrue);
      });

      test('should return true when text scale factor is increased', () {
        // Arrange
        const preferences = AccessibilityPreferences(textScaleFactor: 1.5);

        // Act & Assert
        expect(preferences.hasAccessibilityFeatures, isTrue);
      });

      test('should return true when haptic feedback is not medium', () {
        // Arrange
        const preferences = AccessibilityPreferences(
          hapticFeedback: HapticFeedbackLevel.strong,
        );

        // Act & Assert
        expect(preferences.hasAccessibilityFeatures, isTrue);
      });

      test('should return true when any accessibility feature is enabled', () {
        // Arrange
        const preferences = AccessibilityPreferences(
          largeTouchTargets: true,
          reduceMotion: true,
          voiceNavigation: true,
          screenReaderOptimized: true,
        );

        // Act & Assert
        expect(preferences.hasAccessibilityFeatures, isTrue);
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        const preferences1 = AccessibilityPreferences(
          highContrast: true,
          textScaleFactor: 1.5,
        );
        const preferences2 = AccessibilityPreferences(
          highContrast: true,
          textScaleFactor: 1.5,
        );

        // Act & Assert
        expect(preferences1, equals(preferences2));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const preferences1 = AccessibilityPreferences(highContrast: true);
        const preferences2 = AccessibilityPreferences();

        // Act & Assert
        expect(preferences1, isNot(equals(preferences2)));
      });
    });
  });

  group('UserRole Enum Tests', () {
    test('should have correct values', () {
      expect(UserRole.values, contains(UserRole.user));
      expect(UserRole.values, contains(UserRole.admin));
      expect(UserRole.values.length, equals(2));
    });
  });

  group('HapticFeedbackLevel Enum Tests', () {
    test('should have correct values', () {
      expect(HapticFeedbackLevel.values, contains(HapticFeedbackLevel.none));
      expect(HapticFeedbackLevel.values, contains(HapticFeedbackLevel.light));
      expect(HapticFeedbackLevel.values, contains(HapticFeedbackLevel.medium));
      expect(HapticFeedbackLevel.values, contains(HapticFeedbackLevel.strong));
      expect(HapticFeedbackLevel.values.length, equals(4));
    });
  });
}
