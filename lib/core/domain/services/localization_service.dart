// EduLift Mobile - Localization Service Interface (Domain Layer)
// Abstract interface for application localization

import 'dart:async';
import '../../utils/result.dart';
import '../../errors/failures.dart';
import '../entities/locale_info.dart';

/// Service interface for handling application localization
/// This belongs in the domain layer as it defines business rules for localization
abstract class LocalizationService {
  /// Get current locale
  Future<Result<LocaleInfo, Failure>> getCurrentLocale();

  /// Get all supported locales
  List<LocaleInfo> getSupportedLocales();

  /// Change locale and persist the selection
  Future<Result<LocaleInfo, Failure>> setLocale(LocaleInfo locale);

  /// Check if locale is supported
  bool isLocaleSupported(LocaleInfo locale);

  /// Stream of locale changes
  Stream<LocaleInfo> get localeChanges;
}
