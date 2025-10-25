// Domain entity for locale information
// Replaces Flutter's Locale to maintain domain layer purity

import 'package:equatable/equatable.dart';

/// Domain representation of locale information
/// Maintains independence from Flutter framework
class LocaleInfo extends Equatable {
  final String languageCode;
  final String? countryCode;
  final String? scriptCode;

  const LocaleInfo({
    required this.languageCode,
    this.countryCode,
    this.scriptCode,
  });

  /// Create locale from language code only
  const LocaleInfo.fromLanguageCode(String languageCode)
      : this(languageCode: languageCode);

  /// Create locale from language and country codes
  const LocaleInfo.fromSubtags({
    required String languageCode,
    String? countryCode,
    String? scriptCode,
  }) : this(
          languageCode: languageCode,
          countryCode: countryCode,
          scriptCode: scriptCode,
        );

  /// Convert to string representation
  String toLanguageTag() {
    final buffer = StringBuffer(languageCode);
    if (scriptCode != null) {
      buffer.write('-$scriptCode');
    }
    if (countryCode != null) {
      buffer.write('-$countryCode');
    }
    return buffer.toString();
  }

  @override
  String toString() => toLanguageTag();

  @override
  List<Object?> get props => [languageCode, countryCode, scriptCode];

  /// Check if this locale matches another (ignoring script code)
  bool matches(LocaleInfo other) {
    return languageCode == other.languageCode &&
        countryCode == other.countryCode;
  }

  /// Check if this locale has the same language
  bool hasSameLanguage(LocaleInfo other) {
    return languageCode == other.languageCode;
  }
}
