import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/result.dart';
import '../errors/failures.dart';
import '../security/tiered_storage_service.dart';
import '../domain/services/localization_service.dart';
import '../domain/entities/locale_info.dart';

/// Implementation of LocalizationService following clean architecture

class LocalizationServiceImpl implements LocalizationService {
  static const String _localeKey = 'app_locale';
  static const List<LocaleInfo> _supportedLocales = [
    LocaleInfo(languageCode: 'en', countryCode: 'US'),
    LocaleInfo(languageCode: 'fr', countryCode: 'FR'),
  ];

  final TieredStorageService _storage;
  late final StreamController<LocaleInfo> _localeController;
  LocaleInfo _currentLocale = const LocaleInfo(
    languageCode: 'fr',
    countryCode: 'FR',
  ); // Default to French

  /// Convert LocaleInfo to Flutter Locale for UI layer
  static Locale toFlutterLocale(LocaleInfo localeInfo) {
    return Locale(localeInfo.languageCode, localeInfo.countryCode);
  }

  /// Convert Flutter Locale to LocaleInfo for domain layer
  static LocaleInfo fromFlutterLocale(Locale locale) {
    return LocaleInfo(
      languageCode: locale.languageCode,
      countryCode: locale.countryCode,
    );
  }

  LocalizationServiceImpl(this._storage)
    : _localeController = StreamController<LocaleInfo>.broadcast() {
    _initializeLocale();
  }

  /// Initialize locale from storage or use default
  Future<void> _initializeLocale() async {
    final result = await _loadPersistedLocale();
    if (result.isOk) {
      final locale = result.value!;
      _currentLocale = locale;
      _localeController.add(_currentLocale);
    } else {
      final _ = result.error!;
      // Use default locale if loading fails
      _localeController.add(_currentLocale);
    }
  }

  @override
  Future<Result<LocaleInfo, Failure>> getCurrentLocale() async {
    try {
      return Result.ok(_currentLocale);
    } catch (e) {
      return Result.err(UnexpectedFailure('Failed to get current locale: $e'));
    }
  }

  @override
  List<LocaleInfo> getSupportedLocales() => _supportedLocales;

  @override
  Future<Result<LocaleInfo, Failure>> setLocale(LocaleInfo locale) async {
    try {
      if (!isLocaleSupported(locale)) {
        return Result.err(
          ValidationFailure(
            message: 'Unsupported locale: ${locale.toString()}',
          ),
        );
      }

      // Persist the locale
      final persistResult = await _persistLocale(locale);
      final persistError = persistResult.error;
      // Success, continue
      if (persistError != null) {
        return Result.err(persistError);
      }

      // Update current locale
      _currentLocale = locale;
      _localeController.add(_currentLocale);
      return Result.ok(locale);
    } catch (e) {
      return Result.err(UnexpectedFailure('Failed to set locale: $e'));
    }
  }

  @override
  bool isLocaleSupported(LocaleInfo locale) {
    return _supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Stream<LocaleInfo> get localeChanges => _localeController.stream;

  /// Load persisted locale from storage
  Future<Result<LocaleInfo, Failure>> _loadPersistedLocale() async {
    try {
      final localeString = await _storage.read(_localeKey, DataSensitivity.low);
      if (localeString == null) {
        return Result.ok(_currentLocale); // Use default
      }

      // Parse locale string (e.g., "en_US" or "fr_FR")
      final parts = localeString.split('_');
      if (parts.isEmpty) {
        return Result.ok(_currentLocale); // Use default
      }

      final languageCode = parts[0];
      final countryCode = parts.length > 1 ? parts[1] : null;
      final locale = LocaleInfo(
        languageCode: languageCode,
        countryCode: countryCode,
      );
      return isLocaleSupported(locale)
          ? Result.ok(locale)
          : Result.ok(_currentLocale); // Use default if not supported
    } catch (e) {
      return Result.err(
        StorageFailure('Failed to load locale from storage: $e'),
      );
    }
  }

  /// Persist locale to storage
  Future<Result<void, Failure>> _persistLocale(LocaleInfo locale) async {
    try {
      final localeString = '${locale.languageCode}_${locale.countryCode ?? ''}';
      await _storage.store(_localeKey, localeString, DataSensitivity.low);
      return const Result.ok(());
    } catch (e) {
      return Result.err(StorageFailure('Failed to persist locale: $e'));
    }
  }

  /// Dispose resources
  void dispose() {
    _localeController.close();
  }
}
