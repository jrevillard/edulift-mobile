import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/presentation/widgets/connection/unified_connection_indicator.dart';
import 'package:edulift/features/family/providers.dart';
import '../../../../core/domain/entities/user.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../../../core/utils/timezone_formatter.dart';
import '../../../../core/utils/weekday_localization.dart';
import '../providers/transport_providers.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/seven_day_timeline_widget.dart';
import 'package:edulift/core/navigation/navigation_state.dart';
import 'package:edulift/core/presentation/mixins/navigation_cleanup_mixin.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with NavigationCleanupMixin {
  // NavigationCleanupMixin automatically clears navigation in init state

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(day7TransportSummaryProvider);
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logos/edulift_logo_64.png',
                        width: context.getAdaptiveIconSize(
                          mobile: 28,
                          tablet: 32,
                          desktop: 36,
                        ),
                        height: context.getAdaptiveIconSize(
                          mobile: 28,
                          tablet: 32,
                          desktop: 36,
                        ),
                      ),
                      SizedBox(
                        width: context.getAdaptiveSpacing(
                          mobile: 6,
                          tablet: 8,
                          desktop: 10,
                        ),
                      ),
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            AppLocalizations.of(context).dashboard,
                            key: const Key('dashboard_title'),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsets.only(
                        right: context.getAdaptiveSpacing(mobile: 6, tablet: 8),
                      ),
                      child: const UnifiedConnectionIndicator(
                        key: Key('dashboard_connection_status'),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Logout',
                      child: IconButton(
                        key: const Key('dashboard_logout_button'),
                        icon: Icon(
                          Icons.logout,
                          size: context.getAdaptiveIconSize(
                            mobile: 20,
                            tablet: 24,
                          ),
                        ),
                        onPressed: () async {
                          await ref.read(authStateProvider.notifier).logout();
                          ref
                              .read(navigationStateProvider.notifier)
                              .navigateTo(
                                route: '/auth/login',
                                trigger: NavigationTrigger.userNavigation,
                              );
                        },
                        tooltip: AppLocalizations.of(context).logout,
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    child: Padding(
                      padding: context.getAdaptivePadding(
                        mobileAll: 12,
                        tabletAll: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Combined Welcome & Family Section (Space-optimized for all screen sizes)
                          _buildWelcomeAndFamilySection(context, user, ref),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 12,
                              tablet: 16,
                            ),
                          ),

                          // Main Content
                          if (isDesktop)
                            _buildDesktopLayout(context, ref)
                          else if (isTablet)
                            _buildTabletLayout(context, ref)
                          else
                            _buildPhoneLayout(context, ref),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      key: const Key('tablet_layout'),
      constraints: BoxConstraints(
        maxHeight: context.getAdaptiveMaxHeight(
          mobile: 0.8,
          tablet: 0.7,
          desktop: 0.6,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SevenDayTimelineWidget(),
                  SizedBox(
                    height: context.getAdaptiveSpacing(mobile: 12, tablet: 16),
                  ),
                  _buildCompactQuickActions(context, ref),
                  SizedBox(
                    height: context.getAdaptiveSpacing(mobile: 8, tablet: 12),
                  ),
                  _buildRecentActivities(context, ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      key: const Key('desktop_layout'),
      constraints: BoxConstraints(
        maxHeight: context.getAdaptiveMaxHeight(
          mobile: 0.8,
          tablet: 0.7,
          desktop: 0.6,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content area - takes 2/3 of the space
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SevenDayTimelineWidget(),
                  SizedBox(
                    height: context.getAdaptiveSpacing(
                      mobile: 12,
                      tablet: 16,
                      desktop: 20,
                    ),
                  ),
                  _buildCompactQuickActions(context, ref),
                ],
              ),
            ),
          ),
          SizedBox(
            width: context.getAdaptiveSpacing(
              mobile: 12,
              tablet: 16,
              desktop: 24,
            ),
          ),
          // Side content area - takes 1/3 of the space
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [_buildRecentActivities(context, ref)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      key: const Key('phone_layout'),
      constraints: BoxConstraints(
        maxHeight: context.getAdaptiveMaxHeight(
          mobile: 0.8,
          tablet: 0.7,
          desktop: 0.6,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SevenDayTimelineWidget(),
            SizedBox(
              height: context.getAdaptiveSpacing(mobile: 10, tablet: 12),
            ),
            _buildCompactQuickActions(context, ref),
            SizedBox(height: context.getAdaptiveSpacing(mobile: 6, tablet: 8)),
            _buildRecentActivities(context, ref),
            SizedBox(
              height: context.getAdaptiveSpacing(mobile: 12, tablet: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactQuickActions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.watch(dashboardCallbacksProvider);

    if (actions == null) return const SizedBox.shrink();

    return Card(
      key: const Key('compact_quick_actions_section'),
      child: Padding(
        padding: context.getAdaptivePadding(
          mobileHorizontal: 12,
          mobileVertical: 10,
          tabletHorizontal: 16,
          tabletVertical: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CompactActionButton(
              key: const Key('compact_action_add_child'),
              icon: Icons.person_add,
              onPressed: actions.onAddChild,
              tooltip: l10n.addChildAction,
            ),
            _CompactActionButton(
              key: const Key('compact_action_join_group'),
              icon: Icons.groups,
              onPressed: actions.onJoinGroup,
              tooltip: l10n.joinGroupAction,
            ),
            _CompactActionButton(
              key: const Key('compact_action_add_vehicle'),
              icon: Icons.directions_car,
              onPressed: actions.onAddVehicle,
              tooltip: l10n.addVehicleAction,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(recentActivitiesProvider);
    final l10n = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
      child: Semantics(
        label: l10n.recentActivitiesSection,
        child: Card(
          key: const Key('recent_activities_section'),
          elevation: 4,
          child: Padding(
            padding: context.getAdaptivePadding(mobileAll: 12, tabletAll: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Semantics(
                      label: l10n.recentActivity,
                      child: Icon(
                        Icons.history,
                        color: Theme.of(context).colorScheme.primary,
                        size: context.getAdaptiveIconSize(
                          mobile: 20,
                          tablet: 24,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: context.getAdaptiveSpacing(mobile: 6, tablet: 8),
                    ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          l10n.recentActivity,
                          key: const Key('recent_activity_title'),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: context.getAdaptiveSpacing(mobile: 12, tablet: 16),
                ),
                if (activities.isEmpty)
                  Center(
                    key: const Key('no_activities_empty_state'),
                    child: Padding(
                      padding: context.getAdaptivePadding(
                        mobileAll: 16,
                        tabletAll: 20,
                        desktopAll: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Semantics(
                            label: l10n.noRecentActivityIcon,
                            child: Icon(
                              Icons.directions_run,
                              size: context.getAdaptiveIconSize(
                                mobile: 36,
                                tablet: 48,
                                desktop: 56,
                              ),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 12,
                              tablet: 16,
                            ),
                          ),
                          Text(
                            l10n.noRecentActivity,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 6,
                              tablet: 8,
                            ),
                          ),
                          Text(
                            l10n.noRecentActivityMessage,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: activities
                        .take(3)
                        .map(
                          (activity) => _ActivityItem(
                            icon: _getIconFromName(activity.iconName),
                            title: activity.title,
                            subtitle: activity.subtitle,
                            color: _getActivityColor(activity.type),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeAndFamilySection(
    BuildContext context,
    User? user,
    WidgetRef ref,
  ) {
    final familyAsync = ref.watch(currentFamilyComposedProvider);
    final isDesktop = context.isDesktop;
    final userName = user?.name.split(' ').first ?? 'User';
    final userInitials = user?.initials ?? 'U';
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.welcomeSection,
      child: Card(
        key: const Key('welcome_family_section'),
        elevation: 4,
        child: Padding(
          padding: context.getAdaptivePadding(mobileAll: 12, tabletAll: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Welcome Row
              Row(
                children: [
                  Semantics(
                    label: l10n.userAvatarFor(userName),
                    child: CircleAvatar(
                      key: const Key('user_avatar'),
                      radius:
                          context.getAdaptiveIconSize(
                            mobile:
                                28, // 56px diamètre - confortable pour mobile
                            tablet:
                                32, // 64px diamètre - bonne proportion tablette
                            desktop: 36, // 72px diamètre - équilibré desktop
                          ) /
                          2,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: FittedBox(
                        child: Text(
                          userInitials,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: context.getAdaptiveIconSize(
                                  mobile: 14, // Taille adaptée au cercle mobile
                                  tablet:
                                      16, // Taille adaptée au cercle tablette
                                  desktop:
                                      18, // Taille adaptée au cercle desktop
                                ),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: context.getAdaptiveSpacing(mobile: 10, tablet: 12),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.welcomeBackUser(userName),
                            key: const Key('dashboard_welcome_back_message'),
                            style: isDesktop
                                ? Theme.of(context).textTheme.titleLarge
                                : Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Semantics(
                          label: l10n.currentDateAndDashboardDesc,
                          child: Text(
                            l10n.yourTransportDashboard(_formatCurrentDate()),
                            key: const Key('current_date'),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: context.getAdaptiveSpacing(mobile: 12, tablet: 16),
              ),

              // Family Overview
              familyAsync.when(
                data: (family) {
                  if (family == null) return const SizedBox.shrink();

                  return Container(
                    padding: context.getAdaptivePadding(
                      mobileHorizontal: 12,
                      mobileVertical: 8,
                      tabletHorizontal: 14,
                      tabletVertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.family_restroom,
                          color: Theme.of(context).colorScheme.primary,
                          size: context.getAdaptiveIconSize(
                            mobile: 14,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                        SizedBox(
                          width: context.getAdaptiveSpacing(
                            mobile: 10,
                            tablet: 12,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${family.name} • ${l10n.childrenCount(family.totalChildren)} • ${l10n.vehiclesCount(family.totalVehicles)}',
                            key: const Key('family_summary'),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => SizedBox(
                  height: context.getAdaptiveIconSize(
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  ),
                  child: const LinearProgressIndicator(),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrentDate() {
    final l10n = AppLocalizations.of(context);
    final weekdayLabels = getLocalizedWeekdayLabels(l10n);
    final weekdayName = weekdayLabels[DateTime.now().weekday - 1];

    // Use TimezoneFormatter for date (no timezone needed for current date)
    final formattedDate = TimezoneFormatter.formatDateOnly(
      DateTime.now().toUtc(),
      null,
    );

    // Replace English weekday with localized weekday
    final parts = formattedDate.split(' ');
    if (parts.length >= 2) {
      return '$weekdayName ${parts[1]} ${parts[2]}';
    }

    return formattedDate;
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.childAdded:
        return Theme.of(context).colorScheme.primary;
      case ActivityType.groupJoined:
        return Theme.of(context).colorScheme.secondary;
      case ActivityType.vehicleAdded:
        return Theme.of(context).colorScheme.tertiary;
      case ActivityType.scheduleCreated:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add;
      case 'groups':
        return Icons.groups;
      case 'directions_car':
        return Icons.directions_car;
      case 'schedule':
        return Icons.schedule;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'directions_run':
        return Icons.directions_run;
      default:
        return Icons.info;
    }
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Activity: $title - $subtitle',
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: context.getAdaptiveSpacing(mobile: 3, tablet: 4),
        ),
        child: Row(
          children: [
            SizedBox(
              width: context.getAdaptiveIconSize(
                mobile: 32,
                tablet: 36,
                desktop: 40,
              ),
              height: context.getAdaptiveIconSize(
                mobile: 32,
                tablet: 36,
                desktop: 40,
              ),
              child: Container(
                padding: EdgeInsets.all(
                  context.getAdaptiveSpacing(mobile: 6, tablet: 8),
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: context.getAdaptiveIconSize(
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  ),
                ),
              ),
            ),
            SizedBox(width: context.getAdaptiveSpacing(mobile: 10, tablet: 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Semantics(
        button: true,
        label: tooltip ?? '',
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(
              context.getAdaptiveSpacing(mobile: 6, tablet: 8),
            ),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: context.getAdaptiveIconSize(
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
