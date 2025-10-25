// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appConfigHash() => r'0610c0c321abd60f0aad340d13bea60cd026a8b9';

/// Provider for the application configuration
///
/// This is the foundation provider that all other providers depend on.
/// It reads the environment from dart-define and returns the appropriate config.
///
/// This provider is created once at app startup and used throughout the app.
///
/// Copied from [appConfig].
@ProviderFor(appConfig)
final appConfigProvider = Provider<BaseConfig>.internal(
  appConfig,
  name: r'appConfigProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppConfigRef = ProviderRef<BaseConfig>;
String _$apiBaseUrlHash() => r'a48ab85013008a4b884ee44bede4593d88bd406a';

/// Convenience providers for accessing specific config values
/// These make it easy to inject individual configuration values
///
/// Copied from [apiBaseUrl].
@ProviderFor(apiBaseUrl)
final apiBaseUrlProvider = Provider<String>.internal(
  apiBaseUrl,
  name: r'apiBaseUrlProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$apiBaseUrlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiBaseUrlRef = ProviderRef<String>;
String _$websocketUrlHash() => r'0201cafb02c316c889c4327c3413405d8386ca60';

/// See also [websocketUrl].
@ProviderFor(websocketUrl)
final websocketUrlProvider = Provider<String>.internal(
  websocketUrl,
  name: r'websocketUrlProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$websocketUrlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WebsocketUrlRef = ProviderRef<String>;
String _$mailpitApiUrlHash() => r'c2a9eb6374da0675824f1237623aeb8bea9972fc';

/// See also [mailpitApiUrl].
@ProviderFor(mailpitApiUrl)
final mailpitApiUrlProvider = Provider<String>.internal(
  mailpitApiUrl,
  name: r'mailpitApiUrlProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mailpitApiUrlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MailpitApiUrlRef = ProviderRef<String>;
String _$connectTimeoutHash() => r'9327697fe2acfb356abdab4ac932bd61040cdd06';

/// See also [connectTimeout].
@ProviderFor(connectTimeout)
final connectTimeoutProvider = Provider<Duration>.internal(
  connectTimeout,
  name: r'connectTimeoutProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectTimeoutHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectTimeoutRef = ProviderRef<Duration>;
String _$receiveTimeoutHash() => r'2616306b846a7e70fddd03e140561cf7caf5e0ef';

/// See also [receiveTimeout].
@ProviderFor(receiveTimeout)
final receiveTimeoutProvider = Provider<Duration>.internal(
  receiveTimeout,
  name: r'receiveTimeoutProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$receiveTimeoutHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReceiveTimeoutRef = ProviderRef<Duration>;
String _$sendTimeoutHash() => r'f4f8d66b0b2de859fcd17128cde0a087f11761d5';

/// See also [sendTimeout].
@ProviderFor(sendTimeout)
final sendTimeoutProvider = Provider<Duration>.internal(
  sendTimeout,
  name: r'sendTimeoutProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sendTimeoutHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SendTimeoutRef = ProviderRef<Duration>;
String _$debugEnabledHash() => r'67e1757adaff436d4faaf3453be092f05d0c54b6';

/// See also [debugEnabled].
@ProviderFor(debugEnabled)
final debugEnabledProvider = Provider<bool>.internal(
  debugEnabled,
  name: r'debugEnabledProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$debugEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DebugEnabledRef = ProviderRef<bool>;
String _$firebaseEnabledHash() => r'9cef6884d108a281d513591b4ae87f56353cd135';

/// See also [firebaseEnabled].
@ProviderFor(firebaseEnabled)
final firebaseEnabledProvider = Provider<bool>.internal(
  firebaseEnabled,
  name: r'firebaseEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseEnabledRef = ProviderRef<bool>;
String _$defaultHeadersHash() => r'cd75429ac94504e640655fe4c22f6d617c0c07a5';

/// See also [defaultHeaders].
@ProviderFor(defaultHeaders)
final defaultHeadersProvider = Provider<Map<String, String>>.internal(
  defaultHeaders,
  name: r'defaultHeadersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$defaultHeadersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DefaultHeadersRef = ProviderRef<Map<String, String>>;
String _$appNameHash() => r'953a854e6c206e34defa0d10b365081b0cb84cbd';

/// See also [appName].
@ProviderFor(appName)
final appNameProvider = Provider<String>.internal(
  appName,
  name: r'appNameProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppNameRef = ProviderRef<String>;
String _$environmentNameHash() => r'd17f52de85b02104dd0dd0876636f44015296d14';

/// See also [environmentName].
@ProviderFor(environmentName)
final environmentNameProvider = Provider<String>.internal(
  environmentName,
  name: r'environmentNameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$environmentNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EnvironmentNameRef = ProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
