import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../security/biometric_service.dart';
import '../../../services/deep_link_service.dart';
import '../../../domain/services/deep_link_service.dart' as domain_deep_link;

part 'platform_providers.g.dart';

/// Foundation Platform Providers
///
/// Platform-specific service providers that interface with device capabilities
/// like biometric authentication, deep linking, and other native features.

// =============================================================================
// BIOMETRIC AUTHENTICATION PROVIDERS
// =============================================================================

/// Provider for Local Authentication
///
/// Provides biometric authentication capabilities including fingerprint,
/// face recognition, and other platform-specific authentication methods.
@riverpod
LocalAuthentication localAuthentication(Ref ref) {
  return LocalAuthentication();
}

/// Provider for BiometricService
///
/// Creates BiometricService with LocalAuthentication dependency.
@riverpod
BiometricService biometricService(Ref ref) {
  return BiometricService(ref.watch(localAuthenticationProvider));
}

// =============================================================================
// DEEP LINKING PROVIDERS
// =============================================================================

/// Provider for DeepLinkService
///
/// SINGLETON PATTERN: Uses getInstance() to prevent multiple instances
/// that cause conflicting protocol handlers and file watchers.
@riverpod
domain_deep_link.DeepLinkService deepLinkService(Ref ref) {
  // SINGLETON PATTERN: Use getInstance() to prevent multiple protocol handlers
  return DeepLinkServiceImpl.getInstance(); // Keep getInstance() - DeepLinkService has complex file watching
}

// =============================================================================
// FUTURE PLATFORM PROVIDERS
// =============================================================================
// Additional providers for platform-specific services:
// - Device info providers
// - Package info providers
// - Push notification providers
// - Camera/media providers
// - Location providers
// - Permissions providers
