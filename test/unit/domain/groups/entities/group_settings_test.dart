// Group Settings & Schedule Config Tests - London School TDD Approach
// PRINCIPLE 0: RADICAL CANDOR - Testing actual domain entity behavior, no simulation
// Comprehensive testing of GroupSettings and GroupScheduleConfig business logic

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/groups/group.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
  });

  group('GroupSettings - Domain Entity Behavior', () {
    group('Construction & Default Values', () {
      test('should create with default values when no parameters provided', () {
        // Arrange & Act
        const settings = GroupSettings();

        // Assert - Verify default values
        expect(settings.allowAutoAssignment, isTrue);
        expect(settings.requireParentalApproval, isFalse);
        expect(settings.defaultPickupLocation, isNull);
        expect(settings.defaultDropoffLocation, isNull);
        expect(settings.groupColor, equals('#2196F3'));
        expect(settings.enableNotifications, isTrue);
        expect(settings.privacyLevel, equals(GroupPrivacyLevel.family));
      });

      test('should create with all custom values', () {
        // Arrange & Act
        const settings = GroupSettings(
          allowAutoAssignment: false,
          requireParentalApproval: true,
          defaultPickupLocation: 'Main School Entrance',
          defaultDropoffLocation: 'Community Center Parking',
          groupColor: '#FF5722',
          enableNotifications: false,
          privacyLevel: GroupPrivacyLevel.coordinators,
        );

        // Assert
        expect(settings.allowAutoAssignment, isFalse);
        expect(settings.requireParentalApproval, isTrue);
        expect(settings.defaultPickupLocation, equals('Main School Entrance'));
        expect(
          settings.defaultDropoffLocation,
          equals('Community Center Parking'),
        );
        expect(settings.groupColor, equals('#FF5722'));
        expect(settings.enableNotifications, isFalse);
        expect(settings.privacyLevel, equals(GroupPrivacyLevel.coordinators));
      });

      test('should handle null location values correctly', () {
        // Arrange & Act
        const settings = GroupSettings();

        // Assert
        expect(settings.defaultPickupLocation, isNull);
        expect(settings.defaultDropoffLocation, isNull);
      });
    });

    group('copyWith Method', () {
      test('should create copy with updated fields', () {
        // Arrange
        const original = GroupSettings();

        // Act
        final updated = original.copyWith(
          allowAutoAssignment: false,
          requireParentalApproval: true,
          groupColor: '#FF0000',
          privacyLevel: GroupPrivacyLevel.admins,
        );

        // Assert - Updated fields
        expect(updated.allowAutoAssignment, isFalse);
        expect(updated.requireParentalApproval, isTrue);
        expect(updated.groupColor, equals('#FF0000'));
        expect(updated.privacyLevel, equals(GroupPrivacyLevel.admins));

        // Assert - Unchanged fields
        expect(updated.enableNotifications, isTrue);
        expect(updated.defaultPickupLocation, isNull);
        expect(updated.defaultDropoffLocation, isNull);
      });

      test('should return identical copy when no parameters provided', () {
        // Arrange
        const original = GroupSettings(
          allowAutoAssignment: false,
          groupColor: '#123456',
          defaultPickupLocation: 'Test Location',
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy, equals(original));
        expect(copy.allowAutoAssignment, equals(original.allowAutoAssignment));
        expect(copy.groupColor, equals(original.groupColor));
        expect(
          copy.defaultPickupLocation,
          equals(original.defaultPickupLocation),
        );
      });

      test('should handle location updates including null values', () {
        // Arrange
        const original = GroupSettings(
          defaultPickupLocation: 'Original Pickup',
          defaultDropoffLocation: 'Original Dropoff',
        );

        // Act
        final updated = original.copyWith(defaultPickupLocation: 'New Pickup');

        // Assert
        expect(updated.defaultPickupLocation, equals('New Pickup'));
        expect(updated.defaultDropoffLocation, equals('Original Dropoff'));
      });
    });

    group('Equality & Props', () {
      test('should be equal when all properties match', () {
        // Arrange
        const settings1 = GroupSettings(
          allowAutoAssignment: false,
          requireParentalApproval: true,
          defaultPickupLocation: 'Same Location',
          groupColor: '#FF0000',
          privacyLevel: GroupPrivacyLevel.coordinators,
        );

        const settings2 = GroupSettings(
          allowAutoAssignment: false,
          requireParentalApproval: true,
          defaultPickupLocation: 'Same Location',
          groupColor: '#FF0000',
          privacyLevel: GroupPrivacyLevel.coordinators,
        );

        // Act & Assert
        expect(settings1, equals(settings2));
        expect(settings1.hashCode, equals(settings2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const settings1 = GroupSettings(groupColor: '#FF0000');
        const settings2 = GroupSettings(groupColor: '#00FF00');

        // Act & Assert
        expect(settings1, isNot(equals(settings2)));
      });

      test('should handle null values in equality comparison', () {
        // Arrange
        const settings1 = GroupSettings();
        const settings2 = GroupSettings();
        const settings3 = GroupSettings(defaultPickupLocation: 'Some Location');

        // Act & Assert
        expect(settings1, equals(settings2));
        expect(settings1, isNot(equals(settings3)));
      });
    });
  });

  group('GroupScheduleConfig - Domain Entity Behavior', () {
    group('Construction & Default Values', () {
      test('should create with default values when no parameters provided', () {
        // Arrange & Act
        const config = GroupScheduleConfig();

        // Assert - Verify default values
        expect(config.activeDays, equals([1, 2, 3, 4, 5])); // Monday-Friday
        expect(config.defaultStartTime, isNull);
        expect(config.defaultEndTime, isNull);
        expect(config.timezone, equals('UTC'));
        expect(config.advanceNoticeHours, equals(24));
        expect(config.allowSameDayScheduling, isFalse);
      });

      test('should create with all custom values', () {
        // Arrange & Act
        const config = GroupScheduleConfig(
          activeDays: [1, 3, 5, 7], // Mon, Wed, Fri, Sun
          defaultStartTime: '08:30',
          defaultEndTime: '16:45',
          timezone: 'America/New_York',
          advanceNoticeHours: 48,
          allowSameDayScheduling: true,
        );

        // Assert
        expect(config.activeDays, equals([1, 3, 5, 7]));
        expect(config.defaultStartTime, equals('08:30'));
        expect(config.defaultEndTime, equals('16:45'));
        expect(config.timezone, equals('America/New_York'));
        expect(config.advanceNoticeHours, equals(48));
        expect(config.allowSameDayScheduling, isTrue);
      });

      test('should handle empty active days list', () {
        // Arrange & Act
        const config = GroupScheduleConfig(activeDays: []);

        // Assert
        expect(config.activeDays, isEmpty);
      });

      test('should handle weekend-only schedule', () {
        // Arrange & Act
        const config = GroupScheduleConfig(activeDays: [6, 7]); // Sat, Sun

        // Assert
        expect(config.activeDays, equals([6, 7]));
      });
    });

    group('Business Logic Methods', () {
      group('isActiveOnDay method', () {
        test('should return true for days in active days list', () {
          // Arrange
          const config = GroupScheduleConfig(
            activeDays: [1, 3, 5],
          ); // Mon, Wed, Fri

          // Act & Assert
          expect(config.isActiveOnDay(1), isTrue); // Monday
          expect(config.isActiveOnDay(3), isTrue); // Wednesday
          expect(config.isActiveOnDay(5), isTrue); // Friday
        });

        test('should return false for days not in active days list', () {
          // Arrange
          const config = GroupScheduleConfig(
            activeDays: [1, 3, 5],
          ); // Mon, Wed, Fri

          // Act & Assert
          expect(config.isActiveOnDay(2), isFalse); // Tuesday
          expect(config.isActiveOnDay(4), isFalse); // Thursday
          expect(config.isActiveOnDay(6), isFalse); // Saturday
          expect(config.isActiveOnDay(7), isFalse); // Sunday
        });

        test('should return false for invalid day numbers', () {
          // Arrange
          const config = GroupScheduleConfig();

          // Act & Assert
          expect(config.isActiveOnDay(0), isFalse); // Invalid day
          expect(config.isActiveOnDay(8), isFalse); // Invalid day
          expect(config.isActiveOnDay(-1), isFalse); // Invalid day
        });

        test('should return false when active days is empty', () {
          // Arrange
          const config = GroupScheduleConfig(activeDays: []);

          // Act & Assert
          expect(config.isActiveOnDay(1), isFalse);
          expect(config.isActiveOnDay(7), isFalse);
        });
      });

      group('activeDaysString getter', () {
        test('should return weekdays for default configuration', () {
          // Arrange
          const config = GroupScheduleConfig(); // Default Mon-Fri

          // Act & Assert
          expect(config.activeDaysString, equals('Mon, Tue, Wed, Thu, Fri'));
        });

        test('should return correct string for weekend schedule', () {
          // Arrange
          const config = GroupScheduleConfig(activeDays: [6, 7]); // Sat, Sun

          // Act & Assert
          expect(config.activeDaysString, equals('Sat, Sun'));
        });

        test('should return correct string for custom schedule', () {
          // Arrange
          const config = GroupScheduleConfig(
            activeDays: [1, 3, 5],
          ); // Mon, Wed, Fri

          // Act & Assert
          expect(config.activeDaysString, equals('Mon, Wed, Fri'));
        });

        test('should return empty string for no active days', () {
          // Arrange
          const config = GroupScheduleConfig(activeDays: []);

          // Act & Assert
          expect(config.activeDaysString, isEmpty);
        });

        test('should handle single day correctly', () {
          // Arrange
          const config = GroupScheduleConfig(activeDays: [4]); // Thursday only

          // Act & Assert
          expect(config.activeDaysString, equals('Thu'));
        });

        test('should maintain order of days as specified', () {
          // Arrange - Unusual order to test
          const config = GroupScheduleConfig(
            activeDays: [7, 1, 5, 3],
          ); // Sun, Mon, Fri, Wed

          // Act & Assert
          expect(config.activeDaysString, equals('Sun, Mon, Fri, Wed'));
        });
      });
    });

    group('copyWith Method', () {
      test('should create copy with updated fields', () {
        // Arrange
        const original = GroupScheduleConfig(defaultStartTime: '09:00');

        // Act
        final updated = original.copyWith(
          activeDays: [1, 3, 5],
          defaultEndTime: '17:00',
          timezone: 'EST',
          allowSameDayScheduling: true,
        );

        // Assert - Updated fields
        expect(updated.activeDays, equals([1, 3, 5]));
        expect(updated.defaultEndTime, equals('17:00'));
        expect(updated.timezone, equals('EST'));
        expect(updated.allowSameDayScheduling, isTrue);

        // Assert - Unchanged fields
        expect(updated.defaultStartTime, equals('09:00'));
        expect(updated.advanceNoticeHours, equals(24));
      });

      test('should return identical copy when no parameters provided', () {
        // Arrange
        const original = GroupScheduleConfig(
          activeDays: [6, 7],
          defaultStartTime: '10:00',
          advanceNoticeHours: 48,
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy, equals(original));
        expect(copy.activeDays, equals(original.activeDays));
        expect(copy.defaultStartTime, equals(original.defaultStartTime));
        expect(copy.advanceNoticeHours, equals(original.advanceNoticeHours));
      });
    });

    group('Equality & Props', () {
      test('should be equal when all properties match', () {
        // Arrange
        const config1 = GroupScheduleConfig(
          activeDays: [1, 3, 5],
          defaultStartTime: '09:00',
          defaultEndTime: '15:00',
          timezone: 'PST',
          advanceNoticeHours: 48,
          allowSameDayScheduling: true,
        );

        const config2 = GroupScheduleConfig(
          activeDays: [1, 3, 5],
          defaultStartTime: '09:00',
          defaultEndTime: '15:00',
          timezone: 'PST',
          advanceNoticeHours: 48,
          allowSameDayScheduling: true,
        );

        // Act & Assert
        expect(config1, equals(config2));
        expect(config1.hashCode, equals(config2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const config1 = GroupScheduleConfig(activeDays: [1, 2, 3]);
        const config2 = GroupScheduleConfig(activeDays: [4, 5, 6]);

        // Act & Assert
        expect(config1, isNot(equals(config2)));
      });

      test('should handle null values in equality comparison', () {
        // Arrange
        const config1 = GroupScheduleConfig(
          /* defaultStartTime: null */
        ); // Removed redundant default
        const config2 = GroupScheduleConfig(
          /* defaultStartTime: null */
        ); // Removed redundant default
        const config3 = GroupScheduleConfig(defaultStartTime: '09:00');

        // Act & Assert
        expect(config1, equals(config2));
        expect(config1, isNot(equals(config3)));
      });

      test('should be sensitive to list order in activeDays', () {
        // Arrange
        const config1 = GroupScheduleConfig(activeDays: [1, 2, 3]);
        const config2 = GroupScheduleConfig(activeDays: [3, 2, 1]);

        // Act & Assert
        expect(config1, isNot(equals(config2)));
      });
    });

    group('Edge Cases & Business Rules', () {
      test('should handle extreme advance notice values', () {
        // Arrange - Very short notice
        const shortNotice = GroupScheduleConfig(advanceNoticeHours: 1);
        expect(shortNotice.advanceNoticeHours, equals(1));

        // Arrange - Very long notice
        const longNotice = GroupScheduleConfig(
          advanceNoticeHours: 168,
        ); // 1 week
        expect(longNotice.advanceNoticeHours, equals(168));
      });

      test('should handle all possible day combinations', () {
        // Test all days of week
        for (var day = 1; day <= 7; day++) {
          const config = GroupScheduleConfig(activeDays: [1, 2, 3, 4, 5, 6, 7]);
          expect(config.isActiveOnDay(day), isTrue);
        }
      });

      test('should handle duplicate days in activeDays list', () {
        // Arrange
        const config = GroupScheduleConfig(activeDays: [1, 1, 2, 2, 3]);

        // Act & Assert - Behavior should be consistent
        expect(config.isActiveOnDay(1), isTrue);
        expect(config.isActiveOnDay(2), isTrue);
        expect(config.isActiveOnDay(3), isTrue);
        expect(
          config.activeDays,
          equals([1, 1, 2, 2, 3]),
        ); // Preserves duplicates
      });
    });
  });
}
