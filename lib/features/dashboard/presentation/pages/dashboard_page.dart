import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/presentation/widgets/connection/unified_connection_indicator.dart';
import 'package:edulift/features/family/providers.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../../../../core/domain/entities/user.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../providers/dashboard_providers.dart';
import 'package:edulift/core/navigation/navigation_state.dart';
import 'package:edulift/core/presentation/mixins/navigation_cleanup_mixin.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with NavigationCleanupMixin {
  // NavigationCleanupMixin automatically clears navigation in initState

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () async {
              final refreshCallback = ref.read(dashboardRefreshProvider);
              if (refreshCallback != null) {
                refreshCallback();
              }
            },
            child: CustomScrollView(
              slivers: [
                // Real-time invitation summary widget
                const SliverToBoxAdapter(child: SizedBox.shrink()),
                // Real-time schedule summary widget
                const SliverToBoxAdapter(child: SizedBox.shrink()),
                SliverAppBar(
                  expandedHeight: isTablet ? 120 : 80,
                  floating: true,
                  pinned: true,
                  title: Semantics(
                    header: true,
                    child: Text(
                      AppLocalizations.of(context).dashboard,
                      key: const Key('dashboard_title'),
                    ),
                  ),
                  actions: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: UnifiedConnectionIndicator(
                        key: Key('dashboard_connection_status'),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Logout',
                      child: IconButton(
                        key: const Key('dashboard_logout_button'),
                        icon: const Icon(Icons.logout),
                        onPressed: () async {
                          await ref.read(authStateProvider.notifier).logout();
                          ref.read(navigationStateProvider.notifier).navigateTo(
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
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Welcome Section
                        _buildWelcomeSection(context, user),
                        const SizedBox(height: 24),

                        // Main Content
                        if (isTablet)
                          _buildTabletLayout(context, ref)
                        else
                          _buildPhoneLayout(context, ref),
                      ],
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

  Widget _buildWelcomeSection(BuildContext context, User? user) {
    final userName = user?.name.split(' ').first ?? 'User';
    final userInitials = user?.initials ?? 'U';

    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.welcomeSection,
      child: Card(
        key: const Key('dashboard_welcome_section'),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Semantics(
                label: l10n.userAvatarFor(userName),
                child: CircleAvatar(
                  key: const Key('user_avatar'),
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    userInitials,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Semantics(
                      label: l10n.currentDateAndDashboardDesc,
                      child: Text(
                        l10n.yourTransportDashboard(_formatCurrentDate()),
                        key: const Key('current_date'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          key: const Key('tablet_layout'),
          width: constraints.maxWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFamilyOverview(context, ref),
                    const SizedBox(height: 16),
                    _buildQuickActions(context, ref),
                    const SizedBox(height: 16),
                    _buildRecentActivities(context, ref),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildUpcomingTrips(context, ref)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhoneLayout(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          key: const Key('phone_layout'),
          width: constraints.maxWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFamilyOverview(context, ref),
              const SizedBox(height: 12),
              _buildQuickActions(context, ref),
              const SizedBox(height: 12),
              _buildRecentActivities(context, ref),
              const SizedBox(height: 12),
              _buildUpcomingTrips(context, ref),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFamilyOverview(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(currentFamilyComposedProvider);
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.familyOverviewSection,
      child: familyAsync.when(
        data: (family) {
          if (family == null) {
            return Card(
              key: const Key('no_family_empty_state'),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: l10n.welcomeIcon,
                      child: Icon(
                        Icons.family_restroom,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      header: true,
                      child: Text(
                        'Welcome to EduLift!',
                        key: const Key('dashboard_welcome_new_user_message'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start by creating or joining a family',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Card(
            key: const Key('family_overview_card'),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Semantics(
                        label: l10n.familyIcon,
                        child: Icon(
                          Icons.family_restroom,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            family.name,
                            key: Key('family_name_display_${family.name}'),
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    label: l10n.familyStatistics(
                      family.totalMembers,
                      family.totalChildren,
                      family.totalVehicles,
                    ),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          ).totalMembersCount(family.totalMembers),
                        ),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).totalChildrenCount(family.totalChildren),
                        ),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).totalVehiclesCount(family.totalVehicles),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => Semantics(
          label: l10n.loadingFamilyInformation,
          child: Card(
            key: const Key('family_loading_state'),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading family information...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        error: (error, stackTrace) => Semantics(
          label: l10n.errorLoadingFamilyInformation,
          child: Card(
            key: const Key('family_error_state'),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: 'Error icon',
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading family',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.watch(dashboardCallbacksProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isShortScreen = screenHeight < 700;

    return Semantics(
      label: l10n.quickActionsSection,
      child: Card(
        key: const Key('quick_actions_section'),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(isShortScreen ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(height: isShortScreen ? 8 : 16),
              if (isSmallScreen || isShortScreen)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _QuickActionButton(
                      key: const Key('quick_action_add_child'),
                      icon: Icons.person_add,
                      title: l10n.addChildAction,
                      description: l10n.registerForTransport,
                      onPressed: actions?.onAddChild ?? () {},
                      isCompact: true,
                    ),
                    _QuickActionButton(
                      key: const Key('quick_action_join_group'),
                      icon: Icons.groups,
                      title: l10n.joinGroupAction,
                      description: l10n.connectWithOtherFamilies,
                      onPressed: actions?.onJoinGroup ?? () {},
                      isCompact: true,
                    ),
                    _QuickActionButton(
                      key: const Key('quick_action_add_vehicle'),
                      icon: Icons.directions_car,
                      title: l10n.addVehicleAction,
                      description: l10n.offerRidesToOthers,
                      onPressed: actions?.onAddVehicle ?? () {},
                      isCompact: true,
                    ),
                  ],
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuickActionButton(
                      key: const Key('quick_action_add_child'),
                      icon: Icons.person_add,
                      title: l10n.addChildAction,
                      description: l10n.registerForTransport,
                      onPressed: actions?.onAddChild ?? () {},
                    ),
                    const SizedBox(height: 8),
                    _QuickActionButton(
                      key: const Key('quick_action_join_group'),
                      icon: Icons.groups,
                      title: l10n.joinGroupAction,
                      description: l10n.connectWithOtherFamilies,
                      onPressed: actions?.onJoinGroup ?? () {},
                    ),
                    const SizedBox(height: 8),
                    _QuickActionButton(
                      key: const Key('quick_action_add_vehicle'),
                      icon: Icons.directions_car,
                      title: l10n.addVehicleAction,
                      description: l10n.offerRidesToOthers,
                      onPressed: actions?.onAddVehicle ?? () {},
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(recentActivitiesProvider);
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.recentActivitiesSection,
      child: Card(
        key: const Key('recent_activities_section'),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              if (activities.isEmpty)
                SizedBox(
                  key: const Key('no_activities_empty_state'),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          label: l10n.noRecentActivityIcon,
                          child: Icon(
                            Icons.directions_run,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recent activity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your activity will appear here',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: Column(
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
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTrips(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(upcomingTripsProvider);
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.upcomingTripsSection,
      child: Card(
        key: const Key('upcoming_trips_section'),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'This Week\'s Trips',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              if (trips.isEmpty)
                Container(
                  key: const Key('no_trips_empty_state'),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        label: l10n.noTripsScheduledIcon,
                        child: Icon(
                          Icons.schedule,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No trips this week',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your schedule is clear',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: trips
                        .take(3)
                        .map(
                          (trip) => _TripItem(
                            time: trip.time,
                            destination: trip.destination,
                            type: trip.type,
                            date: trip.date,
                            children: trip.children,
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.childAdded:
        return Colors.blue;
      case ActivityType.groupJoined:
        return Colors.green;
      case ActivityType.vehicleAdded:
        return Colors.orange;
      case ActivityType.scheduleCreated:
        return Colors.purple;
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

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;
  final bool isCompact;

  const _QuickActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title: $description',
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 44.0,
          maxHeight: isCompact ? 60.0 : double.infinity,
          minWidth: isCompact ? 100.0 : double.infinity,
          maxWidth: isCompact ? 160.0 : double.infinity,
        ),
        child: Card(
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
              child: isCompact
                  ? _buildCompactLayout(context)
                  : _buildFullLayout(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFullLayout(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ],
    );
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
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ),
            const SizedBox(width: 12),
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

class _TripItem extends StatelessWidget {
  final String time;
  final String destination;
  final TripType type;
  final String date;
  final List<Child> children;

  const _TripItem({
    required this.time,
    required this.destination,
    required this.type,
    required this.date,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final childrenNames = children.map((child) => child.name).join(', ');
    final tripTypeLabel = type == TripType.dropOff ? 'Drop off' : 'Pick up';

    return Semantics(
      label:
          'Trip: $tripTypeLabel at $time to $destination on $date ${children.isNotEmpty ? 'with $childrenNames' : ''}',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: type == TripType.dropOff
                          ? Colors.orange.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Semantics(
                      label: 'Trip time: $time',
                      child: Text(
                        time,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: type == TripType.dropOff
                                  ? Colors.orange
                                  : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Semantics(
                      label: 'Destination: $destination',
                      child: Text(
                        destination,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Semantics(
                    label: '$tripTypeLabel icon',
                    child: Icon(
                      type == TripType.dropOff
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '$tripTypeLabel • $date',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (children.isNotEmpty) ...[
                const SizedBox(height: 8),
                Semantics(
                  label: 'Children: $childrenNames',
                  child: Text(
                    childrenNames,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
