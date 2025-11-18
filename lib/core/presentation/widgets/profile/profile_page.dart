import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../services/providers/auth_provider.dart';
import '../../../navigation/navigation_state.dart';
import '../settings/settings_page.dart';
import '../../mixins/navigation_cleanup_mixin.dart';
import '../../utils/responsive_breakpoints.dart';
import 'timezone_selector.dart';

/// Page de profil utilisateur avec accès aux paramètres et gestion famille
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with NavigationCleanupMixin {
  // NavigationCleanupMixin automatically clears navigation state in initState

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentUser = ref.watch(currentUserWithFamilyRoleProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),

            // Section Informations Personnelles
            _buildUserInfoCard(context, l10n, currentUser),

            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),

            // Section Timezone Management
            const TimezoneSelector(),

            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),

            // Section Paramètres
            _buildSettingsCard(context, l10n, ref),

            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),

            // Section Actions
            _buildActionsCard(context, l10n, ref),

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
    );
  }

  Widget _buildUserInfoCard(
    BuildContext context,
    AppLocalizations l10n,
    dynamic currentUser,
  ) {
    return Card(
      key: const Key('profile_user_info_card'),
      margin: context.getAdaptivePadding(
        mobileHorizontal: 16,
        mobileVertical: 8,
        tabletHorizontal: 20,
        tabletVertical: 10,
        desktopHorizontal: 24,
        desktopVertical: 12,
      ),
      child: Padding(
        padding: context.getAdaptivePadding(
          mobileAll: 16,
          tabletAll: 20,
          desktopAll: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius:
                      context
                          .getAdaptiveIconSize(
                            mobile: 28,
                            tablet: 32,
                            desktop: 36,
                          )
                          .toDouble() /
                      2,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: context.getAdaptiveIconSize(
                      mobile: 24,
                      tablet: 28,
                      desktop: 32,
                    ),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(
                  width: context.getAdaptiveSpacing(
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.name ?? l10n.profile,
                        key: const Key('profile_user_name'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: context.getAdaptiveSpacing(
                          mobile: 3,
                          tablet: 4,
                          desktop: 5,
                        ),
                      ),
                      Text(
                        currentUser?.email ?? '',
                        key: const Key('profile_user_email'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(
                        height: context.getAdaptiveSpacing(
                          mobile: 3,
                          tablet: 4,
                          desktop: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    return Card(
      margin: context.getAdaptivePadding(
        mobileHorizontal: 16,
        mobileVertical: 8,
        tabletHorizontal: 20,
        tabletVertical: 10,
        desktopHorizontal: 24,
        desktopVertical: 12,
      ),
      child: Padding(
        padding: context.getAdaptivePadding(
          mobileAll: 16,
          tabletAll: 20,
          desktopAll: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(
                  width: context.getAdaptiveSpacing(
                    mobile: 6,
                    tablet: 8,
                    desktop: 10,
                  ),
                ),
                Text(
                  l10n.settings,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),

            // Navigation vers Settings
            InkWell(
              key: const Key('profile_settings_button'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              borderRadius: BorderRadius.circular(
                context.getAdaptiveBorderRadius(
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
              ),
              child: Container(
                padding: context.getAdaptivePadding(
                  mobileHorizontal: 12,
                  mobileVertical: 12,
                  tabletHorizontal: 16,
                  tabletVertical: 14,
                  desktopHorizontal: 20,
                  desktopVertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    context.getAdaptiveBorderRadius(
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                  ),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(
                      width: context.getAdaptiveSpacing(
                        mobile: 10,
                        tablet: 12,
                        desktop: 16,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settings,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            'Language, Developer Tools & More',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    return Card(
      margin: context.getAdaptivePadding(
        mobileHorizontal: 16,
        mobileVertical: 8,
        tabletHorizontal: 20,
        tabletVertical: 10,
        desktopHorizontal: 24,
        desktopVertical: 12,
      ),
      child: Padding(
        padding: context.getAdaptivePadding(
          mobileAll: 16,
          tabletAll: 20,
          desktopAll: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bouton de déconnexion
            InkWell(
              key: const Key('profile_logout_button'),
              onTap: () => _showLogoutConfirmation(context, l10n, ref),
              borderRadius: BorderRadius.circular(
                context.getAdaptiveBorderRadius(
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
              ),
              child: Container(
                padding: context.getAdaptivePadding(
                  mobileHorizontal: 12,
                  mobileVertical: 12,
                  tabletHorizontal: 16,
                  tabletVertical: 14,
                  desktopHorizontal: 20,
                  desktopVertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    context.getAdaptiveBorderRadius(
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                  ),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(
                      width: context.getAdaptiveSpacing(
                        mobile: 10,
                        tablet: 12,
                        desktop: 16,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.logout,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmLogout),
        content: Text(l10n.confirmLogoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
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
      ),
    );
  }
}
