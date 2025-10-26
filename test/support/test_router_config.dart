// Test Router Configuration for GoRouter Test Environment
// Provides comprehensive router setup for testing widgets that require GoRouter context
// Including shell routes with NavigationBar for AppBottomNavigation tests

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edulift/core/router/app_routes.dart';
import 'package:edulift/features/family/presentation/providers/family_provider.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

/// Creates a test-specific GoRouter for widget testing
class TestRouterConfig {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  // REMOVED: setupUserFamilyServiceMock - UserFamilyServiceInjector doesn't exist
  // TODO: Adapt tests to use familyRepositoryProvider instead

  /// Create a comprehensive GoRouter for testing widgets that require router context
  /// Includes shell routes with NavigationBar for AppBottomNavigation tests
  static GoRouter createTestRouter({
    String initialLocation = '/',
    WidgetRef? ref,
    List<RouteBase>? routes,
    bool includeShell = false,
  }) {
    if (includeShell && routes == null) {
      // Return full router with shell route for navigation tests
      return _createShellTestRouter(initialLocation: initialLocation, ref: ref);
    }

    return GoRouter(
      initialLocation: initialLocation,
      routes: routes ?? _defaultTestRoutes,
      // Simple error handler for tests
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Test Route Error: ${state.matchedLocation}')),
      ),
    );
  }

  /// Create a router with shell navigation for AppBottomNavigation tests
  static GoRouter _createShellTestRouter({
    String initialLocation = '/',
    WidgetRef? ref,
  }) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: initialLocation,
      // Add redirect logic to guard protected routes (matching production router behavior)
      redirect: (context, state) {
        try {
          // Access familyProvider through ProviderScope to check family status
          final container = ProviderScope.containerOf(context);
          final familyState = container.read(familyProvider);
          final hasFamily = familyState.family != null;

          // Protected routes that require family membership
          final isProtectedRoute =
              state.matchedLocation.startsWith('/family') ||
              state.matchedLocation.startsWith('/groups') ||
              state.matchedLocation.startsWith('/schedule');

          // Redirect to onboarding if accessing protected route without family
          if (isProtectedRoute &&
              !hasFamily &&
              !state.matchedLocation.startsWith('/onboarding')) {
            return '/onboarding/wizard';
          }
        } catch (e) {
          // If ProviderScope is not available (e.g., in unit tests), skip guard logic
        }
        return null; // No redirect needed
      },
      routes: [
        // Main app shell with bottom navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return TestMainShell(child: child);
          },
          routes: _shellTestRoutes,
        ),
        // Non-shell routes
        ..._defaultTestRoutes.where(
          (route) => route is GoRoute && !_shellRoutePaths.contains(route.path),
        ),
        // Add onboarding route for navigation tests
        GoRoute(
          path: '/onboarding/wizard',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Test Onboarding Wizard')),
          ),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Test Shell Error: ${state.matchedLocation}')),
      ),
    );
  }

  /// Shell route paths that should be inside the NavigationBar shell
  static final Set<String> _shellRoutePaths = {
    AppRoutes.dashboard,
    AppRoutes.family,
    AppRoutes.groups,
    AppRoutes.schedule,
    AppRoutes.profile,
  };

  /// Routes that should be inside the shell with NavigationBar
  static final List<RouteBase> _shellTestRoutes = [
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Test Dashboard'))),
    ),
    GoRoute(
      path: AppRoutes.family,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Test Family'))),
    ),
    GoRoute(
      path: AppRoutes.groups,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Test Groups'))),
    ),
    GoRoute(
      path: AppRoutes.schedule,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Test Schedule'))),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Test Profile'))),
    ),
  ];

  /// Default routes for testing - minimal set to avoid navigation errors
  static final List<RouteBase> _defaultTestRoutes = [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Test Home'))),
    ),
    GoRoute(
      path: '/auth/verify',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Test Auth Verify'))),
    ),
    GoRoute(
      path: '/family/invitation',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Test Family Invitation'))),
    ),
    // Add the shell routes as fallback when not using shell
    ..._shellTestRoutes,
  ];

  /// Create a router specifically for magic link testing
  static GoRouter createMagicLinkTestRouter({
    String initialLocation = '/auth/verify',
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Test Home'))),
        ),
        GoRoute(
          path: '/auth/verify',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Magic Link Verify Test Route')),
          ),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Test Dashboard'))),
        ),
        GoRoute(
          path: '/family/invitation',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Test Family Invitation')),
          ),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Magic Link Test Error: ${state.matchedLocation}'),
        ),
      ),
    );
  }
}

/// Test version of MainShell with simplified AppBottomNavigation
class TestMainShell extends StatelessWidget {
  final Widget child;

  const TestMainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const TestAppBottomNavigation(),
    );
  }
}

/// Test version of AppBottomNavigation that mimics the real implementation
class TestAppBottomNavigation extends ConsumerWidget {
  const TestAppBottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    // CRITICAL FIX: Check familyProvider for family membership
    // This fixes navigation tests that expect users with families to access protected routes
    final familyState = ref.watch(familyProvider);
    final hasFamily = familyState.family != null;

    var selectedIndex = 0;
    switch (currentLocation) {
      case '/dashboard':
        selectedIndex = 0;
        break;
      case '/family':
        selectedIndex = 1;
        break;
      case '/groups':
        selectedIndex = 2;
        break;
      case '/schedule':
        selectedIndex = 3;
        break;
      case '/profile':
        selectedIndex = 4;
        break;
    }

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        // Guard against accessing family features without a family
        if (!hasFamily && (index == 1 || index == 2 || index == 3)) {
          // Redirect to onboarding instead of the requested route
          context.go('/onboarding/wizard');
          return;
        }

        switch (index) {
          case 0:
            context.go(AppRoutes.dashboard);
            break;
          case 1:
            context.go(AppRoutes.family);
            break;
          case 2:
            context.go(AppRoutes.groups);
            break;
          case 3:
            context.go(AppRoutes.schedule);
            break;
          case 4:
            context.go(AppRoutes.profile);
            break;
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard),
          label: _getLocalizedText(context, 'Dashboard'),
        ),
        NavigationDestination(
          icon: Icon(
            Icons.family_restroom_outlined,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.38),
          ),
          selectedIcon: Icon(
            Icons.family_restroom,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.38),
          ),
          label: _getLocalizedText(context, 'Family (setup required)'),
        ),
        NavigationDestination(
          icon: Icon(
            Icons.groups_outlined,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.38),
          ),
          selectedIcon: Icon(
            Icons.groups,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.38),
          ),
          label: _getLocalizedText(context, 'Groups (setup required)'),
        ),
        NavigationDestination(
          icon: Icon(
            Icons.schedule_outlined,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.38),
          ),
          selectedIcon: Icon(
            Icons.schedule,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.38),
          ),
          label: _getLocalizedText(context, 'Schedule (setup required)'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outlined),
          selectedIcon: const Icon(Icons.person),
          label: _getLocalizedText(context, 'Profile'),
        ),
      ],
    );
  }

  /// Helper to get localized text with fallback for tests
  String _getLocalizedText(BuildContext context, String key) {
    try {
      final localizations = AppLocalizations.of(context);
      switch (key) {
        case 'Dashboard':
          return localizations.navigationDashboard;
        case 'Family':
          return localizations.navigationFamily;
        case 'Family (setup required)':
          return '${localizations.navigationFamily} (setup required)';
        case 'Groups':
          return localizations.navigationGroups;
        case 'Groups (setup required)':
          return '${localizations.navigationGroups} (setup required)';
        case 'Schedule':
          return localizations.navigationSchedule;
        case 'Schedule (setup required)':
          return '${localizations.navigationSchedule} (setup required)';
        case 'Profile':
          return localizations.navigationProfile;
        default:
          return key;
      }
    } catch (e) {
      // Fallback for tests where localization might not be properly set up
      return key;
    }
  }
}
