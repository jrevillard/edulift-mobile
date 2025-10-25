// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_family_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userFamilyServiceHash() => r'a4c3fabd8933fc07a719d2e4ddc907d4f11306ac';

/// Provider for UserFamilyService
/// Maintains existing API surface while delegating to FamilyRepository internally
///
/// Copied from [userFamilyService].
@ProviderFor(userFamilyService)
final userFamilyServiceProvider =
    AutoDisposeProvider<UserFamilyService>.internal(
  userFamilyService,
  name: r'userFamilyServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userFamilyServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserFamilyServiceRef = AutoDisposeProviderRef<UserFamilyService>;
String _$cachedUserFamilyStatusHash() =>
    r'68ac71ce65644c819aa32c19aa6aae6ac2e0918a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Cached user family status provider
/// Provides the same API as before but now delegates to FamilyRepository
///
/// Copied from [cachedUserFamilyStatus].
@ProviderFor(cachedUserFamilyStatus)
const cachedUserFamilyStatusProvider = CachedUserFamilyStatusFamily();

/// Cached user family status provider
/// Provides the same API as before but now delegates to FamilyRepository
///
/// Copied from [cachedUserFamilyStatus].
class CachedUserFamilyStatusFamily extends Family<AsyncValue<bool>> {
  /// Cached user family status provider
  /// Provides the same API as before but now delegates to FamilyRepository
  ///
  /// Copied from [cachedUserFamilyStatus].
  const CachedUserFamilyStatusFamily();

  /// Cached user family status provider
  /// Provides the same API as before but now delegates to FamilyRepository
  ///
  /// Copied from [cachedUserFamilyStatus].
  CachedUserFamilyStatusProvider call(String? userId) {
    return CachedUserFamilyStatusProvider(userId);
  }

  @override
  CachedUserFamilyStatusProvider getProviderOverride(
    covariant CachedUserFamilyStatusProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cachedUserFamilyStatusProvider';
}

/// Cached user family status provider
/// Provides the same API as before but now delegates to FamilyRepository
///
/// Copied from [cachedUserFamilyStatus].
class CachedUserFamilyStatusProvider extends AutoDisposeFutureProvider<bool> {
  /// Cached user family status provider
  /// Provides the same API as before but now delegates to FamilyRepository
  ///
  /// Copied from [cachedUserFamilyStatus].
  CachedUserFamilyStatusProvider(String? userId)
      : this._internal(
          (ref) =>
              cachedUserFamilyStatus(ref as CachedUserFamilyStatusRef, userId),
          from: cachedUserFamilyStatusProvider,
          name: r'cachedUserFamilyStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cachedUserFamilyStatusHash,
          dependencies: CachedUserFamilyStatusFamily._dependencies,
          allTransitiveDependencies:
              CachedUserFamilyStatusFamily._allTransitiveDependencies,
          userId: userId,
        );

  CachedUserFamilyStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String? userId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(CachedUserFamilyStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CachedUserFamilyStatusProvider._internal(
        (ref) => create(ref as CachedUserFamilyStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _CachedUserFamilyStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CachedUserFamilyStatusProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CachedUserFamilyStatusRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `userId` of this provider.
  String? get userId;
}

class _CachedUserFamilyStatusProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with CachedUserFamilyStatusRef {
  _CachedUserFamilyStatusProviderElement(super.provider);

  @override
  String? get userId => (origin as CachedUserFamilyStatusProvider).userId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
