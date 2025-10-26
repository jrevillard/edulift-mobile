import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_constants.dart';
// Router provider is imported via providers.dart
import 'core/domain/entities/auth_entities.dart';
import 'core/domain/services/deep_link_service.dart';
import 'core/di/providers/providers.dart';
import 'core/services/providers/theme_provider.dart' as theme_service;
import 'core/services/providers/localization_provider.dart';
import 'core/services/app_state_provider.dart';
import 'core/services/timezone_service.dart';
import 'core/navigation/navigation_state.dart' as nav;
import 'core/navigation/deep_link_transformer.dart';
import 'core/utils/app_logger.dart';
import 'generated/l10n/app_localizations.dart';
// REMOVED: realtime_schedule_indicators.dart - feature simplified (no invitation lists)
import 'features/auth/presentation/providers/magic_link_provider.dart';
import 'core/services/providers/auth_provider.dart';
import 'core/presentation/widgets/connection/unified_connection_indicator.dart';

class EduLiftApp extends ConsumerStatefulWidget {
  const EduLiftApp({super.key});

  @override
  ConsumerState<EduLiftApp> createState() => _EduLiftAppState();
}

class _EduLiftAppState extends ConsumerState<EduLiftApp>
    with WidgetsBindingObserver {
  late final DeepLinkService _deepLinkService;
  bool _isSyncingTimezone = false;
  DateTime? _lastTimezoneSync;

  @override
  void initState() {
    super.initState();
    _initializeDeepLinkHandling();
    WidgetsBinding.instance.addObserver(this);
  }

  void _initializeDeepLinkHandling() {
    _deepLinkService = ref.read(deepLinkServiceProvider);

    // Set up deep link handler with state tracking
    _deepLinkService.setDeepLinkHandler(_handleDeepLink);

    // Check for initial deep link when app launches
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initialLink = await _deepLinkService.getInitialDeepLink();
      if (initialLink != null && mounted) {
        _handleDeepLink(initialLink);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkService.setDeepLinkHandler(null);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes from background, check and sync timezone if auto-sync is enabled
    if (state == AppLifecycleState.resumed) {
      _checkAndSyncTimezoneOnResume();
    }
  }

  Future<void> _checkAndSyncTimezoneOnResume() async {
    if (_isSyncingTimezone) return; // Prevent concurrent calls

    _isSyncingTimezone = true;
    try {
      // CRITICAL FIX: Clear timezone cache to detect device timezone changes when traveling
      TimezoneService.clearCache();

      final authService = ref.read(authServiceProvider);
      final timezoneSynced = await TimezoneService.checkAndSyncTimezone(
        authService,
      );

      if (timezoneSynced && mounted) {
        // Only show snackbar if it's been at least 5 minutes since last sync
        final now = DateTime.now();
        final shouldShowSnackbar =
            _lastTimezoneSync == null ||
            now.difference(_lastTimezoneSync!).inMinutes >= 5;

        // Update auth state to reflect the new timezone
        await ref.read(authStateProvider.notifier).refreshCurrentUser();

        AppLogger.info('✅ Timezone auto-synced on app resume');

        // Show a subtle notification to user
        if (shouldShowSnackbar && mounted) {
          _lastTimezoneSync = now;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Timezone updated automatically'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '[EduLiftApp] Error checking timezone on resume',
        e,
        stackTrace,
      );
    } finally {
      _isSyncingTimezone = false;
    }
  }

  void _handleDeepLink(DeepLinkResult deepLink) {
    if (!mounted) {
      return;
    }

    // ARCHITECTURE FIX: Use state-driven navigation for deep links too
    // This eliminates all manual GoRouter calls and ensures consistent navigation
    AppLogger.debug(
      '🔍 Deep link routing analysis:\n'
      '   - hasPath: ${deepLink.hasPath}\n'
      '   - path: "${deepLink.path}"\n'
      '   - routerPath: "${deepLink.routerPath}"\n'
      '   - hasMagicLink: ${deepLink.hasMagicLink}\n'
      '   - magicToken: ${deepLink.magicToken != null ? "present" : "null"}\n'
      '   - parameters: ${deepLink.parameters}',
    );

    // DECLARATIVE DEEP LINK: For magic link verification, set NavigationProvider state
    if (deepLink.hasMagicLink && deepLink.magicToken != null) {
      AppLogger.debug(
        '🪄 Deep link: Magic link verification detected - setting navigation state',
      );

      // CRITICAL FIX: Reset magic link provider state for fresh verification
      // This prevents stale error states from previous verification attempts
      try {
        final beforeReset = ref.read(magicLinkProvider);
        AppLogger.info(
          '🪄 DEEP_LINK_DEBUG: About to reset magic link provider\n'
          '   - Reset at: ${DateTime.now().toIso8601String()}\n'
          '   - Before reset status: ${beforeReset.status}\n'
          '   - Before reset error: ${beforeReset.errorMessage}\n'
          '   - Before reset hashCode: ${beforeReset.hashCode}',
        );

        ref.read(magicLinkProvider.notifier).reset();

        final afterReset = ref.read(magicLinkProvider);
        AppLogger.info(
          '🪄 DEEP_LINK_DEBUG: Magic link provider reset completed\n'
          '   - After reset status: ${afterReset.status}\n'
          '   - After reset error: ${afterReset.errorMessage}\n'
          '   - After reset hashCode: ${afterReset.hashCode}',
        );
      } catch (e) {
        AppLogger.error(
          '🪄 DEEP_LINK_ERROR: Failed to reset magic link provider\n'
          '   - Error at: ${DateTime.now().toIso8601String()}\n'
          '   - Error: $e',
        );
      }

      // CRITICAL FIX: Clear pendingEmail when magic link deep link arrives
      // This prevents router from redirecting to magic link waiting page instead of verification
      try {
        final authState = ref.read(authStateProvider);
        if (authState.pendingEmail != null) {
          AppLogger.info(
            '🪄 DEEP_LINK_DEBUG: Clearing pendingEmail for magic link verification\n'
            '   - Previous pendingEmail: ${authState.pendingEmail}\n'
            '   - Clear at: ${DateTime.now().toIso8601String()}\n'
            '   - Reason: Magic link deep link received - no longer need waiting page',
          );
          ref.read(authStateProvider.notifier).clearPendingEmail();
        }
      } catch (e) {
        AppLogger.error(
          '🪄 DEEP_LINK_ERROR: Failed to clear pendingEmail\n'
          '   - Error at: ${DateTime.now().toIso8601String()}\n'
          '   - Error: $e',
        );
      }

      // Build the complete verification URL with all parameters
      var verifyUrl = '/auth/verify?token=${deepLink.magicToken}';
      if (deepLink.inviteCode != null) {
        verifyUrl += '&inviteCode=${deepLink.inviteCode}';
      }
      if (deepLink.email != null) {
        verifyUrl += '&email=${Uri.encodeComponent(deepLink.email!)}';
      }

      AppLogger.debug(
        '🪄 Deep link: Setting pending deep link URL: $verifyUrl',
      );

      // CLEAN ARCHITECTURE: Set navigation state, router redirect will handle navigation
      ref
          .read(nav.navigationStateProvider.notifier)
          .navigateTo(
            route: verifyUrl,
            trigger: nav.NavigationTrigger.deepLink,
          );
      return;
    }

    if (deepLink.hasInvitation && deepLink.inviteCode != null) {
      AppLogger.debug(
        '🎫 Deep link: Invitation detected - setting navigation intent',
      );

      // CLEAN ARCHITECTURE: Use centralized deep link transformer
      // This ensures consistency between DeepLinkService and GoRouter
      // Build URI from DeepLinkResult to pass to transformer
      final deepLinkUri = Uri(
        scheme: 'edulift',
        host: deepLink.isGroupJoinPath ? 'groups' : 'families',
        path: '/join',
        queryParameters: deepLink.inviteCode != null
            ? {'code': deepLink.inviteCode!}
            : null,
      );
      final invitationRoute = transformInvitationDeepLink(deepLinkUri);

      if (invitationRoute == null) {
        // Invalid deep link path for invitation - show error page
        AppLogger.warning(
          '❌ Deep link: Malformed invitation deep link - path "${deepLink.path}" is not valid. '
          'Expected "groups/join" or "families/join".',
        );

        // Navigate to invalid deep link error page
        ref
            .read(nav.navigationStateProvider.notifier)
            .navigateTo(
              route:
                  '/invalid-link?path=${Uri.encodeComponent(deepLink.path ?? 'unknown')}',
              trigger: nav.NavigationTrigger.deepLink,
            );
        return;
      }

      final invitationType = deepLink.isGroupJoinPath ? 'group' : 'family';
      AppLogger.debug(
        '🎫 Deep link: Navigating to $invitationType invitation: $invitationRoute',
      );

      ref
          .read(nav.navigationStateProvider.notifier)
          .navigateTo(
            route: invitationRoute,
            trigger: nav.NavigationTrigger.deepLink,
            context: {'inviteCode': deepLink.inviteCode!},
          );
      return;
    }

    // For other deep links, let GoRouter's redirect logic handle navigation based on auth state
    AppLogger.debug(
      '🏠 Deep link: Default handling - GoRouter redirect will navigate based on auth state',
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ STATE-OF-THE-ART FIX: Use singleton router provider instead of recreation
    // Router is now created ONCE and reused, preserving navigation state during UI rebuilds
    final router = ref.watch(goRouterProvider);
    final appTheme = ref.watch(theme_service.themeProvider);
    final appState = ref.watch(appStateProvider);
    final currentLocale = ref.watch(currentLocaleSyncProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      routerConfig: router,
      theme: appTheme.lightTheme,
      darkTheme: appTheme.darkTheme,
      themeMode: appTheme.themeMode,
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // REMOVED: InvitationNotificationListener - feature simplified (no invitation lists)
        // REMOVED: Large red offline banner - replaced with UnifiedConnectionIndicator
        return _ConnectionSnackbarListener(
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),

              // Show loading overlay when app is loading
              if (appState.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Internal widget to listen for connectivity changes and show snackbars
/// Separated to allow ref.listen in a ConsumerWidget build method
class _ConnectionSnackbarListener extends ConsumerWidget {
  const _ConnectionSnackbarListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for connectivity status changes and show contextual snackbars
    ref.listen<ConnectionStatus>(unifiedConnectionStatusProvider, (
      previous,
      next,
    ) {
      if (previous == null || previous == next) return;

      // Only show snackbars for actual state changes
      final l10n = AppLocalizations.of(context);

      switch (next) {
        case ConnectionStatus.fullyConnected:
          // Transitioning to fully connected
          if (previous != ConnectionStatus.fullyConnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.snackbarBackOnline),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green[700],
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          break;

        case ConnectionStatus.limitedConnectivity:
          // Real-time features may be affected
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.snackbarLimitedConnectivity),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.orange[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;

        case ConnectionStatus.offline:
          // Fully offline
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.snackbarOffline),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
      }
    });

    return child;
  }
}
