import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../services/providers/localization_provider.dart';

/// Widget permettant de sélectionner et changer la langue de l'application
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(currentLocaleSyncProvider);

    return Card(
      key: const Key('language_selector_card'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.selectLanguage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            // Liste des langues disponibles
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 4),
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
            // Flag emoji ou icône
            Text(_getFlagEmoji(locale), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                  ),
                  if (languageName != nativeName)
                    Text(
                      languageName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
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

  String _getFlagEmoji(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸'; // ou 🇬🇧 selon preference
      case 'fr':
        return '🇫🇷';
      default:
        return '🌍';
    }
  }
}
