import 'dart:async';
import 'package:edulift/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// COMPOSITION ROOT: Import ONLY from feature-level composition root
import '../../providers.dart';
import 'package:edulift/core/domain/entities/family.dart' as entities;
import '../widgets/invitation_management_widget.dart'
    show FamilyInvitationManagementWidget;
import 'package:edulift/core/router/app_routes.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/presentation/themes/app_colors.dart';
import '../widgets/role_change_confirmation_dialog.dart';
import '../widgets/member_action_bottom_sheet.dart';
import '../widgets/remove_member_confirmation_dialog.dart';
import '../widgets/leave_family_confirmation_dialog.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;
import 'package:edulift/core/presentation/mixins/navigation_cleanup_mixin.dart';
import 'package:edulift/core/presentation/utils/responsive_breakpoints.dart';

/// Family management screen with comprehensive family, children, and vehicles management
class FamilyManagementScreen extends ConsumerStatefulWidget {
  final int? initialTabIndex;

  const FamilyManagementScreen({super.key, this.initialTabIndex});

  @override
  ConsumerState<FamilyManagementScreen> createState() =>
      _FamilyManagementScreenState();
}

class _FamilyManagementScreenState extends ConsumerState<FamilyManagementScreen>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin,
        NavigationCleanupMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _searchQuery = '';
  Timer? _searchTimer;

  @override
  bool get wantKeepAlive => true; // Keep alive for better UX

  @override
  void initState() {
    super.initState();
    // NavigationCleanupMixin automatically clears navigation state
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0,
    );
    _searchController.addListener(_onSearchChanged);

    // CRITICAL FIX: Initialize permissions immediately to ensure isAdmin is available before widget rendering
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      AppLogger.debug(
        'FamilyManagementScreen: Initializing family and permissions',
      );
      // Load family and vehicles first
      await ref.read(familyComposedProvider.notifier).loadFamily();
      await ref.read(familyComposedProvider.notifier).loadVehicles();
      // CRITICAL: Initialize permissions using orchestrator (clean architecture)
      final familyState = ref.read(familyComposedProvider);
      if (familyState.family?.id != null) {
        AppLogger.debug(
          'FamilyManagementScreen: Initializing permissions for family ${familyState.family!.id}',
        );
        await ref
            .read(
              familyPermissionOrchestratorComposedProvider(
                familyState.family!.id,
              ).notifier,
            )
            .initializePermissions();
        AppLogger.debug(
          'FamilyManagementScreen: Permissions initialized for family ${familyState.family!.id}',
        );
      } else {
        AppLogger.warning(
          'FamilyManagementScreen: No family ID found, skipping permission initialization',
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Responsive design detection using responsive_breakpoints
    // Note: isTablet and isSmallScreen variables available for responsive logic

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    // CONSUMER : Accéder aux providers Riverpod uniquement via Consumer
    return Consumer(
      builder: (context, ref, child) {
        // Sélection efficace - seulement ce qui est nécessaire
        final familyState = ref.watch(familyComposedProvider);
        final vehiclesState = ref.watch(familyComposedProvider);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.myFamily),
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size(double.infinity, 140),
              child: Column(
                children: [
                  Padding(
                    padding: context.getAdaptivePadding(
                      mobileHorizontal: 16.0,
                      tabletHorizontal: 24.0,
                      desktopHorizontal: 32.0,
                      mobileVertical: 6.0,
                      tabletVertical: 8.0,
                      desktopVertical: 10.0,
                    ),
                    child: TextField(
                      key: const Key('familyManagement_search_field'),
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                key: const Key(
                                  'familyManagement_clearSearch_button',
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchFocusNode.unfocus();
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.getAdaptiveBorderRadius(
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        key: const Key('family_members_tab'),
                        icon: const Icon(Icons.people),
                        text: l10n.membersTabLabel,
                      ),
                      Tab(
                        key: const Key('family_children_tab'),
                        icon: const Icon(Icons.child_care),
                        text: l10n.children,
                      ),
                      Tab(
                        key: const Key('family_vehicles_tab'),
                        icon: const Icon(Icons.directions_car),
                        text: l10n.vehicles,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              RefreshIndicator(
                key: const Key('familyManagement_members_refreshIndicator'),
                onRefresh: () async {
                  await ref.read(familyComposedProvider.notifier).loadFamily();
                },
                child: _buildMembersTab(familyState, l10n),
              ),
              RefreshIndicator(
                key: const Key('familyManagement_children_refreshIndicator'),
                onRefresh: () async {
                  await ref.read(familyComposedProvider.notifier).loadFamily();
                },
                child: _buildChildrenTab(familyState, l10n),
              ),
              RefreshIndicator(
                key: const Key('familyManagement_vehicles_refreshIndicator'),
                onRefresh: () async {
                  await ref.read(familyComposedProvider.notifier).loadFamily();
                  await ref
                      .read(familyComposedProvider.notifier)
                      .loadVehicles();
                },
                child: _buildVehiclesTab(vehiclesState, l10n),
              ),
            ],
          ),
          floatingActionButton: AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) =>
                _buildFloatingActionButton(context, l10n),
          ),
        );
      },
    );
  }

  /// EXPERT FIX: CustomScrollView with Sliver architecture eliminates assertion errors
  Widget _buildMembersTab(FamilyState familyState, AppLocalizations l10n) {
    final family = familyState.family;
    if (family == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 64,
              color: AppColors.textSecondaryThemed(context),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noFamily,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryThemed(context),
              ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            Container(
              padding: context.getAdaptivePadding(
                mobileHorizontal: 24,
                mobileVertical: 12,
                tabletHorizontal: 30,
                tabletVertical: 14,
                desktopHorizontal: 36,
                desktopVertical: 16,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(
                  context.getAdaptiveBorderRadius(
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  ),
                ),
              ),
              child: GestureDetector(
                key: const Key('familyManagement_noFamily_inviteMember_button'),
                onTap: () => ref
                    .read(nav.navigationStateProvider.notifier)
                    .navigateTo(
                      route: AppRoutes.inviteMember,
                      trigger: nav.NavigationTrigger.userNavigation,
                    ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      SizedBox(
                        width: context.getAdaptiveSpacing(
                          mobile: 8,
                          tablet: 10,
                          desktop: 12,
                        ),
                      ),
                      Text(
                        l10n.inviteFamilyMembers,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Use orchestrator for clean architecture
    final isAdmin = ref.watch(
      canPerformMemberActionsComposedProvider(family.id),
    );
    // DEBUG: Log isAdmin value for debugging E2E tests
    AppLogger.debug(
      'FamilyManagementScreen: isAdmin value for family ${family.id}: $isAdmin',
    );

    // CRITICAL FIX: CustomScrollView eliminates TabBarView constraint conflicts
    return CustomScrollView(
      slivers: [
        // Family members header
        SliverToBoxAdapter(child: _buildMembersHeader(family, l10n)),
        // Members list using SliverList for proper constraint handling
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildMemberCard(
              family.members[index],
              l10n,
              key: ValueKey(
                family.members[index].id,
              ), // CRITICAL: Key for widget identity (needed for tests)
            ),
            childCount: family.members.length,
          ),
        ),
        // Family invitation management widget
        SliverToBoxAdapter(
          child: Container(
            padding: context.getAdaptivePadding(
              mobileAll: 16,
              tabletAll: 20,
              desktopAll: 24,
            ),
            child: FamilyInvitationManagementWidget(
              isAdmin: isAdmin,
              familyId: family.id,
            ),
          ),
        ),
      ],
    );
  }

  /// EXPERT FIX: Separate header widget for clean sliver architecture
  Widget _buildMembersHeader(entities.Family family, AppLocalizations l10n) {
    return Container(
      margin: context.getAdaptivePadding(
        mobileAll: 4.0,
        tabletAll: 8.0,
        desktopAll: 8.0,
      ),
    );
  }

  /// EXPERT FIX: ListTile with proper semantics prevents parent data assertion errors
  Widget _buildMemberCard(
    entities.FamilyMember member,
    AppLocalizations l10n, {
    Key? key,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayName = member.displayNameOrLoading;

    // Responsive design variables using responsive_breakpoints
    // final isTablet = context.isTablet; // Available if needed for responsive logic
    // final isSmallScreen = context.isMobile; // Available if needed for responsive logic

    // Get current user to identify if this is the current user's card
    final currentUser = ref.read(authStateProvider).user;
    final isCurrentUser = currentUser?.id == member.userId;

    // Check if current user can manage members (only admins can) - use orchestrator
    final familyId = ref.read(familyComposedProvider).family?.id ?? '';
    final canManageMembers =
        currentUser != null &&
        ref.watch(canPerformMemberActionsComposedProvider(familyId));

    // Debug logging for member card
    AppLogger.debug(
      '🎴 MemberCard for ${member.displayNameOrLoading} (${member.userId}):\n'
      '  - Member role: ${member.role}\n'
      '  - Current user ID: ${currentUser?.id}\n'
      '  - Family ID: $familyId\n'
      '  - Is current user: $isCurrentUser\n'
      '  - Can manage members: $canManageMembers\n'
      '  - Button will be: ${canManageMembers ? "ENABLED" : "DISABLED"}',
    );

    // CRITICAL FIX: Card + ListTile provides built-in semantic handling
    return Semantics(
      label:
          '${displayName}${isCurrentUser ? l10n.currentUserLabel : ''}, ${member.role.value}${member.userEmail != null ? ', ${member.userEmail}' : ''}',
      child: Card(
        key: key, // CRITICAL: Key parameter for widget identity (used in tests)
        margin: context.getAdaptivePadding(
          mobileHorizontal: 16.0,
          tabletHorizontal: 24.0,
          desktopHorizontal: 32.0,
          mobileVertical: 3.0,
          tabletVertical: 4.0,
          desktopVertical: 5.0,
        ),
        elevation: 0,
        color: isCurrentUser
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            context.getAdaptiveBorderRadius(
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
          side: BorderSide(
            color: isCurrentUser
                ? colorScheme.primary.withValues(alpha: 0.5)
                : colorScheme.outline.withValues(alpha: 0.1),
            width: isCurrentUser ? 1.5 : 1.0,
          ),
        ),
        child: ListTile(
          contentPadding: context.getAdaptivePadding(
            mobileAll: 16.0,
            tabletAll: 20.0,
            desktopAll: 24.0,
          ),
          leading: Container(
            width: context.getAdaptiveSpacing(
              mobile: 48.0,
              tablet: 56.0,
              desktop: 64.0,
            ),
            height: context.getAdaptiveSpacing(
              mobile: 48.0,
              tablet: 56.0,
              desktop: 64.0,
            ),
            decoration: BoxDecoration(
              color: member.role == entities.FamilyRole.admin
                  ? colorScheme.primaryContainer
                  : colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(
                context.getAdaptiveBorderRadius(
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ),
              ),
              border: isCurrentUser
                  ? Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.6),
                      width: 2.0,
                    )
                  : null,
            ),
            child: Center(
              child: member.role == entities.FamilyRole.admin
                  ? Icon(
                      Icons.admin_panel_settings,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    )
                  : Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  displayName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isCurrentUser) ...[
                SizedBox(
                  width: context.getAdaptiveSpacing(
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  ),
                ),
                Container(
                  padding: context.getAdaptivePadding(
                    mobileHorizontal: 8,
                    mobileVertical: 2,
                    tabletHorizontal: 10,
                    tabletVertical: 3,
                    desktopHorizontal: 12,
                    desktopVertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(
                      context.getAdaptiveBorderRadius(
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                      ),
                    ),
                  ),
                  child: Text(
                    l10n.youLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            '${member.role.value}${member.userEmail != null ? ' • ${member.userEmail}' : ''}',
            key: member.userEmail != null
                ? Key('member_email_${member.userEmail}')
                : null,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: canManageMembers
              ? IconButton(
                  key: Key('member_more_vert_button_${member.userName}'),
                  onPressed: () => _showMemberActions(member),
                  icon: const Icon(Icons.more_vert),
                  tooltip: l10n.memberActionsFor(
                    '${displayName}${isCurrentUser ? ' ${l10n.youLabel}' : ''}',
                  ),
                )
              : null,
          onTap: () => _showMemberDetails(member),
        ),
      ),
    );
  }

  Widget _buildChildrenTab(FamilyState familyState, AppLocalizations l10n) {
    if (familyState.isLoading && familyState.children.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (familyState.error != null && familyState.children.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(l10n.loadingError),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  ref.read(familyComposedProvider.notifier).loadFamily(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    final filteredChildren = familyState.children.where((child) {
      return _searchQuery.isEmpty ||
          child.name.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredChildren.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care,
              size: 64,
              color: AppColors.textSecondaryThemed(context),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noChildren,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryThemed(context),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('familyManagement_noChildren_addChild_button'),
              onPressed: () => ref
                  .read(nav.navigationStateProvider.notifier)
                  .navigateTo(
                    route: AppRoutes.addChild,
                    trigger: nav.NavigationTrigger.userNavigation,
                  ),
              child: Text(l10n.addChild),
            ),
          ],
        ),
      );
    }

    // CRITICAL FIX: Use CustomScrollView like members tab to ensure unlimited scrolling
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final child = filteredChildren[index];
            return Padding(
              padding: context.getAdaptivePadding(
                mobileHorizontal: 16,
                mobileVertical: 6,
                tabletHorizontal: 20,
                tabletVertical: 8,
                desktopHorizontal: 24,
                desktopVertical: 10,
              ),
              child: _buildChildCard(child, l10n),
            );
          }, childCount: filteredChildren.length),
        ),
      ],
    );
  }

  Widget _buildVehiclesTab(FamilyState vehiclesState, AppLocalizations l10n) {
    if (vehiclesState.isLoading && vehiclesState.vehicles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vehiclesState.error != null && vehiclesState.vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(l10n.loadingError),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  ref.read(familyComposedProvider.notifier).loadVehicles(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    // Filter vehicles based on search query - only by name and description (real properties)
    final filteredVehicles = vehiclesState.vehicles.where((vehicle) {
      return _searchQuery.isEmpty ||
          vehicle.name.toLowerCase().contains(_searchQuery) ||
          (vehicle.description?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    if (filteredVehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 64,
              color: AppColors.textSecondaryThemed(context),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noVehicles,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryThemed(context),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('familyManagement_noVehicles_addVehicle_button'),
              onPressed: () => ref
                  .read(nav.navigationStateProvider.notifier)
                  .navigateTo(
                    route: AppRoutes.addVehicle,
                    trigger: nav.NavigationTrigger.userNavigation,
                  ),
              child: Text(l10n.addVehicle),
            ),
          ],
        ),
      );
    }

    // CRITICAL FIX: Use CustomScrollView like members tab to ensure unlimited scrolling
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final vehicle = filteredVehicles[index];
            return Padding(
              padding: context.getAdaptivePadding(
                mobileHorizontal: 16,
                mobileVertical: 6,
                tabletHorizontal: 20,
                tabletVertical: 8,
                desktopHorizontal: 24,
                desktopVertical: 10,
              ),
              child: _buildVehicleCard(vehicle, l10n),
            );
          }, childCount: filteredVehicles.length),
        ),
      ],
    );
  }

  Widget _buildChildCard(entities.Child child, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // EMERGENCY FIX: Remove Card and InkWell - use simple Container
    return Container(
      padding: context.getAdaptivePadding(
        mobileAll: 16,
        tabletAll: 20,
        desktopAll: 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(
          context.getAdaptiveBorderRadius(mobile: 16, tablet: 18, desktop: 20),
        ),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: GestureDetector(
        key: Key('familyManagement_childCard_${child.id}'),
        onTap: () => _showChildDetails(child),
        child: Row(
          children: [
            Container(
              width: context.getAdaptiveSpacing(
                mobile: 48,
                tablet: 56,
                desktop: 64,
              ),
              height: context.getAdaptiveSpacing(
                mobile: 48,
                tablet: 56,
                desktop: 64,
              ),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(
                  context.getAdaptiveBorderRadius(
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: context.getAdaptiveSpacing(
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    key: Key('child_name_display_${child.name}'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (child.age != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      l10n.age(child.age!),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // ALWAYS show context menu - permissions filtered inside menu
            SizedBox(
              width: context.getAdaptiveSpacing(
                mobile: 44,
                tablet: 48,
                desktop: 52,
              ),
              height: context.getAdaptiveSpacing(
                mobile: 44,
                tablet: 48,
                desktop: 52,
              ),
              child: GestureDetector(
                key: Key('child_more_actions_${child.name}'),
                onTap: () => _showChildActions(child),
                child: const Icon(Icons.more_vert),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(entities.Vehicle vehicle, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // EMERGENCY FIX: Remove Card and InkWell - use simple Container
    return Container(
      padding: context.getAdaptivePadding(
        mobileAll: 16,
        tabletAll: 20,
        desktopAll: 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(
          context.getAdaptiveBorderRadius(mobile: 16, tablet: 18, desktop: 20),
        ),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: GestureDetector(
        key: Key('familyManagement_vehicleCard_${vehicle.id}'),
        onTap: () => _showVehicleDetails(vehicle),
        child: Row(
          children: [
            Container(
              width: context.getAdaptiveSpacing(
                mobile: 48,
                tablet: 56,
                desktop: 64,
              ),
              height: context.getAdaptiveSpacing(
                mobile: 48,
                tablet: 56,
                desktop: 64,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(
                  context.getAdaptiveBorderRadius(
                    mobile: 12,
                    tablet: 14,
                    desktop: 16,
                  ),
                ),
              ),
              child: Icon(
                Icons.directions_car,
                color: colorScheme.onPrimaryContainer,
                size: context.getAdaptiveIconSize(
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ),
              ),
            ),
            SizedBox(
              width: context.getAdaptiveSpacing(
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    key: Key('vehicle_name_display_${vehicle.name}'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(
                    height: context.getAdaptiveSpacing(
                      mobile: 4,
                      tablet: 6,
                      desktop: 8,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: context.getAdaptiveIconSize(
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      SizedBox(
                        width: context.getAdaptiveSpacing(
                          mobile: 4,
                          tablet: 6,
                          desktop: 8,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '${vehicle.capacity} ${l10n.seats}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (vehicle.description != null &&
                      vehicle.description!.isNotEmpty) ...[
                    SizedBox(
                      height: context.getAdaptiveSpacing(
                        mobile: 4,
                        tablet: 6,
                        desktop: 8,
                      ),
                    ),
                    Text(
                      vehicle.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              width: context.getAdaptiveSpacing(
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            Column(
              children: [
                // ALWAYS show context menu - permissions filtered inside menu
                GestureDetector(
                  key: Key('vehicle_more_actions_${vehicle.name}'),
                  onTap: () => _showVehicleActions(vehicle),
                  child: Container(
                    padding: context.getAdaptivePadding(
                      mobileAll: 8,
                      tabletAll: 10,
                      desktopAll: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        context.getAdaptiveBorderRadius(
                          mobile: 8,
                          tablet: 10,
                          desktop: 12,
                        ),
                      ),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.more_vert,
                      size: context.getAdaptiveIconSize(
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final currentIndex = _tabController.index;
    final familyId = ref.watch(familyComposedProvider).family?.id;

    // Check permissions at build time for FAB visibility
    final isAdmin = ref.watch(
      canPerformMemberActionsComposedProvider(familyId ?? ''),
    );

    // Hide FAB if user doesn't have permissions
    if (!isAdmin) {
      return const SizedBox.shrink();
    }

    String semanticLabel;
    IconData icon;
    VoidCallback onPressed;

    switch (currentIndex) {
      case 0:
        semanticLabel = l10n.inviteFamilyMembers;
        icon = Icons.person_add;
        onPressed = () {
          AppLogger.debug(
            'FAB clicked for tab 0 - navigating to invite member',
          );
          ref
              .read(nav.navigationStateProvider.notifier)
              .navigateTo(
                route: AppRoutes.inviteMember,
                trigger: nav.NavigationTrigger.userNavigation,
              );
        };
        break;
      case 1:
        semanticLabel = l10n.addChild;
        icon = Icons.add_circle;
        onPressed = () {
          AppLogger.debug('FAB clicked for tab 1 - navigating to add child');
          ref
              .read(nav.navigationStateProvider.notifier)
              .navigateTo(
                route: AppRoutes.addChild,
                trigger: nav.NavigationTrigger.userNavigation,
              );
        };
        break;
      case 2:
        semanticLabel = l10n.addVehicle;
        icon = Icons.add_circle;
        onPressed = () {
          AppLogger.debug('FAB clicked for tab 2 - navigating to add vehicle');
          ref
              .read(nav.navigationStateProvider.notifier)
              .navigateTo(
                route: AppRoutes.addVehicle,
                trigger: nav.NavigationTrigger.userNavigation,
              );
        };
        break;
      default:
        return const SizedBox.shrink();
    }

    return FloatingActionButton(
      key: Key('floating_action_button_tab_$currentIndex'),
      onPressed: onPressed,
      tooltip: semanticLabel,
      child: Icon(icon),
    );
  }

  void _showDeleteConfirmation({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          key: const Key('confirm_delete_dialog'),
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              key: const Key('familyManagement_deleteCancel_button'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            ElevatedButton(
              key: const Key('delete_confirm_button'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorThemed(context),
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: Text(AppLocalizations.of(context).delete),
            ),
          ],
        );
      },
    );
  }

  void _showChildDetails(entities.Child child) {
    ref
        .read(nav.navigationStateProvider.notifier)
        .navigateTo(
          route: AppRoutes.childDetails(child.id),
          trigger: nav.NavigationTrigger.userNavigation,
        );
  }

  void _showVehicleDetails(entities.Vehicle vehicle) {
    ref
        .read(nav.navigationStateProvider.notifier)
        .navigateTo(
          route: AppRoutes.vehicleDetails(vehicle.id),
          trigger: nav.NavigationTrigger.userNavigation,
        );
  }

  void _showChildActions(entities.Child child) {
    final l10n = AppLocalizations.of(context);

    // Check admin permissions for child management
    final familyId = ref.read(familyComposedProvider).family?.id;
    final isAdmin =
        familyId != null &&
        ref.read(canPerformMemberActionsComposedProvider(familyId));

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: context.getAdaptivePadding(
                mobileAll: 16,
                tabletAll: 20,
                desktopAll: 24,
              ),
              child: Text(
                '${l10n.moreActionsFor} ${child.name}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            // ADMIN ONLY: Edit action
            if (isAdmin)
              ListTile(
                key: const Key('child_edit_action'),
                leading: const Icon(Icons.edit),
                title: Text(l10n.edit),
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(nav.navigationStateProvider.notifier)
                      .navigateTo(
                        route: AppRoutes.editChild(child.id),
                        trigger: nav.NavigationTrigger.userNavigation,
                      );
                },
              ),
            // ALL USERS: View Details action
            ListTile(
              key: const Key('child_view_details_action'),
              leading: const Icon(Icons.info),
              title: Text(l10n.viewDetails),
              onTap: () {
                Navigator.pop(context);
                _showChildDetails(child);
              },
            ),
            // ADMIN ONLY: Delete action
            if (isAdmin)
              ListTile(
                key: const Key('child_delete_action'),
                leading: Icon(
                  Icons.delete,
                  color: AppColors.errorThemed(context),
                ),
                title: Text(
                  l10n.delete,
                  style: TextStyle(color: AppColors.errorThemed(context)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(
                    title: l10n.delete,
                    content: '${l10n.confirmDelete} ${child.name}?',
                    onConfirm: () {
                      ref
                          .read(familyComposedProvider.notifier)
                          .removeChild(child.id);
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _showMemberDetails(entities.FamilyMember member) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            context.getAdaptiveBorderRadius(
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
          ),
        ),
      ),
      builder: (context) {
        return Container(
          padding: context.getAdaptivePadding(
            mobileAll: 24,
            tabletAll: 30,
            desktopAll: 36,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: context.getAdaptiveSpacing(
                      mobile: 32,
                      tablet: 36,
                      desktop: 40,
                    ),
                    backgroundColor: member.role == entities.FamilyRole.admin
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.secondaryContainer,
                    child: member.role == entities.FamilyRole.admin
                        ? Icon(
                            Icons.admin_panel_settings,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: context.getAdaptiveIconSize(
                              mobile: 24,
                              tablet: 28,
                              desktop: 32,
                            ),
                          )
                        : Text(
                            member.displayNameOrLoading.isNotEmpty
                                ? member.displayNameOrLoading[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 20 * context.fontScale,
                            ),
                          ),
                  ),
                  SizedBox(
                    width: context.getAdaptiveSpacing(
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.displayNameOrLoading,
                          style: theme.textTheme.headlineSmall,
                        ),
                        Text(
                          member.role.value,
                          key: Key('user_role_${member.role.value}_display'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Member information
              if (member.userEmail != null) ...[
                _buildDetailRow(
                  icon: Icons.email,
                  label: 'Email',
                  value: member.userEmail!,
                  theme: theme,
                ),
                const SizedBox(height: 16),
              ],

              _buildDetailRow(
                icon: Icons.calendar_today,
                label: 'Joined',
                value: _formatJoinDate(context, member.joinedAt),
                theme: theme,
              ),

              const SizedBox(height: 32),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key(
                    'familyManagement_memberDetails_actions_button',
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showMemberActions(member);
                  },
                  icon: const Icon(Icons.settings),
                  label: Text(AppLocalizations.of(context).memberActions),
                  style: ElevatedButton.styleFrom(
                    padding: context.getAdaptivePadding(
                      mobileVertical: 16,
                      tabletVertical: 20,
                      desktopVertical: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: context.getAdaptiveIconSize(
            mobile: 18,
            tablet: 20,
            desktop: 22,
          ),
          color: theme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(
          width: context.getAdaptiveSpacing(
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ],
    );
  }

  String _formatJoinDate(BuildContext context, DateTime joinedAt) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(joinedAt);
    if (difference.inDays < 1) {
      return l10n.today;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return l10n.weeksAgo(weeks);
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return l10n.monthsAgo(months);
    } else {
      final years = (difference.inDays / 365).floor();
      return l10n.yearsAgo(years);
    }
  }

  void _showMemberActions(entities.FamilyMember member) {
    final currentUser = ref.read(authStateProvider).user;
    final isCurrentUser = currentUser?.id == member.userId;
    final family = ref.read(familyComposedProvider).family;

    // CRITICAL: Last admin protection - cannot change role of last admin
    // This prevents families from being left without any administrator
    final adminCount =
        family?.members
            .where((m) => m.role == entities.FamilyRole.admin)
            .length ??
        0;
    final isLastAdmin =
        member.role == entities.FamilyRole.admin && adminCount == 1;

    // Only admins can manage roles, current user cannot change own role,
    // and last admin cannot have role changed (family must have at least 1 admin)
    final permissionProvider = ref.read(familyPermissionComposedProvider);
    final canManageRoles =
        permissionProvider.canManageMembers && !isCurrentUser && !isLastAdmin;

    debugPrint(
      '🔍 _showMemberActions: ${member.displayNameOrLoading} (${member.role.value})',
    );
    debugPrint(
      '   currentUser=${currentUser?.id}, isCurrentUser=$isCurrentUser',
    );
    debugPrint(
      '   permissionProvider.canManageMembers=${permissionProvider.canManageMembers}',
    );
    debugPrint('   adminCount=$adminCount, isLastAdmin=$isLastAdmin');
    debugPrint(
      '   canManageRoles=$canManageRoles (last admin protection applied)',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            context.getAdaptiveBorderRadius(
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
          ),
        ),
      ),
      builder: (context) => MemberActionBottomSheet(
        member: member,
        canManageRoles: canManageRoles,
        onViewDetails: () => _showMemberDetails(member),
        onChangeRole: canManageRoles
            ? () => _showRoleChangeConfirmation(member)
            : null,
        onRemoveMember: !isCurrentUser
            ? () => _showRemoveMemberConfirmation(member)
            : null,
        onLeaveFamily: isCurrentUser
            ? () => _showLeaveFamilyConfirmation(member)
            : null,
      ),
    );
  }

  void _showRoleChangeConfirmation(entities.FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => RoleChangeConfirmationDialog(
        member: member,
        onSuccess: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  ).roleUpdatedSuccessfully(member.displayNameOrLoading),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        },
      ),
    );
  }

  void _showLeaveFamilyConfirmation(entities.FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => LeaveFamilyConfirmationDialog(
        member: member,
        onSuccess: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).youHaveLeftFamily),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        },
      ),
    );
  }

  void _showRemoveMemberConfirmation(entities.FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => RemoveMemberConfirmationDialog(
        member: member,
        onSuccess: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  ).memberRemovedFromFamily(member.displayNameOrLoading),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        },
      ),
    );
  }

  void _showVehicleActions(entities.Vehicle vehicle) {
    final l10n = AppLocalizations.of(context);

    // Check admin permissions for vehicle management
    final familyId = ref.read(familyComposedProvider).family?.id;
    final isAdmin =
        familyId != null &&
        ref.read(canPerformMemberActionsComposedProvider(familyId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            context.getAdaptiveBorderRadius(
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
          ),
        ),
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
                  width: context.getAdaptiveSpacing(
                    mobile: 32,
                    tablet: 36,
                    desktop: 40,
                  ),
                  height: context.getAdaptiveSpacing(
                    mobile: 4,
                    tablet: 5,
                    desktop: 6,
                  ),
                  margin: EdgeInsets.only(
                    top: context.getAdaptiveSpacing(
                      mobile: 12,
                      tablet: 16,
                      desktop: 20,
                    ),
                    bottom: context.getAdaptiveSpacing(
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(
                      context.getAdaptiveBorderRadius(
                        mobile: 2,
                        tablet: 3,
                        desktop: 4,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.getAdaptiveSpacing(
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                    context.getAdaptiveSpacing(
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                    context.getAdaptiveSpacing(
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                    context.getAdaptiveSpacing(
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                  ),
                  child: Text(
                    '${l10n.moreActionsFor} ${vehicle.name}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                // ADMIN ONLY: Edit action
                if (isAdmin)
                  ListTile(
                    key: const Key('vehicle_edit_action'),
                    leading: const Icon(Icons.edit),
                    title: Text(l10n.edit),
                    onTap: () {
                      Navigator.pop(context);
                      ref
                          .read(nav.navigationStateProvider.notifier)
                          .navigateTo(
                            route: '/family/vehicles/${vehicle.id}/edit',
                            trigger: nav.NavigationTrigger.userNavigation,
                          );
                    },
                  ),
                // ALL USERS: View Details action
                ListTile(
                  key: const Key('vehicle_view_details_action'),
                  leading: const Icon(Icons.info),
                  title: Text(l10n.viewDetails),
                  onTap: () {
                    Navigator.pop(context);
                    _showVehicleDetails(vehicle);
                  },
                ),
                // REMOVED: Seat Override - belongs to schedule/time slot, not vehicle management
                // ADMIN ONLY: Delete action
                if (isAdmin)
                  ListTile(
                    key: const Key('vehicle_delete_action'),
                    leading: Icon(
                      Icons.delete,
                      color: AppColors.errorThemed(context),
                    ),
                    title: Text(
                      l10n.delete,
                      style: TextStyle(color: AppColors.errorThemed(context)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(
                        title: l10n.delete,
                        content: '${l10n.confirmDelete} ${vehicle.name}?',
                        onConfirm: () {
                          ref
                              .read(familyComposedProvider.notifier)
                              .deleteVehicle(vehicle.id);
                        },
                      );
                    },
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

  // REMOVED: _showSeatOverrideDialog - Seat Override belongs to schedule/time slot (VehicleAssignment), not vehicle management
  // Seat override is used in SchedulePage to temporarily adjust capacity for a specific session (broken seat, added equipment, etc.)
}
