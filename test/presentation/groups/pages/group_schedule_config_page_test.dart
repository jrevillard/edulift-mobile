// Group Schedule Config Page Tests
// Tests the group schedule configuration page functionality

import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/groups/presentation/pages/group_schedule_config_page.dart';

void main() {
  group('GroupScheduleConfigPage', () {
    test('can be instantiated with required parameters', () {
      // Act & Assert
      expect(
        const GroupScheduleConfigPage(
          groupId: 'test-group-id',
          groupName: 'Test Group',
        ),
        isNotNull,
      );
    });
  });
}
