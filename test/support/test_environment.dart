// Flutter Test Environment Configuration (2025 Best Practices)
//
// Provides centralized test environment setup following Flutter testing guidelines:
// - Memory management
// - Test data isolation
// - Service locator cleanup
// - Performance monitoring
// - Widget test app creation with provider overrides
// - Accessibility testing setup

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import consolidated mock classes
import '../test_mocks/generated_mocks.mocks.dart';

// Import localization support
import 'package:edulift/generated/l10n/app_localizations.dart';

import 'test_di_config.dart';
import 'test_router_config.dart';

/// Test environment configuration and lifecycle management
class TestEnvironment {
  static bool _initialized = false;
  static late Directory _testDataDirectory;

  /// Initialize test environment with 2025 standards
  static Future<void> initialize() async {
    if (_initialized) return;

    // Ensure Flutter test binding
    TestWidgetsFlutterBinding.ensureInitialized();

    // Setup test data directory
    _testDataDirectory = await _createTestDataDirectory();

    // Configure test services
    await _configureTestServices();

    // Setup test dependencies
    TestDIConfig.setupTestDependencies();

    _initialized = true;
  }

  /// Create test app wrapper with provider overrides (2025 Standard)
  static Widget createTestApp({
    required Widget child,
    List<Override> providerOverrides = const [],
    ThemeData? theme,
    Locale? locale,
    bool useRouter = false,
    GoRouter? customRouter,
    String? initialRoute,
  }) {
    if (useRouter || customRouter != null) {
      // Create router-enabled test app for GoRouter context
      final router =
          customRouter ??
          TestRouterConfig.createTestRouter(
            initialLocation: initialRoute ?? '/',
          );

      return ProviderScope(
        overrides: providerOverrides,
        child: MaterialApp.router(
          routerConfig: router,
          theme: theme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          builder: (context, routerChild) {
            // Insert the test widget into the router context
            return child;
          },
        ),
      );
    }

    // Legacy mode: simple MaterialApp without router
    return ProviderScope(
      overrides: providerOverrides,
      child: MaterialApp(
        home: child,
        theme: theme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Disable animations for consistent testing
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  /// Create test app specifically for widgets requiring GoRouter context
  static Widget createRouterTestApp({
    required Widget child,
    List<Override> providerOverrides = const [],
    ThemeData? theme,
    Locale? locale,
    String initialRoute = '/',
    GoRouter? customRouter,
  }) {
    final router =
        customRouter ??
        TestRouterConfig.createTestRouter(initialLocation: initialRoute);

    return ProviderScope(
      overrides: providerOverrides,
      child: MaterialApp.router(
        routerConfig: router,
        theme: theme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        builder: (context, routerChild) {
          // Provide GoRouter context to the child widget
          return child;
        },
      ),
    );
  }

  /// Cleanup test environment
  static Future<void> cleanup() async {
    if (!_initialized) return;

    // Clean up service locator
    try {
      await TestDIConfig.cleanup();
    } catch (e) {
      // Ignore cleanup errors
    }

    // Clean up test data directory
    if (_testDataDirectory.existsSync()) {
      try {
        await _testDataDirectory.delete(recursive: true);
      } catch (e) {
        // Ignore cleanup errors
      }
    }

    _initialized = false;
  }

  /// Create widget test app wrapper - alias for createTestApp for backwards compatibility
  static Widget createWidgetTestApp({
    required Widget child,
    List<Override> providerOverrides = const [],
    ThemeData? theme,
    Locale? locale,
    bool useRouter = false,
    GoRouter? customRouter,
    String? initialRoute,
  }) {
    return createTestApp(
      child: child,
      providerOverrides: providerOverrides,
      theme: theme,
      locale: locale,
      useRouter: useRouter,
      customRouter: customRouter,
      initialRoute: initialRoute,
    );
  }

  /// Get test data directory for test file storage
  static Directory get testDataDirectory => _testDataDirectory;

  /// Create isolated test data directory
  static Future<Directory> _createTestDataDirectory() async {
    final tempDir = Directory.systemTemp;
    final testDir = Directory(
      '${tempDir.path}/flutter_test_${DateTime.now().millisecondsSinceEpoch}',
    );
    await testDir.create(recursive: true);
    return testDir;
  }

  /// Configure test-specific services (2025 Standards)
  static Future<void> _configureTestServices() async {
    // Configure HTTP client for testing
    HttpOverrides.global = _TestHttpOverrides();

    // Setup accessibility testing
    await _setupAccessibilityTesting();

    // Configure performance monitoring
    await _setupPerformanceMonitoring();
  }

  /// Setup accessibility testing environment
  static Future<void> _setupAccessibilityTesting() async {
    // Enable semantics by default for all tests
    WidgetsBinding.instance.ensureSemantics();
  }

  /// Setup performance monitoring for tests
  static Future<void> _setupPerformanceMonitoring() async {
    // Configure timeline for performance tests
    // This is a placeholder for actual performance monitoring setup
  }
}

/// Test-specific HTTP overrides
class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) =>
          true; // Allow self-signed certs in tests
  }
}

/// Provider-specific test patterns and utilities
class FamilyProviderTestUtils {
  /// Create overrides for FamilyNotifier testing
  static List<Override> createFamilyProviderOverrides({
    MockGetFamilyUsecase? mockGetFamilyUsecase,
    // REMOVED: MockAddChildUsecase, MockUpdateChildUsecase, MockRemoveChildUsecase per consolidation plan
    // These have been replaced with ChildrenService
    // Note: Children operations are now part of FamilyRepository
    MockInvitationRepository? mockInvitationRepository,
  }) {
    return [
      // Create provider overrides here when family provider is converted to proper StateNotifierProvider
      // For now, the tests manually instantiate TestableFamilyNotifier
    ];
  }

  /// Validate family state transitions (simplified without FamilyState dependency)
  static void validateFamilyStateTransition({
    required String operation,
    required bool expectingLoad,
    required bool actualLoad,
    String? additionalContext,
  }) {
    if (expectingLoad != actualLoad) {
      throw StateError(
        'Loading state mismatch for $operation: expected $expectingLoad, got $actualLoad. $additionalContext',
      );
    }
  }
}

/// Vehicles provider test utilities
class VehiclesProviderTestUtils {
  /// Create overrides for VehiclesNotifier testing
  static List<Override> createVehiclesProviderOverrides() {
    return [
      // Create provider overrides here when vehicles provider is converted to proper StateNotifierProvider
    ];
  }
}

/// Provider test result validation utilities
class ProviderTestValidation {
  /// Validate that provider operations completed successfully
  static void validateSuccessfulOperation({
    required String operationName,
    required bool operationCompleted,
    required bool stateUpdated,
    String? additionalContext,
  }) {
    if (!operationCompleted) {
      throw StateError(
        'Operation $operationName did not complete successfully. $additionalContext',
      );
    }

    if (!stateUpdated) {
      throw StateError(
        'State was not updated after $operationName. $additionalContext',
      );
    }
  }

  /// Validate error handling in provider operations
  static void validateErrorHandling({
    required String operationName,
    required bool errorOccurred,
    required bool errorStateSet,
    required bool loadingStateCleared,
    String? expectedErrorMessage,
  }) {
    if (!errorOccurred) {
      throw StateError('Expected error did not occur for $operationName');
    }

    if (!errorStateSet) {
      throw StateError('Error state was not set after $operationName failure');
    }

    if (!loadingStateCleared) {
      throw StateError(
        'Loading state was not cleared after $operationName failure',
      );
    }
  }

  /// Validate provider state consistency
  static void validateStateConsistency<T>({
    required T state,
    required bool Function(T) isConsistent,
    required String stateDescription,
  }) {
    if (!isConsistent(state)) {
      throw StateError('State inconsistency detected: $stateDescription');
    }
  }
}

/// Enhanced provider test utilities for better Riverpod integration
class ProviderTestHelper {
  /// Create a test container with proper overrides for provider testing
  static ProviderContainer createTestContainer({
    List<Override> overrides = const [],
  }) {
    return ProviderContainer(
      overrides: [
        // Core test overrides that should always be present
        ...TestDIConfig.getTestProviderOverrides(),
        // Additional test-specific overrides
        ...overrides,
      ],
    );
  }

  /// Create a widget for testing providers with proper scope setup
  static Widget createProviderTestWidget({
    required Widget child,
    List<Override> overrides = const [],
    ProviderContainer? container,
  }) {
    final testContainer =
        container ?? createTestContainer(overrides: overrides);

    return UncontrolledProviderScope(
      container: testContainer,
      child: MaterialApp(
        home: Scaffold(body: child),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  /// Wait for provider state changes to complete
  static Future<void> waitForProviderUpdates([Duration? delay]) async {
    await Future.delayed(delay ?? const Duration(milliseconds: 10));
    // Allow microtasks to complete
    await Future.delayed(Duration.zero);
  }

  /// Safely dispose of provider container with error handling
  static void disposeContainer(ProviderContainer container) {
    try {
      container.dispose();
    } catch (e) {
      // Log but don't fail tests on disposal errors
      debugPrint('Provider container disposal warning: $e');
    }
  }

  /// Create mock overrides for StateNotifierProvider
  static Override createStateNotifierOverride<T extends StateNotifier<S>, S>(
    StateNotifierProvider<T, S> provider,
    T Function(Ref) create,
  ) {
    return provider.overrideWith(create);
  }

  /// Create mock overrides for Provider
  static Override createProviderOverride<T>(Provider<T> provider, T value) {
    return provider.overrideWithValue(value);
  }

  /// Validate provider state transitions
  static void validateStateTransition<T>({
    required T previousState,
    required T currentState,
    required bool Function(T prev, T curr) validator,
    String? message,
  }) {
    final isValid = validator(previousState, currentState);
    if (!isValid) {
      throw StateError(
        message ??
            'Invalid state transition from $previousState to $currentState',
      );
    }
  }
}

/// Base class for provider testing with common patterns
abstract class BaseProviderTest {
  late ProviderContainer container;
  final List<Override> overrides = [];

  /// Override this method to add provider-specific overrides
  List<Override> createOverrides();

  /// Setup method to be called in setUp()
  void setUpProvider() {
    overrides.clear();
    overrides.addAll(createOverrides());
    container = ProviderTestHelper.createTestContainer(overrides: overrides);
  }

  /// Teardown method to be called in tearDown()
  void tearDownProvider() {
    ProviderTestHelper.disposeContainer(container);
  }

  /// Helper to read provider state
  T readProvider<T>(ProviderListenable<T> provider) {
    return container.read(provider);
  }

  /// Helper to listen to provider state changes
  ProviderSubscription<T> listenProvider<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener,
  ) {
    return container.listen<T>(provider, listener);
  }

  /// Wait for async provider operations to complete
  Future<void> waitForAsyncOperation() async {
    await ProviderTestHelper.waitForProviderUpdates();
  }
}

void main() {
  // Test environment is a support utility - no direct tests needed
  // This file provides centralized test environment configuration
}
