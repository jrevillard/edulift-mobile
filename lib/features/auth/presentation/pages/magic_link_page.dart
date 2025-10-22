import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/presentation/widgets/accessibility/accessible_button.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/navigation/navigation_state.dart';

class MagicLinkPage extends ConsumerStatefulWidget {
  final String email;

  const MagicLinkPage({super.key, required this.email});

  @override
  ConsumerState<MagicLinkPage> createState() => _MagicLinkPageState();
}

class _MagicLinkPageState extends ConsumerState<MagicLinkPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authStateProvider);

    // ARCHITECTURE FIX: Remove page-level auth navigation listener
    // Let router handle all auth-driven navigation through centralized redirect logic
    // This eliminates race conditions between multiple ref.listen callbacks

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.magicLinkSentTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await ref.read(authStateProvider.notifier).logout();
            ref.read(navigationStateProvider.notifier).navigateTo(
              route: '/auth/login',
              trigger: NavigationTrigger.userNavigation,
            );
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // State-of-the-art responsive UX: Adapt spacing and sizing based on available space
            final screenHeight = constraints.maxHeight;
            final isCompactScreen = screenHeight < 600;
            final isVeryCompactScreen = screenHeight < 500;

            // Dynamic spacing based on screen size - modern adaptive design
            final largePadding = isVeryCompactScreen ? 12.0 : (isCompactScreen ? 16.0 : 24.0);
            final mediumSpacing = isVeryCompactScreen ? 12.0 : (isCompactScreen ? 16.0 : 24.0);
            final smallSpacing = isVeryCompactScreen ? 6.0 : (isCompactScreen ? 8.0 : 12.0);
            final iconSize = isVeryCompactScreen ? 48.0 : (isCompactScreen ? 60.0 : 80.0);

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(largePadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Success Icon - responsive sizing
                        Icon(
                          Icons.mark_email_read,
                          size: iconSize,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: mediumSpacing),

                        // Title
                        Text(
                          key: const Key('magic_link_sent_message'),
                          l10n.checkYourEmail,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: isCompactScreen ? 22 : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: smallSpacing),

                        // Description
                        Text(
                          '${l10n.magicLinkSentDescription}\n${widget.email}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: isCompactScreen ? 14 : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: mediumSpacing),

                        // Help Card with instructions
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: EdgeInsets.all(isCompactScreen ? 12.0 : 16.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: isCompactScreen ? 18 : 20,
                                ),
                                SizedBox(height: smallSpacing),
                                Text(
                                  '${l10n.instructionsTitle}\n${l10n.instructionStep1}\n${l10n.instructionStep2}\n${l10n.instructionStep3}\n${l10n.instructionStep4}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: isCompactScreen ? 12 : null,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: mediumSpacing),

                        // Resend Magic Link Button
                        AccessibleButton.outlined(
                          key: const Key('resend_magic_link_button'),
                          onPressed: authState.isLoading ? null : _resendMagicLink,
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.resendLink),
                        ),
                        SizedBox(height: smallSpacing),

                        // Back to Login
                        TextButton(
                          key: const Key('back_to_login_button'),
                          onPressed: () async {
                            await ref.read(authStateProvider.notifier).logout();
                            ref.read(navigationStateProvider.notifier).navigateTo(
                              route: '/auth/login',
                              trigger: NavigationTrigger.userNavigation,
                            );
                          },
                          child: Text(l10n.backToLogin),
                        ),

                        SizedBox(height: smallSpacing),

                        // Help Text - responsive typography
                        Text(
                          l10n.linkExpiryInfo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: isCompactScreen ? 11 : null,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // Error Display
                        if (authState.error != null) ...[
                          SizedBox(height: smallSpacing),
                          Container(
                            key: const Key('errorMessage'),
                            padding: EdgeInsets.all(isCompactScreen ? 8.0 : 12.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              () {
                                switch (authState.error) {
                                  case 'errorNetwork':
                                  case 'errorNetworkGeneral':
                                    return l10n.errorNetworkMessage;
                                  case 'errorServer':
                                  case 'errorServerGeneral':
                                    return l10n.errorServerMessage;
                                  case 'errorAuth':
                                    return l10n.errorAuthMessage;
                                  case 'errorValidation':
                                    return l10n.errorValidationMessage;
                                  default:
                                    return l10n.errorUnexpectedMessage;
                                }
                              }(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                                fontSize: isCompactScreen ? 12 : null,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _resendMagicLink() async {
    final authState = ref.read(authStateProvider);

    // CLEAN ARCHITECTURE: Only use auth domain - no family dependencies
    // INVITATION FIX: Include stored invitation code in resend
    await ref.read(authStateProvider.notifier).sendMagicLink(
      widget.email,
      inviteCode: authState.pendingInviteCode,
    );

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            key: const Key('successMessage'),
            l10n.magicLinkResent,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}