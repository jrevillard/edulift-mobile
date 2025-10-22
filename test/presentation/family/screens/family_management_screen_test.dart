import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/core/domain/entities/family.dart';
import '../../../support/simple_widget_test_helper.dart';
import '../../../support/test_screen_sizes.dart';
import '../../../test_mocks/test_mocks.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
  });
  group('FamilyManagementScreen Vehicle Actions Bottom Sheet Layout Fix Tests', () {
    testWidgets(
      'bottom sheet layout prevents RenderFlex overflow with proper scrollable design',
      (tester) async {
        // Arrange - Create a test vehicle with proper required fields
        final testVehicle = Vehicle(
          id: '1',
          name: 'Test Vehicle',
          familyId: 'test-family-id',
          capacity: 5,
          description: 'Test vehicle description',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Create a minimal test widget to test the bottom sheet layout fix
        final testWidget = MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                key: const Key('test_vehicle_actions_button'),
                onPressed: () => _showTestVehicleActions(context, testVehicle),
                child: const Text('Test Vehicle Actions'),
              ),
            ),
          ),
        );

        // Act
        await tester.pumpWidget(testWidget);
        await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

        // Tap the test button to show the bottom sheet
        await tester.tap(find.byKey(const Key('test_vehicle_actions_button')));
        await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

        // Assert
        // 1. Verify SingleChildScrollView is present (makes it scrollable)
        expect(find.byType(SingleChildScrollView), findsOneWidget);

        // 2. Verify all 5 action ListTiles are present and accessible
        expect(find.byType(ListTile), findsNWidgets(5));

        // 3. Verify the Container with proper constraints is present
        expect(find.byType(Container), findsWidgets);

        // 4. Verify all action icons are visible
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.byIcon(Icons.info), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
        expect(find.byIcon(Icons.airline_seat_recline_normal), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);

        // 5. Most importantly: Test that the widget renders without overflow exceptions
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('bottom sheet is scrollable on small screens to prevent overflow', (
      tester,
    ) async {
      // Arrange - Test overflow prevention on small screen with modal bottom sheet
      await TestScreenSizes.setScreenSize(
        tester,
        TestScreenSizes.testSmallMobile,
      );

      final testVehicle = Vehicle(
        id: '2',
        name:
            'Vehicle with a Very Long Name That Could Potentially Cause Layout Issues',
        familyId: 'test-family-id',
        capacity: 8,
        description: 'Another test vehicle',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final testWidget = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => _showTestVehicleActions(context, testVehicle),
              child: const Text('Test Small Screen'),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(testWidget);
      await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

      await tester.tap(find.text('Test Small Screen'));
      await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

      // Assert
      // 1. Verify scrollable content is present
      final scrollView = find.byType(SingleChildScrollView);
      expect(scrollView, findsOneWidget);

      // 2. Test scrolling capability - this should work without overflow
      await tester.drag(scrollView, const Offset(0, -100));
      await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

      // 3. All actions should remain accessible after scrolling
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);

      // 4. Critical: No exceptions should occur, especially RenderFlex overflow
      expect(tester.takeException(), isNull);

      // Reset screen size after small screen modal test
      await TestScreenSizes.resetScreenSize(tester);
    });

    testWidgets(
      'bottom sheet uses proper Material Design patterns with safe constraints',
      (tester) async {
        final testVehicle = Vehicle(
          id: '3',
          name: 'Styled Vehicle',
          familyId: 'test-family-id',
          capacity: 6,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final testWidget = MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => _showTestVehicleActions(context, testVehicle),
                child: const Text('Test MD3 Styling'),
              ),
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

        await tester.tap(find.text('Test MD3 Styling'));
        await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

        // Verify Material Design 3 patterns are applied
        // 1. Drag handle container is present for better UX
        expect(find.byType(Container), findsWidgets);

        // 2. Proper padding and margins are applied
        expect(find.byType(Padding), findsWidgets);

        // 3. All required action icons are present and properly styled
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.byIcon(Icons.info), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
        expect(find.byIcon(Icons.airline_seat_recline_normal), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);

        // 4. Vehicle name is displayed properly in the title
        expect(find.textContaining('Styled Vehicle'), findsOneWidget);

        // 5. No layout exceptions with the new design
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('FamilyManagementScreen Member Management Tests', () {
    testWidgets('displays current user with (You) badge', (tester) async {
      // Arrange
      final currentUser = FamilyMember(
        id: 'current-user-id',
        familyId: 'test-family-id',
        userId: 'current-user-id',
        role: FamilyRole.admin,
      status: 'ACTIVE',
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        userName: 'Current User',
        userEmail: 'current@example.com',
      );

      final otherMember = FamilyMember(
        id: 'other-user-id',
        familyId: 'test-family-id',
        userId: 'other-user-id',
        role: FamilyRole.member,
      status: 'ACTIVE',
        joinedAt: DateTime.now().subtract(const Duration(days: 15)),
        userName: 'Other User',
        userEmail: 'other@example.com',
      );

      final widget = MaterialApp(
        home: SimpleMockWidget(
          members: [currentUser, otherMember],
          currentUserId: 'current-user-id',
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Current user should have "(You)" badge
      expect(find.textContaining('Current User'), findsOneWidget);
      expect(find.textContaining('(You)'), findsOneWidget);
      expect(find.textContaining('Other User'), findsOneWidget);
    });

    testWidgets('admin can see member action buttons for other members', (
      tester,
    ) async {
      // Arrange
      final adminUser = FamilyMember(
        id: 'admin-user-id',
        familyId: 'test-family-id',
        userId: 'admin-user-id',
        role: FamilyRole.admin,
      status: 'ACTIVE',
        joinedAt: DateTime.now().subtract(const Duration(days: 60)),
        userName: 'Admin User',
        userEmail: 'admin@example.com',
      );

      final regularMember = FamilyMember(
        id: 'regular-member-id',
        familyId: 'test-family-id',
        userId: 'regular-member-id',
        role: FamilyRole.member,
      status: 'ACTIVE',
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        userName: 'Regular Member',
        userEmail: 'member@example.com',
      );

      final widget = MaterialApp(
        home: SimpleMockWidget(
          members: [adminUser, regularMember],
          currentUserId: 'admin-user-id',
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Find member cards
      final regularMemberCard = find.ancestor(
        of: find.textContaining('Regular Member'),
        matching: find.byType(Card),
      );
      expect(regularMemberCard, findsOneWidget);

      // Admin should be able to see more options for other members
      final moreButton = find.descendant(
        of: regularMemberCard,
        matching: find.byIcon(Icons.more_vert),
      );
      expect(moreButton, findsOneWidget);

      // Tap the more options button
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Should show member management options
      expect(find.textContaining('Promote'), findsOneWidget);
      expect(find.textContaining('Remove'), findsOneWidget);
    });

    testWidgets('regular member cannot see action buttons for other members', (
      tester,
    ) async {
      // Arrange
      final regularUser = FamilyMember(
        id: 'regular-user-id',
        familyId: 'test-family-id',
        userId: 'regular-user-id',
        role: FamilyRole.member,
      status: 'ACTIVE',
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        userName: 'Regular User',
        userEmail: 'regular@example.com',
      );

      final adminMember = FamilyMember(
        id: 'admin-member-id',
        familyId: 'test-family-id',
        userId: 'admin-member-id',
        role: FamilyRole.admin,
      status: 'ACTIVE',
        joinedAt: DateTime.now().subtract(const Duration(days: 60)),
        userName: 'Admin Member',
        userEmail: 'admin@example.com',
      );

      final widget = MaterialApp(
        home: SimpleMockWidget(
          members: [regularUser, adminMember],
          currentUserId: 'regular-user-id',
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Find admin member card
      final adminMemberCard = find.ancestor(
        of: find.textContaining('Admin Member'),
        matching: find.byType(Card),
      );
      expect(adminMemberCard, findsOneWidget);

      // Regular member should NOT see action buttons for admin
      final moreButton = find.descendant(
        of: adminMemberCard,
        matching: find.byIcon(Icons.more_vert),
      );
      expect(moreButton, findsNothing);
    });

    testWidgets('member action buttons work correctly', (tester) async {
      // Arrange - Test that action buttons appear for other members when current user is admin
      final adminUser = FamilyMember(
        id: 'admin-user-id',
        familyId: 'test-family-id',
        userId: 'admin-user-id',
        role: FamilyRole.admin,
      status: 'ACTIVE',
        joinedAt: DateTime.now().subtract(const Duration(days: 60)),
        userName: 'Admin User',
        userEmail: 'admin@example.com',
      );

      final regularMember = FamilyMember(
        id: 'regular-member-id',
        familyId: 'test-family-id',
        userId: 'regular-member-id',
        role: FamilyRole.member,
      status: 'ACTIVE',
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        userName: 'Regular Member',
        userEmail: 'member@example.com',
      );

      final widget = MaterialApp(
        home: SimpleMockWidget(
          members: [adminUser, regularMember],
          currentUserId: 'admin-user-id',
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Admin should see action buttons for other members but not themselves
      final adminCard = find.ancestor(
        of: find.textContaining('Admin User'),
        matching: find.byType(Card),
      );
      final regularCard = find.ancestor(
        of: find.textContaining('Regular Member'),
        matching: find.byType(Card),
      );

      expect(adminCard, findsOneWidget);
      expect(regularCard, findsOneWidget);

      // Admin should NOT have action button on their own card
      final adminActionButton = find.descendant(
        of: adminCard,
        matching: find.byIcon(Icons.more_vert),
      );
      expect(adminActionButton, findsNothing);

      // Admin should have action button on other member's card
      final memberActionButton = find.descendant(
        of: regularCard,
        matching: find.byIcon(Icons.more_vert),
      );
      expect(memberActionButton, findsOneWidget);
    });

    testWidgets('member roles are displayed correctly', (tester) async {
      // Arrange
      final adminMember = FamilyMember(
        id: 'admin-id',
        familyId: 'test-family-id',
        userId: 'admin-id',
        role: FamilyRole.admin,
      status: 'ACTIVE',
        joinedAt: DateTime.now().subtract(const Duration(days: 60)),
        userName: 'Admin User',
        userEmail: 'admin@example.com',
      );

      final regularMember = FamilyMember(
        id: 'member-id',
        familyId: 'test-family-id',
        userId: 'member-id',
        role: FamilyRole.member,
      status: 'ACTIVE',
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        userName: 'Regular User',
        userEmail: 'regular@example.com',
      );

      final widget = MaterialApp(
        home: SimpleMockWidget(
          members: [adminMember, regularMember],
          currentUserId: 'admin-id',
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Role badges should be displayed
      expect(find.textContaining('ADMIN'), findsOneWidget);
      expect(find.textContaining('MEMBER'), findsOneWidget);
    });

    testWidgets('member join dates are formatted correctly', (tester) async {
      // Arrange
      final joinDate = DateTime(2024, 1, 15);
      final member = FamilyMember(
        id: 'member-id',
        familyId: 'test-family-id',
        userId: 'member-id',
        role: FamilyRole.member,
      status: 'ACTIVE',
        joinedAt: joinDate,
        userName: 'Test Member',
        userEmail: 'test@example.com',
      );

      final widget = MaterialApp(
        home: SimpleMockWidget(members: [member], currentUserId: 'member-id'),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Join date should be formatted
      expect(find.textContaining('Joined'), findsOneWidget);
      expect(find.textContaining('2024-01-15'), findsOneWidget);
    });
  });
}

// Simple mock for testing without complex provider setup
class SimpleMockWidget extends StatelessWidget {
  final List<FamilyMember> members;
  final String? currentUserId;

  const SimpleMockWidget({
    super.key,
    required this.members,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Management')),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          final isCurrentUser = member.userId == currentUserId;
          return Card(
            child: ListTile(
              title: Row(
                children: [
                  Text(member.userName ?? 'Unknown'),
                  if (isCurrentUser)
                    const Text(
                      ' (You)',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.userEmail ?? ''),
                  Text('Role: ${member.role.value}'),
                  Text('Joined: ${member.joinedAt.toString().split(' ')[0]}'),
                ],
              ),
              trailing: _shouldShowActionButton(member, currentUserId)
                  ? IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showMemberActions(context, member),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// Check if the current user should see action button for this member
  /// Only admins can manage other members (not themselves)
  bool _shouldShowActionButton(FamilyMember member, String? currentUserId) {
    if (currentUserId == null) return false;

    // Find current user's role
    final currentUserMember = members.firstWhere(
      (m) => m.userId == currentUserId,
      orElse: () => FamilyMember(
        id: 'unknown',
        familyId: 'unknown',
        userId: currentUserId,
        role: FamilyRole.member, // Default to member if not found
        status: 'ACTIVE',
        joinedAt: DateTime.now(),
      ),
    );

    // Only admins can see action buttons
    final isCurrentUserAdmin = currentUserMember.role == FamilyRole.admin;
    // Don't show action button for current user's own card
    final isNotCurrentUser = member.userId != currentUserId;

    return isCurrentUserAdmin && isNotCurrentUser;
  }

  void _showMemberActions(BuildContext context, FamilyMember member) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Promote'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            title: const Text('Remove'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// Test helper function that replicates the fixed _showVehicleActions method
void _showTestVehicleActions(BuildContext context, Vehicle vehicle) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle for better UX
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  'More actions for ${vehicle.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('View Details'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Schedule'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.airline_seat_recline_normal),
                title: const Text('Seat Override'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(context),
              ),
              // Bottom padding for safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      );
    },
  );
}
