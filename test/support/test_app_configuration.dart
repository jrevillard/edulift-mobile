import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

/// Configuration de test professionnelle pour les widgets avec localisations complètes
///
/// Résout les problèmes de localisations dans les tests widgets en fournissant:
/// - ProviderScope pour les widgets Consumer (Riverpod)
/// - AppLocalizations correctement configurées
/// - Support multi-langues (fr/en)
/// - Initialisation automatique des formats de date
///
/// Usage:
/// ```dart
/// await TestAppConfiguration.initialize();
///
/// await tester.pumpWidget(
///   TestAppConfiguration.createTestWidget(
///     child: YourWidget(),
///     locale: 'fr', // optionnel, par défaut 'fr'
///   ),
/// );
/// ```
class TestAppConfiguration {
  static bool _isInitialized = false;

  /// Initialise tous les prérequis pour les tests avec localisations
  /// Doit être appelée dans setUpAll() ou setUp() des tests
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialiser les formats de date pour les langues supportées
      await initializeDateFormatting('fr_FR');
      await initializeDateFormatting('en_US');

      // Initialiser d'autres locales si nécessaire
      await initializeDateFormatting('fr');
      await initializeDateFormatting('en');

      _isInitialized = true;
    } catch (e) {
      // En cas d'erreur, on continue quand même
      // Les tests fonctionneront même avec une initialisation partielle
      _isInitialized = true;
    }
  }

  /// Réinitialise l'état d'initialisation (pour les tests isolés)
  static void reset() {
    _isInitialized = false;
  }

  /// Crée un widget de test complet avec ProviderScope et localisations
  ///
  /// [child] Le widget à tester
  /// [locale] La locale à utiliser ('fr' ou 'en')
  /// [useScaffold] Si true, enveloppe le widget dans un Scaffold
  /// [theme] Thème personnalisé optionnel
  static Widget createTestWidget({
    required Widget child,
    String locale = 'fr',
    bool useScaffold = true,
    ThemeData? theme,
  }) {
    final testLocale = Locale(locale);

    var wrappedChild = child;

    // Envelopper dans un Scaffold si demandé
    if (useScaffold) {
      wrappedChild = Scaffold(body: child);
    }

    // Créer le MaterialApp avec localisations complètes
    final materialApp = MaterialApp(
      locale: testLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('fr', '')],
      theme: theme,
      home: wrappedChild,
      debugShowCheckedModeBanner:
          false, // Éviter la bannière de debug dans les tests
    );

    // Envelopper dans ProviderScope pour les widgets Consumer
    return ProviderScope(child: materialApp);
  }

  /// Crée un widget de test sans Scaffold (pour les widgets qui ont déjà leur propre structure)
  static Widget createBareTestWidget({
    required Widget child,
    String locale = 'fr',
    ThemeData? theme,
  }) {
    return createTestWidget(
      child: child,
      locale: locale,
      useScaffold: false,
      theme: theme,
    );
  }

  /// Crée un widget de test avec MediaQuery personnalisée (pour les tests responsives)
  static Widget createResponsiveTestWidget({
    required Widget child,
    String locale = 'fr',
    Size screenSize = const Size(375, 667), // Taille mobile par défaut
    double textScaleFactor = 1.0,
  }) {
    return ProviderScope(
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', ''), Locale('fr', '')],
        home: MediaQuery(
          data: MediaQueryData(
            size: screenSize,
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: Scaffold(body: child),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
