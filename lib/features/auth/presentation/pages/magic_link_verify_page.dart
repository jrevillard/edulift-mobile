// EduLift Mobile - Magic Link Verification Page
// Professional UI states for magic link processing with error handling and navigation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/errors/failures.dart'; // Import Failure types for error handling
import '../../../../core/domain/entities/auth_entities.dart';
import '../../../../core/services/providers/auth_provider.dart';
import '../../../../core/navigation/navigation_state.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/magic_link_provider.dart';

/// Magic link verification page that handles different processing states
class MagicLinkVerifyPage extends ConsumerStatefulWidget {
  final String token;
  final String? inviteCode;
  final String? email;

  const MagicLinkVerifyPage({
    super.key,
    required this.token,
    this.inviteCode,
    this.email,
  });

  @override
  ConsumerState<MagicLinkVerifyPage> createState() =>
      _MagicLinkVerifyPageState();
}

class _MagicLinkVerifyPageState extends ConsumerState<MagicLinkVerifyPage> {
  @override
  void initState() {
    super.initState();
    AppLogger.info(
      '🪄 WIDGET_LIFECYCLE: Magic link verify page initialized\n'
      '   - Token: ${widget.token.substring(0, 10)}...\n'
      '   - Widget created at: ${DateTime.now().toIso8601String()}',
    );
    // Start verification process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogger.info(
        '🪄 WIDGET_LIFECYCLE: Starting magic link verification\n'
        '   - PostFrameCallback at: ${DateTime.now().toIso8601String()}\n'
        '   - Widget ref hashCode: ${ref.hashCode}',
      );
      ref
          .read(magicLinkProvider.notifier)
          .verifyMagicLink(
            widget.token,
            inviteCode: widget.inviteCode,
            email: widget.email,
          );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Removed ref.listen from here - moved to build method
  }

  // PHASE 5: dispose() cleanup removed - causes "ref after dispose" error
  // Router cleanup (Phase 3) with addPostFrameCallback is sufficient
  void _handleSuccessNavigation(MagicLinkVerificationResult result) {
    // 2025 STATE-OF-THE-ART: Pure declarative navigation via state changes
    // UI components NEVER call navigation methods - only trigger state changes
    // The router redirect logic handles all navigation based on state

    // STATE-OF-THE-ART: No manual navigation - let router redirect based on auth state
    // All invitation processing is now handled in MagicLinkProvider
    // Router will automatically detect authenticated state and redirect accordingly
    AppLogger.info(
      '🏠 MAGIC_LINK_SUCCESS: Auth state updated - router will handle navigation declaratively',
    );
  }

  void _handleRetry() {
    ref
        .read(magicLinkProvider.notifier)
        .verifyMagicLink(
          widget.token,
          inviteCode: widget.inviteCode,
          email: widget.email,
        );
  }

  void _handleBackToLogin() {
    AppLogger.error(
      '🔙 MAGIC_LINK_ACTION: _handleBackToLogin called\n'
      '   - Action triggered at: ${DateTime.now().toIso8601String()}\n'
      '   - Current magic link status: ${ref.read(magicLinkProvider).status}\n'
      '   - Widget mounted: $mounted\n'
      '   - About to clear states and navigate to login...',
    );
    // CRITICAL FIX: Clear the persistent deep link navigation state first
    // This prevents the router from navigating back to the magic link verify page
    // Clear the persistent deep link navigation state first
    ref.read(navigationStateProvider.notifier).clearNavigation();
    // Clear magic link state to prevent staying on error page
    ref.read(magicLinkProvider.notifier).reset();
    // STANDARDIZED NAVIGATION: Use navigationStateProvider pattern
    if (mounted) {
      ref
          .read(navigationStateProvider.notifier)
          .navigateTo(
            route: '/auth/login',
            trigger: NavigationTrigger.userNavigation,
          );
      AppLogger.error(
        '🔙 MAGIC_LINK_ACTION: Navigation to login completed using navigationStateProvider',
      );
    }
  }

  void _handleRequestNewLink() {
    // Get email from widget parameter or from magic link state
    final email = widget.email ?? ref.read(magicLinkProvider).email;

    if (email != null) {
      AppLogger.info('🔄 Magic Link: Resending magic link for email: $email');
      // ARCHITECTURE FIX: Just trigger resend and let the auth flow handle navigation
      // The sendMagicLink call will trigger the router redirect logic
      ref.read(authStateProvider.notifier).sendMagicLink(email);
    } else {
      AppLogger.warning(
        '⚠️ Magic Link: No email available - going back to login',
      );
      _handleBackToLogin();
    }
  }

  /// Build responsive button with consistent sizing and styling
  Widget _buildResponsiveButton({
    required String keyValue,
    required VoidCallback? onPressed,
    required String text,
    bool isPrimary = true,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;

    return SizedBox(
      width: double.infinity,
      height: isTablet ? 56 : 48,
      child: isPrimary
          ? ElevatedButton(
              key: Key(keyValue),
              onPressed: onPressed,
              child: Text(text),
            )
          : OutlinedButton(
              key: Key(keyValue),
              onPressed: onPressed,
              child: Text(text),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final magicLinkState = ref.watch(magicLinkProvider);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;

    // CRITICAL DEBUG: Log the current UI state to understand what's being rendered
    AppLogger.info(
      '🎨 UI_DEBUG: Magic link page build called\n'
      '   - Current status: ${magicLinkState.status}\n'
      '   - Error message: ${magicLinkState.errorMessage}\n'
      '   - Can retry: ${magicLinkState.canRetry}\n'
      '   - Widget email: ${widget.email}\n'
      '   - State email: ${magicLinkState.email}\n'
      '   - Widget mounted: $mounted\n'
      '   - About to render: ${magicLinkState.status.toString()}',
    );

    // Listen for state changes to handle navigation
    ref.listen<MagicLinkState>(magicLinkProvider, (previous, current) {
      AppLogger.info(
        '🎯 MAGIC_LINK_LISTENER: State change detected\n'
        '   - Listen callback at: ${DateTime.now().toIso8601String()}\n'
        '   - Previous status: ${previous?.status}\n'
        '   - Current status: ${current.status}\n'
        '   - Previous error: ${previous?.errorMessage}\n'
        '   - Current error: ${current.errorMessage}\n'
        '   - Widget mounted: $mounted\n'
        '   - About to process state change...',
      );
      if (current.status == MagicLinkVerificationStatus.success &&
          current.result != null) {
        AppLogger.info('✅ MAGIC_LINK_LISTENER: SUCCESS state detected');

        // PHASE 4: Check if invitation processing failed
        final authState = ref.read(authStateProvider);
        final invitationResult = authState.invitationResult;

        if (invitationResult != null && !invitationResult.processed) {
          // ❌ Invitation failed - set error state in magic link provider
          AppLogger.error(
            '❌ MAGIC_LINK_LISTENER: Invitation processing failed\n'
            '   - Reason: ${invitationResult.reason}\n'
            '   - Converting success state to error state for UI display',
          );

          // Convert to magic link error state to display using the new method
          ref
              .read(magicLinkProvider.notifier)
              .setInvitationError(
                invitationResult.reason ?? 'Failed to process invitation',
              );

          AppLogger.error(
            '❌ MAGIC_LINK_LISTENER: Error state set - router will keep us on page to display error',
          );
          return;
        }

        // ✅ Success - let router handle navigation
        AppLogger.info(
          '✅ MAGIC_LINK_LISTENER: Invitation processed successfully or no invitation - calling _handleSuccessNavigation',
        );
        _handleSuccessNavigation(current.result!);
      } else if (current.status == MagicLinkVerificationStatus.error) {
        AppLogger.error(
          '🚨 MAGIC_LINK_LISTENER: ERROR state detected\n'
          '   - Error at: ${DateTime.now().toIso8601String()}\n'
          '   - Error message: ${current.errorMessage}\n'
          '   - Can retry: ${current.canRetry}\n'
          '   - Widget mounted: $mounted\n'
          '   - Router should keep us on error page',
        );
        // 2025 STATE-OF-THE-ART: Pure state-driven - no manual router manipulation
        // The router will automatically check magic link state during navigation events
        AppLogger.info(
          '🚨 MAGIC_LINK_DEBUG: Magic link verification failed - error state set for router to check',
        );
        // Log error details for debugging
        if (current.errorMessage != null) {
          AppLogger.warning('🚨 Magic link error: ${current.errorMessage}');
        }

        // ERROR HANDLING: Stay on error page - do NOT clear navigation state
        // The router should keep us on the verification page to display the error
        AppLogger.error(
          '🚨 MAGIC_LINK_LISTENER: Completed error state processing - no navigation clearing',
        );
      } else {
        AppLogger.info(
          '🎯 MAGIC_LINK_LISTENER: Other status (${current.status}) - no specific action',
        );
      }
    });
    return Scaffold(
      key: const Key('magic-link-verify-page'), // For Patrol E2E testing
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
                    child: isTablet
                        ? _buildTabletLayout(context, magicLinkState)
                        : _buildMobileLayout(context, magicLinkState),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStateContent(MagicLinkState state) {
    AppLogger.info(
      '🎨 UI_DEBUG: _buildStateContent called with status: ${state.status}',
    );
    switch (state.status) {
      case MagicLinkVerificationStatus.initial:
      case MagicLinkVerificationStatus.verifying:
        AppLogger.info('🎨 UI_DEBUG: Rendering verifying state');
        return _buildVerifyingState();
      case MagicLinkVerificationStatus.success:
        AppLogger.info('🎨 UI_DEBUG: Rendering success state');
        return _buildSuccessState();
      case MagicLinkVerificationStatus.error:
        AppLogger.info('🎨 UI_DEBUG: Rendering error state');
        return _buildErrorState(state);
    }
  }

  Widget _buildVerifyingState() {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;

    return Column(
      children: [
        const CircularProgressIndicator(),
        SizedBox(height: isTablet ? 24 : 16),
        Text(
          l10n.verifyingMagicLink,
          key: const Key('verifying-magic-link-text'), // For Patrol E2E testing
          style: isTablet
              ? Theme.of(context).textTheme.headlineSmall
              : Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Text(
          l10n.verifyingMagicLinkMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;

    return Column(
      children: [
        Icon(
          Icons.check_circle,
          size: isTablet ? 64 : 48, // Responsive icon size
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: isTablet ? 24 : 16),
        Text(
          l10n.verificationSuccessful,
          key: const Key(
            'verification-successful-text',
          ), // For Patrol E2E testing
          style: isTablet
              ? Theme.of(context).textTheme.headlineSmall
              : Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Text(
          l10n.welcomeAfterMagicLinkSuccess,
          key: const Key('welcome_to_edulift_message'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorState(MagicLinkState state) {
    AppLogger.error(
      '🎨 ERROR_UI_DEBUG: _buildErrorState method started\n'
      '   - Method called at: ${DateTime.now().toIso8601String()}\n'
      '   - Widget mounted: $mounted\n'
      '   - State status: ${state.status}\n'
      '   - State hashCode: ${state.hashCode}',
    );

    final l10n = AppLocalizations.of(context);
    final canRetry = state.canRetry;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;

    // Check if we have email for better UX decisions
    final email = widget.email ?? state.email;
    final hasEmail = email != null && email.isNotEmpty;

    // CRITICAL FIX: Use failure type to determine the correct localized message
    // This matches the Phase 1-3 error handling pattern
    String localizedErrorMessage;
    if (state.failure != null) {
      // Determine error message based on failure type (not string matching)
      if (state.failure is NetworkFailure ||
          state.failure is NoConnectionFailure ||
          state.failure is OfflineFailure) {
        localizedErrorMessage = l10n.errorNetworkMessage;
      } else if (state.failure is ServerFailure) {
        localizedErrorMessage = l10n.errorServerMessage;
      } else if (state.failure is AuthFailure) {
        localizedErrorMessage = l10n.errorAuthMessage;
      } else {
        // Unknown failure type - use generic message
        localizedErrorMessage = l10n.errorUnexpectedMessage;
      }
    } else {
      // No failure object - fallback to generic message
      localizedErrorMessage = l10n.errorUnexpectedMessage;
    }

    AppLogger.error(
      '🎨 ERROR_UI_DEBUG: Error state variables:\n'
      '   - failure type: ${state.failure?.runtimeType}\n'
      '   - errorMessage (raw): ${state.errorMessage}\n'
      '   - localizedErrorMessage: $localizedErrorMessage\n'
      '   - canRetry: $canRetry\n'
      '   - email: $email\n'
      '   - hasEmail: $hasEmail\n'
      '   - isTablet: $isTablet\n'
      '   - About to render error UI at: ${DateTime.now().toIso8601String()}',
    );
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: isTablet ? 64 : 48, // Responsive icon size
          color: Theme.of(context).colorScheme.error,
        ),
        SizedBox(height: isTablet ? 24 : 16),
        Text(
          l10n.verificationFailedTitle,
          key: const Key('verification-failed-text'), // For Patrol E2E testing
          style:
              (isTablet
                      ? Theme.of(context).textTheme.headlineSmall
                      : Theme.of(context).textTheme.titleLarge)
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Text(
          localizedErrorMessage,
          key: const Key('errorMessage'), // For E2E tests to find error message
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isTablet ? 32 : 24),

        // Action Buttons - Improved UX
        Column(
          children: [
            // Primary action based on error type and email availability
            _buildResponsiveButton(
              keyValue: canRetry
                  ? 'try_again_button' // E2E test expects this key for retry
                  : hasEmail
                  ? 'request-new-link-button'
                  : 'back-to-login-button',
              onPressed: canRetry
                  ? _handleRetry
                  : hasEmail
                  ? _handleRequestNewLink
                  : _handleBackToLogin,
              text: canRetry
                  ? AppLocalizations.of(context).retry
                  : hasEmail
                  ? AppLocalizations.of(context).resendLink
                  : AppLocalizations.of(context).backToLogin,
            ),

            // Show secondary button only if we have email and primary action is not login
            if (hasEmail && canRetry) ...[
              SizedBox(height: isTablet ? 12 : 8),
              _buildResponsiveButton(
                keyValue: 'request-new-link-button',
                onPressed: _handleRequestNewLink,
                text: AppLocalizations.of(context).resendLink,
                isPrimary: false,
              ),
            ],

            // Show back to login button only if primary action is not login
            if (canRetry || hasEmail) ...[
              SizedBox(height: isTablet ? 12 : 8),
              _buildResponsiveButton(
                keyValue: 'back-to-login-button',
                onPressed: _handleBackToLogin,
                text: AppLocalizations.of(context).backToLogin,
                isPrimary: false,
              ),
            ],
          ],
        ),

        SizedBox(height: isTablet ? 24 : 16),

        // Help Text
        Text(
          () {
            // CRITICAL FIX: Use failure type instead of string matching
            if (canRetry && state.failure != null) {
              if (state.failure is NetworkFailure ||
                  state.failure is NoConnectionFailure ||
                  state.failure is OfflineFailure) {
                return AppLocalizations.of(context).actionCheckConnection;
              }
            }
            return AppLocalizations.of(context).linkExpiryInfo;
          }(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    MagicLinkState magicLinkState,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // EduLift Branding - Mobile sized
        Text(
          'EduLift',
          style: TextStyle(
            fontSize: 28, // Smaller for mobile
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32), // Reduced spacing
        // Main Content Card
        Card(
          elevation: 2,
          margin: EdgeInsets.zero, // Remove default margin for mobile
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Reduced padding for mobile
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildStateContent(magicLinkState)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    MagicLinkState magicLinkState,
  ) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        // Left column - Branding
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'EduLift',
                style: TextStyle(
                  fontSize: 40, // Larger for tablet
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.secureAuthentication,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(width: 48),

        // Right column - Content
        Expanded(
          flex: 3,
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(32.0), // Larger padding for tablet
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [_buildStateContent(magicLinkState)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
