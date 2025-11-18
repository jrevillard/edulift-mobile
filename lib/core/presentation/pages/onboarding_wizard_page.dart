// EduLift Mobile - Onboarding Wizard Page
// Simplified onboarding flow without Clean Architecture layers
// Guides users through family setup after magic link verification

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../../services/providers/auth_provider.dart';
import '../../navigation/navigation_state.dart';
import '../utils/responsive_breakpoints.dart';
import '../../../features/family/presentation/providers/family_provider.dart';
import '../../domain/entities/family.dart' as family_domain;

/// Onboarding wizard page that guides users through family setup
/// Simplified version without unnecessary Clean Architecture layers
class OnboardingWizardPage extends ConsumerStatefulWidget {
  final String? invitationCode;

  const OnboardingWizardPage({super.key, this.invitationCode});

  @override
  ConsumerState<OnboardingWizardPage> createState() =>
      _OnboardingWizardPageState();
}

class _OnboardingWizardPageState extends ConsumerState<OnboardingWizardPage> {
  // Focus nodes for keyboard navigation
  final FocusNode _primaryButtonFocusNode = FocusNode();
  final FocusNode _secondaryButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Check if user already has a family and redirect if they do
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final family = ref.read(familyDataProvider);

      // If user already has a family, redirect to dashboard
      if (family != null && mounted) {
        // Router will automatically redirect to dashboard via redirect logic
      }
    });
  }

  @override
  void dispose() {
    _primaryButtonFocusNode.dispose();
    _secondaryButtonFocusNode.dispose();
    super.dispose();
  }

  void _handleCreateFamily() {
    // Use declarative navigation pattern following app architecture
    ref
        .read(navigationStateProvider.notifier)
        .navigateTo(
          route: '/family/create',
          trigger: NavigationTrigger.userNavigation,
        );
  }

  void _handleJoinFamily() {
    if (widget.invitationCode != null) {
      // Process existing invitation code directly
      _processJoinFamily(widget.invitationCode!);
    } else {
      // Navigate to family invitation page for manual code entry
      ref
          .read(navigationStateProvider.notifier)
          .navigateTo(
            route: '/family-invitation',
            trigger: NavigationTrigger.userNavigation,
          );
    }
  }

  void _processJoinFamily(String invitationCode) {
    // Use declarative navigation pattern - navigate to family join page
    ref
        .read(navigationStateProvider.notifier)
        .navigateTo(
          route: '/family-invitation?code=$invitationCode',
          trigger: NavigationTrigger.userNavigation,
        );
  }

  /// Build user information card showing current user details
  Widget _buildUserInfoCard(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) return const SizedBox.shrink();

    final avatarRadius = context.getAdaptiveBorderRadius(
      mobile: 24,
      tablet: 28,
      desktop: 32,
    );
    final spacing = context.getAdaptiveSpacing(
      mobile: 12,
      tablet: 16,
      desktop: 20,
    );

    return Card(
      key: const Key('onboarding_user_info_card'),
      elevation: context.isDesktop
          ? 3
          : context.isTablet
          ? 2
          : 1,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: context.getAdaptivePadding(
          mobileHorizontal: 16,
          mobileVertical: 16,
          tabletHorizontal: 20,
          tabletVertical: 18,
          desktopHorizontal: 24,
          desktopVertical: 20,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: context.getAdaptiveFontSize(
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context).loggedInAs,
                    style:
                        (context.isTablet || context.isDesktop
                                ? Theme.of(context).textTheme.bodyMedium
                                : Theme.of(context).textTheme.bodySmall)
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: context.getAdaptiveFontSize(
                                mobile: 12,
                                tablet: 14,
                                desktop: 16,
                              ),
                            ),
                  ),
                  SizedBox(
                    height: context.getAdaptiveSpacing(
                      mobile: 2,
                      tablet: 3,
                      desktop: 4,
                    ),
                  ),
                  Text(
                    user.name.isNotEmpty ? user.name : 'Unknown User',
                    key: const Key('onboarding_user_name'),
                    style:
                        (context.isTablet || context.isDesktop
                                ? Theme.of(context).textTheme.titleMedium
                                : Theme.of(context).textTheme.bodyLarge)
                            ?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: context.getAdaptiveFontSize(
                                mobile: 16,
                                tablet: 18,
                                desktop: 20,
                              ),
                            ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.email.isNotEmpty) ...[
                    SizedBox(
                      height: context.getAdaptiveSpacing(
                        mobile: 1,
                        tablet: 2,
                        desktop: 3,
                      ),
                    ),
                    Text(
                      user.email,
                      key: const Key('onboarding_user_email'),
                      style:
                          (context.isTablet || context.isDesktop
                                  ? Theme.of(context).textTheme.bodyMedium
                                  : Theme.of(context).textTheme.bodySmall)
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: context.getAdaptiveFontSize(
                                  mobile: 12,
                                  tablet: 14,
                                  desktop: 16,
                                ),
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle user logout action
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          key: const Key('logout_confirmation_dialog'),
          title: Text(l10n.confirmLogout),
          content: Text(l10n.confirmLogoutMessage),
          actions: [
            TextButton(
              key: const Key('logout_cancel_button'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              key: const Key('logout_confirm_button'),
              onPressed: () async {
                Navigator.of(context).pop();
                // ARCHITECTURE FIX: Direct navigation after logout since targetRoute doesn't work
                await ref.read(authStateProvider.notifier).logout();
                ref
                    .read(navigationStateProvider.notifier)
                    .navigateTo(
                      route: '/auth/login',
                      trigger: NavigationTrigger.userNavigation,
                    );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final family = ref.watch(familyDataProvider);
    final familyState = ref.watch(familyProvider);

    // Listen for family changes and redirect if family is created
    ref.listen<family_domain.Family?>(familyDataProvider, (previous, next) {
      if (next != null && mounted) {
        // Router will automatically redirect to dashboard via redirect logic
      }
    });

    // Show loading while checking family status
    if (familyState.isLoading && family == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            key: const Key('onboarding_logout_button'),
            onPressed: _handleLogout,
            icon: Icon(
              Icons.logout,
              size: context.getAdaptiveIconSize(
                mobile: 24,
                tablet: 26,
                desktop: 28,
              ),
            ),
            tooltip: AppLocalizations.of(context).logout,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompactHeight = context.isCompactHeight;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: context.maxContentWidth,
                ),
                child: IntrinsicHeight(
                  child: Center(
                    child: Padding(
                      padding: context.getAdaptivePadding(
                        mobileHorizontal: 24,
                        mobileVertical: isCompactHeight ? 16 : 24,
                        tabletHorizontal: 32,
                        tabletVertical: isCompactHeight ? 20 : 32,
                        desktopHorizontal: 48,
                        desktopVertical: isCompactHeight ? 24 : 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // EduLift Branding
                          Container(
                            padding: context.getAdaptivePadding(
                              mobileAll: 16,
                              tabletAll: 24,
                              desktopAll: 32,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                context.getAdaptiveBorderRadius(
                                  mobile: 20,
                                  tablet: 28,
                                  desktop: 36,
                                ),
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/logos/edulift_logo_192.png',
                              width: context.isDesktop
                                  ? 200
                                  : context.isTablet
                                  ? 160
                                  : 120,
                              height: context.isDesktop
                                  ? 200
                                  : context.isTablet
                                  ? 160
                                  : 120,
                            ),
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: isCompactHeight ? 20 : 28,
                              tablet: isCompactHeight ? 24 : 36,
                              desktop: isCompactHeight ? 28 : 44,
                            ),
                          ),
                          Text(
                            'EduLift',
                            style: TextStyle(
                              fontSize: context.getAdaptiveFontSize(
                                mobile: 32,
                                tablet: 40,
                                desktop: 48,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: isCompactHeight ? 16 : 24,
                              tablet: isCompactHeight ? 20 : 32,
                              desktop: isCompactHeight ? 24 : 40,
                            ),
                          ),

                          // Welcome Message
                          Text(
                            AppLocalizations.of(context).welcomeOnboarding,
                            key: const Key('onboarding_welcome_message'),
                            style:
                                (context.isTablet || context.isDesktop
                                        ? Theme.of(
                                            context,
                                          ).textTheme.headlineMedium
                                        : Theme.of(
                                            context,
                                          ).textTheme.headlineSmall)
                                    ?.copyWith(
                                      fontSize: context.getAdaptiveFontSize(
                                        mobile: 24,
                                        tablet: 28,
                                        desktop: 32,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 12,
                              tablet: 16,
                              desktop: 20,
                            ),
                          ),

                          Text(
                            AppLocalizations.of(
                              context,
                            ).toGetStartedSetupFamily,
                            style:
                                (context.isTablet || context.isDesktop
                                        ? Theme.of(
                                            context,
                                          ).textTheme.titleMedium
                                        : Theme.of(context).textTheme.bodyLarge)
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      fontSize: context.getAdaptiveFontSize(
                                        mobile: 16,
                                        tablet: 18,
                                        desktop: 20,
                                      ),
                                    ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 24,
                              tablet: 32,
                              desktop: 40,
                            ),
                          ),

                          // User Information Card
                          _buildUserInfoCard(context),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: isCompactHeight ? 32 : 48,
                              tablet: isCompactHeight ? 40 : 56,
                              desktop: isCompactHeight ? 48 : 64,
                            ),
                          ),

                          // Family Choice Card
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: context.isDesktop
                                  ? 800
                                  : context.isTablet
                                  ? 600
                                  : double.infinity,
                            ),
                            child: Card(
                              elevation: context.isDesktop
                                  ? 4
                                  : context.isTablet
                                  ? 3
                                  : 2,
                              child: Padding(
                                padding: context.getAdaptivePadding(
                                  mobileHorizontal: 24,
                                  mobileVertical: 24,
                                  tabletHorizontal: 32,
                                  tabletVertical: 28,
                                  desktopHorizontal: 40,
                                  desktopVertical: 32,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.invitationCode != null) ...[
                                      // User has pending invitation
                                      Icon(
                                        Icons.family_restroom,
                                        size: context.getAdaptiveIconSize(
                                          mobile: 64,
                                          tablet: 80,
                                          desktop: 96,
                                        ),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      SizedBox(
                                        height: context.getAdaptiveSpacing(
                                          mobile: 16,
                                          tablet: 20,
                                          desktop: 24,
                                        ),
                                      ),

                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        ).youveBeenInvitedToJoinFamily,
                                        style:
                                            (context.isTablet ||
                                                        context.isDesktop
                                                    ? Theme.of(
                                                        context,
                                                      ).textTheme.headlineSmall
                                                    : Theme.of(
                                                        context,
                                                      ).textTheme.titleLarge)
                                                ?.copyWith(
                                                  fontSize: context
                                                      .getAdaptiveFontSize(
                                                        mobile: 22,
                                                        tablet: 26,
                                                        desktop: 30,
                                                      ),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: context.getAdaptiveSpacing(
                                          mobile: 8,
                                          tablet: 12,
                                          desktop: 16,
                                        ),
                                      ),

                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        ).acceptInvitationToCoordinate,
                                        style:
                                            (context.isTablet ||
                                                        context.isDesktop
                                                    ? Theme.of(
                                                        context,
                                                      ).textTheme.titleMedium
                                                    : Theme.of(
                                                        context,
                                                      ).textTheme.bodyMedium)
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                  fontSize: context
                                                      .getAdaptiveFontSize(
                                                        mobile: 16,
                                                        tablet: 18,
                                                        desktop: 20,
                                                      ),
                                                ),
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: context.getAdaptiveSpacing(
                                          mobile: 24,
                                          tablet: 28,
                                          desktop: 32,
                                        ),
                                      ),

                                      SizedBox(
                                        width: double.infinity,
                                        height: context.getAdaptiveButtonHeight(
                                          mobile: 48,
                                          tablet: 52,
                                          desktop: 56,
                                        ),
                                        child: ElevatedButton(
                                          focusNode: _primaryButtonFocusNode,
                                          onPressed: _handleJoinFamily,
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            ).getStarted,
                                            style: TextStyle(
                                              fontSize: context
                                                  .getAdaptiveFontSize(
                                                    mobile: 16,
                                                    tablet: 18,
                                                    desktop: 20,
                                                  ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: context.getAdaptiveSpacing(
                                          mobile: 12,
                                          tablet: 16,
                                          desktop: 20,
                                        ),
                                      ),

                                      SizedBox(
                                        height: context.getAdaptiveButtonHeight(
                                          mobile: 44,
                                          tablet: 48,
                                          desktop: 52,
                                        ),
                                        child: TextButton(
                                          key: const Key(
                                            'create_new_family_button',
                                          ),
                                          focusNode: _secondaryButtonFocusNode,
                                          onPressed: _handleCreateFamily,
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            ).skipOnboarding,
                                            style: TextStyle(
                                              fontSize: context
                                                  .getAdaptiveFontSize(
                                                    mobile: 14,
                                                    tablet: 16,
                                                    desktop: 18,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      // No pending invitation - show choice
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        ).chooseYourFamilySetup,
                                        style:
                                            (context.isTablet ||
                                                        context.isDesktop
                                                    ? Theme.of(
                                                        context,
                                                      ).textTheme.headlineSmall
                                                    : Theme.of(
                                                        context,
                                                      ).textTheme.titleLarge)
                                                ?.copyWith(
                                                  fontSize: context
                                                      .getAdaptiveFontSize(
                                                        mobile: 22,
                                                        tablet: 26,
                                                        desktop: 30,
                                                      ),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: context.getAdaptiveSpacing(
                                          mobile: 24,
                                          tablet: 28,
                                          desktop: 32,
                                        ),
                                      ),

                                      // Create Family Option
                                      SizedBox(
                                        width: double.infinity,
                                        height: context.getAdaptiveButtonHeight(
                                          mobile: 48,
                                          tablet: 52,
                                          desktop: 56,
                                        ),
                                        child: OutlinedButton.icon(
                                          key: const Key(
                                            'create_family_button',
                                          ),
                                          focusNode: _primaryButtonFocusNode,
                                          onPressed: _handleCreateFamily,
                                          icon: Icon(
                                            Icons.add,
                                            size: context.getAdaptiveIconSize(
                                              mobile: 20,
                                              tablet: 22,
                                              desktop: 24,
                                            ),
                                          ),
                                          label: Text(
                                            AppLocalizations.of(
                                              context,
                                            ).createFamily,
                                            style: TextStyle(
                                              fontSize: context
                                                  .getAdaptiveFontSize(
                                                    mobile: 16,
                                                    tablet: 18,
                                                    desktop: 20,
                                                  ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: context.getAdaptiveSpacing(
                                          mobile: 12,
                                          tablet: 16,
                                          desktop: 20,
                                        ),
                                      ),

                                      // Join Family Option
                                      SizedBox(
                                        width: double.infinity,
                                        height: context.getAdaptiveButtonHeight(
                                          mobile: 48,
                                          tablet: 52,
                                          desktop: 56,
                                        ),
                                        child: OutlinedButton.icon(
                                          key: const Key(
                                            'join_existing_family_button',
                                          ),
                                          focusNode: _secondaryButtonFocusNode,
                                          onPressed: _handleJoinFamily,
                                          icon: Icon(
                                            Icons.group_add,
                                            size: context.getAdaptiveIconSize(
                                              mobile: 20,
                                              tablet: 22,
                                              desktop: 24,
                                            ),
                                          ),
                                          label: Text(
                                            AppLocalizations.of(
                                              context,
                                            ).joinExistingFamily,
                                            style: TextStyle(
                                              fontSize: context
                                                  .getAdaptiveFontSize(
                                                    mobile: 16,
                                                    tablet: 18,
                                                    desktop: 20,
                                                  ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 24,
                              tablet: 32,
                              desktop: 40,
                            ),
                          ),
                        ],
                      ),
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
}
