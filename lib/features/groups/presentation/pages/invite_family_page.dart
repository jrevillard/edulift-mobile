// EduLift Mobile - Invite Family to Group Page
// Mobile-first page for searching and selecting families to invite

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/network/group_api_client.dart';
import '../../../../core/di/providers/repository_providers.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import 'configure_family_invitation_page.dart';

/// Invite Family Page - Mobile-first search and selection
///
/// Allows group admins to search for families and select one to invite.
/// After selection, navigates to configuration page for role and message.
class InviteFamilyPage extends ConsumerStatefulWidget {
  final String groupId;

  const InviteFamilyPage({super.key, required this.groupId});

  @override
  ConsumerState<InviteFamilyPage> createState() => _InviteFamilyPageState();
}

class _InviteFamilyPageState extends ConsumerState<InviteFamilyPage> {
  final TextEditingController _searchController = TextEditingController();

  List<FamilySearchResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    final query = _searchController.text.trim();

    // Clear results if query is too short
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // Debounce search by 300ms
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final repository = ref.read(groupRepositoryProvider);
      final result = await repository.searchFamiliesForInvitation(
        widget.groupId,
        query,
        10, // Limit to 10 results (backend limit)
      );

      if (!mounted) return;

      result.when(
        ok: (families) {
          setState(() {
            _searchResults = families;
            _isSearching = false;
          });
        },
        err: (failure) {
          setState(() {
            _isSearching = false;
          });

          final l10n = AppLocalizations.of(context);
          final errorMessage = failure.message ?? l10n.errorUnexpected;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              key: const Key('family_search_error_snackbar'),
              content: Text(l10n.searchFailed(errorMessage)),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
      });

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('family_search_error_snackbar'),
          content: Text(l10n.searchFailed(l10n.unexpectedError)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _onFamilySelected(FamilySearchResult family) {
    // Navigate to configuration page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigureFamilyInvitationPage(
          groupId: widget.groupId,
          familyId: family.id,
          familyName: family.name,
          memberCount: family.memberCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isTablet = context.isTablet;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('invite_family_back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.inviteFamilyToGroup,
          style: TextStyle(fontSize: (isTablet ? 22 : 20) * context.fontScale),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Header Section
            Container(
              padding: context.getAdaptivePadding(
                mobileHorizontal: 16,
                mobileVertical: 16,
                tabletHorizontal: 24,
                tabletVertical: 20,
                desktopHorizontal: 32,
                desktopVertical: 24,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow(context),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions
                  Text(
                    l10n.inviteFamilyToGroupSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryThemed(context),
                    ),
                  ),
                  SizedBox(
                    height: context.getAdaptiveSpacing(
                      mobile: 12,
                      tablet: 16,
                      desktop: 20,
                    ),
                  ),

                  // Search Field
                  TextField(
                    key: const Key('family_search_field'),
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l10n.searchFamilies,
                      hintText: l10n.enterFamilyName,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),

            // Search Results Section
            Expanded(
              child: _buildSearchResults(context, l10n, theme, isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    bool isTablet,
  ) {
    // Empty state - waiting for search query
    if (_searchController.text.trim().length < 2) {
      return Center(
        child: Padding(
          padding: context.getAdaptivePadding(
            mobileAll: 32,
            tabletAll: 48,
            desktopAll: 64,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: isTablet ? 64 : 56,
                color: AppColors.textSecondaryThemed(
                  context,
                ).withValues(alpha: 0.5),
              ),
              SizedBox(
                height: context.getAdaptiveSpacing(
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              Text(
                l10n.enterAtLeast2Characters,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryThemed(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Loading state
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    // No results state
    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: context.getAdaptivePadding(
            mobileAll: 32,
            tabletAll: 48,
            desktopAll: 64,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: isTablet ? 64 : 56,
                color: AppColors.textSecondaryThemed(
                  context,
                ).withValues(alpha: 0.5),
              ),
              SizedBox(
                height: context.getAdaptiveSpacing(
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              Text(
                l10n.noFamiliesFound,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryThemed(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Results list
    return Column(
      children: [
        // Results Header
        Container(
          padding: context.getAdaptivePadding(
            mobileHorizontal: 16,
            mobileVertical: 12,
            tabletHorizontal: 24,
            tabletVertical: 16,
            desktopHorizontal: 32,
            desktopVertical: 20,
          ),
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Row(
            children: [
              Text(
                l10n.searchResults,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_searchResults.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (_searchResults.length >= 10)
                Tooltip(
                  message: l10n.refineSearchForMoreResults,
                  child: const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.warning,
                  ),
                ),
            ],
          ),
        ),

        // Results List
        Expanded(
          child: ListView.separated(
            padding: context.getAdaptivePadding(
              mobileAll: 16,
              tabletAll: 24,
              desktopAll: 32,
            ),
            itemCount: _searchResults.length,
            separatorBuilder: (context, index) => SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            itemBuilder: (context, index) {
              final family = _searchResults[index];
              return _FamilySearchResultCard(
                key: Key('family_search_result_${family.id}'),
                family: family,
                onTap: () => _onFamilySelected(family),
                l10n: l10n,
                theme: theme,
                isTablet: isTablet,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Family Search Result Card - Mobile-first design
class _FamilySearchResultCard extends StatelessWidget {
  final FamilySearchResult family;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final ThemeData theme;
  final bool isTablet;

  const _FamilySearchResultCard({
    super.key,
    required this.family,
    required this.onTap,
    required this.l10n,
    required this.theme,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('family_card_${family.id}'),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: family.canInvite ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Family Icon
                  Container(
                    width: isTablet ? 56 : 48,
                    height: isTablet ? 56 : 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                    ),
                    child: Icon(
                      Icons.groups,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: isTablet ? 28 : 24,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),

                  // Family Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          family.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.memberCount(family.memberCount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryThemed(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status/Action Indicator
                  if (!family.canInvite)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariantThemed(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        l10n.alreadyInvited,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryThemed(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios,
                      size: isTablet ? 20 : 16,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),

              // Admin Contacts (if available)
              if (family.adminContacts.isNotEmpty) ...[
                SizedBox(height: isTablet ? 12 : 8),
                Divider(height: 1, color: AppColors.borderThemed(context)),
                SizedBox(height: isTablet ? 12 : 8),
                _AdminContactsDisplay(
                  adminContacts: family.adminContacts,
                  l10n: l10n,
                  theme: theme,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Admin Contacts Display Widget
class _AdminContactsDisplay extends StatelessWidget {
  final List<AdminContact> adminContacts;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _AdminContactsDisplay({
    required this.adminContacts,
    required this.l10n,
    required this.theme,
  });

  String _getCompactContact(AdminContact admin) {
    if (admin.name.isNotEmpty) {
      return admin.name;
    }
    return admin.email;
  }

  @override
  Widget build(BuildContext context) {
    final displayCount = adminContacts.length > 2 ? 2 : adminContacts.length;
    final hasMore = adminContacts.length > 2;
    final moreCount = adminContacts.length - 2;

    return Row(
      children: [
        Icon(
          Icons.admin_panel_settings,
          size: 14,
          color: AppColors.textSecondaryThemed(context),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ...adminContacts.take(displayCount).map(
                    (admin) => Text(
                      _getCompactContact(admin),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryThemed(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              if (hasMore)
                Text(
                  l10n.andXMore(moreCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryThemed(context),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
