// Group Entity Domain Tests - London School TDD Approach
// PRINCIPLE 0: RADICAL CANDOR - Testing actual domain logic, no simulation
// Comprehensive testing of Group entity business logic and behavior

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/groups/group.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
  });

  group('Group Entity - Business Logic & Behavior', () {
    late DateTime testDateTime;

    setUp(() {
      testDateTime = DateTime(2024, 1, 15, 10, 30);
    });

    group('Entity Construction & Properties', () {
      test('should create group with required fields only', () {
        // Arrange & Act
        final group = Group(
          id: 'test-group-id',
          name: 'Test Group',
          familyId: 'family-123',
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Assert
        expect(group.id, equals('test-group-id'));
        expect(group.name, equals('Test Group'));
        expect(group.familyId, equals('family-123'));
        expect(group.createdAt, equals(testDateTime));
        expect(group.updatedAt, equals(testDateTime));

        // Default values
        expect(group.description, isNull);
        expect(group.status, equals(GroupStatus.active));
        expect(group.memberCount, equals(0));
        expect(group.maxMembers, isNull);
        expect(group.userRole, isNull);
        expect(group.familyCount, equals(0));
        expect(group.scheduleCount, equals(0));
        expect(group.settings, equals(const GroupSettings()));
        expect(group.scheduleConfig, equals(const GroupScheduleConfig()));
      });

      test('should create group with all optional fields', () {
        // Arrange
        const customSettings = GroupSettings(
          allowAutoAssignment: false,
          requireParentalApproval: true,
          defaultPickupLocation: 'School Main Gate',
          defaultDropoffLocation: 'Community Center',
          groupColor: '#FF5722',
          enableNotifications: false,
          privacyLevel: GroupPrivacyLevel.coordinators,
        );

        const customScheduleConfig = GroupScheduleConfig(
          activeDays: [1, 3, 5], // Mon, Wed, Fri
          defaultStartTime: '08:00',
          defaultEndTime: '15:00',
          timezone: 'America/New_York',
          advanceNoticeHours: 48,
          allowSameDayScheduling: true,
        );

        // Act
        final group = Group(
          id: 'full-group-id',
          name: 'Full Feature Group',
          familyId: 'family-full',
          description: 'A group with all features configured',
          createdAt: testDateTime,
          updatedAt: testDateTime.add(const Duration(hours: 1)),
          settings: customSettings,
          status: GroupStatus.paused,
          memberCount: 15,
          maxMembers: 25,
          scheduleConfig: customScheduleConfig,
          userRole: GroupMemberRole.admin,
          familyCount: 5,
          scheduleCount: 12,
        );

        // Assert
        expect(
          group.description,
          equals('A group with all features configured'),
        );
        expect(group.status, equals(GroupStatus.paused));
        expect(group.memberCount, equals(15));
        expect(group.maxMembers, equals(25));
        expect(group.settings, equals(customSettings));
        expect(group.scheduleConfig, equals(customScheduleConfig));
        expect(group.userRole, equals(GroupMemberRole.admin));
        expect(group.familyCount, equals(5));
        expect(group.scheduleCount, equals(12));
      });
    });

    group('Business Logic Methods', () {
      group('initials getter', () {
        test('should return single letter for single word name', () {
          // Arrange
          final group = Group(
            id: 'single-word',
            name: 'Carpool',
            familyId: 'family-1',
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.initials, equals('C'));
        });

        test('should return two letters for two-word name', () {
          // Arrange
          final group = Group(
            id: 'two-word',
            name: 'Morning Carpool',
            familyId: 'family-1',
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.initials, equals('MC'));
        });

        test(
          'should return two letters from first two words for multi-word name',
          () {
            // Arrange
            final group = Group(
              id: 'multi-word',
              name: 'Morning Carpool Activity Group',
              familyId: 'family-1',
              createdAt: testDateTime,
              updatedAt: testDateTime,
            );

            // Act & Assert
            expect(group.initials, equals('MC'));
          },
        );

        test('should handle empty name gracefully', () {
          // Arrange
          final group = Group(
            id: 'empty-name',
            name: '',
            familyId: 'family-1',
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.initials, equals('G')); // Default fallback
        });

        test('should handle whitespace-only name', () {
          // Arrange
          final group = Group(
            id: 'whitespace-name',
            name: '   ',
            familyId: 'family-1',
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.initials, equals('G')); // Default fallback
        });

        test('should handle names with leading/trailing whitespace', () {
          // Arrange
          final group = Group(
            id: 'trimmed-name',
            name: '  Test Group  ',
            familyId: 'family-1',
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.initials, equals('TG'));
        });

        test('should return uppercase initials', () {
          // Arrange
          final group = Group(
            id: 'lowercase-name',
            name: 'morning carpool',
            familyId: 'family-1',
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.initials, equals('MC'));
        });
      });

      group('isActive getter', () {
        test('should return true for active status', () {
          // Arrange
          final group = Group(
            id: 'active-group',
            name: 'Active Group',
            familyId: 'family-1',
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.isActive, isTrue);
        });

        test('should return false for non-active statuses', () {
          // Test paused
          var group = Group(
            id: 'paused-group',
            name: 'Paused Group',
            familyId: 'family-1',
            status: GroupStatus.paused,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );
          expect(group.isActive, isFalse);

          // Test archived
          group = group.copyWith(status: GroupStatus.archived);
          expect(group.isActive, isFalse);

          // Test draft
          group = group.copyWith(status: GroupStatus.draft);
          expect(group.isActive, isFalse);
        });
      });

      group('isAtCapacity getter', () {
        test('should return false when no max members set', () {
          // Arrange
          final group = Group(
            id: 'no-limit-group',
            name: 'No Limit Group',
            familyId: 'family-1',
            memberCount: 100,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.isAtCapacity, isFalse);
        });

        test('should return true when member count equals max members', () {
          // Arrange
          final group = Group(
            id: 'at-capacity-group',
            name: 'At Capacity Group',
            familyId: 'family-1',
            memberCount: 10,
            maxMembers: 10,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.isAtCapacity, isTrue);
        });

        test('should return true when member count exceeds max members', () {
          // Arrange
          final group = Group(
            id: 'over-capacity-group',
            name: 'Over Capacity Group',
            familyId: 'family-1',
            memberCount: 12,
            maxMembers: 10,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.isAtCapacity, isTrue);
        });

        test('should return false when member count is below max members', () {
          // Arrange
          final group = Group(
            id: 'below-capacity-group',
            name: 'Below Capacity Group',
            familyId: 'family-1',
            memberCount: 5,
            maxMembers: 10,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.isAtCapacity, isFalse);
        });
      });

      group('canAcceptNewMembers getter', () {
        test('should return true for active group below capacity', () {
          // Arrange
          final group = Group(
            id: 'accepting-group',
            name: 'Accepting Group',
            familyId: 'family-1',
            memberCount: 5,
            maxMembers: 10,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.canAcceptNewMembers, isTrue);
        });

        test(
          'should return false for inactive group even if below capacity',
          () {
            // Arrange
            final group = Group(
              id: 'inactive-group',
              name: 'Inactive Group',
              familyId: 'family-1',
              status: GroupStatus.paused,
              memberCount: 5,
              maxMembers: 10,
              createdAt: testDateTime,
              updatedAt: testDateTime,
            );

            // Act & Assert
            expect(group.canAcceptNewMembers, isFalse);
          },
        );

        test('should return false for active group at capacity', () {
          // Arrange
          final group = Group(
            id: 'full-group',
            name: 'Full Group',
            familyId: 'family-1',
            memberCount: 10,
            maxMembers: 10,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.canAcceptNewMembers, isFalse);
        });

        test('should return true for active group with no member limit', () {
          // Arrange
          final group = Group(
            id: 'unlimited-group',
            name: 'Unlimited Group',
            familyId: 'family-1',
            memberCount: 100,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.canAcceptNewMembers, isTrue);
        });
      });

      group('availableSpots getter', () {
        test('should return high number when no max members set', () {
          // Arrange
          final group = Group(
            id: 'unlimited-spots',
            name: 'Unlimited Spots',
            familyId: 'family-1',
            memberCount: 50,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.availableSpots, equals(999));
        });

        test('should return correct spots available', () {
          // Arrange
          final group = Group(
            id: 'available-spots',
            name: 'Available Spots',
            familyId: 'family-1',
            memberCount: 7,
            maxMembers: 15,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.availableSpots, equals(8)); // 15 - 7 = 8
        });

        test('should return zero when at or over capacity', () {
          // At capacity
          var group = Group(
            id: 'at-capacity',
            name: 'At Capacity',
            familyId: 'family-1',
            memberCount: 10,
            maxMembers: 10,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );
          expect(group.availableSpots, equals(0));

          // Over capacity
          group = group.copyWith(memberCount: 12);
          expect(group.availableSpots, equals(0));
        });
      });

      group('utilizationPercentage getter', () {
        test('should return 0.0 when no max members set', () {
          // Arrange
          final group = Group(
            id: 'no-max-utilization',
            name: 'No Max Utilization',
            familyId: 'family-1',
            memberCount: 50,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.utilizationPercentage, equals(0.0));
        });

        test('should return 0.0 when max members is zero', () {
          // Arrange
          final group = Group(
            id: 'zero-max',
            name: 'Zero Max',
            familyId: 'family-1',
            maxMembers: 0,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.utilizationPercentage, equals(0.0));
        });

        test('should calculate correct utilization percentage', () {
          // Arrange - 6 out of 10 = 60%
          final group = Group(
            id: 'sixty-percent',
            name: 'Sixty Percent',
            familyId: 'family-1',
            memberCount: 6,
            maxMembers: 10,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.utilizationPercentage, equals(60.0));
        });

        test('should handle over 100% utilization', () {
          // Arrange - 15 out of 10 = 150%
          final group = Group(
            id: 'over-capacity-utilization',
            name: 'Over Capacity Utilization',
            familyId: 'family-1',
            memberCount: 15,
            maxMembers: 10,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.utilizationPercentage, equals(150.0));
        });

        test('should handle decimal utilization', () {
          // Arrange - 1 out of 3 = 33.333...%
          final group = Group(
            id: 'decimal-utilization',
            name: 'Decimal Utilization',
            familyId: 'family-1',
            memberCount: 1,
            maxMembers: 3,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          // Act & Assert
          expect(group.utilizationPercentage, closeTo(33.33333, 0.001));
        });
      });

      group('daysSinceCreated getter', () {
        test('should calculate days since creation correctly', () {
          // Arrange - Group created 5 days ago
          final createdAt = DateTime.now().subtract(const Duration(days: 5));
          final group = Group(
            id: 'days-test',
            name: 'Days Test',
            familyId: 'family-1',
            createdAt: createdAt,
            updatedAt: createdAt,
          );

          // Act & Assert
          expect(group.daysSinceCreated, equals(5));
        });

        test('should return 0 for group created today', () {
          // Arrange - Group created today
          final today = DateTime.now();
          final group = Group(
            id: 'today-group',
            name: 'Today Group',
            familyId: 'family-1',
            createdAt: today,
            updatedAt: today,
          );

          // Act & Assert
          expect(group.daysSinceCreated, equals(0));
        });
      });
    });

    group('copyWith Method', () {
      test('should create copy with updated fields', () {
        // Arrange
        final original = Group(
          id: 'original-id',
          name: 'Original Group',
          familyId: 'original-family',
          description: 'Original description',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          memberCount: 5,
          maxMembers: 10,
        );

        // Act
        final updated = original.copyWith(
          name: 'Updated Group',
          description: 'Updated description',
          memberCount: 8,
          status: GroupStatus.paused,
        );

        // Assert - Updated fields
        expect(updated.name, equals('Updated Group'));
        expect(updated.description, equals('Updated description'));
        expect(updated.memberCount, equals(8));
        expect(updated.status, equals(GroupStatus.paused));

        // Assert - Unchanged fields
        expect(updated.id, equals('original-id'));
        expect(updated.familyId, equals('original-family'));
        expect(updated.createdAt, equals(testDateTime));
        expect(updated.updatedAt, equals(testDateTime));
        expect(updated.maxMembers, equals(10));
      });

      test('should return identical copy when no parameters provided', () {
        // Arrange
        final original = Group(
          id: 'identical-test',
          name: 'Identical Test',
          familyId: 'family-identical',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          memberCount: 3,
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy, equals(original));
        expect(copy.id, equals(original.id));
        expect(copy.name, equals(original.name));
        expect(copy.memberCount, equals(original.memberCount));
      });
    });

    group('Equality & HashCode', () {
      test('should be equal when all properties match', () {
        // Arrange
        final group1 = Group(
          id: 'equal-test',
          name: 'Equal Test',
          familyId: 'family-equal',
          description: 'Test description',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          memberCount: 5,
          maxMembers: 10,
        );

        final group2 = Group(
          id: 'equal-test',
          name: 'Equal Test',
          familyId: 'family-equal',
          description: 'Test description',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          memberCount: 5,
          maxMembers: 10,
        );

        // Act & Assert
        expect(group1, equals(group2));
        expect(group1.hashCode, equals(group2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final group1 = Group(
          id: 'not-equal-1',
          name: 'Group 1',
          familyId: 'family-1',
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final group2 = Group(
          id: 'not-equal-2',
          name: 'Group 2',
          familyId: 'family-2',
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Act & Assert
        expect(group1, isNot(equals(group2)));
      });
    });

    group('toString Method', () {
      test('should provide readable string representation', () {
        // Arrange
        final group = Group(
          id: 'tostring-test',
          name: 'ToString Test Group',
          familyId: 'family-tostring',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          memberCount: 7,
        );

        // Act
        final stringRepresentation = group.toString();

        // Assert
        expect(stringRepresentation, contains('tostring-test'));
        expect(stringRepresentation, contains('ToString Test Group'));
        expect(stringRepresentation, contains('7'));
        expect(stringRepresentation, contains('active'));
      });
    });
  });
}
