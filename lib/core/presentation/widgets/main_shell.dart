import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../../router/app_router.dart';
import '../utils/responsive_breakpoints.dart';
import '../../navigation/navigation_state.dart';

class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use responsive breakpoints to determine layout
    if (context.isDesktop) {
      // Desktop: NavigationRail for better use of horizontal space
      return Scaffold(
        body: Row(
          children: [
            AppNavigationRail(navigationShell: navigationShell, ref: ref),
            Expanded(child: navigationShell),
          ],
        ),
      );
    } else if (context.isTablet) {
      // Tablet: Extended bottom navigation with better spacing
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: ExtendedAppBottomNavigation(
          navigationShell: navigationShell,
        ),
      );
    } else {
      // Mobile: Standard bottom navigation
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: const AppBottomNavigation(),
      );
    }
  }
}

/// Desktop navigation rail with responsive design
class AppNavigationRail extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final WidgetRef ref;

  const AppNavigationRail({
    super.key,
    required this.navigationShell,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isWideDesktop = context.isWideDesktop;
    final destinations = _getNavigationDestinations(context, isRail: true);

    // Ensure selectedIndex is valid (in range of destinations)
    // If we're on a page like Profile that's not in the rail, set to null
    final currentIndex = navigationShell.currentIndex;
    final selectedIndex =
        (currentIndex >= 0 && currentIndex < destinations.length)
            ? currentIndex
            : null;

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(index),
      extended: isWideDesktop,
      minExtendedWidth: 200,
      labelType: isWideDesktop
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 1,
      destinations: destinations,
      trailing: isWideDesktop ? _buildTrailingActions(context) : null,
    );
  }

  Widget _buildTrailingActions(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                // Settings/Profile button
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    ref.read(navigationStateProvider.notifier).navigateTo(
                          route: '/profile',
                          trigger: NavigationTrigger.userNavigation,
                        );
                  },
                  tooltip: AppLocalizations.of(context).profile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<NavigationRailDestination> _getNavigationDestinations(
    BuildContext context, {
    required bool isRail,
  }) {
    return [
      NavigationRailDestination(
        icon: Icon(
          Icons.dashboard_outlined,
          size: context.getAdaptiveIconSize(desktop: 24, tablet: 22),
        ),
        selectedIcon: Icon(
          Icons.dashboard,
          size: context.getAdaptiveIconSize(desktop: 24, tablet: 22),
        ),
        label: Text(AppLocalizations.of(context).dashboard),
      ),
      NavigationRailDestination(
        icon: Icon(
          Icons.family_restroom_outlined,
          size: context.getAdaptiveIconSize(desktop: 24, tablet: 22),
        ),
        selectedIcon: Icon(
          Icons.family_restroom,
          size: context.getAdaptiveIconSize(desktop: 24, tablet: 22),
        ),
        label: Text(AppLocalizations.of(context).family),
      ),
      NavigationRailDestination(
        icon: Icon(
          Icons.groups_outlined,
          size: context.getAdaptiveIconSize(desktop: 24, tablet: 22),
        ),
        selectedIcon: Icon(
          Icons.groups,
          size: context.getAdaptiveIconSize(desktop: 24, tablet: 22),
        ),
        label: Text(AppLocalizations.of(context).groupsLabel),
      ),
      NavigationRailDestination(
        icon: Icon(
          Icons.schedule_outlined,
          size: context.getAdaptiveIconSize(desktop: 24, tablet: 22),
        ),
        selectedIcon: Icon(
          Icons.schedule,
          size: context.getAdaptiveIconSize(desktop: 24, tablet: 22),
        ),
        label: Text(AppLocalizations.of(context).scheduleLabel),
      ),
    ];
  }
}

/// Extended bottom navigation for tablet with enhanced spacing and sizing
class ExtendedAppBottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ExtendedAppBottomNavigation({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final adaptiveHeight = context.getAdaptiveButtonHeight(
      tablet: 72,
      desktop: 80,
    );

    return Container(
      height: adaptiveHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildTabletNavigationItems(context),
        ),
      ),
    );
  }

  List<Widget> _buildTabletNavigationItems(BuildContext context) {
    final items = [
      _TabletNavItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: AppLocalizations.of(context).dashboard,
        isSelected: navigationShell.currentIndex == 0,
        onTap: () => navigationShell.goBranch(0),
      ),
      _TabletNavItem(
        icon: Icons.family_restroom_outlined,
        selectedIcon: Icons.family_restroom,
        label: AppLocalizations.of(context).family,
        isSelected: navigationShell.currentIndex == 1,
        onTap: () => navigationShell.goBranch(1),
      ),
      _TabletNavItem(
        icon: Icons.groups_outlined,
        selectedIcon: Icons.groups,
        label: AppLocalizations.of(context).groupsLabel,
        isSelected: navigationShell.currentIndex == 2,
        onTap: () => navigationShell.goBranch(2),
      ),
      _TabletNavItem(
        icon: Icons.schedule_outlined,
        selectedIcon: Icons.schedule,
        label: AppLocalizations.of(context).scheduleLabel,
        isSelected: navigationShell.currentIndex == 3,
        onTap: () => navigationShell.goBranch(3),
      ),
    ];

    return items;
  }
}

/// Individual tablet navigation item with enhanced touch targets
class _TabletNavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabletNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: context.getAdaptivePadding(
              mobileVertical: 8,
              tabletVertical: 12,
              desktopVertical: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: context.getAdaptiveIconSize(
                    mobile: 24,
                    tablet: 26,
                    desktop: 28,
                  ),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 12 * context.fontScale,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
