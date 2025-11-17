import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

/// Utilitaire pour l'initialisation des localisations dans les tests
class TestLocalizationHelper {
  static bool _isInitialized = false;

  /// Initialise les localisations Flutter pour les tests
  /// Doit être appelée dans setUp() des tests qui utilisent DateFormat
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialiser les localisations par défaut utilisées dans l'app
    await initializeDateFormatting('fr_FR');
    await initializeDateFormatting('en_US');

    _isInitialized = true;
  }

  /// Réinitialise l'état d'initialisation (utile pour les tests isolés)
  static void reset() {
    _isInitialized = false;
  }

  /// Crée un MaterialApp avec les localisations configurées pour les tests
  static Widget createLocalizedTestWidget({
    required Widget child,
    Locale locale = const Locale('fr'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('fr', '')],
      home: Scaffold(body: child),
    );
  }

  /// Crée un MaterialApp avec ProviderScope et localisations pour les tests Riverpod
  static Widget createLocalizedTestWidgetWithProvider({
    required Widget child,
    Locale locale = const Locale('fr'),
  }) {
    return ProviderScope(
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', ''), Locale('fr', '')],
        home: Scaffold(body: child),
      ),
    );
  }
}
