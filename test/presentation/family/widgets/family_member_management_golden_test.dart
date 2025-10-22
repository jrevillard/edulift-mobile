import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:edulift/features/family/presentation/widgets/member_action_bottom_sheet.dart';
import 'package:edulift/features/family/presentation/widgets/remove_member_confirmation_dialog.dart';
import 'package:edulift/features/family/presentation/widgets/invite_member_widget.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

import '../../../support/mock_fallbacks.dart';
import '../../../support/accessibility_test_helper.dart';
import '../../../support/test_provider_overrides.dart';
import '../../../support/simple_widget_test_helper.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/features/family/presentation/providers/family_provider.dart';
import 'package:edulift/core/utils/result.dart';
import '../../../test_mocks/generated_mocks.dart' as gen_mocks;

void main() {
  setUpAll(() {
    setupMockFallbacks();
  });

  group('Family Member Management Golden Tests', () {
    late FamilyMember regularMember;
    late FamilyMember adminMember;
    late User currentUser;

    setUp(() {
      regularMember = FamilyMember(
        id: 'member-123',
        familyId: 'family-456',
        userId: 'user-789',
        role: FamilyRole.member,
      status: 'ACTIVE',
        joinedAt: DateTime(2024),
        userName: 'John Member',
        userEmail: 'john@example.com',
      );

      adminMember = FamilyMember(
        id: 'admin-123',
        familyId: 'family-456',
        userId: 'admin-789',
        role: FamilyRole.admin,
      status: 'ACTIVE',
        joinedAt: DateTime(2024),
        userName: 'Admin User',
        userEmail: 'admin@example.com',
      );

      currentUser = User(
        id: 'current-user-123',
        email: 'current@example.com',
        name: 'Current User',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
    });

    testWidgets('member action bottom sheet for regular member', (
      tester,
    ) async {
      // Arrange
      final widget = ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) {
            final notifier = TestAuthNotifier.withRef(ref);
            notifier.state = AuthState(user: currentUser, isInitialized: true);
            return notifier;
          }),
        ],
        child: MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MemberActionBottomSheet(
              member: regularMember,
              canManageRoles: true,
              onViewDetails: () {},
              onChangeRole: () {},
              onRemoveMember: () {},
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Golden test
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'member_action_bottom_sheet_regular_member',
        finder: find.byType(MemberActionBottomSheet),
      );

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('member action bottom sheet for admin member', (tester) async {
      // Arrange
      final widget = ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) {
            final notifier = TestAuthNotifier.withRef(ref);
            notifier.state = AuthState(user: currentUser, isInitialized: true);
            return notifier;
          }),
        ],
        child: MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MemberActionBottomSheet(
              member: adminMember,
              canManageRoles: true,
              onViewDetails: () {},
              onChangeRole: () {},
              onRemoveMember: () {},
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Golden test
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'member_action_bottom_sheet_admin_member',
        finder: find.byType(MemberActionBottomSheet),
      );

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets(
      'member action bottom sheet for current user (leave family option)',
      (tester) async {
        // Arrange
        final currentUserMember = regularMember.copyWith(
          userId: currentUser.id,
          userName: currentUser.name,
          userEmail: currentUser.email,
        );

        final widget = ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) {
              final notifier = TestAuthNotifier.withRef(ref);
              notifier.state = AuthState(
                user: currentUser,
                isInitialized: true,
              );
              return notifier;
            }),
          ],
          child: MaterialApp(
            theme: ThemeData.light(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MemberActionBottomSheet(
                member: currentUserMember,
                canManageRoles: true,
                onViewDetails: () {},
                onLeaveFamily: () {},
              ),
            ),
          ),
        );

        // Act
        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Assert - Golden test
        await SimpleWidgetTestHelper.expectGoldenFile(
          tester,
          'member_action_bottom_sheet_current_user',
          finder: find.byType(MemberActionBottomSheet),
        );

        // Verify accessibility
        await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
      },
    );

    testWidgets('remove member confirmation dialog for regular member', (
      tester,
    ) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RemoveMemberConfirmationDialog(member: regularMember),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Golden test
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'remove_member_dialog_regular_member',
        finder: find.byType(AlertDialog),
      );

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('remove member confirmation dialog for admin member', (
      tester,
    ) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RemoveMemberConfirmationDialog(member: adminMember),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Golden test
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'remove_member_dialog_admin_member',
        finder: find.byType(AlertDialog),
      );

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('remove member confirmation dialog with loading state', (
      tester,
    ) async {
      // Arrange
      final mockFamilyNotifier = gen_mocks.MockFamilyNotifier();
      when(
        mockFamilyNotifier.removeMember(
          familyId: anyNamed('familyId'),
          memberId: 'member-123',
        ),
      ).thenAnswer((_) async {
        return null;
      });

      final widget = ProviderScope(
        overrides: [familyProvider.overrideWith((ref) => mockFamilyNotifier)],
        child: MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RemoveMemberConfirmationDialog(member: regularMember),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Trigger remove action - Use specific finder to avoid ambiguity
      // Look for the Remove Member text within a clickable button context
      final removeButton = find.descendant(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is TextButton ||
              widget is ElevatedButton ||
              widget is InkWell,
        ),
        matching: find.text('Remove Member'),
      );
      await tester.tap(removeButton);
      await tester.pump(); // Capture loading state

      // Assert - Golden test for loading state
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'remove_member_dialog_loading',
        finder: find.byType(AlertDialog),
      );

      // Verify accessibility during loading
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('invite member widget initial state', (tester) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: InviteMemberWidget(),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Golden test
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'invite_member_widget_initial',
        finder: find.byType(Card),
      );

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('invite member widget with form filled', (tester) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: InviteMemberWidget(),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Fill form fields - Use TextFormField by index since we know the order
      final allTextFields = find.byType(TextFormField);
      if (allTextFields.evaluate().length >= 2) {
        await tester.enterText(allTextFields.at(0), 'newmember@example.com');
        await tester.enterText(allTextFields.at(1), 'New Family Member');
      }
      await tester.pumpAndSettle();

      // Select invitation type using key
      await tester.tap(find.byKey(const Key('invitation_type_selector')));
      await tester.pumpAndSettle();

      // Assert - Golden test with filled form
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'invite_member_widget_filled',
        finder: find.byType(Card),
      );

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('invite member widget with validation errors', (tester) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: InviteMemberWidget(),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Enter invalid email and trigger validation
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address *'),
        'invalid-email',
      );
      await tester.tap(find.byKey(const Key('send_invitation_button')));
      await tester.pumpAndSettle();

      // Assert - Golden test with validation errors
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'invite_member_widget_validation_errors',
        finder: find.byType(Card),
      );

      // Verify accessibility with errors
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('invite member widget with loading state', (tester) async {
      // Arrange
      final mockFamilyNotifier = gen_mocks.MockFamilyNotifier();
      when(
        mockFamilyNotifier.sendFamilyInvitationToMember(
          familyId: anyNamed('familyId'),
          email: anyNamed('email'),
          role: anyNamed('role'),
          personalMessage: anyNamed('personalMessage'),
        ),
      ).thenAnswer((_) async {
        return Result.ok(gen_mocks.TestDataFactory.createTestInvitation());
      });

      final widget = ProviderScope(
        overrides: [familyProvider.overrideWith((ref) => mockFamilyNotifier)],
        child: MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: InviteMemberWidget(),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Fill form and trigger sending
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address *'),
        'test@example.com',
      );
      await tester.tap(find.byKey(const Key('send_invitation_button')));
      await tester.pump(); // Capture loading state

      // Assert - Golden test for loading state
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'invite_member_widget_loading',
        finder: find.byType(Card),
      );

      // Verify accessibility during loading
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('dark theme - member action bottom sheet', (tester) async {
      // Arrange
      final widget = ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) {
            final notifier = TestAuthNotifier.withRef(ref);
            notifier.state = AuthState(user: currentUser, isInitialized: true);
            return notifier;
          }),
        ],
        child: MaterialApp(
          theme: ThemeData.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MemberActionBottomSheet(
              member: regularMember,
              canManageRoles: true,
              onViewDetails: () {},
              onChangeRole: () {},
              onRemoveMember: () {},
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Golden test for dark theme
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'member_action_bottom_sheet_dark_theme',
        finder: find.byType(MemberActionBottomSheet),
      );

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('dark theme - remove member confirmation dialog', (
      tester,
    ) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          theme: ThemeData.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RemoveMemberConfirmationDialog(member: regularMember),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Golden test for dark theme
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'remove_member_dialog_dark_theme',
        finder: find.byType(AlertDialog),
      );

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('dark theme - invite member widget', (tester) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          theme: ThemeData.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: InviteMemberWidget(),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Golden test for dark theme
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'invite_member_widget_dark_theme',
        finder: find.byType(Card),
      );

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('custom color scheme - member management widgets', (
      tester,
    ) async {
      // Arrange
      const customColorScheme = ColorScheme.light(
        primary: Colors.green,
        secondary: Colors.orange,
        error: Colors.red,
        surface: Colors.grey,
        primaryContainer: Colors.lightGreen,
        errorContainer: Colors.pink,
      );

      final widget = ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) {
            final notifier = TestAuthNotifier.withRef(ref);
            notifier.state = AuthState(user: currentUser, isInitialized: true);
            return notifier;
          }),
        ],
        child: MaterialApp(
          theme: ThemeData(colorScheme: customColorScheme),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  MemberActionBottomSheet(
                    member: regularMember,
                    canManageRoles: true,
                    onChangeRole: () {},
                    onRemoveMember: () {},
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: InviteMemberWidget(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Golden test for custom theme
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'member_management_custom_theme',
        finder: find.byType(Scaffold),
      );

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('member with very long name display', (tester) async {
      // Arrange
      final memberWithLongName = regularMember.copyWith(
        userName:
            'This Is A Member With A Very Long Name That Should Be Handled Properly In The UI',
      );

      final widget = ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) {
            final notifier = TestAuthNotifier.withRef(ref);
            notifier.state = AuthState(user: currentUser, isInitialized: true);
            return notifier;
          }),
        ],
        child: MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MemberActionBottomSheet(
              member: memberWithLongName,
              canManageRoles: true,
              onChangeRole: () {},
              onRemoveMember: () {},
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Golden test for long name handling
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'member_action_bottom_sheet_long_name',
        finder: find.byType(MemberActionBottomSheet),
      );

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('member with empty/null display name', (tester) async {
      // Arrange
      final memberWithEmptyName = regularMember.copyWith(userName: '');

      final widget = ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) {
            final notifier = TestAuthNotifier.withRef(ref);
            notifier.state = AuthState(user: currentUser, isInitialized: true);
            return notifier;
          }),
        ],
        child: MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MemberActionBottomSheet(
              member: memberWithEmptyName,
              canManageRoles: true,
              onChangeRole: () {},
              onRemoveMember: () {},
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Golden test for empty name handling
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'member_action_bottom_sheet_empty_name',
        finder: find.byType(MemberActionBottomSheet),
      );

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });
  });
}
