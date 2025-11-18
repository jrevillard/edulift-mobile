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
    // Système de navigation unifié : Desktop vs Mobile/Tablette
    if (context.isDesktopOrLarger) {
      // Desktop: NavigationRail avec bouton profile intégré
      return Scaffold(
        body: Row(
          children: [
            AppNavigationRail(navigationShell: navigationShell, ref: ref),
            Expanded(child: navigationShell),
          ],
        ),
      );
    } else {
      // Mobile/Tablette: AppBottomNavigation unifié avec 5 onglets (profile inclus)
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
    final isTabletOrLarger = context.isTabletOrLarger;
    final destinations = _getNavigationDestinations(context, isRail: true);

    // Ensure selectedIndex is valid (in range of destinations)
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
      trailing: isTabletOrLarger ? _buildTrailingActions(context) : null,
    );
  }

  Widget _buildTrailingActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          // Profile button - accessible en bas sur desktop/tablette
          IconButton(
            icon: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              ref
                  .read(navigationStateProvider.notifier)
                  .navigateTo(
                    route: '/profile',
                    trigger: NavigationTrigger.userNavigation,
                  );
            },
            tooltip: AppLocalizations.of(context).profile,
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
        label: Text(AppLocalizations.of(context).navigationDashboard),
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
        label: Text(AppLocalizations.of(context).navigationFamily),
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
        label: Text(AppLocalizations.of(context).navigationGroups),
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
        label: Text(AppLocalizations.of(context).navigationSchedule),
      ),
    ];
  }
}
