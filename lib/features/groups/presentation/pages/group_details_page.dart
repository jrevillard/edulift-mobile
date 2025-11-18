import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import '../../../../core/navigation/navigation_state.dart';
import '../../providers.dart';
import '../../../../core/domain/entities/groups/group.dart';
import 'edit_group_page.dart';
import '../widgets/leave_group_confirmation_dialog.dart';
import '../../../../core/presentation/mixins/navigation_cleanup_mixin.dart';
import '../utils/groups_error_translation_helper.dart';

class GroupDetailsPage extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailsPage({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends ConsumerState<GroupDetailsPage>
    with NavigationCleanupMixin {
  // NavigationCleanupMixin automatically clears navigation state in initState

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupsState = ref.watch(groupsComposedProvider);
    final isTablet = context.isTablet;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('groupDetails_goBack_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.groupDetails,
          style: TextStyle(fontSize: (isTablet ? 22 : 20) * context.fontScale),
        ),
      ),
      body: groupsState.isLoading && groupsState.groups.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : groupsState.error != null && groupsState.groups.isEmpty
          ? _buildErrorWidget(l10n, groupsState.error!)
          : _buildGroupDetails(context, l10n, groupsState.groups, isTablet),
    );
  }

  Widget _buildGroupDetails(
    BuildContext context,
    AppLocalizations l10n,
    List<dynamic> groups,
    bool isTablet,
  ) {
    // Find the group with the matching ID
    dynamic group;
    try {
      group = groups.firstWhere(
        (g) => (g is Map ? g['id'] : g?.id) == widget.groupId,
      );
    } catch (e) {
      group = null;
    }

    if (group == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: context.getAdaptiveIconSize(
                mobile: 56,
                tablet: 64,
                desktop: 72,
              ),
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            Text(
              l10n.groupNotFound,
              style: TextStyle(fontSize: 16 * context.fontScale),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 6,
                tablet: 8,
                desktop: 10,
              ),
            ),
            Text(
              l10n.groupNotFoundOrNoAccess,
              style: TextStyle(
                color: AppColors.textSecondaryThemed(context),
                fontSize: 14 * context.fontScale,
              ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ),
            ),
            ElevatedButton(
              key: const Key('groupDetails_error_goBack_button'),
              onPressed: () => ref
                  .read(navigationStateProvider.notifier)
                  .navigateTo(
                    route: '/groups',
                    trigger: NavigationTrigger.userNavigation,
                  ),
              child: Text(l10n.goBackButton),
            ),
          ],
        ),
      );
    }

    final groupName = group is Map
        ? group['name']
        : group?.name ?? l10n.unnamedGroup;
    final groupDescription = group is Map
        ? group['description']
        : group?.description;
    final userRole = group is Map ? group['userRole'] : group?.userRole;
    final familyCount = group is Map
        ? group['familyCount']
        : group?.familyCount ?? 0;
    final scheduleCount = group is Map
        ? group['scheduleCount']
        : group?.scheduleCount ?? 0;
    final createdAt = group is Map ? group['createdAt'] : group?.createdAt;

    final isGroupAdmin =
        userRole == GroupMemberRole.admin || userRole == GroupMemberRole.owner;

    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.maxContentWidth),
            child: Padding(
              padding: context.getAdaptivePadding(
                mobileHorizontal: 16,
                mobileVertical: 12,
                tabletHorizontal: 24,
                tabletVertical: 16,
                desktopHorizontal: 32,
                desktopVertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group header
                  Card(
                    child: Padding(
                      padding: context.getAdaptivePadding(
                        mobileAll: 16,
                        tabletAll: 20,
                        desktopAll: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: context.getAdaptiveIconSize(
                                  mobile: 48,
                                  tablet: 56,
                                  desktop: 64,
                                ),
                                height: context.getAdaptiveIconSize(
                                  mobile: 48,
                                  tablet: 56,
                                  desktop: 64,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    context.getAdaptiveBorderRadius(
                                      mobile: 10,
                                      tablet: 12,
                                      desktop: 14,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  Icons.groups,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: context.getAdaptiveIconSize(
                                    mobile: 24,
                                    tablet: 28,
                                    desktop: 32,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: context.getAdaptiveSpacing(
                                  mobile: 12,
                                  tablet: 16,
                                  desktop: 20,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            groupName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        if (isGroupAdmin) ...[
                                          IconButton(
                                            key: const Key(
                                              'groupDetails_edit_button',
                                            ),
                                            icon: Icon(
                                              Icons.edit,
                                              size: context.getAdaptiveIconSize(
                                                mobile: 20,
                                                tablet: 22,
                                                desktop: 24,
                                              ),
                                            ),
                                            onPressed: () =>
                                                _navigateToEditGroup(
                                                  context,
                                                  ref,
                                                  widget.groupId,
                                                  groupName,
                                                  groupDescription,
                                                ),
                                            tooltip: l10n.editGroup,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (userRole != null) ...[
                                      SizedBox(
                                        height: context.getAdaptiveSpacing(
                                          mobile: 4,
                                          tablet: 6,
                                          desktop: 8,
                                        ),
                                      ),
                                      _buildRoleBadge(
                                        _roleToString(userRole),
                                        context,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (groupDescription != null &&
                              groupDescription.isNotEmpty) ...[
                            SizedBox(
                              height: context.getAdaptiveSpacing(
                                mobile: 12,
                                tablet: 16,
                                desktop: 20,
                              ),
                            ),
                            Text(
                              groupDescription,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontSize: 15 * context.fontScale),
                            ),
                          ],
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 12,
                              tablet: 16,
                              desktop: 20,
                            ),
                          ),
                          Wrap(
                            spacing: context.getAdaptiveSpacing(
                              mobile: 8,
                              tablet: 12,
                              desktop: 16,
                            ),
                            runSpacing: context.getAdaptiveSpacing(
                              mobile: 8,
                              tablet: 12,
                              desktop: 16,
                            ),
                            children: [
                              _buildInfoChip(
                                Icons.family_restroom,
                                l10n.familyCount(familyCount),
                                context,
                              ),
                              _buildInfoChip(
                                Icons.event,
                                l10n.scheduleCount(scheduleCount),
                                context,
                              ),
                              if (createdAt != null)
                                _buildInfoChip(
                                  Icons.calendar_today,
                                  '${l10n.created.toLowerCase()} ${_formatDate(createdAt, context)}',
                                  context,
                                ),
                              _buildInfoChip(
                                Icons.fingerprint,
                                'ID: ${widget.groupId}',
                                context,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: context.getAdaptiveSpacing(
                      mobile: 20,
                      tablet: 24,
                      desktop: 28,
                    ),
                  ),

                  // Member Management Card (visible for all users)
                  // All users can view members (per Access-Control-and-Permissions.md)
                  // But only ADMIN/OWNER can invite families or manage roles
                  Card(
                    child: Padding(
                      padding: context.getAdaptivePadding(
                        mobileAll: 16,
                        tabletAll: 20,
                        desktopAll: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: Theme.of(context).colorScheme.primary,
                                size: context.getAdaptiveIconSize(
                                  mobile: 20,
                                  tablet: 22,
                                  desktop: 24,
                                ),
                              ),
                              SizedBox(
                                width: context.getAdaptiveSpacing(
                                  mobile: 10,
                                  tablet: 12,
                                  desktop: 14,
                                ),
                              ),
                              Text(
                                l10n.manageMembers,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.isMobile
                                          ? 18
                                          : 20 * context.fontScale,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 6,
                              tablet: 8,
                              desktop: 10,
                            ),
                          ),
                          Text(
                            l10n.manageMembersDescription,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondaryThemed(context),
                                  fontSize: 14 * context.fontScale,
                                ),
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              key: const Key(
                                'groupDetails_manageMembers_button',
                              ),
                              onPressed: () {
                                ref
                                    .read(navigationStateProvider.notifier)
                                    .navigateTo(
                                      route:
                                          '/groups/${widget.groupId}/members?groupName=${Uri.encodeComponent(groupName)}',
                                      trigger: NavigationTrigger.userNavigation,
                                    );
                              },
                              icon: Icon(
                                Icons.group,
                                size: context.getAdaptiveIconSize(
                                  mobile: 18,
                                  tablet: 20,
                                  desktop: 22,
                                ),
                              ),
                              label: Text(l10n.manageMembers),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: context.getAdaptiveSpacing(
                      mobile: 20,
                      tablet: 24,
                      desktop: 28,
                    ),
                  ),

                  // Schedule Configuration Card (for admins only)
                  if (isGroupAdmin) ...[
                    Card(
                      child: Padding(
                        padding: context.getAdaptivePadding(
                          mobileAll: 16,
                          tabletAll: 20,
                          desktopAll: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: context.getAdaptiveIconSize(
                                    mobile: 20,
                                    tablet: 22,
                                    desktop: 24,
                                  ),
                                ),
                                SizedBox(
                                  width: context.getAdaptiveSpacing(
                                    mobile: 10,
                                    tablet: 12,
                                    desktop: 14,
                                  ),
                                ),
                                Text(
                                  l10n.scheduleConfiguration,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.isMobile
                                            ? 18
                                            : 20 * context.fontScale,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: context.getAdaptiveSpacing(
                                mobile: 6,
                                tablet: 8,
                                desktop: 10,
                              ),
                            ),
                            Text(
                              l10n.defaultGroupConfigInfo,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondaryThemed(
                                      context,
                                    ),
                                    fontSize: 14 * context.fontScale,
                                  ),
                            ),
                            SizedBox(
                              height: context.getAdaptiveSpacing(
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                key: const Key(
                                  'groupDetails_configureSchedule_button',
                                ),
                                onPressed: () {
                                  ref
                                      .read(navigationStateProvider.notifier)
                                      .navigateTo(
                                        route:
                                            '/groups/${widget.groupId}/manage',
                                        trigger:
                                            NavigationTrigger.userNavigation,
                                      );
                                },
                                icon: Icon(
                                  Icons.settings,
                                  size: context.getAdaptiveIconSize(
                                    mobile: 18,
                                    tablet: 20,
                                    desktop: 22,
                                  ),
                                ),
                                label: Text(l10n.configureSchedule),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: context.getAdaptiveSpacing(
                        mobile: 20,
                        tablet: 24,
                        desktop: 28,
                      ),
                    ),
                  ],

                  // Group Actions Card
                  Card(
                    child: Padding(
                      padding: context.getAdaptivePadding(
                        mobileAll: 16,
                        tabletAll: 20,
                        desktopAll: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.group,
                                color: Theme.of(context).colorScheme.primary,
                                size: context.getAdaptiveIconSize(
                                  mobile: 20,
                                  tablet: 22,
                                  desktop: 24,
                                ),
                              ),
                              SizedBox(
                                width: context.getAdaptiveSpacing(
                                  mobile: 10,
                                  tablet: 12,
                                  desktop: 14,
                                ),
                              ),
                              Text(
                                l10n.groupActions,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.isMobile
                                          ? 18
                                          : 20 * context.fontScale,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              key: const Key(
                                'groupDetails_viewSchedule_button',
                              ),
                              onPressed: () {
                                ref
                                    .read(navigationStateProvider.notifier)
                                    .navigateTo(
                                      route:
                                          '/schedule?group=${widget.groupId}',
                                      trigger: NavigationTrigger.userNavigation,
                                    );
                              },
                              icon: Icon(
                                Icons.calendar_today,
                                size: context.getAdaptiveIconSize(
                                  mobile: 18,
                                  tablet: 20,
                                  desktop: 22,
                                ),
                              ),
                              label: Text(l10n.viewGroupSchedule),
                            ),
                          ),
                          // Leave Group button - only show if not owner
                          if (userRole != null &&
                              userRole != GroupMemberRole.owner) ...[
                            SizedBox(
                              height: context.getAdaptiveSpacing(
                                mobile: 10,
                                tablet: 12,
                                desktop: 14,
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                key: const Key(
                                  'groupDetails_leaveGroup_button',
                                ),
                                onPressed: () => _showLeaveGroupDialog(
                                  context,
                                  ref,
                                  widget.groupId,
                                  groupName,
                                  userRole,
                                ),
                                icon: Icon(
                                  Icons.exit_to_app,
                                  size: context.getAdaptiveIconSize(
                                    mobile: 18,
                                    tablet: 20,
                                    desktop: 22,
                                  ),
                                ),
                                label: Text(l10n.leaveGroup),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(AppLocalizations l10n, String errorKey) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: context.getAdaptiveIconSize(
              mobile: 56,
              tablet: 64,
              desktop: 72,
            ),
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(
            height: context.getAdaptiveSpacing(
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),
          Text(
            l10n.failedToLoadGroupDetails,
            style: TextStyle(fontSize: 16 * context.fontScale),
          ),
          SizedBox(
            height: context.getAdaptiveSpacing(
              mobile: 6,
              tablet: 8,
              desktop: 10,
            ),
          ),
          Text(
            GroupsErrorTranslationHelper.translateError(l10n, errorKey),
            style: TextStyle(
              color: AppColors.textSecondaryThemed(context),
              fontSize: 14 * context.fontScale,
            ),
          ),
          SizedBox(
            height: context.getAdaptiveSpacing(
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
          ),
          ElevatedButton(
            key: const Key('groupDetails_tryAgain_button'),
            onPressed: () {
              ref.read(groupsComposedProvider.notifier).loadUserGroups();
            },
            child: Text(l10n.tryAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role, BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (role.toUpperCase()) {
      case 'OWNER':
        backgroundColor = Theme.of(context).colorScheme.tertiaryContainer;
        textColor = AppColors.tertiary(context);
        break;
      case 'ADMIN':
        backgroundColor = Theme.of(context).colorScheme.errorContainer;
        textColor = Theme.of(context).colorScheme.error;
        break;
      case 'MEMBER':
      default:
        backgroundColor = AppColors.surfaceVariantThemed(context);
        textColor = AppColors.textSecondaryThemed(context);
        break;
    }

    return Container(
      padding: context.getAdaptivePadding(
        mobileHorizontal: 10,
        mobileVertical: 3,
        tabletHorizontal: 12,
        tabletVertical: 4,
        desktopHorizontal: 14,
        desktopVertical: 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          context.getAdaptiveBorderRadius(mobile: 14, tablet: 16, desktop: 18),
        ),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: textColor,
          fontSize: 11 * context.fontScale,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, BuildContext context) {
    return Container(
      padding: context.getAdaptivePadding(
        mobileHorizontal: 10,
        mobileVertical: 4,
        tabletHorizontal: 12,
        tabletVertical: 6,
        desktopHorizontal: 14,
        desktopVertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          context.getAdaptiveBorderRadius(mobile: 14, tablet: 16, desktop: 18),
        ),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: context.getAdaptiveIconSize(
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(
            width: context.getAdaptiveSpacing(mobile: 4, tablet: 6, desktop: 8),
          ),
          Text(label, style: TextStyle(fontSize: 11 * context.fontScale)),
        ],
      ),
    );
  }

  String _roleToString(GroupMemberRole role) {
    final l10n = AppLocalizations.of(context);
    switch (role) {
      case GroupMemberRole.owner:
        return l10n.roleOwner;
      case GroupMemberRole.admin:
        return l10n.roleAdmin;
      case GroupMemberRole.member:
        return l10n.roleMember;
    }
  }

  String _formatDate(DateTime date, BuildContext context) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToEditGroup(
    BuildContext context,
    WidgetRef ref,
    String groupId,
    String currentName,
    String? currentDescription,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditGroupPage(
          groupId: groupId,
          currentName: currentName,
          currentDescription: currentDescription,
        ),
      ),
    );
    // updateGroup() in EditGroupPage already calls loadUserGroups() internally
    // so the provider state is automatically refreshed
  }

  void _showLeaveGroupDialog(
    BuildContext context,
    WidgetRef ref,
    String groupId,
    String groupName,
    GroupMemberRole userRole,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => LeaveGroupConfirmationDialog(
        groupId: groupId,
        groupName: groupName,
        userRole: userRole,
        onSuccess: () {
          // Navigate to groups list after successful leave
          ref
              .read(navigationStateProvider.notifier)
              .navigateTo(
                route: '/groups',
                trigger: NavigationTrigger.userNavigation,
              );
        },
      ),
    );

    // If the user left the group, navigation will happen via onSuccess callback
    // No need to refresh here as the user is already navigated away
  }
}
