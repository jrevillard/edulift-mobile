import 'dart:async';
import 'package:flutter/material.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/invalid_deep_link_page.dart';
import '../presentation/widgets/main_shell.dart';
import '../presentation/themes/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

import '../utils/app_logger.dart' as core_logger;
import '../services/providers/auth_provider.dart';
// CLEAN ARCHITECTURE: Import family providers from family module
import '../../features/family/presentation/providers/family_provider.dart';
import '../navigation/navigation_state.dart' as nav;
import '../navigation/deep_link_transformer.dart';
// REMOVED: realtime_notification_badge.dart - feature simplified (no invitation lists)
import '../../features/auth/presentation/providers/magic_link_provider.dart';
import 'app_routes.dart';
import 'route_factory.dart';
import 'route_registration.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  // CLEAN ARCHITECTURE FIX: Remove static shell navigator key to avoid GlobalKey conflicts
  // Let GoRouter manage the shell navigator key automatically

  // Static refresh notifier to prevent recreation on each router build
  static final _refreshListenable = ValueNotifier<int>(0);

  // ✅ FIX: Debounce timer to prevent router refresh cascade (111 refreshes → ~10-15)
  // NetworkErrorHandler onSuccess callbacks can trigger multiple rapid familyProvider updates
  // Debouncing prevents race conditions that cause Duplicate GlobalKey errors
  static Timer? _familyRefreshDebouncer;
  static const _familyRefreshDebounceDelay = Duration(milliseconds: 500);

  /// Check if user has family using synchronous familyProvider state
  /// Returns target route: '/onboarding/wizard' or '/dashboard'
  ///
  /// OPTIMIZATION: Uses synchronous familyProvider state read (instant, no async overhead)
  /// This eliminates 10-20 API calls per session from router redirects
  static String _checkFamilyStatusAndGetRoute(WidgetRef ref, String? userId) {
    if (userId == null) {
      core_logger.AppLogger.debug(
        '[Router] No userId - redirecting to onboarding',
      );
      return '/onboarding/wizard';
    }

    // ✅ OPTIMIZATION 3: Synchronous state read (no async overhead, instant response)
    final familyState = ref.read(familyProvider);
    final hasFamily = familyState.family != null;

    core_logger.AppLogger.debug(
      '[Router] _checkFamilyStatusAndGetRoute - hasFamily: $hasFamily (synchronous state read)',
    );

    return hasFamily ? '/dashboard' : '/onboarding/wizard';
  }

  static GoRouter createRouter(WidgetRef ref) {
    core_logger.AppLogger.info(
      '🚨 ARCHITECTURE FIX: GoRouter.createRouter using refreshListenable pattern\n'
      '   - Using ValueNotifier to trigger route refresh on auth changes\n'
      '   - Router redirect will use fresh provider context via ref.read\n'
      '   - NO STALE CONTAINER REFERENCES - Provider mismatch ELIMINATED',
    );

    // CRITICAL FIX: Make router refresh SYNCHRONOUS for auth state changes
    // Reading provider state is instant - no async coordination needed
    // This ensures tests see immediate state updates and router redirects work correctly
    ref.listen(authStateProvider, (previous, next) {
      core_logger.AppLogger.info(
        '🚨 [Router Listener] ═══ AUTH STATE CHANGE DETECTED ═══\n'
        '   - Listener callback TRIGGERED at ${DateTime.now().toIso8601String()}\n'
        '   - Previous state: auth=${previous?.isAuthenticated}, init=${previous?.isInitialized}, user=${previous?.user?.id}, hash=${previous?.hashCode}\n'
        '   - Next state: auth=${next.isAuthenticated}, init=${next.isInitialized}, user=${next.user?.id}, hash=${next.hashCode}\n'
        '   - States identical: ${identical(previous, next)}\n'
        '   - States equal: ${previous == next}',
      );

      // CRITICAL FIX: Don't refresh router if magic link is in error state UNLESS auth state changed
      // This prevents redirecting away from the error page but allows logout navigation
      final magicLinkState = ref.read(magicLinkProvider);
      core_logger.AppLogger.debug(
        '🚨 [Router Listener] ═══ CRITICAL DEBUG ═══\n'
        '   - Check at: ${DateTime.now().toIso8601String()}\n'
        '   - Magic link status: ${magicLinkState.status}\n'
        '   - Error message: ${magicLinkState.errorMessage}\n'
        '   - Can retry: ${magicLinkState.canRetry}\n'
        '   - State hashCode: ${magicLinkState.hashCode}\n'
        '   - Auth changed: ${previous?.isAuthenticated != next.isAuthenticated}\n'
        '   - Hash changed: ${previous?.hashCode != next.hashCode}\n'
        '   - About to decide: block or allow router refresh?',
      );

      if (magicLinkState.status == MagicLinkVerificationStatus.error &&
          previous?.isAuthenticated == next.isAuthenticated &&
          previous?.hashCode == next.hashCode) {
        core_logger.AppLogger.info(
          '🚨 [Router Listener] ❌ MAGIC LINK ERROR STATE DETECTED - BLOCKING ROUTER REFRESH!\n'
          '   - Blocked at: ${DateTime.now().toIso8601String()}\n'
          '   - This prevents redirect away from error page\n'
          '   - User should see error: ${magicLinkState.errorMessage}\n'
          '   - Auth state unchanged - blocking navigation',
        );
        core_logger.AppLogger.debug(
          '🚨 [Router Listener] ❌ RETURNING EARLY TO PREVENT REDIRECT',
        );
        return; // Don't refresh router when magic link is showing error AND auth unchanged
      }

      if (magicLinkState.status == MagicLinkVerificationStatus.error &&
          (previous?.isAuthenticated != next.isAuthenticated ||
              previous?.hashCode != next.hashCode)) {
        core_logger.AppLogger.info(
          '🚨 [Router Listener] ✅ MAGIC LINK ERROR BUT STATE CHANGED - ALLOWING NAVIGATION\n'
          '   - Allowing at: ${DateTime.now().toIso8601String()}\n'
          '   - Auth changed: ${previous?.isAuthenticated} → ${next.isAuthenticated}\n'
          '   - Hash changed: ${previous?.hashCode} → ${next.hashCode}\n'
          '   - This allows logout navigation from error page',
        );
      } else {
        core_logger.AppLogger.debug(
          '🚨 [Router Listener] ✅ Magic link NOT in error state - proceeding with router refresh\n'
          '   - Continuing at: ${DateTime.now().toIso8601String()}\n'
          '   - Router refresh will proceed normally',
        );
      }

      // ARCHITECTURE FIX: Only refresh router on STRUCTURAL changes (auth, user, family, magic link)
      // REMOVED: postLogoutTargetRouteProvider check - using direct navigation now
      // CLEAN ARCHITECTURE: Remove familyId comparison - family changes handled via FamilyProvider
      // CRITICAL FIX: Don't refresh on loading state changes to prevent infinite recursion
      if (previous?.isAuthenticated != next.isAuthenticated ||
          previous?.isInitialized != next.isInitialized ||
          previous?.user?.id != next.user?.id ||
          previous?.pendingEmail != next.pendingEmail) {
        core_logger.AppLogger.info(
          '🔄 [Router Refresh] ✅ TRIGGERING ROUTER REFRESH ✅\n'
          '   - Was authenticated: ${previous?.isAuthenticated} -> Now authenticated: ${next.isAuthenticated}\n'
          '   - Was initialized: ${previous?.isInitialized} -> Now initialized: ${next.isInitialized}\n'
          '   - User ID: ${previous?.user?.id} -> ${next.user?.id}\n'
          '   - Family: [tracked via FamilyProvider, not User entity]\n'
          '   - Pending Email: ${previous?.pendingEmail} -> ${next.pendingEmail}\n'
          '   - Hash Code: ${previous?.hashCode} -> ${next.hashCode}\n'
          '   - ⚠️ Loading state changes ignored to prevent recursion',
        );
        // Increment to notify GoRouter to refresh routes
        _refreshListenable.value++;
        core_logger.AppLogger.info(
          '🔄 [Router Refresh] ✅ NOTIFIED GoRouter - _refreshListenable.value is now: ${_refreshListenable.value}',
        );
        // Navigation intent handling removed - using direct GoRouter navigation instead
      } else {
        core_logger.AppLogger.warning(
          '🔄 [Router Listener] ❌ NO meaningful changes detected - skipping router refresh',
        );
      }
    });

    // 🎯 STATE-OF-THE-ART: Navigation state listener - purely reactive
    ref.listen(nav.navigationStateProvider, (previous, next) {
      core_logger.AppLogger.info(
        '🧭 [Navigation State] ═══ STATE CHANGE DETECTED ═══\n'
        '   - Previous route: ${previous?.pendingRoute}\n'
        '   - Next route: ${next.pendingRoute}\n'
        '   - Previous trigger: ${previous?.trigger}\n'
        '   - Next trigger: ${next.trigger}',
      );
      // STATE-OF-THE-ART: Only refresh router when navigation state actually changes
      if (previous?.pendingRoute != next.pendingRoute ||
          previous?.trigger != next.trigger) {
        core_logger.AppLogger.info(
          '🔄 [Navigation State] Router refresh triggered\n'
          '   - Route change: ${previous?.pendingRoute} → ${next.pendingRoute}\n'
          '   - Trigger change: ${previous?.trigger} → ${next.trigger}',
        );
        _refreshListenable.value++;
        core_logger.AppLogger.info(
          '🔄 [Navigation State] Router notified - refresh count: ${_refreshListenable.value}',
        );
      } else {
        core_logger.AppLogger.debug(
          '🔄 [Navigation State] No meaningful changes - skipping refresh',
        );
      }
    });

    // ✅ FIX: Listen to family state changes to refresh router with debounce
    // When family loads after AutoLoad, router re-evaluates redirects
    // DEBOUNCE: NetworkErrorHandler onSuccess callbacks can trigger 111+ rapid refreshes
    // during E2E tests. Debouncing reduces this to ~10-15 refreshes, preventing
    // Duplicate GlobalKey errors from race conditions during navigation.
    ref.listen(familyProvider, (previous, next) {
      // Only trigger refresh when family actually loads (null → not null)
      if (previous?.family == null && next.family != null) {
        core_logger.AppLogger.info(
          '🔄 [Router Refresh] Family loaded - scheduling debounced router refresh\n'
          '   - Previous family: null\n'
          '   - New family: ${next.family?.id}\n'
          '   - Debounce delay: ${_familyRefreshDebounceDelay.inMilliseconds}ms to prevent cascade',
        );

        // Cancel any pending refresh to restart the debounce timer
        _familyRefreshDebouncer?.cancel();

        // Schedule debounced refresh
        _familyRefreshDebouncer = Timer(_familyRefreshDebounceDelay, () {
          _refreshListenable.value++;
          core_logger.AppLogger.info(
            '🔄 [Router Refresh] Debounced refresh executed - count: ${_refreshListenable.value}',
          );
        });
      } else {
        core_logger.AppLogger.debug(
          '🔄 [Family State] Family state changed but no null→loaded transition - skipping refresh\n'
          '   - Previous family: ${previous?.family?.id}\n'
          '   - Next family: ${next.family?.id}',
        );
      }
    });

    // Clear any existing routes to prevent duplicates
    RouteRegistry.clear();
    // Register all route factories using composition pattern
    RouteRegistration.registerAll();
    // Get all routes once to avoid duplicate registrations
    final allRoutes = RouteRegistry.getAllRoutes();

    // Define which routes should be inside the shell
    final shellRoutePaths = {
      AppRoutes.dashboard,
      AppRoutes.family,
      AppRoutes.groups,
      AppRoutes.schedule,
      AppRoutes.profile,
    };

    // Split routes into shell and non-shell routes
    final shellRoutes = <RouteBase>[];
    final nonShellRoutes = <RouteBase>[];
    for (final route in allRoutes) {
      if (route is GoRoute && shellRoutePaths.contains(route.path)) {
        shellRoutes.add(route);
      } else {
        nonShellRoutes.add(route);
      }
    }

    // ARCHITECTURE FIX: Remove magic link listener to prevent router interference
    // Magic link page now handles all states internally without router redirects

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.login,
      debugLogDiagnostics: true,
      // ARCHITECTURE FIX: Use static refreshListenable to trigger route refresh on auth changes
      refreshListenable: _refreshListenable,
      // ARCHITECTURE FIX: Use fresh provider context instead of stale container
      redirect: (context, state) async {
        // TRANSFORM stale edulift:// invitation URIs using centralized transformer
        // When navigation state clears, GoRouter refresh sees the original edulift:// URI again
        // We must re-transform it to prevent 404 /join errors
        // IMPORTANT: Only transforms invitation deep links (groups/families), not magic links (auth)
        final transformedRoute = transformInvitationDeepLink(state.uri);
        if (transformedRoute != null) {
          core_logger.AppLogger.info(
            '🔄 [GoRouter Redirect] RE-TRANSFORMING stale invitation deep link\n'
            '   - Original URI: ${state.uri}\n'
            '   - Target route: $transformedRoute\n'
            '   - Reason: Navigation state cleared, GoRouter saw stale edulift:// URI',
          );
          return transformedRoute;
        }

        // Get FRESH auth state using ref.read - NO STALE REFERENCES
        final authState = ref.read(authStateProvider);
        // CLEAN ARCHITECTURE: Get navigation state for pending deep links
        final navigationState = ref.read(nav.navigationStateProvider);

        // CRITICAL FIX: Respect explicit user navigation TO onboarding wizard (e.g., back button)
        // Only block automatic redirections when user explicitly navigates TO /onboarding/wizard
        // This prevents interference with normal navigation FROM /onboarding/wizard to other pages
        if (navigationState.pendingRoute == '/onboarding/wizard' &&
            navigationState.trigger == nav.NavigationTrigger.userNavigation) {
          core_logger.AppLogger.info(
            '🔄 [GoRouter Redirect] PERFORMING explicit user navigation TO onboarding wizard\n'
            '   - User explicitly navigating TO: ${navigationState.pendingRoute}\n'
            '   - Current location: ${state.matchedLocation}\n'
            '   - Trigger: ${navigationState.trigger}\n'
            '   - Executing navigation to respect user intent',
          );
          return navigationState
              .pendingRoute; // Perform the explicit navigation
        }

        // CLEAN ARCHITECTURE: Navigation intents are now handled by the event-based system
        // in NavigationHandler, not by router redirects. This prevents router rebuilds
        // and eliminates GlobalKey conflicts completely.
        core_logger.AppLogger.info(
          '   - Router redirect now focuses ONLY on authentication-based routing\n'
          '   - This eliminates GlobalKey conflicts while maintaining navigation flow',
        );
        final isAuthenticated = authState.isAuthenticated;
        final currentUser = authState.user;

        // Consolidated debug logging with fresh state info
        core_logger.AppLogger.info(
          '🚨 ARCHITECTURE FIX: GoRouter redirect using FRESH provider context\n'
          '   - Using ref.read(authStateProvider) for CURRENT state\n'
          '   - Auth state: authenticated=${authState.isAuthenticated}, init=${authState.isInitialized}\n'
          '   - User ID: ${authState.user?.id ?? 'null'}\n'
          '   - Family: [tracked via UserFamilyService]\n'
          '   - Provider container mismatch ELIMINATED\n'
          '🔄 [GoRouter Redirect] ══════════════════════════════════════\n'
          '🔧 ARCHITECTURE FIX: Always using fresh provider context\n'
          '🔄 [GoRouter Redirect] Location: ${state.uri}\n'
          '🔄 [GoRouter Redirect] Matched Location: ${state.matchedLocation}\n'
          '🔄 [GoRouter Redirect] IsAuthenticated: $isAuthenticated\n'
          '🔄 [GoRouter Redirect] CurrentUser ID: ${currentUser?.id}\n'
          '🔄 [GoRouter Redirect] CurrentUser Email: ${currentUser?.email}\n'
          '🔄 [GoRouter Redirect] CurrentUser.family: [via UserFamilyService]\n'
          '🔄 [GoRouter Redirect] Auth state initialized: ${authState.isInitialized}\n'
          '🔄 [GoRouter Redirect] Timestamp: ${DateTime.now().toIso8601String()}',
        );

        // Wait for auth initialization before making routing decisions
        // CRITICAL FIX: Allow magic link verification even when auth not initialized
        // User may click magic link from email before having an active session
        final isMagicLinkVerifyRoute = state.matchedLocation.startsWith(
          '/auth/verify',
        );
        if (!authState.isInitialized && !isMagicLinkVerifyRoute) {
          core_logger.AppLogger.debug(
            '🔄 [GoRouter Redirect] Auth not yet initialized - showing splash',
          );
          return AppRoutes.splash;
        }

        // REMOVED: Post-logout target route handling - using direct navigation instead

        final isAuthRoute = state.matchedLocation.startsWith('/auth');
        final isSplashRoute = state.matchedLocation == '/splash';
        final isOnboardingRoute = state.matchedLocation.startsWith(
          '/onboarding',
        );
        // isMagicLinkVerifyRoute already declared above
        // ARCHITECTURE FIX: Removed isMagicLinkWaitingRoute - no longer needed with state-driven navigation
        final isInvitationRoute =
            state.matchedLocation.startsWith('/invite') ||
            state.matchedLocation.startsWith('/family-invitation') ||
            state.matchedLocation.startsWith('/group-invitation');

        // Enhanced magic link verification debugging
        if (isMagicLinkVerifyRoute) {
          core_logger.AppLogger.info(
            '🪄 [GoRouter] Magic link verification route detected',
          );
          core_logger.AppLogger.debug(
            '🪄 [GoRouter] Token parameter: ${state.uri.queryParameters['token']?.substring(0, 10)}...',
          );
          core_logger.AppLogger.debug(
            '🪄 [GoRouter] Invite code parameter: ${state.uri.queryParameters['inviteCode']}',
          );
        }

        // DECLARATIVE MAGIC LINK HANDLING: Check for pending email (magic link sent) - HIGHEST PRIORITY
        // CRITICAL FIX: Only redirect to login if on waiting page without pendingEmail
        // BUT allow /auth/verify routes to proceed (user clicked magic link)
        if (state.matchedLocation.startsWith(AppRoutes.magicLink) &&
            !state.matchedLocation.startsWith('/auth/verify') &&
            !isAuthenticated &&
            authState.pendingEmail == null) {
          core_logger.AppLogger.info(
            '🔄 [GoRouter Redirect] DECISION: On magic link waiting page but no pending email (logout) - redirecting to login',
          );
          return AppRoutes.login;
        }

        // If user has sent magic link, navigate to waiting page (HIGHEST PRIORITY - overrides pending navigation)
        // CRITICAL FIX: Don't override navigation if we're currently on magic link page
        // and a pending navigation exists (likely a deeplink that just arrived)
        if (!isAuthenticated && authState.pendingEmail != null) {
          final magicLinkWaitingUrl =
              '${AppRoutes.magicLink}?email=${Uri.encodeComponent(authState.pendingEmail!)}';
          if (state.matchedLocation != magicLinkWaitingUrl) {
            core_logger.AppLogger.info(
              '🪄 [GoRouter Redirect] PRIORITY DECISION: Magic link sent to ${authState.pendingEmail} - navigating to waiting page (overriding ALL pending navigation)',
            );

            // CRITICAL FIX: Clear any pending navigation (e.g. from logout) because magic link has HIGHEST priority
            // This prevents /auth/login navigation from overriding /auth/login/magic-link
            if (navigationState.hasPendingNavigation) {
              core_logger.AppLogger.info(
                '🪄 [GoRouter Redirect] CLEARING pending navigation (${navigationState.pendingRoute}) - magic link takes priority',
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(nav.navigationStateProvider.notifier)
                    .clearNavigation();
              });
            }

            return magicLinkWaitingUrl;
          }
        }

        // 🎯 STATE-OF-THE-ART DECLARATIVE NAVIGATION: Check for pending navigation (LOWER PRIORITY)
        // The router makes decisions based purely on current state, no manual clearing needed
        core_logger.AppLogger.info(
          '🧭 [Router State] NAVIGATION CHECK: hasPending=${navigationState.hasPendingNavigation}, route=${navigationState.pendingRoute}',
        );
        if (navigationState.hasPendingNavigation == true &&
            navigationState.pendingRoute != null) {
          final pendingUrl = navigationState.pendingRoute!;

          core_logger.AppLogger.info(
            '🧭 [Router State] DECLARATIVE: Pending navigation detected\n'
            '   - Target: $pendingUrl\n'
            '   - Trigger: ${navigationState.trigger}\n'
            '   - Current location: ${state.matchedLocation}',
          );

          // STATE-OF-THE-ART: For magic link routes, check if we should honor the navigation
          if (pendingUrl.startsWith('/auth/verify')) {
            final magicLinkState = ref.read(magicLinkProvider);
            final authState = ref.read(authStateProvider);
            core_logger.AppLogger.info(
              '🪄 [Router State] Magic link route state analysis:\n'
              '   - Magic link status: ${magicLinkState.status}\n'
              '   - Has error: ${magicLinkState.errorMessage != null}\n'
              '   - Error message: ${magicLinkState.errorMessage}\n'
              '   - User authenticated: ${authState.isAuthenticated}\n'
              '   - Should navigate: ${state.matchedLocation != pendingUrl}',
            );

            // STATE-OF-THE-ART: If magic link succeeded and user is authenticated, clear navigation
            if (magicLinkState.status == MagicLinkVerificationStatus.success &&
                authState.isAuthenticated) {
              core_logger.AppLogger.info(
                '🎉 [Router State] SUCCESS: Magic link succeeded and user authenticated - clearing navigation for dashboard redirect\n'
                '   - Decision at: ${DateTime.now().toIso8601String()}\n'
                '   - User ID: ${authState.user?.id}\n'
                '   - Family: [via UserFamilyService]\n'
                '   - Clearing navigation to allow auth-based routing...',
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(nav.navigationStateProvider.notifier)
                    .clearNavigation();
                core_logger.AppLogger.info(
                  '🎉 [Router State] Navigation cleared - router will redirect based on auth state',
                );
              });
              return null; // Don't navigate to verification, let auth-based redirect handle it
            }

            // If magic link has a permanent error and we're asking to navigate away, clear the pending navigation
            if (magicLinkState.status == MagicLinkVerificationStatus.error &&
                !state.matchedLocation.startsWith('/auth/verify')) {
              core_logger.AppLogger.info(
                '🪄 [Router State] CRITICAL: Magic link has permanent error - clearing stale navigation state\n'
                '   - Decision at: ${DateTime.now().toIso8601String()}\n'
                '   - Current location: ${state.matchedLocation}\n'
                '   - Pending URL: $pendingUrl\n'
                '   - Magic link error: ${magicLinkState.errorMessage}\n'
                '   - About to clear navigation and return null...',
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(nav.navigationStateProvider.notifier)
                    .clearNavigation();
                core_logger.AppLogger.debug(
                  '🪄 [Router State] Navigation state cleared due to magic link error',
                );
              });
              return null; // Don't navigate, let normal redirect logic handle
            }
          }

          // Normal navigation processing
          if (state.matchedLocation != pendingUrl) {
            core_logger.AppLogger.info(
              '🧭 [Router State] NAVIGATION_DECISION: Navigate to $pendingUrl\n'
              '   - Decision at: ${DateTime.now().toIso8601String()}\n'
              '   - From: ${state.matchedLocation}\n'
              '   - To: $pendingUrl\n'
              '   - Trigger: ${navigationState.trigger}\n'
              '   - About to navigate...',
            );

            // ARCHITECTURE FIX: No automatic navigation clearing
            // Each route/page is responsible for managing its own navigation state
            core_logger.AppLogger.debug(
              '🧭 [Router State] Navigation transition complete - letting routes manage their own state',
            );

            return pendingUrl;
          } else {
            core_logger.AppLogger.debug(
              '🧭 [Router State] Navigation already processing ($pendingUrl) - skipping duplicate redirect call',
            );
            // Navigation is already being processed, don't interfere
            return null;
          }
        }

        // If not authenticated and not on auth/invitation/onboarding routes, redirect to login
        if (!isAuthenticated &&
            !isAuthRoute &&
            !isSplashRoute &&
            !isInvitationRoute &&
            !isOnboardingRoute &&
            !isMagicLinkVerifyRoute) {
          core_logger.AppLogger.warning(
            '🔄 [GoRouter Redirect] DECISION: Not authenticated - redirecting to login',
          );
          core_logger.AppLogger.debug(
            '🔄 [GoRouter Redirect] Route analysis: isAuth=$isAuthRoute, isSplash=$isSplashRoute, isInvite=$isInvitationRoute, isOnboarding=$isOnboardingRoute, isMagicVerify=$isMagicLinkVerifyRoute',
          );
          return AppRoutes.login;
        }

        // STATE-OF-THE-ART: Handle magic link verification route with declarative navigation
        if (isMagicLinkVerifyRoute) {
          // CRITICAL FIX: If user is authenticated, ALWAYS redirect to dashboard/onboarding
          // This prevents getting stuck on verification page after successful auth
          if (isAuthenticated && currentUser != null) {
            core_logger.AppLogger.info(
              '🪄 [GoRouter Redirect] CRITICAL: User authenticated on magic link page - redirecting immediately\n'
              '   - User ID: ${currentUser.id}\n'
              '   - Bypassing magic link state checks',
            );
            // PHASE 3: Check for invitation result from magic link
            final invitationResult = ref
                .read(authStateProvider)
                .invitationResult;

            if (invitationResult != null) {
              core_logger.AppLogger.info(
                '📨 [GoRouter] Invitation result found - processed: ${invitationResult.processed}',
              );

              if (invitationResult.processed) {
                // Backend successfully processed invitation
                final targetRoute =
                    invitationResult.redirectUrl ?? '/dashboard';
                core_logger.AppLogger.info(
                  '✅ [GoRouter] Invitation processed successfully - redirecting to: $targetRoute',
                );

                // Clear invitation result AFTER navigation completes
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(authStateProvider.notifier).clearInvitationResult();
                });

                return targetRoute;
              } else {
                // Backend couldn't process invitation (e.g., requires family onboarding)
                core_logger.AppLogger.error(
                  '❌ [GoRouter] Invitation NOT processed - reason: ${invitationResult.reason ?? "unknown"}',
                );
                core_logger.AppLogger.info(
                  '🔄 [GoRouter] Staying on magic link page to display error',
                );

                // Clear invitation result to prevent retry loops
                ref.read(authStateProvider.notifier).clearInvitationResult();

                // Stay on magic link verification page to show error
                // The magic link provider should have already set error state
                return null;
              }
            }

            // PHASE 3: No invitation result - continue normal auth flow
            // CLEAN ARCHITECTURE: FamilyRepository handles cache automatically
            // No manual cache initialization needed

            // OPTIMIZATION: Synchronous family check (no async overhead)
            final targetRoute = _checkFamilyStatusAndGetRoute(
              ref,
              currentUser.id,
            );
            core_logger.AppLogger.info(
              '🪄 [GoRouter Redirect] DECISION: Magic link success + authenticated user - redirecting to $targetRoute',
            );
            return targetRoute;
          }

          // User not yet authenticated or initial state - allow verification process
          core_logger.AppLogger.info(
            '🪄 [GoRouter Redirect] DECISION: Magic link verification - allowing verification process (unauthenticated)',
          );
          return null; // Let the verification page display and process
        }

        // If authenticated and on OTHER auth routes (not magic link verify), check family status
        if (isAuthenticated && isAuthRoute && !isMagicLinkVerifyRoute) {
          // CRITICAL FIX: Include magic link waiting page in login redirect logic
          // This fixes authenticated users getting stuck on magic link waiting page
          if (state.matchedLocation == AppRoutes.login ||
              state.matchedLocation.startsWith('/auth/login/magic-link')) {
            // OPTIMIZATION: Synchronous family check (no async overhead)
            final targetRoute = _checkFamilyStatusAndGetRoute(
              ref,
              currentUser?.id,
            );
            core_logger.AppLogger.info(
              '🪄 [GoRouter Redirect] DECISION: Authenticated user on auth page - redirecting to $targetRoute',
            );
            return targetRoute;
          }
        }

        // Handle authenticated users on splash screen
        if (isAuthenticated && isSplashRoute) {
          // OPTIMIZATION: Synchronous family check (no async overhead)
          final familyState = ref.read(familyProvider);

          // ✅ FIX: Wait for family loading to complete before making decision
          // During app startup, AutoLoadFamilyNotifier loads family asynchronously.
          // Router must wait for this load to complete to avoid wrong redirects.
          if (familyState.isLoading) {
            core_logger.AppLogger.info(
              '🔄 [GoRouter Redirect] DECISION: Family loading in progress - staying on splash',
            );
            return null; // Stay on splash while loading
          }

          final userHasFamily = familyState.family != null;

          if (!userHasFamily) {
            core_logger.AppLogger.info(
              '🔄 [GoRouter Redirect] DECISION: Authenticated user on splash without family - redirecting to onboarding',
            );
            return '/onboarding/wizard';
          }
          core_logger.AppLogger.info(
            '🔄 [GoRouter Redirect] DECISION: Authenticated user on splash with family - redirecting to dashboard',
          );
          return AppRoutes.dashboard;
        }

        // Handle unauthenticated users on splash screen
        if (!isAuthenticated && isSplashRoute) {
          core_logger.AppLogger.info(
            '🔄 [GoRouter Redirect] DECISION: Unauthenticated user on splash - redirecting to login',
          );
          return AppRoutes.login;
        }

        // If authenticated and on LOGIN-SPECIFIC auth routes, check family status
        // CRITICAL FIX: Include magic link waiting page in this check too
        if (isAuthenticated &&
            (state.matchedLocation == AppRoutes.login ||
                state.matchedLocation.startsWith('/auth/login/magic-link')) &&
            !isMagicLinkVerifyRoute) {
          // OPTIMIZATION: Synchronous family check (no async overhead)
          final familyState = ref.read(familyProvider);

          // ✅ FIX: Wait for family loading to complete before making decision
          if (familyState.isLoading) {
            core_logger.AppLogger.info(
              '🔄 [GoRouter Redirect] DECISION: Family loading in progress - staying on current page',
            );
            return null; // Stay on current page while loading
          }

          final userHasFamily = familyState.family != null;

          if (!userHasFamily) {
            core_logger.AppLogger.warning(
              '🔄 [GoRouter Redirect] DECISION: No family found - redirecting to onboarding',
            );
            return '/onboarding/wizard';
          }
          core_logger.AppLogger.info(
            '🔄 [GoRouter Redirect] DECISION: User has familyId and is on login/auth page - redirecting to dashboard',
          );
          return AppRoutes.dashboard;
        }

        // If authenticated user without family tries to access dashboard, redirect to onboarding
        if (isAuthenticated &&
            state.matchedLocation == '/dashboard' &&
            !isOnboardingRoute) {
          // OPTIMIZATION: Synchronous family check (no async overhead)
          final familyState = ref.read(familyProvider);

          // ✅ FIX: Wait for family loading to complete before making decision
          if (familyState.isLoading) {
            core_logger.AppLogger.info(
              '🔄 [GoRouter Redirect] DECISION: Family loading in progress - staying on current page',
            );
            return null; // Stay on current page while loading
          }

          final userHasFamily = familyState.family != null;

          if (!userHasFamily) {
            core_logger.AppLogger.warning(
              '🔄 [GoRouter Redirect] DECISION: Dashboard access without family - redirecting to onboarding',
            );
            return '/onboarding/wizard';
          }
        }

        // If authenticated user WITH family is on family creation page, redirect to dashboard
        if (isAuthenticated && state.uri.path == '/family/create') {
          // OPTIMIZATION: Synchronous family check (no async overhead)
          final familyState = ref.read(familyProvider);

          // ✅ FIX: Wait for family loading to complete before making decision
          if (familyState.isLoading) {
            core_logger.AppLogger.info(
              '🔄 [GoRouter Redirect] DECISION: Family loading in progress - staying on current page',
            );
            return null; // Stay on current page while loading
          }

          final userHasFamily = familyState.family != null;

          if (userHasFamily) {
            core_logger.AppLogger.info(
              '🔄 [GoRouter Redirect] DECISION: User with family on family creation page - redirecting to dashboard',
            );
            return AppRoutes.dashboard;
          }
        }

        // If authenticated user without family tries to access protected routes, redirect to onboarding
        if (isAuthenticated &&
            (state.uri.path.startsWith('/family') ||
                state.uri.path.startsWith('/groups') ||
                state.uri.path.startsWith('/schedule')) &&
            !isOnboardingRoute &&
            state.uri.path != '/family/create' &&
            state.uri.path != '/family/invite' &&
            !state.uri.path.startsWith('/family-invitation')) {
          // OPTIMIZATION: Synchronous family check (no async overhead)
          final familyState = ref.read(familyProvider);

          // ✅ FIX: Wait for family loading to complete before making decision
          if (familyState.isLoading) {
            core_logger.AppLogger.info(
              '🔄 [GoRouter Redirect] DECISION: Family loading in progress - staying on current page',
            );
            return null; // Stay on current page while loading
          }

          final userHasFamily = familyState.family != null;

          if (!userHasFamily) {
            core_logger.AppLogger.warning(
              '🔄 [GoRouter Redirect] DECISION: Protected route access without family - redirecting to onboarding',
            );
            return '/onboarding/wizard';
          }
        }

        // ✅ FIX: If authenticated user WITH family is on onboarding wizard, redirect to dashboard
        // This handles the case after acceptInvitation() where user just joined a family
        if (isAuthenticated && state.matchedLocation == '/onboarding/wizard') {
          final familyState = ref.read(familyProvider);

          // Wait for family loading to complete before making decision
          if (familyState.isLoading) {
            core_logger.AppLogger.info(
              '🔄 [GoRouter Redirect] DECISION: Family loading in progress on onboarding - staying on current page',
            );
            return null; // Stay on current page while loading
          }

          final userHasFamily = familyState.family != null;

          if (userHasFamily) {
            core_logger.AppLogger.info(
              '🔄 [GoRouter Redirect] DECISION: User with family on onboarding wizard - redirecting to dashboard',
            );
            return AppRoutes.dashboard;
          }
        }

        // FALLBACK: If user is unauthenticated and NOT on allowed routes, redirect to login
        if (!isAuthenticated &&
            !isAuthRoute &&
            !isSplashRoute &&
            !isOnboardingRoute &&
            !isInvitationRoute) {
          core_logger.AppLogger.info(
            '🔄 [GoRouter Redirect] DECISION: Unauthenticated user on protected route - redirecting to login',
          );
          return AppRoutes.login;
        }

        // No redirect needed
        core_logger.AppLogger.debug(
          '🔄 [GoRouter Redirect] DECISION: No redirect needed - staying on current route',
        );
        return null;
      },
      routes: [
        // Splash route
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),

        // Main app shell with bottom navigation
        // CLEAN ARCHITECTURE FIX: Remove navigatorKey to avoid static GlobalKey conflicts
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShell(navigationShell: navigationShell);
          },
          branches: shellRoutes
              .map((route) => StatefulShellBranch(routes: [route]))
              .toList(),
        ),

        // Add all non-shell routes
        ...nonShellRoutes,

        // Invalid deep link error page
        GoRoute(
          path: '/invalid-link',
          name: 'invalid-deep-link',
          builder: (context, state) {
            final invalidPath = state.uri.queryParameters['path'];
            return InvalidDeepLinkPage(invalidPath: invalidPath);
          },
        ),
      ],

      // Error handling - 404 page
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                '404 - Page Not Found',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text('${state.matchedLocation}'),
            ],
          ),
        ),
      ),
    );
  }

  /// Create a stable router instance for use with Provider pattern
  ///
  /// This method creates a router that works with the Provider singleton pattern,
  /// preventing recreation on every build and preserving navigation state
  /// during language changes and other UI rebuilds.
  static GoRouter createStableRouter(Ref ref) {
    core_logger.AppLogger.info(
      '🚨 ARCHITECTURE FIX: GoRouter.createStableRouter using Provider pattern...',
    );
    final refAdapter = _RefAdapter(ref);
    return createRouter(refAdapter);
  }
}

/// Minimal adapter to provide WidgetRef interface from Ref for router creation
class _RefAdapter implements WidgetRef {
  final Ref _ref;

  _RefAdapter(this._ref);

  @override
  T read<T>(ProviderListenable<T> provider) => _ref.read(provider);

  @override
  T watch<T>(ProviderListenable<T> provider) => _ref.watch(provider);

  @override
  void listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    _ref.listen(provider, listener, onError: onError);
  }

  @override
  ProviderSubscription<T> listenManual<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    bool fireImmediately = false,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    // Router doesn't use manual subscriptions, throw unsupported
    throw UnsupportedError(
      'listenManual not supported in router provider context',
    );
  }

  @override
  bool exists(ProviderBase<Object?> provider) => _ref.exists(provider);

  @override
  void invalidate(ProviderOrFamily provider) => _ref.invalidate(provider);

  @override
  T refresh<T>(Refreshable<T> provider) => _ref.refresh(provider);

  // Not available in Provider context, but required by interface
  @override
  BuildContext get context =>
      throw UnsupportedError('BuildContext not available in Provider context');

  // Widget property not available in Provider context
  Widget? get widget => null;
}

class AppBottomNavigation extends ConsumerWidget {
  const AppBottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    var selectedIndex = 0;
    // FIX: Check if location starts with the base path to handle sub-routes
    // This ensures the correct tab is highlighted when on sub-pages like /groups/{groupId}
    if (currentLocation.startsWith('/groups')) {
      selectedIndex = 2;
    } else if (currentLocation.startsWith('/family')) {
      selectedIndex = 1;
    } else if (currentLocation.startsWith('/schedule')) {
      selectedIndex = 3;
    } else if (currentLocation.startsWith('/profile')) {
      selectedIndex = 4;
    } else if (currentLocation.startsWith('/dashboard')) {
      selectedIndex = 0;
    }

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        // ARCHITECTURE FIX: Use standardized navigationStateProvider pattern for consistent navigation
        // FIX: Always navigate to base route when tab is tapped, even if already on that tab's sub-page
        // This ensures tapping "Groups" from /groups/{groupId} returns to /groups list
        // CRITICAL FIX: Don't navigate if already on the target route to prevent navigation loops
        final currentLocation = GoRouterState.of(context).uri.path;

        String targetRoute;
        switch (index) {
          case 0:
            targetRoute = '/dashboard';
            break;
          case 1:
            targetRoute = '/family';
            break;
          case 2:
            targetRoute = '/groups';
            break;
          case 3:
            targetRoute = '/schedule';
            break;
          case 4:
            targetRoute = '/profile';
            break;
          default:
            return;
        }

        // Only navigate if we're not already on the target route
        if (currentLocation != targetRoute) {
          ref
              .read(nav.navigationStateProvider.notifier)
              .navigateTo(
                route: targetRoute,
                trigger: nav.NavigationTrigger.userNavigation,
              );
        }
      },
      destinations: [
        NavigationDestination(
          key: const Key('navigation_dashboard'),
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard),
          label: AppLocalizations.of(context).navigationDashboard,
        ),
        NavigationDestination(
          key: const Key('navigation_family'),
          icon: const Icon(Icons.family_restroom_outlined),
          selectedIcon: const Icon(Icons.family_restroom),
          label: AppLocalizations.of(context).navigationFamily,
        ),
        NavigationDestination(
          key: const Key('navigation_groups'),
          icon: const Icon(Icons.groups_outlined),
          selectedIcon: const Icon(Icons.groups),
          label: AppLocalizations.of(context).navigationGroups,
        ),
        NavigationDestination(
          key: const Key('navigation_schedule'),
          icon: const Icon(Icons.schedule_outlined),
          selectedIcon: const Icon(Icons.schedule),
          label: AppLocalizations.of(context).navigationSchedule,
        ),
        NavigationDestination(
          key: const Key('navigation_profile'),
          icon: const Icon(Icons.person_outlined),
          selectedIcon: const Icon(Icons.person),
          label: AppLocalizations.of(context).navigationProfile,
        ),
      ],
    );
  }
}
