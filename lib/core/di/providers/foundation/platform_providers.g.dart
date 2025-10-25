// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localAuthenticationHash() =>
    r'e51061f5b1d6a1bd524c854a0121bb35c77822d3';

/// Foundation Platform Providers
///
/// Platform-specific service providers that interface with device capabilities
/// like biometric authentication, deep linking, and other native features.
/// Provider for Local Authentication
///
/// Provides biometric authentication capabilities including fingerprint,
/// face recognition, and other platform-specific authentication methods.
///
/// Copied from [localAuthentication].
@ProviderFor(localAuthentication)
final localAuthenticationProvider =
    AutoDisposeProvider<LocalAuthentication>.internal(
  localAuthentication,
  name: r'localAuthenticationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localAuthenticationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalAuthenticationRef = AutoDisposeProviderRef<LocalAuthentication>;
String _$biometricServiceHash() => r'b7b12013c9d84106ca3c0cb418c0f1448a458083';

/// Provider for BiometricService
///
/// Creates BiometricService with LocalAuthentication dependency.
///
/// Copied from [biometricService].
@ProviderFor(biometricService)
final biometricServiceProvider = AutoDisposeProvider<BiometricService>.internal(
  biometricService,
  name: r'biometricServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$biometricServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BiometricServiceRef = AutoDisposeProviderRef<BiometricService>;
String _$deepLinkServiceHash() => r'0d9a2fac5cf951bb0419a28b2147895a7f023745';

/// Provider for DeepLinkService
///
/// SINGLETON PATTERN: Uses getInstance() to prevent multiple instances
/// that cause conflicting protocol handlers and file watchers.
///
/// Copied from [deepLinkService].
@ProviderFor(deepLinkService)
final deepLinkServiceProvider =
    AutoDisposeProvider<domain_deep_link.DeepLinkService>.internal(
  deepLinkService,
  name: r'deepLinkServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deepLinkServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeepLinkServiceRef
    = AutoDisposeProviderRef<domain_deep_link.DeepLinkService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
