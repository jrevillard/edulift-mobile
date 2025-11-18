import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'language_selector.dart';
import 'developer_settings_section.dart';
import '../../mixins/navigation_cleanup_mixin.dart';
import '../../utils/responsive_breakpoints.dart';

/// Page des paramètres de l'application avec sélecteur de langue
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with NavigationCleanupMixin {
  // NavigationCleanupMixin automatically clears navigation state in initState

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: TextStyle(
            fontSize: context.getAdaptiveFontSize(
              mobile: 20,
              tablet: 22,
              desktop: 24,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        titleSpacing: context.getAdaptiveSpacing(
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
      ),
      body: SingleChildScrollView(
        padding: context.getAdaptivePadding(
          mobileHorizontal: 16,
          mobileVertical: 8,
          tabletHorizontal: 24,
          tabletVertical: 12,
          desktopHorizontal: 32,
          desktopVertical: 16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.isDesktop
                  ? context.maxContentWidth
                  : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: context.getAdaptiveSpacing(
                    mobile: context.isCompactHeight ? 8 : 16,
                    tablet: context.isCompactHeight ? 12 : 20,
                    desktop: 24,
                  ),
                ),
                // Sélecteur de langue
                const LanguageSelector(),

                SizedBox(
                  height: context.getAdaptiveSpacing(
                    mobile: context.isCompactHeight ? 16 : 24,
                    tablet: context.isCompactHeight ? 24 : 32,
                    desktop: 40,
                  ),
                ),

                // Developer Settings Section - 2025 State-of-the-Art
                const DeveloperSettingsSection(),

                SizedBox(
                  height: context.getAdaptiveSpacing(
                    mobile: context.isCompactHeight ? 8 : 16,
                    tablet: context.isCompactHeight ? 12 : 20,
                    desktop: 24,
                  ),
                ),

                // Autres paramètres peuvent être ajoutés ici
                Card(
                  elevation: context.isDesktop ? 2 : 1,
                  margin: context.getAdaptivePadding(
                    mobileHorizontal: 16,
                    tabletHorizontal: 20,
                    desktopHorizontal: 24,
                    mobileVertical: 8,
                    tabletVertical: 10,
                    desktopVertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      context.getAdaptiveBorderRadius(
                        mobile: 12,
                        tablet: 16,
                        desktop: 20,
                      ),
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: context.getAdaptiveAspectRatio(
                      mobile: context.isCompactHeight ? 1.5 : 1.8,
                      tablet: 2.0,
                      desktop: 2.2,
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
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                                size: context.getAdaptiveIconSize(
                                  mobile: 20,
                                  tablet: 24,
                                  desktop: 28,
                                ),
                              ),
                              SizedBox(
                                width: context.getAdaptiveSpacing(
                                  mobile: 8,
                                  tablet: 10,
                                  desktop: 12,
                                ),
                              ),
                              Text(
                                l10n.about,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.getAdaptiveFontSize(
                                        mobile: 16,
                                        tablet: 17,
                                        desktop: 18,
                                      ),
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
                          Text(
                            l10n.appName,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: context.getAdaptiveFontSize(
                                    mobile: 16,
                                    tablet: 17,
                                    desktop: 18,
                                  ),
                                ),
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 4,
                              tablet: 6,
                              desktop: 8,
                            ),
                          ),
                          Text(
                            l10n.appVersion,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: context.getAdaptiveFontSize(
                                    mobile: 14,
                                    tablet: 15,
                                    desktop: 16,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: context.getAdaptiveSpacing(
                    mobile: context.isCompactHeight ? 24 : 32,
                    tablet: context.isCompactHeight ? 32 : 40,
                    desktop: 48,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
