// Network Mocking for Golden Tests
// Provides network override functions for golden tests to prevent real network calls

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global network mock overrides for golden tests
List<Override> _networkMockOverrides = [];

/// Setup golden test network overrides to prevent real network calls
void setupGoldenTestNetworkOverrides() {
  // Store network mock overrides
  _networkMockOverrides = [
    // Add any HTTP client provider overrides here if needed
    // This is a placeholder for future HTTP client provider mocking
  ];
}

/// Get all network mock overrides for golden tests
List<Override> getAllNetworkMockOverrides() {
  return _networkMockOverrides;
}

/// Clear golden test network overrides
void clearGoldenTestNetworkOverrides() {
  _networkMockOverrides.clear();
}