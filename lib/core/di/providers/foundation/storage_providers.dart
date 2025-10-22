import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Core services
import '../../../security/crypto_config.dart';
import '../../../security/crypto_service.dart';
import '../../../security/secure_key_manager.dart';
import '../../../storage/adaptive_secure_storage.dart';
import '../../../storage/secure_storage.dart';
import '../../../storage/hive_orchestrator.dart';
import '../../../services/adaptive_storage_service.dart';

part 'storage_providers.g.dart';

/// Foundation Storage Providers
///
/// Core storage infrastructure providers including secure storage,
/// cryptography services, and data persistence.

// =============================================================================
// CRYPTO CONFIGURATION PROVIDER
// =============================================================================

/// Provider for CryptoConfig - matches CryptoModule.cryptoConfig
///
/// Provides crypto configuration with faster settings for debug mode.
@riverpod
CryptoConfig cryptoConfig(Ref ref) {
  // Use faster config for debug mode (including devcontainer)
  if (kDebugMode) {
    return const CryptoConfig(
      pbkdf2Iterations: 10000, // Much faster for development (still secure)
    );
  }
  return CryptoConfig.production;
}

// =============================================================================
// SECURE STORAGE PROVIDERS
// =============================================================================

/// Provider for AdaptiveSecureStorage
///
/// SINGLETON PATTERN: Uses @Riverpod(keepAlive: true) to prevent multiple instances
/// that cause DBus hanging and inconsistent environment detection.
@riverpod
AdaptiveSecureStorage adaptiveSecureStorage(Ref ref) {
  // Riverpod manages singleton behavior - no need for manual getInstance()
  return AdaptiveSecureStorage();
}

/// Provider for SecureStorage (named instance)
///
/// Creates SecureStorage instance for SecureKeyManager dependency.
@riverpod
SecureStorage namedSecureStorage(Ref ref) {
  // Return AdaptiveSecureStorage as SecureStorage interface
  return ref.watch(adaptiveSecureStorageProvider);
}

/// Provider for Shared Preferences
///
/// Provides access to shared preferences for storing application settings.
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}

// =============================================================================
// CORE SERVICE PROVIDERS
// =============================================================================
// REMOVED: ValidationService provider - toxic system eliminated in PHASE 5
// Validation is now handled by domain-specific validators (FamilyFormValidator, etc.)

/// Provider for CryptoService
///
/// Creates CryptoService with CryptoConfig dependency.
@riverpod
CryptoService cryptoService(Ref ref) {
  final config = ref.watch(cryptoConfigProvider);
  return CryptoService(config);
}

/// Provider for SecureKeyManager
///
/// Creates SecureKeyManager with SecureStorage dependency.
@riverpod
SecureKeyManager secureKeyManager(Ref ref) {
  final secureStorage = ref.watch(namedSecureStorageProvider);
  return SecureKeyManager(secureStorage);
}

/// Provider for HiveOrchestrator
///
/// Creates HiveOrchestrator with SecureKeyManager dependency.
@riverpod
HiveOrchestrator hiveOrchestrator(Ref ref) {
  final keyManager = ref.watch(secureKeyManagerProvider);
  return HiveOrchestrator(keyManager);
}

/// Provider for AdaptiveStorageService
///
/// Creates AdaptiveStorageService with all required dependencies.
@riverpod
AdaptiveStorageService adaptiveStorageService(Ref ref) {
  final storage = ref.watch(adaptiveSecureStorageProvider);
  final cryptoService = ref.watch(cryptoServiceProvider);
  final keyManager = ref.watch(secureKeyManagerProvider);

  return AdaptiveStorageService(
    storage: storage,
    cryptoService: cryptoService,
    keyManager: keyManager,
  );
}
