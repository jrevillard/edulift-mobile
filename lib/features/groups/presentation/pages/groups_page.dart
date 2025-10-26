import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/navigation/navigation_state.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import '../../providers.dart';
import '../widgets/group_card.dart';
import '../../../../core/presentation/mixins/navigation_cleanup_mixin.dart';
import '../utils/groups_error_translation_helper.dart';

class GroupsPage extends ConsumerStatefulWidget {
  const GroupsPage({super.key});

  @override
  ConsumerState<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends ConsumerState<GroupsPage>
    with NavigationCleanupMixin {
  @override
  void initState() {
    super.initState();
    // NavigationCleanupMixin automatically clears navigation state
    // Load groups when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupsComposedProvider.notifier).loadUserGroups();
    });
  }

  void _handleSelectGroup(String groupId) {
    // MODERN ARCHITECTURE: Use navigation state with trigger
    ref
        .read(navigationStateProvider.notifier)
        .navigateTo(
          route: '/groups/$groupId',
          trigger: NavigationTrigger.userNavigation,
          context: {'groupId': groupId, 'action': 'view_details'},
        );
  }

  void _handleManageGroup(String groupId) {
    // MODERN ARCHITECTURE: Use navigation state for group schedule management
    ref
        .read(navigationStateProvider.notifier)
        .navigateTo(
          route: '/groups/$groupId/manage',
          trigger: NavigationTrigger.userNavigation,
          context: {'groupId': groupId, 'action': 'manage_schedule'},
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupsState = ref.watch(groupsComposedProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.transportGroups,
          key: const Key('transportation_groups_title'),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          // Join Group Button
          IconButton(
            key: const Key('join_group_button'),
            icon: Icon(
              Icons.person_add,
              size: context.getAdaptiveIconSize(
                mobile: 24,
                tablet: 26,
                desktop: 28,
              ),
            ),
            onPressed: () {
              ref.read(groupsComposedProvider.notifier).clearJoinError();
              ref
                  .read(navigationStateProvider.notifier)
                  .navigateTo(
                    route: '/group-invitation',
                    trigger: NavigationTrigger.userNavigation,
                  );
            },
            tooltip: l10n.joinGroup,
          ),
          // Create Group Button
          IconButton(
            key: const Key('create_group_button'),
            icon: Icon(
              Icons.add,
              size: context.getAdaptiveIconSize(
                mobile: 24,
                tablet: 26,
                desktop: 28,
              ),
            ),
            onPressed: () {
              ref.read(groupsComposedProvider.notifier).clearCreateError();
              ref
                  .read(navigationStateProvider.notifier)
                  .navigateTo(
                    route: '/groups/create',
                    trigger: NavigationTrigger.userNavigation,
                  );
            },
            tooltip: l10n.createGroup,
          ),
        ],
      ),
      body: // Build UI based on GroupsState
      groupsState.isLoading && groupsState.groups.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : groupsState.error != null && groupsState.groups.isEmpty
          ? _buildErrorState(
              GroupsErrorTranslationHelper.translateError(
                l10n,
                groupsState.error!,
              ),
            )
          : _buildGroupsList(groupsState.groups),
    );
  }

  Widget _buildGroupsList(List<dynamic> groups) {
    return RefreshIndicator(
      key: const Key('groupsList_refreshIndicator'),
      onRefresh: () =>
          ref.read(groupsComposedProvider.notifier).loadUserGroups(),
      child: groups.isEmpty ? _buildEmptyState() : _buildGroupsGrid(groups),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    final isTablet = context.isTablet;

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxWidth: context.maxContentWidth,
              ),
              child: Padding(
                padding: context.getAdaptivePadding(
                  mobileHorizontal: 32,
                  mobileVertical: 24,
                  tabletHorizontal: 48,
                  tabletVertical: 32,
                  desktopHorizontal: 64,
                  desktopVertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: context.getAdaptiveIconSize(
                        mobile: 120,
                        tablet: 140,
                        desktop: 160,
                      ),
                      color: AppColors.borderThemed(context),
                    ),
                    SizedBox(
                      height: context.getAdaptiveSpacing(
                        mobile: 24,
                        tablet: 28,
                        desktop: 32,
                      ),
                    ),
                    Text(
                      l10n.noTransportGroups,
                      style:
                          (isTablet
                                  ? Theme.of(context).textTheme.headlineMedium
                                  : Theme.of(context).textTheme.headlineSmall)
                              ?.copyWith(
                                color: AppColors.textSecondaryThemed(context),
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    (isTablet ? 28 : 24) * context.fontScale,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: context.getAdaptiveSpacing(
                        mobile: 12,
                        tablet: 16,
                        desktop: 20,
                      ),
                    ),
                    Text(
                      l10n.noTransportGroupsDescription,
                      textAlign: TextAlign.center,
                      style:
                          (isTablet
                                  ? Theme.of(context).textTheme.titleMedium
                                  : Theme.of(context).textTheme.bodyMedium)
                              ?.copyWith(
                                color: AppColors.textSecondaryThemed(context),
                                fontSize:
                                    (isTablet ? 18 : 16) * context.fontScale,
                              ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: context.getAdaptiveSpacing(
                        mobile: 32,
                        tablet: 40,
                        desktop: 48,
                      ),
                    ),
                    // Responsive button layout
                    if (isTablet)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: context.getAdaptiveButtonHeight(
                              tablet: 52,
                              desktop: 56,
                            ),
                            child: ElevatedButton.icon(
                              key: const Key('join_group_empty_state_button'),
                              onPressed: () {
                                ref
                                    .read(groupsComposedProvider.notifier)
                                    .clearJoinError();
                                ref
                                    .read(navigationStateProvider.notifier)
                                    .navigateTo(
                                      route: '/group-invitation',
                                      trigger: NavigationTrigger.userNavigation,
                                    );
                              },
                              icon: Icon(
                                Icons.person_add,
                                size: context.getAdaptiveIconSize(
                                  tablet: 22,
                                  desktop: 24,
                                ),
                              ),
                              label: Text(
                                l10n.joinGroup,
                                style: TextStyle(
                                  fontSize:
                                      (isTablet ? 18 : 16) * context.fontScale,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                padding: context.getAdaptivePadding(
                                  tabletHorizontal: 24,
                                  desktopHorizontal: 32,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: context.getAdaptiveSpacing(
                              tablet: 20,
                              desktop: 24,
                            ),
                          ),
                          SizedBox(
                            height: context.getAdaptiveButtonHeight(
                              tablet: 52,
                              desktop: 56,
                            ),
                            child: ElevatedButton.icon(
                              key: const Key('create_group_empty_state_button'),
                              onPressed: () {
                                ref
                                    .read(groupsComposedProvider.notifier)
                                    .clearCreateError();
                                ref
                                    .read(navigationStateProvider.notifier)
                                    .navigateTo(
                                      route: '/groups/create',
                                      trigger: NavigationTrigger.userNavigation,
                                    );
                              },
                              icon: Icon(
                                Icons.add,
                                size: context.getAdaptiveIconSize(
                                  tablet: 22,
                                  desktop: 24,
                                ),
                              ),
                              label: Text(
                                l10n.createGroup,
                                style: TextStyle(
                                  fontSize:
                                      (isTablet ? 18 : 16) * context.fontScale,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: context.getAdaptivePadding(
                                  tabletHorizontal: 24,
                                  desktopHorizontal: 32,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: context.getAdaptiveButtonHeight(mobile: 48),
                            child: ElevatedButton.icon(
                              key: const Key('join_group_empty_state_button'),
                              onPressed: () {
                                ref
                                    .read(groupsComposedProvider.notifier)
                                    .clearJoinError();
                                ref
                                    .read(navigationStateProvider.notifier)
                                    .navigateTo(
                                      route: '/group-invitation',
                                      trigger: NavigationTrigger.userNavigation,
                                    );
                              },
                              icon: const Icon(Icons.person_add),
                              label: Text(l10n.joinGroup),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(mobile: 16),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: context.getAdaptiveButtonHeight(mobile: 48),
                            child: ElevatedButton.icon(
                              key: const Key('create_group_empty_state_button'),
                              onPressed: () {
                                ref
                                    .read(groupsComposedProvider.notifier)
                                    .clearCreateError();
                                ref
                                    .read(navigationStateProvider.notifier)
                                    .navigateTo(
                                      route: '/groups/create',
                                      trigger: NavigationTrigger.userNavigation,
                                    );
                              },
                              icon: const Icon(Icons.add),
                              label: Text(l10n.createGroup),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupsGrid(List<dynamic> groups) {
    // Responsive grid columns following established patterns
    final crossAxisCount = context.getGridColumns(
      mobile: 1,
      tablet: 2,
      desktop: 3,
      wide: 4,
    );

    final childAspectRatio = context.isDesktop
        ? 1.0
        : (context.isTablet ? 0.9 : 0.8);

    return Padding(
      padding: context.getAdaptivePadding(
        mobileHorizontal: 16,
        mobileVertical: 8,
        tabletHorizontal: 24,
        tabletVertical: 12,
        desktopHorizontal: 32,
        desktopVertical: 16,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.maxContentWidth),
            child: GridView.builder(
              key: const Key('groupsList_grid'),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: context.getAdaptiveSpacing(
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                ),
                mainAxisSpacing: context.getAdaptiveSpacing(
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                ),
              ),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return GroupCard(
                  key: Key('groupCard_${group.id}'),
                  group: group,
                  onSelect: () => _handleSelectGroup(group.id),
                  onManage: () => _handleManageGroup(group.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final l10n = AppLocalizations.of(context);
    final isTablet = context.isTablet;

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxWidth: context.maxContentWidth,
              ),
              child: Padding(
                padding: context.getAdaptivePadding(
                  mobileHorizontal: 32,
                  mobileVertical: 24,
                  tabletHorizontal: 48,
                  tabletVertical: 32,
                  desktopHorizontal: 64,
                  desktopVertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: context.getAdaptiveIconSize(
                        mobile: 80,
                        tablet: 96,
                        desktop: 112,
                      ),
                      color: AppColors.errorThemed(context),
                    ),
                    SizedBox(
                      height: context.getAdaptiveSpacing(
                        mobile: 16,
                        tablet: 20,
                        desktop: 24,
                      ),
                    ),
                    Text(
                      l10n.failedToLoadGroups,
                      style:
                          (isTablet
                                  ? Theme.of(context).textTheme.headlineMedium
                                  : Theme.of(context).textTheme.headlineSmall)
                              ?.copyWith(
                                color: AppColors.errorThemed(context),
                                fontSize:
                                    (isTablet ? 28 : 24) * context.fontScale,
                                fontWeight: FontWeight.w600,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: context.getAdaptiveSpacing(
                        mobile: 8,
                        tablet: 12,
                        desktop: 16,
                      ),
                    ),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style:
                          (isTablet
                                  ? Theme.of(context).textTheme.titleMedium
                                  : Theme.of(context).textTheme.bodyMedium)
                              ?.copyWith(
                                color: AppColors.textSecondaryThemed(context),
                                fontSize:
                                    (isTablet ? 18 : 16) * context.fontScale,
                              ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: context.getAdaptiveSpacing(
                        mobile: 24,
                        tablet: 32,
                        desktop: 40,
                      ),
                    ),
                    SizedBox(
                      height: context.getAdaptiveButtonHeight(
                        mobile: 48,
                        tablet: 52,
                        desktop: 56,
                      ),
                      child: ElevatedButton.icon(
                        key: const Key('groupsList_tryAgain_button'),
                        onPressed: () {
                          final notifier = ref.read(
                            groupsComposedProvider.notifier,
                          );
                          notifier.clearError();
                          notifier.loadUserGroups();
                        },
                        icon: Icon(
                          Icons.refresh,
                          size: context.getAdaptiveIconSize(
                            mobile: 20,
                            tablet: 22,
                            desktop: 24,
                          ),
                        ),
                        label: Text(
                          l10n.tryAgain,
                          style: TextStyle(
                            fontSize: (isTablet ? 18 : 16) * context.fontScale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: context.getAdaptivePadding(
                            mobileHorizontal: 24,
                            tabletHorizontal: 32,
                            desktopHorizontal: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Cancel any ongoing operations
    super.dispose();
  }
}
