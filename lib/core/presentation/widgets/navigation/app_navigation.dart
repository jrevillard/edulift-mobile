import 'package:flutter/material.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../accessibility/accessible_button.dart';

/// Main navigation component with Material 3 design and accessibility
class AppNavigation extends StatefulWidget {
  const AppNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.isExtended = false,
    this.destinations = const [],
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isExtended;
  final List<NavigationDestination> destinations;

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    // Use navigation rail for larger screens
    if (mediaQuery.size.width >= 640) {
      return _buildNavigationRail(theme);
    }

    // Use navigation bar for mobile
    return _buildNavigationBar(theme);
  }

  Widget _buildNavigationBar(ThemeData theme) {
    return FadeTransition(
      opacity: _animation,
      child: NavigationBar(
        selectedIndex: widget.currentIndex,
        onDestinationSelected: _handleDestinationSelected,
        destinations: widget.destinations.isNotEmpty
            ? widget.destinations
            : _getDefaultDestinations(),
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildNavigationRail(ThemeData theme) {
    return FadeTransition(
      opacity: _animation,
      child: NavigationRail(
        selectedIndex: widget.currentIndex,
        onDestinationSelected: _handleDestinationSelected,
        extended: widget.isExtended,
        destinations: _getNavigationRailDestinations(),
        leading: widget.isExtended
            ? null
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AccessibleIconButton(
                  onPressed: () => _showNavigationMenu(context),
                  icon: const Icon(Icons.menu),
                  semanticLabel: 'Open navigation menu',
                ),
              ),
        trailing: widget.isExtended
            ? null
            : Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AccessibleIconButton(
                      onPressed: () => _showUserMenu(context),
                      icon: const Icon(Icons.account_circle),
                      semanticLabel: 'Open user menu',
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  List<NavigationDestination> _getDefaultDestinations() {
    return const [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      NavigationDestination(
        key: Key('navigation_family'),
        icon: Icon(Icons.people_outlined),
        selectedIcon: Icon(Icons.people),
        label: 'Family',
      ),
      NavigationDestination(
        icon: Icon(Icons.schedule_outlined),
        selectedIcon: Icon(Icons.schedule),
        label: 'Schedule',
      ),
      NavigationDestination(
        key: Key('navigation_groups'),
        icon: Icon(Icons.group_outlined),
        selectedIcon: Icon(Icons.group),
        label: 'Groups',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];
  }

  List<NavigationRailDestination> _getNavigationRailDestinations() {
    final destinations = _getDefaultDestinations();
    return destinations
        .map(
          (dest) => NavigationRailDestination(
            icon: dest.icon,
            selectedIcon: dest.selectedIcon,
            label: Text(dest.label),
          ),
        )
        .toList();
  }

  void _handleDestinationSelected(int index) {
    HapticFeedback.selectionClick();
    widget.onDestinationSelected(index);

    // Announce navigation change for accessibility
    final destinations = _getDefaultDestinations();
    if (index < destinations.length) {
      final destination = destinations[index];
      _announceNavigation(destination.label);
    }
  }

  void _announceNavigation(String destination) {
    // Accessibility announcement temporarily disabled due to import issues
    // TODO: Fix SemanticsService import
    // SemanticsService.announce(
    //   'Navigated to $destination',
    //   TextDirection.ltr,
    // );
  }

  void _showNavigationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const NavigationMenuSheet(),
    );
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const UserMenuSheet(),
    );
  }
}

/// Responsive scaffold that adapts navigation based on screen size
class ResponsiveScaffold extends StatefulWidget {
  const ResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.destinations = const [],
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? endDrawer;
  final List<NavigationDestination> destinations;

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  final bool _isRailExtended = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isWideScreen = mediaQuery.size.width >= 1200;
    final isMediumScreen = mediaQuery.size.width >= 640;

    if (isMediumScreen) {
      return Scaffold(
        appBar: widget.appBar,
        drawer: widget.drawer,
        endDrawer: widget.endDrawer,
        floatingActionButton: widget.floatingActionButton,
        body: Row(
          children: [
            AppNavigation(
              currentIndex: widget.currentIndex,
              onDestinationSelected: widget.onDestinationSelected,
              isExtended: isWideScreen || _isRailExtended,
              destinations: widget.destinations,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: widget.appBar,
      drawer: widget.drawer,
      endDrawer: widget.endDrawer,
      body: widget.body,
      bottomNavigationBar: AppNavigation(
        currentIndex: widget.currentIndex,
        onDestinationSelected: widget.onDestinationSelected,
        destinations: widget.destinations,
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

/// Adaptive navigation that works across different screen sizes
class AdaptiveNavigation extends StatelessWidget {
  const AdaptiveNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.showLabels = true,
    this.height,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveNavigationDestination> destinations;
  final bool showLabels;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    // Tablet/desktop layout with navigation rail
    if (mediaQuery.size.width >= 640) {
      return _buildNavigationRail(theme);
    }

    // Mobile layout with bottom navigation
    return _buildBottomNavigation(theme);
  }

  Widget _buildNavigationRail(ThemeData theme) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: _handleDestinationSelected,
      destinations: destinations
          .map(
            (dest) => NavigationRailDestination(
              icon: dest.icon,
              selectedIcon: dest.selectedIcon,
              label: Text(dest.label),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomNavigation(ThemeData theme) {
    return SizedBox(
      height: height ?? kBottomNavigationBarHeight + 16,
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: _handleDestinationSelected,
        destinations: destinations
            .map(
              (dest) => NavigationDestination(
                icon: dest.icon,
                selectedIcon: dest.selectedIcon,
                label: dest.label,
              ),
            )
            .toList(),
        labelBehavior: showLabels
            ? NavigationDestinationLabelBehavior.alwaysShow
            : NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
    );
  }

  void _handleDestinationSelected(int index) {
    HapticFeedback.selectionClick();
    onDestinationSelected(index);

    // Announce navigation change
    if (index < destinations.length) {
      // Accessibility announcement temporarily disabled due to import issues
      // TODO: Fix SemanticsService import
      // SemanticsService.announce(
      //   'Navigated to ${destinations[index].label}',
      //   TextDirection.ltr,
      // );
    }
  }
}

/// Navigation destination that works with adaptive navigation
class AdaptiveNavigationDestination {
  const AdaptiveNavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.tooltip,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final String label;
  final String? tooltip;
}

/// Quick navigation actions for common tasks
class QuickNavigation extends StatelessWidget {
  const QuickNavigation({
    super.key,
    required this.actions,
    this.direction = Axis.horizontal,
    this.spacing = 8.0,
    this.padding = const EdgeInsets.all(16),
  });

  final List<QuickNavigationAction> actions;
  final Axis direction;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildAction(QuickNavigationAction action) {
      return AccessibleButton(
        onPressed: action.onPressed,
        semanticLabel: action.semanticLabel,
        semanticHint: action.semanticHint,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, size: 24),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: theme.textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: padding,
      child: direction == Axis.horizontal
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: actions
                  .map(
                    (action) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                        child: buildAction(action),
                      ),
                    ),
                  )
                  .toList(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: actions
                  .map(
                    (action) => Padding(
                      padding: EdgeInsets.symmetric(vertical: spacing / 2),
                      child: buildAction(action),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class QuickNavigationAction {
  const QuickNavigationAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.semanticLabel,
    this.semanticHint,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final String semanticLabel;
  final String? semanticHint;
}

// Placeholder sheets for navigation menus
class NavigationMenuSheet extends StatelessWidget {
  const NavigationMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Navigation Menu',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).additionalNavigationOptions),
        ],
      ),
    );
  }
}

class UserMenuSheet extends StatelessWidget {
  const UserMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).userMenu,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).userProfileOptions),
        ],
      ),
    );
  }
}
