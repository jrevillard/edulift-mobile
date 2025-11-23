// EduLift - Dashboard Screen Golden Tests
// Comprehensive visual regression tests for dashboard screen using REAL production page

@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/services/providers/connectivity_provider.dart';
import 'package:edulift/core/presentation/widgets/connection/unified_connection_indicator.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;
import 'package:edulift/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:edulift/features/family/providers.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/factories/test_data_factory.dart';
import '../../test_mocks/test_mocks.dart' show setupMockFallbacks;
import '../../support/network_mocking.dart';

void main() {
  // Reset factories before tests
  setUpAll(() {
    // Setup all mock fallbacks first
    setupMockFallbacks();

    TestDataFactory.resetSeed();
  });

  group('Dashboard Screen - Golden Tests (Real Production Code)', () {
    testWidgets('DashboardPage - real production page', (tester) async {
      final testUser = User(
        id: 'user-1',
        email: 'admin@example.com',
        name: 'Günther Beaumont',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // Mock dashboard providers for new dashboard implementation
        dashboardCallbacksProvider.overrideWith((ref) => null),
        dashboardRefreshProvider.overrideWith((ref) => () {}),
        dashboardLoadingProvider.overrideWith((ref) => false),
        currentFamilyComposedProvider.overrideWith(
          (ref) => const AsyncValue.data(null),
        ),

        // Mock connectivity provider to prevent MissingPluginException
        connectivityProvider.overrideWith(
          (ref) => ConnectivityNotifier.test(const AsyncValue.data(true)),
        ),

        // Mock unified connection status provider to prevent dependency on connectivity
        unifiedConnectionStatusProvider.overrideWith(
          (ref) => ConnectionStatus.fullyConnected,
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const DashboardPage(),
        testName: 'dashboard_real_production',
        providerOverrides: overrides,
      );
    });

    testWidgets('DashboardPage - empty state', (tester) async {
      final testUser = User(
        id: 'user-2',
        email: 'new@example.com',
        name: 'New User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // Mock dashboard providers for new dashboard implementation
        dashboardCallbacksProvider.overrideWith((ref) => null),
        dashboardRefreshProvider.overrideWith((ref) => () {}),
        dashboardLoadingProvider.overrideWith((ref) => false),
        currentFamilyComposedProvider.overrideWith(
          (ref) => const AsyncValue.data(null),
        ),

        // Mock connectivity provider to prevent MissingPluginException
        connectivityProvider.overrideWith(
          (ref) => ConnectivityNotifier.test(const AsyncValue.data(true)),
        ),

        // Mock unified connection status provider to prevent dependency on connectivity
        unifiedConnectionStatusProvider.overrideWith(
          (ref) => ConnectionStatus.fullyConnected,
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testEmptyState(
        tester: tester,
        widget: const DashboardPage(),
        testName: 'dashboard',
        category: 'screen',
        providerOverrides: overrides,
      );
    });

    testWidgets('DashboardPage - dark theme', (tester) async {
      final testUser = User(
        id: 'user-3',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // Mock dashboard providers for new dashboard implementation
        dashboardCallbacksProvider.overrideWith((ref) => null),
        dashboardRefreshProvider.overrideWith((ref) => () {}),
        dashboardLoadingProvider.overrideWith((ref) => false),
        currentFamilyComposedProvider.overrideWith(
          (ref) => const AsyncValue.data(null),
        ),

        // Mock connectivity provider to prevent MissingPluginException
        connectivityProvider.overrideWith(
          (ref) => ConnectivityNotifier.test(const AsyncValue.data(true)),
        ),

        // Mock unified connection status provider to prevent dependency on connectivity
        unifiedConnectionStatusProvider.overrideWith(
          (ref) => ConnectionStatus.fullyConnected,
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const DashboardPage(),
        testName: 'dashboard_dark_real',
        providerOverrides: overrides,
      );
    });

    testWidgets('DashboardPage - tablet layout', (tester) async {
      final testUser = User(
        id: 'user-4',
        email: 'tablet@example.com',
        name: 'Tablet User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // Mock dashboard providers for new dashboard implementation
        dashboardCallbacksProvider.overrideWith((ref) => null),
        dashboardRefreshProvider.overrideWith((ref) => () {}),
        dashboardLoadingProvider.overrideWith((ref) => false),
        currentFamilyComposedProvider.overrideWith(
          (ref) => const AsyncValue.data(null),
        ),

        // Mock connectivity provider to prevent MissingPluginException
        connectivityProvider.overrideWith(
          (ref) => ConnectivityNotifier.test(const AsyncValue.data(true)),
        ),

        // Mock unified connection status provider to prevent dependency on connectivity
        unifiedConnectionStatusProvider.overrideWith(
          (ref) => ConnectionStatus.fullyConnected,
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const DashboardPage(),
        testName: 'dashboard_tablet_real',
        providerOverrides: overrides,
      );
    });
  });
}
