import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../services/providers/localization_provider.dart';
import '../../utils/responsive_breakpoints.dart';

/// Widget allowing user to select and change application language
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(currentLocaleSyncProvider);

    return Card(
      key: const Key('language_selector_card'),
      margin: EdgeInsets.symmetric(
        horizontal: context.getAdaptiveSpacing(
          mobile: 8,
          tablet: 12,
          desktop: 16,
        ),
        vertical: context.getAdaptiveSpacing(mobile: 4, tablet: 6, desktop: 8),
      ),
      child: Padding(
        padding: context.getAdaptivePadding(
          mobileAll: 12,
          tabletAll: 16,
          desktopAll: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
                  size: context.getAdaptiveIconSize(
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                ),
                SizedBox(
                  width: context.getAdaptiveSpacing(
                    mobile: 6,
                    tablet: 8,
                    desktop: 10,
                  ),
                ),
                Text(
                  l10n.language,
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
            Text(
              l10n.selectLanguage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
            ),
            // List of available languages
            ...AppLocalizations.supportedLocales.map(
              (locale) => _buildLanguageOption(
                context,
                ref,
                locale,
                currentLocale,
                l10n,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
    Locale currentLocale,
    AppLocalizations l10n,
  ) {
    final isSelected = locale.languageCode == currentLocale.languageCode;
    final languageName = _getLanguageName(locale, l10n);
    final nativeName = _getNativeLanguageName(locale);

    return InkWell(
      key: Key('language_option_${locale.languageCode}'),
      onTap: () => _changeLanguage(context, ref, locale),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.getAdaptiveSpacing(
            mobile: 10,
            tablet: 12,
            desktop: 14,
          ),
          vertical: context.getAdaptiveSpacing(
            mobile: 6,
            tablet: 8,
            desktop: 10,
          ),
        ),
        margin: EdgeInsets.only(
          bottom: context.getAdaptiveSpacing(mobile: 2, tablet: 3, desktop: 4),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Row(
          children: [
            // Flag icon using AssetImage for reliable rendering
            Container(
              width: context.getAdaptiveIconSize(
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
              height: context.getAdaptiveIconSize(
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  context.getAdaptiveBorderRadius(
                    mobile: 4,
                    tablet: 6,
                    desktop: 8,
                  ),
                ),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  context.getAdaptiveBorderRadius(
                    mobile: 2,
                    tablet: 3,
                    desktop: 4,
                  ),
                ),
                child: Image.asset(
                  _getFlagAssetPath(locale),
                  width: context.getAdaptiveIconSize(
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                  ),
                  height: context.getAdaptiveIconSize(
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: context.getAdaptiveIconSize(
                        mobile: 20,
                        tablet: 24,
                        desktop: 28,
                      ),
                      height: context.getAdaptiveIconSize(
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.public,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: context.getAdaptiveIconSize(
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: context.getAdaptiveSpacing(
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  if (languageName != nativeName)
                    Text(
                      languageName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: context.getAdaptiveIconSize(
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    try {
      await ref.read(currentLocaleProvider.notifier).setLocale(locale);

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            key: const Key('language_change_success'),
            content: Text(l10n.languageChanged),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            key: const Key('language_change_error'),
            content: Text(l10n.errorChangingLanguage),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getLanguageName(Locale locale, AppLocalizations l10n) {
    switch (locale.languageCode) {
      case 'en':
        return l10n.english;
      case 'fr':
        return l10n.french;
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  String _getNativeLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  String _getFlagAssetPath(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'assets/images/flags/us.png'; // US flag
      case 'fr':
        return 'assets/images/flags/fr.png'; // French flag
      default:
        return 'assets/images/flags/globe.png'; // Globe fallback
    }
  }
}
