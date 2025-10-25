// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loadingStateHash() => r'a1da76c3539baecfe16740bbce87903c02ccf764';

/// Loading state provider for global loading indicators
/// AUTO-DISPOSE: No keepAlive needed - can be disposed when not observed
///
/// Copied from [LoadingState].
@ProviderFor(LoadingState)
final loadingStateProvider =
    AutoDisposeNotifierProvider<LoadingState, bool>.internal(
  LoadingState.new,
  name: r'loadingStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$loadingStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LoadingState = AutoDisposeNotifier<bool>;
String _$errorStateHash() => r'dbd0dfecda17f8cf3b9d77542a1a91e819eab042';

/// Error state provider for global error handling
/// AUTO-DISPOSE: No keepAlive needed - can be disposed when not observed
///
/// Copied from [ErrorState].
@ProviderFor(ErrorState)
final errorStateProvider =
    AutoDisposeNotifierProvider<ErrorState, String?>.internal(
  ErrorState.new,
  name: r'errorStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$errorStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ErrorState = AutoDisposeNotifier<String?>;
String _$navigationStateHash() => r'a8680996d73e4f9e57ae936da4390d9271eb83c8';

/// Navigation state provider for tracking navigation state
/// AUTO-DISPOSE: No keepAlive needed - can be disposed when not observed
///
/// Copied from [NavigationState].
@ProviderFor(NavigationState)
final navigationStateProvider =
    AutoDisposeNotifierProvider<NavigationState, String?>.internal(
  NavigationState.new,
  name: r'navigationStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$navigationStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NavigationState = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
