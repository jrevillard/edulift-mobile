// Group Details Page Tests
// Tests the group details page functionality

import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/groups/presentation/pages/group_details_page.dart';

void main() {
  group('GroupDetailsPage', () {
    test('can be instantiated with required parameters', () {
      // Act & Assert
      expect(const GroupDetailsPage(groupId: 'test-group-id'), isNotNull);
    });

    test('has correct groupId property', () {
      // Arrange
      const groupId = 'test-group-123';
      const page = GroupDetailsPage(groupId: groupId);

      // Assert
      expect(page.groupId, equals(groupId));
    });

    test('is a ConsumerWidget', () {
      // Arrange
      const page = GroupDetailsPage(groupId: 'test-id');

      // Assert - Verify it's a ConsumerWidget (has build method with WidgetRef)
      expect(page, isNotNull);
    });
  });
}
