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
              size: 64,
              color: AppColors.errorThemed(context),
            ),
            const SizedBox(height: 16),
            Text(l10n.groupNotFound, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              l10n.groupNotFoundOrNoAccess,
              style: TextStyle(color: AppColors.textSecondaryThemed(context)),
            ),
            const SizedBox(height: 24),
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
        : group?.name ?? 'Unnamed Group';
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
                                  borderRadius: BorderRadius.circular(12),
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
                                  ?.copyWith(fontSize: 16 * context.fontScale),
                            ),
                          ],
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 12,
                              tablet: 16,
                              desktop: 20,
                            ),
                          ),
                          Row(
                            children: [
                              _buildInfoChip(
                                Icons.family_restroom,
                                l10n.familyCount(familyCount),
                                context,
                              ),
                              SizedBox(
                                width: context.getAdaptiveSpacing(
                                  mobile: 12,
                                  tablet: 16,
                                  desktop: 20,
                                ),
                              ),
                              _buildInfoChip(
                                Icons.event,
                                l10n.scheduleCount(scheduleCount),
                                context,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Member Management Card (visible for all users)
                  // All users can view members (per Access-Control-and-Permissions.md)
                  // But only ADMIN/OWNER can invite families or manage roles
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.manageMembers,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.manageMembersDescription,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondaryThemed(context),
                                ),
                          ),
                          const SizedBox(height: 16),
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
                              icon: const Icon(Icons.group),
                              label: Text(l10n.manageMembers),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Schedule Configuration Card (for admins only)
                  if (isGroupAdmin) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.scheduleConfiguration,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Configure the schedule for this group including time slots and active days',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondaryThemed(
                                      context,
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 16),
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
                                icon: const Icon(Icons.settings),
                                label: Text(l10n.configureSchedule),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Group Actions Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.group,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Group Actions',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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
                              icon: const Icon(Icons.calendar_today),
                              label: Text(l10n.viewGroupSchedule),
                            ),
                          ),
                          // Leave Group button - only show if not owner
                          if (userRole != null &&
                              userRole != GroupMemberRole.owner) ...[
                            const SizedBox(height: 12),
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
                                icon: const Icon(Icons.exit_to_app),
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

                  const SizedBox(height: 24),

                  // Group Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Group Information',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (createdAt != null) ...[
                            _buildInfoRow(
                              'Created',
                              _formatDate(createdAt, context),
                              context,
                            ),
                            const SizedBox(height: 8),
                          ],
                          _buildInfoRow('Group ID', widget.groupId, context),
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
            size: 64,
            color: AppColors.errorThemed(context),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.failedToLoadGroupDetails,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            GroupsErrorTranslationHelper.translateError(l10n, errorKey),
            style: TextStyle(color: AppColors.textSecondaryThemed(context)),
          ),
          const SizedBox(height: 24),
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
        backgroundColor = AppColors.tertiaryContainer(context);
        textColor = AppColors.tertiary(context);
        break;
      case 'ADMIN':
        backgroundColor = AppColors.errorContainer(context);
        textColor = AppColors.errorThemed(context);
        break;
      case 'MEMBER':
      default:
        backgroundColor = AppColors.surfaceVariantThemed(context);
        textColor = AppColors.textSecondaryThemed(context);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
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
        borderRadius: BorderRadius.circular(16),
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
          Text(label, style: TextStyle(fontSize: 12 * context.fontScale)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: AppColors.textSecondaryThemed(context)),
          ),
        ),
      ],
    );
  }

  String _roleToString(GroupMemberRole role) {
    switch (role) {
      case GroupMemberRole.owner:
        return 'Owner';
      case GroupMemberRole.admin:
        return 'Admin';
      case GroupMemberRole.member:
        return 'Member';
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
