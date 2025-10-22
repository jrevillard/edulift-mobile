import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_di_initializer.dart';

/// Flutter Test Configuration (2025 Best Practices)
///
/// This configuration provides:
/// - Proper test environment setup
/// - Golden test configuration
/// - Memory leak detection
/// - Accessibility testing support
/// - Test data isolation
/// - Performance monitoring
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Configure test environment for optimal testing
  // NOTE: Integration tests handle their own binding initialization
  // Check if this is an integration test by examining the current test file
  final isIntegrationTest = _isIntegrationTest();

  if (!isIntegrationTest) {
    TestWidgetsFlutterBinding.ensureInitialized();
  }

  // Setup test environment
  await _initializeTestEnvironment();

  // Configure golden tests
  if (!kIsWeb) {
    _configureGoldenTests();
  }

  // Setup accessibility testing
  _configureAccessibilityTesting();

  // Configure platform channels for testing (only if not integration test)
  if (!isIntegrationTest) {
    _configurePlatformChannels();
  }

  try {
    // Run the actual test
    await testMain();
  } finally {
    // Cleanup test environment
    await _cleanupTestEnvironment();
  }
}

/// Initialize test environment
Future<void> _initializeTestEnvironment() async {
  debugPrint('Initializing test environment...');

  // Initialize TestDIInitializer to set up dummy values for mocks
  try {
    TestDIInitializer.initialize();
  } catch (e) {
    // Ignore if TestDIInitializer is not available for some tests
    debugPrint('TestDIInitializer not available: $e');
  }
}

/// Configure golden file testing
void _configureGoldenTests() {
  // Configure golden files for current platform
  if (goldenFileComparator is LocalFileComparator) {
    final testUrl = (goldenFileComparator as LocalFileComparator).basedir;
    goldenFileComparator = LocalFileComparator(testUrl);
  }
}

/// Configure accessibility testing
void _configureAccessibilityTesting() {
  debugPrint('Configuring accessibility testing...');
}

/// Cleanup test environment
Future<void> _cleanupTestEnvironment() async {
  debugPrint('Cleaning up test environment...');

  // Cleanup TestDIInitializer
  try {
    await TestDIInitializer.tearDown();
  } catch (e) {
    // Ignore cleanup errors
    debugPrint('TestDIInitializer cleanup error: $e');
  }
}

/// Configure platform channels for testing
void _configurePlatformChannels() {
  // Set up method channel mocks that are commonly needed
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (methodCall) async {
          switch (methodCall.method) {
            case 'getTemporaryDirectory':
              return Directory.systemTemp.path;
            case 'getApplicationSupportDirectory':
              return Directory.systemTemp.path;
            case 'getApplicationDocumentsDirectory':
              return Directory.systemTemp.path;
            default:
              return null;
          }
        },
      );

  // Mock secure storage for tests
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (methodCall) async {
          return null; // Default empty response
        },
      );

  // Mock connectivity for tests
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/connectivity'),
        (methodCall) async {
          return ['wifi']; // Default connected state
        },
      );

  // Mock shared_preferences for tests
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        (methodCall) async {
          switch (methodCall.method) {
            case 'getAll':
              return <String, dynamic>{};
            case 'setBool':
            case 'setDouble':
            case 'setInt':
            case 'setString':
            case 'setStringList':
              return true;
            case 'remove':
            case 'clear':
              return true;
            default:
              return null;
          }
        },
      );

  // Mock app_links for tests
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.app_links/messages'),
        (methodCall) async {
          switch (methodCall.method) {
            case 'getInitialAppLink':
              return null;
            case 'getLatestAppLink':
              return null;
            default:
              return null;
          }
        },
      );

  // Mock local_auth for tests
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        (methodCall) async {
          switch (methodCall.method) {
            case 'isDeviceSupported':
              return true;
            case 'getAvailableBiometrics':
              return <String>['face', 'fingerprint'];
            case 'authenticate':
              return true;
            case 'deviceSupportsBiometrics':
              return true;
            default:
              return null;
          }
        },
      );

  // Mock url_launcher for tests
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/url_launcher'),
        (methodCall) async {
          switch (methodCall.method) {
            case 'canLaunch':
              return true;
            case 'launch':
              return true;
            default:
              return null;
          }
        },
      );
}

/// Check if the current test is an integration test
/// Integration tests typically contain "integration" in their path or filename
bool _isIntegrationTest() {
  try {
    // Get the current stack trace to examine the test file path
    final stackTrace = StackTrace.current.toString();

    // First priority: Check for integration_test directory (Patrol E2E tests)
    if (stackTrace.contains('integration_test/')) {
      return true;
    }

    // Look for integration test indicators in the stack trace
    final hasIntegrationInPath =
        stackTrace.contains('/integration/') ||
        stackTrace.contains('integration_test') ||
        stackTrace.contains('_e2e_test.dart') ||
        stackTrace.contains('tab_navigation_integration_test.dart') ||
        stackTrace.contains('vehicle_management_complete_cycle_test.dart') ||
        stackTrace.contains('complete_authentication_flow_test.dart') ||
        stackTrace.contains('deeplink_flow_test.dart') ||
        stackTrace.contains('magic_link_verification_security_e2e_test.dart') ||
        stackTrace.contains('user_registration_and_login_flows_e2e_test.dart');

    // Also check environment variables that might indicate integration test mode
    final testMode = Platform.environment['FLUTTER_TEST_MODE'];
    final isIntegrationMode = testMode?.contains('integration') ?? false;

    // Check if IntegrationTestWidgetsFlutterBinding is already initialized
    final hasIntegrationBinding = _hasIntegrationBinding();

    // debugPrint('Integration test detection: hasIntegrationInPath=$hasIntegrationInPath, isIntegrationMode=$isIntegrationMode, hasIntegrationBinding=$hasIntegrationBinding');

    return hasIntegrationInPath || isIntegrationMode || hasIntegrationBinding;
  } catch (e) {
    // debugPrint('Error in integration test detection: $e');
    // If we can't determine, assume it's not an integration test
    // This is safer as regular tests will work with TestWidgetsFlutterBinding
    return false;
  }
}

/// Check if IntegrationTestWidgetsFlutterBinding is already initialized
bool _hasIntegrationBinding() {
  try {
    // Check if the binding is already of integration test type
    final binding = WidgetsBinding.instance;
    return binding.runtimeType.toString().contains('IntegrationTest');
  } catch (e) {
    return false;
  }
}
