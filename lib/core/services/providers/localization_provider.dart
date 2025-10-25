import 'dart:ui' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/services/localization_service.dart';
import '../../../core/services/localization_service.dart' as impl;
import '../../di/providers/service_providers.dart'; // For localizationServiceProvider

// REMOVED: Duplicate provider that caused circular dependency
// The real localizationServiceProvider is in service_providers.g.dart

/// Provider for current locale state with async operations
final currentLocaleProvider =
    AsyncNotifierProvider<CurrentLocaleNotifier, Locale>(
  CurrentLocaleNotifier.new,
);

/// AsyncNotifier for managing locale state with proper error handling and loading states
class CurrentLocaleNotifier extends AsyncNotifier<Locale> {
  LocalizationService get _localizationService =>
      ref.read(localizationServiceProvider);

  @override
  Future<Locale> build() async {
    // Initialize with current locale from service
    final result = await _localizationService.getCurrentLocale();
    return result.when(
      ok: (localeInfo) =>
          impl.LocalizationServiceImpl.toFlutterLocale(localeInfo),
      err: (_) => const Locale('fr', 'FR'), // Default fallback
    );
  }

  /// Set a new locale with proper async state management
  Future<void> setLocale(Locale locale) async {
    // Set loading state
    state = const AsyncLoading<Locale>();

    try {
      final localeInfo = impl.LocalizationServiceImpl.fromFlutterLocale(locale);
      final result = await _localizationService.setLocale(localeInfo);
      if (result.isSuccess) {
        state = AsyncData(
          impl.LocalizationServiceImpl.toFlutterLocale(result.value!),
        );
      } else {
        state = AsyncError(result.error!, StackTrace.current);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// Get current locale synchronously (from state)
  Locale? get currentLocale => state.valueOrNull;

  /// Check if locale is supported
  bool isLocaleSupported(Locale locale) {
    final localeInfo = impl.LocalizationServiceImpl.fromFlutterLocale(locale);
    return _localizationService.isLocaleSupported(localeInfo);
  }

  /// Get all supported locales
  List<Locale> get supportedLocales => _localizationService
      .getSupportedLocales()
      .map(
        (localeInfo) =>
            impl.LocalizationServiceImpl.toFlutterLocale(localeInfo),
      )
      .toList();
}

/// Provider for locale change loading state
final localeChangeLoadingProvider = Provider<bool>((ref) {
  final localeState = ref.watch(currentLocaleProvider);
  return localeState.isLoading;
});

/// Provider for locale error state
final localeErrorProvider = Provider<Object?>((ref) {
  final localeState = ref.watch(currentLocaleProvider);
  return localeState.error;
});

/// Convenience provider for current locale (synchronous access)
final currentLocaleSyncProvider = Provider<Locale>((ref) {
  final localeState = ref.watch(currentLocaleProvider);
  return localeState.valueOrNull ?? const Locale('fr', 'FR');
});

/// Helper providers for common locale operations
final localeHelpersProvider = Provider<LocaleHelpers>((ref) {
  return LocaleHelpers(ref);
});

/// Helper class for common locale operations
class LocaleHelpers {
  final Ref _ref;

  LocaleHelpers(this._ref);

  /// Set English locale
  Future<void> setEnglish() async {
    await _ref
        .read(currentLocaleProvider.notifier)
        .setLocale(const Locale('en', 'US'));
  }

  /// Set French locale
  Future<void> setFrench() async {
    await _ref
        .read(currentLocaleProvider.notifier)
        .setLocale(const Locale('fr', 'FR'));
  }

  /// Toggle between English and French
  Future<void> toggleLocale() async {
    final currentLocale = _ref.read(currentLocaleSyncProvider);
    final newLocale = currentLocale.languageCode == 'en'
        ? const Locale('fr', 'FR')
        : const Locale('en', 'US');
    await _ref.read(currentLocaleProvider.notifier).setLocale(newLocale);
  }

  /// Get current language code
  String get currentLanguageCode {
    return _ref.read(currentLocaleSyncProvider).languageCode;
  }

  /// Check if current locale is English
  bool get isEnglish {
    return _ref.read(currentLocaleSyncProvider).languageCode == 'en';
  }

  /// Check if current locale is French
  bool get isFrench {
    return _ref.read(currentLocaleSyncProvider).languageCode == 'fr';
  }
}

/// Extension on WidgetRef for convenient locale access
extension LocaleRefExtension on WidgetRef {
  /// Get current locale with reactive updates
  Locale get locale => watch(currentLocaleSyncProvider);

  /// Get locale helpers for operations
  LocaleHelpers get localeHelpers => read(localeHelpersProvider);

  /// Check if locale change is in progress
  bool get isLocaleChanging => watch(localeChangeLoadingProvider);

  /// Get current locale error if any
  Object? get localeError => watch(localeErrorProvider);
}
