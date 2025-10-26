import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'core/utils/app_logger.dart';
import 'core/services/timezone_service.dart';
import 'core/di/providers/providers.dart';
import 'core/config/environment_config.dart';
import 'core/config/feature_flags.dart';
import 'core/di/providers/foundation/config_providers.dart';
// REMOVED: UserFamilyExtension import - Clean Architecture violation eliminated

/// Bootstrap function that creates and initializes a [ProviderContainer] for the app.
///
/// This is the single source of truth for app initialization.
/// It can be used by both the production `main.dart` and test suites.
///
/// The container returned by this function should be passed to [UncontrolledProviderScope]
/// and should NOT be disposed manually - let the framework handle its lifecycle.
Future<ProviderContainer> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get configuration from environment (dart-define)
  final config = EnvironmentConfig.getConfig();

  if (kDebugMode) {
    debugPrint(
      '🎯 Bootstrap: Starting with ${config.environmentName} environment',
    );
    debugPrint('📱 App: ${config.appName}');
    debugPrint('🔗 API: ${config.apiBaseUrl}');
    debugPrint('🌐 WebSocket: ${config.websocketUrl}');
    debugPrint('🔧 Debug: ${config.debugEnabled}');
    debugPrint('🔥 Firebase: ${config.firebaseEnabled}');
    if (config.environmentName == 'e2e') {
      debugPrint('📧 Mailpit: ${config.mailpitWebUrl}');
    }
  }

  // Initialize Firebase based on configuration
  var firebaseInitialized = false;
  if (config.firebaseEnabled) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseInitialized = true;

      // Initialize persistent logging system AFTER Firebase
      await AppLogger.initialize();

      AppLogger.info('✅ Firebase initialized successfully');

      // Only enable Crashlytics in release mode for production error reporting
      if (kReleaseMode) {
        FlutterError.onError = (FlutterErrorDetails details) {
          // Log to local logger first
          AppLogger.error(
            'Flutter Error: ${details.summary}',
            details.exception,
            details.stack,
          );

          // Report to Firebase Crashlytics in production
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        };

        // Handle async errors that are not caught by Flutter
        PlatformDispatcher.instance.onError = (error, stack) {
          AppLogger.error('Uncaught async error', error, stack);

          // Report to Firebase Crashlytics in production
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

          return true; // Mark error as handled
        };
      } else {
        // Debug mode: only local logging, no Firebase reporting
        AppLogger.info(
          '🔧 Debug mode: Firebase Crashlytics disabled, using local logging only',
        );
      }
    } catch (e) {
      AppLogger.warning('⚠️ Firebase initialization failed: $e');
      firebaseInitialized = false;
    }
  } else {
    // Initialize AppLogger for non-Firebase environments (tests, development, e2e)
    await AppLogger.initialize();

    // Log environment-specific Firebase skip message
    AppLogger.info(
      '🔧 ${config.environmentName} mode: Skipping Firebase initialization',
    );
  }

  AppLogger.info(
    '✅ App starting with ${config.environmentName} environment\n'
    '📱 App: ${config.appName}\n'
    '📍 API Base URL: ${config.apiBaseUrl}\n'
    '🔧 Debug Mode: ${config.debugEnabled}',
  );

  // Log feature flags configuration for debugging
  if (FeatureFlags.verboseLogging) {
    FeatureFlags.logConfiguration();
  }

  // Fallback error handling when Firebase is not available or in debug mode
  if ((!firebaseInitialized || kDebugMode) && config.environmentName != 'e2e') {
    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.error(
        'Flutter Error: ${details.summary}',
        details.exception,
        details.stack,
      );
      // Also report to console for immediate visibility in debug mode
      FlutterError.presentError(details);
    };

    // Handle async errors that are not caught by Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.error('Uncaught async error', error, stack);
      return true; // Mark error as handled
    };
  }

  // Handle errors in isolates (skip in tests to avoid interference)
  if (FeatureFlags.firebaseEnabled) {
    Isolate.current.addErrorListener(
      RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;
        final error = errorAndStacktrace.first;
        final stackTrace = errorAndStacktrace.length > 1
            ? StackTrace.fromString(errorAndStacktrace.last.toString())
            : null;

        AppLogger.error('Isolate error: $error', error, stackTrace);

        // Report isolate errors to Firebase in production
        if (firebaseInitialized && kReleaseMode) {
          await FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace,
            fatal: true,
          );
        }
      }).sendPort,
    );
  }

  // Configure logger for debug mode
  Logger.level = Level.debug;

  // Create the container that will hold all our providers
  // Create ProviderContainer with configuration override
  final container = ProviderContainer(
    overrides: [
      // Override the appConfig provider with our configuration
      appConfigProvider.overrideWithValue(config),
    ],
  );

  try {
    // Initialize critical services - these will be available throughout the app's lifecycle
    // IMPORTANT: The container keeps these services alive unlike the old anti-pattern

    // Initialize timezone database for proper datetime handling
    await TimezoneService.initialize();
    AppLogger.info('✅ TimezoneService initialized successfully');

    // Check and sync timezone if auto-sync is enabled
    // This will only sync if user is logged in and timezone is different
    final authService = container.read(authServiceProvider);
    final timezoneSynced = await TimezoneService.checkAndSyncTimezone(
      authService,
    );
    if (timezoneSynced) {
      AppLogger.info('✅ Timezone auto-synced on startup');
    }

    // Initialize HiveOrchestrator with encryption enabled
    final hiveOrchestrator = container.read(hiveOrchestratorProvider);
    await hiveOrchestrator.initialize();
    AppLogger.info('✅ HiveOrchestrator initialized successfully');

    // Initialize DeepLinkService for multi-platform magic links
    final deepLinkService = container.read(deepLinkServiceProvider);
    await deepLinkService.initialize();
    AppLogger.info('✅ DeepLinkService initialized successfully');

    // REMOVED: UserFamilyExtension - Clean Architecture violation eliminated
    // Family data now accessed directly via UserFamilyService
    AppLogger.info('✅ Bootstrap completed successfully');
  } catch (e) {
    AppLogger.error('❌ Service initialization failed during bootstrap', e);
    container.dispose(); // Clean up on failure
    rethrow;
  }

  // CRITICAL: Return the container WITHOUT disposing it
  // The container's lifecycle will be managed by UncontrolledProviderScope
  return container;
}
