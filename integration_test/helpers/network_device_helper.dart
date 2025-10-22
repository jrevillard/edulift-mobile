// Network Device Helper for E2E Testing
// Provides device-level network control for comprehensive authentication testing
// with real device network conditions

// IMPORTANT: This helper requires:
// - Real device testing for full functionality
// - Proper device permissions for network control
// - Platform-specific network management capabilities

// Coverage:
// - Airplane mode simulation (complete offline)
// - WiFi-only and cellular-only scenarios
// - Network transition testing
// - Network resilience validation

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:patrol/patrol.dart';

/// Helper class for device-level network control in E2E tests
///
/// This helper provides realistic network testing scenarios by controlling
/// actual device network settings. It enables comprehensive testing of:
/// - Offline behavior and error handling
/// - Network recovery and retry mechanisms
/// - Different connectivity scenarios (WiFi-only, cellular-only)
/// - Network transitions and resilience
///
/// Usage:
/// ```dart
/// // Simulate complete network failure
/// await NetworkDeviceHelper.enableAirplaneMode($);
///
/// // Test app behavior with no network
/// await $.tap(find.byKey(const Key('login_button')));
/// await $.waitUntilVisible(find.textContaining('offline'));
///
/// // Restore normal network conditions
/// await NetworkDeviceHelper.resetToNormalNetwork($);
/// ```
class NetworkDeviceHelper {
  static bool _isAirplaneModeEnabled = false;
  static bool _isWifiDisabled = false;
  static bool _isCellularDisabled = false;

  /// Enable airplane mode to simulate complete network unavailability
  /// This provides the most realistic offline testing scenario
  static Future<void> enableAirplaneMode(PatrolIntegrationTester patrol) async {
    try {
      await patrol.native.enableAirplaneMode();
      _isAirplaneModeEnabled = true;
      _isWifiDisabled = true;
      _isCellularDisabled = true;

      if (kDebugMode) {
        print('✈️ NetworkDevice: Airplane mode enabled (real device)');
      }

      // Wait a moment for the network state to propagate
      await Future.delayed(const Duration(milliseconds: 1500));
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ NetworkDevice: Failed to enable airplane mode: $e');
        print('   This may require manual device permissions or may not be supported on this platform');
      }
      rethrow;
    }
  }

  /// Disable airplane mode to restore network connectivity
  /// This returns the device to normal network operation
  static Future<void> disableAirplaneMode(PatrolIntegrationTester patrol) async {
    try {
      await patrol.native.disableAirplaneMode();
      _isAirplaneModeEnabled = false;
      _isWifiDisabled = false;
      _isCellularDisabled = false;

      if (kDebugMode) {
        print('📶 NetworkDevice: Airplane mode disabled (real device)');
      }

      // Wait for network connectivity to be restored
      await Future.delayed(const Duration(milliseconds: 2000));
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ NetworkDevice: Failed to disable airplane mode: $e');
      }
      rethrow;
    }
  }

  /// Disable WiFi while keeping cellular active
  /// This simulates cellular-only network scenarios
  static Future<void> disableWifi(PatrolIntegrationTester patrol) async {
    try {
      await patrol.native.disableWifi();
      _isWifiDisabled = true;

      if (kDebugMode) {
        print('📱 NetworkDevice: WiFi disabled, cellular available');
      }

      // Wait for the network change to propagate
      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ NetworkDevice: Failed to disable WiFi: $e');
      }
      rethrow;
    }
  }

  /// Enable WiFi to restore WiFi connectivity
  /// This reactivates WiFi network access
  static Future<void> enableWifi(PatrolIntegrationTester patrol) async {
    try {
      await patrol.native.enableWifi();
      _isWifiDisabled = false;

      if (kDebugMode) {
        print('📶 NetworkDevice: WiFi enabled');
      }

      // Wait for WiFi to connect and stabilize
      await Future.delayed(const Duration(milliseconds: 2000));
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ NetworkDevice: Failed to enable WiFi: $e');
      }
      rethrow;
    }
  }

  /// Disable cellular while keeping WiFi active
  /// This simulates WiFi-only network scenarios
  static Future<void> disableCellular(PatrolIntegrationTester patrol) async {
    try {
      await patrol.native.disableCellular();
      _isCellularDisabled = true;

      if (kDebugMode) {
        print('📶 NetworkDevice: Cellular disabled, WiFi available');
      }

      // Wait for the network change to propagate
      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ NetworkDevice: Failed to disable cellular: $e');
      }
      rethrow;
    }
  }

  /// Enable cellular to restore cellular connectivity
  /// This reactivates cellular network access
  static Future<void> enableCellular(PatrolIntegrationTester patrol) async {
    try {
      await patrol.native.enableCellular();
      _isCellularDisabled = false;

      if (kDebugMode) {
        print('📱 NetworkDevice: Cellular enabled');
      }

      // Wait for cellular to connect and stabilize
      await Future.delayed(const Duration(milliseconds: 2000));
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ NetworkDevice: Failed to enable cellular: $e');
      }
      rethrow;
    }
  }

  /// Reset all network settings to normal operation
  /// This ensures both WiFi and cellular are enabled and airplane mode is off
  static Future<void> resetToNormalNetwork(PatrolIntegrationTester patrol) async {
    if (kDebugMode) {
      print('🔄 NetworkDevice: Resetting to normal network state...');
    }

    try {
      if (_isAirplaneModeEnabled) {
        await disableAirplaneMode(patrol);
      }

      if (_isWifiDisabled) {
        await enableWifi(patrol);
      }

      if (_isCellularDisabled) {
        await enableCellular(patrol);
      }

      if (kDebugMode) {
        print('✅ NetworkDevice: Reset to normal network complete');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ NetworkDevice: Failed to reset network state: $e');
      }
      rethrow;
    }
  }

  /// Simulate network hiccup by briefly disconnecting and reconnecting
  /// This tests network resilience and retry mechanisms
  static Future<void> simulateNetworkHiccup(
    PatrolIntegrationTester patrol, {
    Duration disconnectDuration = const Duration(seconds: 3),
  }) async {
    if (kDebugMode) {
      print('🌐 NetworkDevice: Simulating network hiccup...');
    }

    try {
      // Brief airplane mode to simulate hiccup
      await enableAirplaneMode(patrol);
      await Future.delayed(disconnectDuration);
      await disableAirplaneMode(patrol);

      if (kDebugMode) {
        print('✅ NetworkDevice: Network hiccup simulation complete');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ NetworkDevice: Network hiccup simulation failed: $e');
      }
      rethrow;
    }
  }

  /// Simulate network transition between different connection types
  /// This tests how the app handles network type changes
  static Future<void> simulateNetworkTransition(
    PatrolIntegrationTester patrol, {
    Duration transitionDelay = const Duration(seconds: 2),
  }) async {
    if (kDebugMode) {
      print('🔄 NetworkDevice: Simulating network transition...');
    }

    try {
      // Start with WiFi only
      await disableCellular(patrol);
      await Future.delayed(transitionDelay);

      // Switch to cellular only
      await disableWifi(patrol);
      await enableCellular(patrol);
      await Future.delayed(transitionDelay);

      // Back to both
      await enableWifi(patrol);

      if (kDebugMode) {
        print('✅ NetworkDevice: Network transition simulation complete');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ NetworkDevice: Network transition simulation failed: $e');
      }
      rethrow;
    }
  }

  /// Get current network device state
  static NetworkDeviceState get currentState {
    return NetworkDeviceState(
      isAirplaneModeEnabled: _isAirplaneModeEnabled,
      isWifiDisabled: _isWifiDisabled,
      isCellularDisabled: _isCellularDisabled,
    );
  }

  /// Get human-readable description of current network state
  static String getStateDescription() {
    final state = currentState;
    if (state.isAirplaneModeEnabled) {
      return 'Airplane Mode (No Network)';
    }
    if (state.isWifiDisabled && state.isCellularDisabled) {
      return 'No Network Available';
    }
    if (state.isWifiDisabled) {
      return 'Cellular Only';
    }
    if (state.isCellularDisabled) {
      return 'WiFi Only';
    }
    return 'Full Network (WiFi + Cellular)';
  }

  /// Wait for network connectivity to be restored
  /// This is useful after network changes to ensure the device is ready
  static Future<void> waitForNetworkConnectivity(
    PatrolIntegrationTester patrol, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (kDebugMode) {
      print('⏳ NetworkDevice: Waiting for network connectivity...');
    }

    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      if (!currentState.isCompletelyOffline) {
        if (kDebugMode) {
          print('✅ NetworkDevice: Network connectivity restored');
        }
        return;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    throw TimeoutException(
      'Network connectivity not restored within ${timeout.inSeconds} seconds',
      timeout,
    );
  }
}

/// Represents the current network device state
class NetworkDeviceState {
  final bool isAirplaneModeEnabled;
  final bool isWifiDisabled;
  final bool isCellularDisabled;

  const NetworkDeviceState({
    required this.isAirplaneModeEnabled,
    required this.isWifiDisabled,
    required this.isCellularDisabled,
  });

  /// Whether any network connection is available
  bool get hasAnyNetworkEnabled =>
      !isAirplaneModeEnabled && (!isWifiDisabled || !isCellularDisabled);

  /// Whether the device is completely offline
  bool get isCompletelyOffline =>
      isAirplaneModeEnabled || (isWifiDisabled && isCellularDisabled);

  @override
  String toString() {
    if (isAirplaneModeEnabled) return 'Airplane Mode';
    if (isWifiDisabled && isCellularDisabled) return 'No Network';
    if (isWifiDisabled) return 'Cellular Only';
    if (isCellularDisabled) return 'WiFi Only';
    return 'Full Network';
  }
}

/// Extension methods for easier network testing scenarios
extension NetworkDeviceTestExtensions on NetworkDeviceHelper {
  /// Quick setup for offline mode testing
  static Future<void> simulateOfflineMode(PatrolIntegrationTester patrol) async {
    await NetworkDeviceHelper.enableAirplaneMode(patrol);
  }

  /// Quick setup for WiFi-only testing
  static Future<void> simulateWifiOnlyMode(PatrolIntegrationTester patrol) async {
    await NetworkDeviceHelper.disableCellular(patrol);
  }

  /// Quick setup for cellular-only testing
  static Future<void> simulateCellularOnlyMode(PatrolIntegrationTester patrol) async {
    await NetworkDeviceHelper.disableWifi(patrol);
  }

  /// Quick setup for poor connectivity testing
  static Future<void> simulatePoorConnectivity(PatrolIntegrationTester patrol) async {
    await NetworkDeviceHelper.simulateNetworkHiccup(
      patrol,
      disconnectDuration: const Duration(seconds: 2),
    );
  }
}

/// Debug utilities for network device testing
class NetworkDeviceDebug {
  /// Print current network state for debugging
  static void printCurrentState() {
    final state = NetworkDeviceHelper.currentState;
    if (kDebugMode) {
      print('🔍 NetworkDevice State: ${state.toString()}');
      print('   Airplane Mode: ${state.isAirplaneModeEnabled}');
      print('   WiFi Disabled: ${state.isWifiDisabled}');
      print('   Cellular Disabled: ${state.isCellularDisabled}');
      print('   Has Network: ${state.hasAnyNetworkEnabled}');
      print('   Completely Offline: ${state.isCompletelyOffline}');
    }
  }

  /// Validate that device controls are working as expected
  static Future<bool> validateDeviceControls(PatrolIntegrationTester patrol) async {
    if (kDebugMode) {
      print('🧪 NetworkDevice: Running validation tests...');
    }

    try {
      // Test airplane mode
      await NetworkDeviceHelper.enableAirplaneMode(patrol);
      if (!NetworkDeviceHelper.currentState.isCompletelyOffline) {
        if (kDebugMode) print('❌ Airplane mode validation failed');
        return false;
      }

      await NetworkDeviceHelper.disableAirplaneMode(patrol);
      if (NetworkDeviceHelper.currentState.isCompletelyOffline) {
        if (kDebugMode) print('❌ Airplane mode disable validation failed');
        return false;
      }

      if (kDebugMode) print('✅ NetworkDevice: All validations passed');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ NetworkDevice: Validation failed: $e');
      return false;
    }
  }
}