// Group Domain Commands Tests - London School TDD Approach
// PRINCIPLE 0: RADICAL CANDOR - Testing actual command validation logic, no simulation
// Comprehensive testing of CreateGroupCommand and UpdateGroupCommand business rules

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/groups/group.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
  });

  group('CreateGroupCommand - Domain Command Validation', () {
    group('Construction & Properties', () {
      test('should create command with required name only', () {
        // Arrange & Act
        const command = CreateGroupCommand(name: 'Test Group');

        // Assert
        expect(command.name, equals('Test Group'));
        expect(command.description, isNull);
        expect(command.settings, isNull);
        expect(command.maxMembers, isNull);
        expect(command.scheduleConfig, isNull);
      });

      test('should create command with all optional properties', () {
        // Arrange
        const customSettings = GroupSettings(
          allowAutoAssignment: false,
          requireParentalApproval: true,
          defaultPickupLocation: 'Main Office',
          groupColor: '#FF5722',
          privacyLevel: GroupPrivacyLevel.coordinators,
        );

        const customScheduleConfig = GroupScheduleConfig(
          activeDays: [1, 3, 5], // Mon, Wed, Fri
          defaultStartTime: '08:30',
          defaultEndTime: '15:30',
          timezone: 'America/New_York',
          advanceNoticeHours: 48,
        );

        // Act
        const command = CreateGroupCommand(
          name: 'Full Featured Group',
          description: 'A group with all features configured',
          settings: customSettings,
          maxMembers: 25,
          scheduleConfig: customScheduleConfig,
        );

        // Assert
        expect(command.name, equals('Full Featured Group'));
        expect(
          command.description,
          equals('A group with all features configured'),
        );
        expect(command.settings, equals(customSettings));
        expect(command.maxMembers, equals(25));
        expect(command.scheduleConfig, equals(customScheduleConfig));
      });
    });

    group('Validation Logic - isValid getter', () {
      test('should be valid with non-empty name and no max members', () {
        // Arrange
        const command = CreateGroupCommand(name: 'Valid Group');

        // Act & Assert
        expect(command.isValid, isTrue);
      });

      test('should be valid with non-empty name and positive max members', () {
        // Arrange
        const command = CreateGroupCommand(
          name: 'Valid Group with Limit',
          maxMembers: 15,
        );

        // Act & Assert
        expect(command.isValid, isTrue);
      });

      test('should be invalid with empty name', () {
        // Arrange
        const command = CreateGroupCommand(name: '');

        // Act & Assert
        expect(command.isValid, isFalse);
      });

      test('should be invalid with whitespace-only name', () {
        // Arrange
        const command = CreateGroupCommand(name: '   \t\n   ');

        // Act & Assert
        expect(command.isValid, isFalse);
      });

      test('should be invalid with zero max members', () {
        // Arrange
        const command = CreateGroupCommand(name: 'Valid Name', maxMembers: 0);

        // Act & Assert
        expect(command.isValid, isFalse);
      });

      test('should be invalid with negative max members', () {
        // Arrange
        const command = CreateGroupCommand(name: 'Valid Name', maxMembers: -5);

        // Act & Assert
        expect(command.isValid, isFalse);
      });

      test('should handle edge case with exactly one max member', () {
        // Arrange
        const command = CreateGroupCommand(
          name: 'Single Member Group',
          maxMembers: 1,
        );

        // Act & Assert
        expect(command.isValid, isTrue);
      });
    });

    group('Validation Errors - validationErrors getter', () {
      test('should return empty list for valid command', () {
        // Arrange
        const command = CreateGroupCommand(
          name: 'Valid Command',
          description: 'Valid description',
          maxMembers: 10,
        );

        // Act & Assert
        expect(command.validationErrors, isEmpty);
      });

      test('should return name error for empty name', () {
        // Arrange
        const command = CreateGroupCommand(name: '');

        // Act
        final errors = command.validationErrors;

        // Assert
        expect(errors, hasLength(1));
        expect(errors.first, equals('Group name is required'));
      });

      test('should return max members error for invalid max members', () {
        // Arrange
        const command = CreateGroupCommand(name: 'Valid Name', maxMembers: -1);

        // Act
        final errors = command.validationErrors;

        // Assert
        expect(errors, hasLength(1));
        expect(errors.first, equals('Maximum members must be greater than 0'));
      });

      test('should return multiple errors when multiple validations fail', () {
        // Arrange
        const command = CreateGroupCommand(name: '', maxMembers: 0);

        // Act
        final errors = command.validationErrors;

        // Assert
        expect(errors, hasLength(2));
        expect(errors, contains('Group name is required'));
        expect(errors, contains('Maximum members must be greater than 0'));
      });

      test('should handle whitespace-only name as invalid', () {
        // Arrange
        const command = CreateGroupCommand(name: '   ');

        // Act
        final errors = command.validationErrors;

        // Assert
        expect(errors, hasLength(1));
        expect(errors.first, equals('Group name is required'));
      });
    });

    group('Equality & Props', () {
      test('should be equal when all properties match', () {
        // Arrange
        const customSettings = GroupSettings(groupColor: '#FF0000');
        const command1 = CreateGroupCommand(
          name: 'Test Group',
          description: 'Test description',
          settings: customSettings,
          maxMembers: 10,
        );
        const command2 = CreateGroupCommand(
          name: 'Test Group',
          description: 'Test description',
          settings: customSettings,
          maxMembers: 10,
        );

        // Act & Assert
        expect(command1, equals(command2));
        expect(command1.hashCode, equals(command2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const command1 = CreateGroupCommand(name: 'Group 1');
        const command2 = CreateGroupCommand(name: 'Group 2');

        // Act & Assert
        expect(command1, isNot(equals(command2)));
      });
    });
  });

  group('UpdateGroupCommand - Domain Command Validation', () {
    group('Construction & Properties', () {
      test('should create command with group ID and single update', () {
        // Arrange & Act
        const command = UpdateGroupCommand(
          groupId: 'group-123',
          name: 'Updated Name',
        );

        // Assert
        expect(command.groupId, equals('group-123'));
        expect(command.name, equals('Updated Name'));
        expect(command.description, isNull);
        expect(command.settings, isNull);
        expect(command.maxMembers, isNull);
        expect(command.scheduleConfig, isNull);
      });

      test('should create command with multiple updates', () {
        // Arrange
        const newSettings = GroupSettings(groupColor: '#00FF00');
        const newScheduleConfig = GroupScheduleConfig(activeDays: [2, 4, 6]);

        // Act
        const command = UpdateGroupCommand(
          groupId: 'group-multi',
          name: 'Multi Update Group',
          description: 'Updated description',
          settings: newSettings,
          maxMembers: 20,
          scheduleConfig: newScheduleConfig,
        );

        // Assert
        expect(command.groupId, equals('group-multi'));
        expect(command.name, equals('Multi Update Group'));
        expect(command.description, equals('Updated description'));
        expect(command.settings, equals(newSettings));
        expect(command.maxMembers, equals(20));
        expect(command.scheduleConfig, equals(newScheduleConfig));
      });
    });

    group('Business Logic - hasUpdates getter', () {
      test('should return false when no updates provided', () {
        // Arrange
        const command = UpdateGroupCommand(groupId: 'group-no-updates');

        // Act & Assert
        expect(command.hasUpdates, isFalse);
      });

      test('should return true when name update provided', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'group-name-update',
          name: 'New Name',
        );

        // Act & Assert
        expect(command.hasUpdates, isTrue);
      });

      test('should return true when description update provided', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'group-desc-update',
          description: 'New description',
        );

        // Act & Assert
        expect(command.hasUpdates, isTrue);
      });

      test('should return true when settings update provided', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'group-settings-update',
          settings: GroupSettings(groupColor: '#BLUE'),
        );

        // Act & Assert
        expect(command.hasUpdates, isTrue);
      });

      test('should return true when maxMembers update provided', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'group-max-update',
          maxMembers: 50,
        );

        // Act & Assert
        expect(command.hasUpdates, isTrue);
      });

      test('should return true when scheduleConfig update provided', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'group-schedule-update',
          scheduleConfig: GroupScheduleConfig(timezone: 'PST'),
        );

        // Act & Assert
        expect(command.hasUpdates, isTrue);
      });

      test('should return true with multiple updates', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'group-multiple-updates',
          name: 'New Name',
          description: 'New description',
          maxMembers: 30,
        );

        // Act & Assert
        expect(command.hasUpdates, isTrue);
      });
    });

    group('Validation Logic - isValid getter', () {
      test('should be valid with no name update', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'group-valid',
          description: 'Valid description update',
        );

        // Act & Assert
        expect(command.isValid, isTrue);
      });

      test('should be valid with non-empty name update', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'group-valid-name',
          name: 'Valid Name Update',
        );

        // Act & Assert
        expect(command.isValid, isTrue);
      });

      test('should be valid with positive max members', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'group-valid-max',
          maxMembers: 25,
        );

        // Act & Assert
        expect(command.isValid, isTrue);
      });

      test('should be invalid with empty name update', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'group-invalid-name',
          name: '',
        );

        // Act & Assert
        expect(command.isValid, isFalse);
      });

      test('should be invalid with whitespace-only name update', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'group-whitespace-name',
          name: '   \t   ',
        );

        // Act & Assert
        expect(command.isValid, isFalse);
      });

      test('should be invalid with zero max members', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'group-zero-max',
          maxMembers: 0,
        );

        // Act & Assert
        expect(command.isValid, isFalse);
      });

      test('should be invalid with negative max members', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'group-negative-max',
          maxMembers: -10,
        );

        // Act & Assert
        expect(command.isValid, isFalse);
      });
    });

    group('Validation Errors - validationErrors getter', () {
      test('should return empty list for valid command', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'valid-update',
          name: 'Valid Update Name',
          maxMembers: 15,
        );

        // Act & Assert
        expect(command.validationErrors, isEmpty);
      });

      test('should return name error for empty name update', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'empty-name-update',
          name: '',
        );

        // Act
        final errors = command.validationErrors;

        // Assert
        expect(errors, hasLength(1));
        expect(errors.first, equals('Group name cannot be empty'));
      });

      test('should return max members error for invalid max members', () {
        // Arrange
        const command = UpdateGroupCommand(
          groupId: 'invalid-max-update',
          maxMembers: -5,
        );

        // Act
        final errors = command.validationErrors;

        // Assert
        expect(errors, hasLength(1));
        expect(errors.first, equals('Maximum members must be greater than 0'));
      });

      test(
        'should return multiple errors for multiple validation failures',
        () {
          // Arrange
          const command = UpdateGroupCommand(
            groupId: 'multiple-errors',
            name: '',
            maxMembers: 0,
          );

          // Act
          final errors = command.validationErrors;

          // Assert
          expect(errors, hasLength(2));
          expect(errors, contains('Group name cannot be empty'));
          expect(errors, contains('Maximum members must be greater than 0'));
        },
      );
    });

    // NOTE: toMap() method removed - serialization is now handled by DTOs in data layer
    // This follows Clean Architecture principles: domain entities don't know about API format
    // See: lib/core/network/models/group/group_dto.dart for serialization logic

    group('Equality & Props', () {
      test('should be equal when all properties match', () {
        // Arrange
        const settings = GroupSettings(groupColor: '#BLUE');
        const command1 = UpdateGroupCommand(
          groupId: 'equality-test',
          name: 'Test Name',
          settings: settings,
          maxMembers: 15,
        );
        const command2 = UpdateGroupCommand(
          groupId: 'equality-test',
          name: 'Test Name',
          settings: settings,
          maxMembers: 15,
        );

        // Act & Assert
        expect(command1, equals(command2));
        expect(command1.hashCode, equals(command2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const command1 = UpdateGroupCommand(
          groupId: 'different-1',
          name: 'Name 1',
        );
        const command2 = UpdateGroupCommand(
          groupId: 'different-2',
          name: 'Name 2',
        );

        // Act & Assert
        expect(command1, isNot(equals(command2)));
      });

      test('should not be equal when groupId differs', () {
        // Arrange
        const command1 = UpdateGroupCommand(
          groupId: 'group-1',
          name: 'Same Name',
        );
        const command2 = UpdateGroupCommand(
          groupId: 'group-2',
          name: 'Same Name',
        );

        // Act & Assert
        expect(command1, isNot(equals(command2)));
      });
    });
  });
}
