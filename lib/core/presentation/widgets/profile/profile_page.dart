import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../services/providers/auth_provider.dart';
import '../../../services/user_family_service.dart';
import '../../../navigation/navigation_state.dart';
import '../settings/settings_page.dart';
import '../../mixins/navigation_cleanup_mixin.dart';
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
            const SizedBox(height: 16),

            // Section Informations Personnelles
            _buildUserInfoCard(context, l10n, currentUser),

            const SizedBox(height: 16),

            // Section Timezone Management
            const TimezoneSelector(),

            const SizedBox(height: 16),

            // Section Paramètres
            _buildSettingsCard(context, l10n, ref),

            const SizedBox(height: 16),

            // Section Actions
            _buildActionsCard(context, l10n, ref),

            const SizedBox(height: 32),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.name ?? l10n.profile,
                        key: const Key('profile_user_name'),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser?.email ?? '',
                        key: const Key('profile_user_email'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      // Family role chip - delegates to UserFamilyService
                      Consumer(
                        builder: (context, ref, child) {
                          return FutureBuilder<bool>(
                            future: currentUser != null
                                ? ref.read(
                                    cachedUserFamilyStatusProvider(
                                      currentUser!.id,
                                    ).future,
                                  )
                                : Future.value(false),
                            builder: (context, snapshot) {
                              final hasFamily = snapshot.data ?? false;
                              return Chip(
                                key: const Key('profile_family_role'),
                                label: Text(
                                  hasFamily ? 'Member' : 'No Family',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                visualDensity: VisualDensity.compact,
                              );
                            },
                          );
                        },
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.settings,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Navigation vers Settings
            InkWell(
              key: const Key('profile_settings_button'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
                    const SizedBox(width: 12),
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
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bouton de déconnexion
            InkWell(
              key: const Key('profile_logout_button'),
              onTap: () => _showLogoutConfirmation(context, l10n, ref),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
                    const SizedBox(width: 12),
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
              ref.read(navigationStateProvider.notifier).navigateTo(
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
