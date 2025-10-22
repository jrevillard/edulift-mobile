// Universal Test Widget Pattern - Expert Recommendation
// Provides consistent widget testing infrastructure with proper provider overrides
// Follows expert-recommended patterns for systematic test fixes

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:edulift/generated/l10n/app_localizations.dart';
import 'test_provider_overrides.dart';

/// Universal test widget factory following expert recommendations
/// This provides consistent testing infrastructure across all tests
class UniversalTestWidget {
  /// Create a standard test app with proper provider overrides
  /// Use this for most widget tests that don't require navigation
  static Widget createApp({
    required Widget child,
    List<Override>? additionalOverrides,
  }) {
    return ProviderScope(
      overrides: [...TestProviderOverrides.common, ...?additionalOverrides],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  /// Create a test app with router for navigation tests
  /// Use this for tests that need to test navigation behavior
  static Widget createAppWithRouter({
    required Widget child,
    List<Override>? additionalOverrides,
    String initialLocation = '/',
  }) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
          routes: [
            GoRoute(
              path: '/secondary',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Secondary Page'))),
            ),
          ],
        ),
      ],
      initialLocation: initialLocation,
    );

    return ProviderScope(
      overrides: [...TestProviderOverrides.common, ...?additionalOverrides],
      child: MaterialApp.router(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  /// Create a test app for pages that already have Scaffold
  /// Use this for page-level tests
  static Widget createPageApp({
    required Widget page,
    List<Override>? additionalOverrides,
  }) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home Page'))),
          routes: [GoRoute(path: '/page', builder: (context, state) => page)],
        ),
      ],
      initialLocation: '/page',
    );

    return ProviderScope(
      overrides: [...TestProviderOverrides.common, ...?additionalOverrides],
      child: MaterialApp.router(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  /// Create a test app with authentication overrides
  /// Use this for tests that specifically need to test auth behavior
  static Widget createAuthApp({
    required Widget child,
    List<Override>? additionalOverrides,
  }) {
    return ProviderScope(
      overrides: [
        ...TestProviderOverrides.authOverrides,
        ...?additionalOverrides,
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  /// Create a test app with family-specific overrides
  /// Use this for family feature tests
  static Widget createFamilyApp({
    required Widget child,
    List<Override>? additionalOverrides,
  }) {
    return ProviderScope(
      overrides: [
        ...TestProviderOverrides.familyOverrides,
        ...?additionalOverrides,
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  /// Create a test app with vehicles-specific overrides
  /// Use this for vehicles feature tests
  static Widget createVehiclesApp({
    required Widget child,
    List<Override>? additionalOverrides,
  }) {
    return ProviderScope(
      overrides: [
        ...TestProviderOverrides.vehiclesOverrides,
        ...?additionalOverrides,
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }
}
