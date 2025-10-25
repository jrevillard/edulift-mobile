// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cryptoConfigHash() => r'd3fd853d560fa6736420cae392851476353093c2';

/// Foundation Storage Providers
///
/// Core storage infrastructure providers including secure storage,
/// cryptography services, and data persistence.
/// Provider for CryptoConfig - matches CryptoModule.cryptoConfig
///
/// Provides crypto configuration with faster settings for debug mode.
///
/// Copied from [cryptoConfig].
@ProviderFor(cryptoConfig)
final cryptoConfigProvider = AutoDisposeProvider<CryptoConfig>.internal(
  cryptoConfig,
  name: r'cryptoConfigProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cryptoConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CryptoConfigRef = AutoDisposeProviderRef<CryptoConfig>;
String _$adaptiveSecureStorageHash() =>
    r'b95f1e1ea34190ab079287e4d20a2d7c8ac55b42';

/// Provider for AdaptiveSecureStorage
///
/// SINGLETON PATTERN: Uses @Riverpod(keepAlive: true) to prevent multiple instances
/// that cause DBus hanging and inconsistent environment detection.
///
/// Copied from [adaptiveSecureStorage].
@ProviderFor(adaptiveSecureStorage)
final adaptiveSecureStorageProvider =
    AutoDisposeProvider<AdaptiveSecureStorage>.internal(
  adaptiveSecureStorage,
  name: r'adaptiveSecureStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adaptiveSecureStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdaptiveSecureStorageRef
    = AutoDisposeProviderRef<AdaptiveSecureStorage>;
String _$namedSecureStorageHash() =>
    r'1802219c30a026fc87756ca175b6b0dbe3d4ac2e';

/// Provider for SecureStorage (named instance)
///
/// Creates SecureStorage instance for SecureKeyManager dependency.
///
/// Copied from [namedSecureStorage].
@ProviderFor(namedSecureStorage)
final namedSecureStorageProvider = AutoDisposeProvider<SecureStorage>.internal(
  namedSecureStorage,
  name: r'namedSecureStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$namedSecureStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NamedSecureStorageRef = AutoDisposeProviderRef<SecureStorage>;
String _$sharedPreferencesHash() => r'dc403fbb1d968c7d5ab4ae1721a29ffe173701c7';

/// Provider for Shared Preferences
///
/// Provides access to shared preferences for storing application settings.
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider =
    AutoDisposeFutureProvider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = AutoDisposeFutureProviderRef<SharedPreferences>;
String _$cryptoServiceHash() => r'b3b875ad5b2cb7701430f072732a407c7f5909e1';

/// Provider for CryptoService
///
/// Creates CryptoService with CryptoConfig dependency.
///
/// Copied from [cryptoService].
@ProviderFor(cryptoService)
final cryptoServiceProvider = AutoDisposeProvider<CryptoService>.internal(
  cryptoService,
  name: r'cryptoServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cryptoServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CryptoServiceRef = AutoDisposeProviderRef<CryptoService>;
String _$secureKeyManagerHash() => r'7170eeb124941176fdc4f4fef0c7432faec1a39e';

/// Provider for SecureKeyManager
///
/// Creates SecureKeyManager with SecureStorage dependency.
///
/// Copied from [secureKeyManager].
@ProviderFor(secureKeyManager)
final secureKeyManagerProvider = AutoDisposeProvider<SecureKeyManager>.internal(
  secureKeyManager,
  name: r'secureKeyManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureKeyManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecureKeyManagerRef = AutoDisposeProviderRef<SecureKeyManager>;
String _$hiveOrchestratorHash() => r'9856ac42262e8c9a32d17aaf59d3028b6da6b8b5';

/// Provider for HiveOrchestrator
///
/// Creates HiveOrchestrator with SecureKeyManager dependency.
///
/// Copied from [hiveOrchestrator].
@ProviderFor(hiveOrchestrator)
final hiveOrchestratorProvider = AutoDisposeProvider<HiveOrchestrator>.internal(
  hiveOrchestrator,
  name: r'hiveOrchestratorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hiveOrchestratorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HiveOrchestratorRef = AutoDisposeProviderRef<HiveOrchestrator>;
String _$adaptiveStorageServiceHash() =>
    r'9d8c1930c86a8ee79ad0fe5aa27b266045a8642b';

/// Provider for AdaptiveStorageService
///
/// Creates AdaptiveStorageService with all required dependencies.
///
/// Copied from [adaptiveStorageService].
@ProviderFor(adaptiveStorageService)
final adaptiveStorageServiceProvider =
    AutoDisposeProvider<AdaptiveStorageService>.internal(
  adaptiveStorageService,
  name: r'adaptiveStorageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adaptiveStorageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdaptiveStorageServiceRef
    = AutoDisposeProviderRef<AdaptiveStorageService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
