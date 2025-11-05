import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
    AppLogger.info(
      '🎯 Bootstrap: Starting with ${config.environmentName} environment',
    );
    AppLogger.info('📱 App: ${config.appName}');
    // Avoid logging sensitive URLs in debug logs - use AppLogger for security
    AppLogger.info('📊 Log Level: ${config.logLevel}');
    AppLogger.info('🔥 Firebase: ${config.firebaseEnabled}');
    if (config.environmentName == 'e2e') {
      AppLogger.info('📧 Mailpit available');
    }
  }

  // Initialize Firebase based on configuration
  var firebaseInitialized = false;
  if (config.firebaseEnabled) {
    try {
      // Firebase.initializeApp() automatically uses the correct google-services.json
      // file based on the build flavor without needing hardcoded options
      await Firebase.initializeApp();
      firebaseInitialized = true;

      // Initialize persistent logging system AFTER Firebase
      await AppLogger.initialize();

      // Initialize enhanced Flutter error handling with context tracking
      AppLogger.initializeFlutterErrorHandling();

      AppLogger.info('✅ Firebase initialized successfully');
      AppLogger.info('🔥 Crashlytics enabled: ${FeatureFlags.crashReporting}');
      AppLogger.info('📊 Enhanced Flutter error handling activated');
    } catch (e) {
      AppLogger.warning('⚠️ Firebase initialization failed: $e');
      firebaseInitialized = false;
    }

    // UNIFIED ASYNC ERROR HANDLER - Always active for maximum robustness
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.error('Uncaught async error', error, stack);

      // Report to Firebase only if initialized and enabled
      if (firebaseInitialized && FeatureFlags.crashReporting) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }

      return true; // Mark error as handled
    };
  } else {
    // Initialize AppLogger for non-Firebase environments (tests, development, e2e)
    await AppLogger.initialize();

    // Initialize enhanced Flutter error handling even without Firebase
    AppLogger.initializeFlutterErrorHandling();

    // Log environment-specific Firebase skip message
    AppLogger.info(
      '🔧 ${config.environmentName} mode: Skipping Firebase initialization',
    );
    AppLogger.info('📊 Enhanced Flutter error handling activated (local only)');
  }

  AppLogger.info(
    '✅ App starting with ${config.environmentName} environment\n'
    '📱 App: ${config.appName}\n'
    '📊 Log Level: ${config.logLevel}',
  );

  // Log configuration details using appropriate log levels
  // Use DEBUG level for sensitive information (API URLs) and INFO for general startup
  if (config.loggerLogLevel.index <= Level.debug.index) {
    AppLogger.debug('📍 API Base URL: ${config.apiBaseUrl}');
    AppLogger.debug('🌐 WebSocket URL: ${config.websocketUrl}');
    AppLogger.debug('Feature Flags Configuration:');
    FeatureFlags.logConfiguration();
  }

  // Note: Error handling is now unified above to prevent FlutterError.onError conflicts
  // The unified handlers automatically adapt based on FeatureFlags.crashReporting and debug mode

  // Handle errors in isolates - CRITICAL FIX: Always log errors regardless of Firebase status
  // Firebase reporting is conditional inside the listener, but error capture should be universal
  // Skip isolate error listeners only in test environments to prevent interference with test runners
  final shouldEnableIsolateErrorListener = config.environmentName != 'test';

  if (shouldEnableIsolateErrorListener) {
    Isolate.current.addErrorListener(
      RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;
        final error = errorAndStacktrace.first;

        // RESILIENCE FIX: Defensive parsing of isolate stack trace to prevent handler crashes
        // Validate that we have a proper stack trace before parsing to avoid index errors
        StackTrace? stackTrace;
        if (errorAndStacktrace.length > 1 &&
            errorAndStacktrace.last != null &&
            errorAndStacktrace.last.toString().isNotEmpty) {
          try {
            stackTrace = StackTrace.fromString(
              errorAndStacktrace.last.toString(),
            );
          } catch (e) {
            // If stack trace parsing fails, log the parsing error but don't crash the handler
            AppLogger.warning('Failed to parse isolate stack trace', e);
            stackTrace = null;
          }
        }

        AppLogger.error('Isolate error: $error', error, stackTrace);

        // Report isolate errors to Firebase based on feature flags
        if (firebaseInitialized && FeatureFlags.crashReporting) {
          await FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace,
            fatal: true,
          );
        }
      }).sendPort,
    );
  }

  // Note: Logger configuration is now centralized in AppLogger.initialize()
  // AppLogger handles debug/production level configuration automatically

  // Create the container that will hold all our providers
  // Create ProviderContainer with configuration override
  final container = ProviderContainer(
    overrides: [
      // Override the appConfig provider with our configuration
      appConfigProvider.overrideWithValue(config),
    ],
  );

  try {
    // Initialize critical services with performance optimization
    // IMPORTANT: The container keeps these services alive unlike the old anti-pattern

    // 🚀 PERFORMANCE OPTIMIZATION: Parallel initialization of independent services
    // These services can be initialized concurrently as they don't depend on each other
    // OBSERVABILITY FIX: Added specific error logging for each service to improve debugging
    final parallelInitializationFuture = Future.wait([
      // Initialize timezone database for proper datetime handling
      TimezoneService.initialize()
          .then((_) {
            AppLogger.info('✅ TimezoneService initialized successfully');
          })
          .catchError((e, stackTrace) {
            AppLogger.error(
              '❌ TimezoneService initialization failed',
              e,
              stackTrace,
            );
            // Re-throw to fail the bootstrap process - critical service
            throw e;
          }),

      // Initialize HiveOrchestrator with encryption enabled (independent service)
      container
          .read(hiveOrchestratorProvider)
          .initialize()
          .then((_) {
            AppLogger.info('✅ HiveOrchestrator initialized successfully');
          })
          .catchError((e, stackTrace) {
            AppLogger.error(
              '❌ HiveOrchestrator initialization failed',
              e,
              stackTrace,
            );
            // Re-throw to fail the bootstrap process - critical service
            throw e;
          }),

      // Initialize DeepLinkService for multi-platform magic links (independent service)
      container
          .read(deepLinkServiceProvider)
          .initialize()
          .then((_) {
            AppLogger.info('✅ DeepLinkService initialized successfully');
          })
          .catchError((e, stackTrace) {
            AppLogger.error(
              '❌ DeepLinkService initialization failed',
              e,
              stackTrace,
            );
            // Re-throw to fail the bootstrap process - critical service
            throw e;
          }),
    ]);

    // Execute parallel initialization
    await parallelInitializationFuture;

    // 🔗 ARCHITECTURAL NOTE: TimezoneService.checkAndSyncTimezone(authService) dependency
    // This is a temporary architectural constraint - TimezoneService currently uses static methods
    // and requires manual dependency injection (authService). This breaks the Riverpod pattern.
    //
    // TODO: MIGRATION PLAN - Convert TimezoneService to Riverpod provider:
    // 1. Convert static methods to instance methods
    // 2. Create timezoneServiceProvider in DI that depends on authServiceProvider
    // 3. Remove manual dependency injection from bootstrap
    // 4. Update all TimezoneService calls throughout the app to use the provider
    //
    // Current pattern (anti-pattern):
    //   TimezoneService.checkAndSyncTimezone(authService)
    //
    // Target pattern (clean architecture):
    //   await container.read(timezoneServiceProvider).checkAndSyncTimezone()
    final authService = container.read(authServiceProvider);
    final timezoneSynced = await TimezoneService.checkAndSyncTimezone(
      authService,
    );
    if (timezoneSynced) {
      AppLogger.info('✅ Timezone auto-synced on startup');
    }

    // REMOVED: UserFamilyExtension - Clean Architecture violation eliminated
    // Family data now accessed directly via UserFamilyService
    AppLogger.info(
      '✅ Bootstrap completed successfully with optimized parallel initialization',
    );
  } catch (e) {
    AppLogger.error('❌ Service initialization failed during bootstrap', e);
    container.dispose(); // Clean up on failure
    rethrow;
  }

  // CRITICAL: Return the container WITHOUT disposing it
  // The container's lifecycle will be managed by UncontrolledProviderScope
  return container;
}
