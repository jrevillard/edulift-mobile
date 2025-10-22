import 'package:go_router/go_router.dart';
import '../../../../core/router/route_factory.dart';
import '../../../../core/router/app_routes.dart';
import '../pages/groups_page.dart';
import '../pages/group_details_page.dart';
import '../pages/group_schedule_config_page.dart';
import '../pages/group_invitation_page.dart';
import '../pages/group_members_management_page.dart';
import '../pages/create_group_page.dart';

/// Route factory for groups feature
class GroupsRouteFactory implements AppRouteFactory {
  @override
  List<RouteBase> get routes => [
    // Groups
    GoRoute(
      path: AppRoutes.groups,
      name: 'groups',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: GroupsPage()),
      routes: [
        // IMPORTANT: Static routes MUST come BEFORE dynamic :groupId route
        // Otherwise 'create' will be interpreted as groupId value

        // Create group route (static - must be before :groupId)
        GoRoute(
          path: 'create',
          name: 'create-group',
          builder: (context, state) => const CreateGroupPage(),
        ),

        // Dynamic group details route (must be AFTER static routes)
        GoRoute(
          path: ':groupId',
          name: 'group-details',
          builder: (context, state) {
            final groupId = state.pathParameters['groupId']!;
            return GroupDetailsPage(groupId: groupId);
          },
          routes: [
            GoRoute(
              path: 'manage',
              name: 'group-manage',
              builder: (context, state) {
                final groupId = state.pathParameters['groupId']!;
                return GroupScheduleConfigPage(
                  groupId: groupId, groupName: '', // Will be loaded in the page
                );
              },
            ),
            GoRoute(
              path: 'members',
              name: 'group-members',
              builder: (context, state) {
                final groupId = state.pathParameters['groupId']!;
                final groupName = state.uri.queryParameters['groupName'] ?? '';
                return GroupMembersManagementPage(
                  groupId: groupId,
                  groupName: groupName,
                );
              },
            ),
          ],
        ),
      ],
    ),

    // Group invitation routes - OUTSIDE shell (no menu/navigation)
    // Must be at root level to avoid being wrapped in main shell
    GoRoute(
      path: AppRoutes.groupInvitation,
      name: 'group-invitation',
      builder: (context, state) {
        final code = state.uri.queryParameters['code'];
        return GroupInvitationPage(inviteCode: code);
      },
    ),
  ];
}
