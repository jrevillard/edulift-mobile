// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_families_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupFamiliesHash() => r'67f94c73159d2db5d8dc4323a0e2bec0b22aa0e4';

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

/// Provider for fetching families in a specific group
///
/// This provider automatically fetches and caches the list of families
/// for a given group ID. It will auto-refresh when:
/// - The provider is first accessed
/// - Dependencies change (e.g., repository updates)
/// - Manual refresh is triggered via `ref.invalidate()`
///
/// **Error Handling:**
/// - Throws [Exception] on failure, which Riverpod will catch and expose
///   through AsyncValue error state
/// - UI should handle AsyncValue states: loading, data, error
///
/// **Usage Example:**
/// ```dart
/// final familiesAsync = ref.watch(groupFamiliesProvider('group-123'));
/// familiesAsync.when(
///   data: (families) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
///
/// **Parameters:**
/// - [groupId] - The unique identifier of the group
///
/// **Returns:**
/// A Future that resolves to a list of [GroupFamily] entities
///
/// Copied from [groupFamilies].
@ProviderFor(groupFamilies)
const groupFamiliesProvider = GroupFamiliesFamily();

/// Provider for fetching families in a specific group
///
/// This provider automatically fetches and caches the list of families
/// for a given group ID. It will auto-refresh when:
/// - The provider is first accessed
/// - Dependencies change (e.g., repository updates)
/// - Manual refresh is triggered via `ref.invalidate()`
///
/// **Error Handling:**
/// - Throws [Exception] on failure, which Riverpod will catch and expose
///   through AsyncValue error state
/// - UI should handle AsyncValue states: loading, data, error
///
/// **Usage Example:**
/// ```dart
/// final familiesAsync = ref.watch(groupFamiliesProvider('group-123'));
/// familiesAsync.when(
///   data: (families) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
///
/// **Parameters:**
/// - [groupId] - The unique identifier of the group
///
/// **Returns:**
/// A Future that resolves to a list of [GroupFamily] entities
///
/// Copied from [groupFamilies].
class GroupFamiliesFamily extends Family<AsyncValue<List<GroupFamily>>> {
  /// Provider for fetching families in a specific group
  ///
  /// This provider automatically fetches and caches the list of families
  /// for a given group ID. It will auto-refresh when:
  /// - The provider is first accessed
  /// - Dependencies change (e.g., repository updates)
  /// - Manual refresh is triggered via `ref.invalidate()`
  ///
  /// **Error Handling:**
  /// - Throws [Exception] on failure, which Riverpod will catch and expose
  ///   through AsyncValue error state
  /// - UI should handle AsyncValue states: loading, data, error
  ///
  /// **Usage Example:**
  /// ```dart
  /// final familiesAsync = ref.watch(groupFamiliesProvider('group-123'));
  /// familiesAsync.when(
  ///   data: (families) => ListView(...),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (err, stack) => ErrorWidget(err),
  /// );
  /// ```
  ///
  /// **Parameters:**
  /// - [groupId] - The unique identifier of the group
  ///
  /// **Returns:**
  /// A Future that resolves to a list of [GroupFamily] entities
  ///
  /// Copied from [groupFamilies].
  const GroupFamiliesFamily();

  /// Provider for fetching families in a specific group
  ///
  /// This provider automatically fetches and caches the list of families
  /// for a given group ID. It will auto-refresh when:
  /// - The provider is first accessed
  /// - Dependencies change (e.g., repository updates)
  /// - Manual refresh is triggered via `ref.invalidate()`
  ///
  /// **Error Handling:**
  /// - Throws [Exception] on failure, which Riverpod will catch and expose
  ///   through AsyncValue error state
  /// - UI should handle AsyncValue states: loading, data, error
  ///
  /// **Usage Example:**
  /// ```dart
  /// final familiesAsync = ref.watch(groupFamiliesProvider('group-123'));
  /// familiesAsync.when(
  ///   data: (families) => ListView(...),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (err, stack) => ErrorWidget(err),
  /// );
  /// ```
  ///
  /// **Parameters:**
  /// - [groupId] - The unique identifier of the group
  ///
  /// **Returns:**
  /// A Future that resolves to a list of [GroupFamily] entities
  ///
  /// Copied from [groupFamilies].
  GroupFamiliesProvider call(String groupId) {
    return GroupFamiliesProvider(groupId);
  }

  @override
  GroupFamiliesProvider getProviderOverride(
    covariant GroupFamiliesProvider provider,
  ) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupFamiliesProvider';
}

/// Provider for fetching families in a specific group
///
/// This provider automatically fetches and caches the list of families
/// for a given group ID. It will auto-refresh when:
/// - The provider is first accessed
/// - Dependencies change (e.g., repository updates)
/// - Manual refresh is triggered via `ref.invalidate()`
///
/// **Error Handling:**
/// - Throws [Exception] on failure, which Riverpod will catch and expose
///   through AsyncValue error state
/// - UI should handle AsyncValue states: loading, data, error
///
/// **Usage Example:**
/// ```dart
/// final familiesAsync = ref.watch(groupFamiliesProvider('group-123'));
/// familiesAsync.when(
///   data: (families) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
///
/// **Parameters:**
/// - [groupId] - The unique identifier of the group
///
/// **Returns:**
/// A Future that resolves to a list of [GroupFamily] entities
///
/// Copied from [groupFamilies].
class GroupFamiliesProvider
    extends AutoDisposeFutureProvider<List<GroupFamily>> {
  /// Provider for fetching families in a specific group
  ///
  /// This provider automatically fetches and caches the list of families
  /// for a given group ID. It will auto-refresh when:
  /// - The provider is first accessed
  /// - Dependencies change (e.g., repository updates)
  /// - Manual refresh is triggered via `ref.invalidate()`
  ///
  /// **Error Handling:**
  /// - Throws [Exception] on failure, which Riverpod will catch and expose
  ///   through AsyncValue error state
  /// - UI should handle AsyncValue states: loading, data, error
  ///
  /// **Usage Example:**
  /// ```dart
  /// final familiesAsync = ref.watch(groupFamiliesProvider('group-123'));
  /// familiesAsync.when(
  ///   data: (families) => ListView(...),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (err, stack) => ErrorWidget(err),
  /// );
  /// ```
  ///
  /// **Parameters:**
  /// - [groupId] - The unique identifier of the group
  ///
  /// **Returns:**
  /// A Future that resolves to a list of [GroupFamily] entities
  ///
  /// Copied from [groupFamilies].
  GroupFamiliesProvider(String groupId)
    : this._internal(
        (ref) => groupFamilies(ref as GroupFamiliesRef, groupId),
        from: groupFamiliesProvider,
        name: r'groupFamiliesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupFamiliesHash,
        dependencies: GroupFamiliesFamily._dependencies,
        allTransitiveDependencies:
            GroupFamiliesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupFamiliesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    FutureOr<List<GroupFamily>> Function(GroupFamiliesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupFamiliesProvider._internal(
        (ref) => create(ref as GroupFamiliesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<GroupFamily>> createElement() {
    return _GroupFamiliesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupFamiliesProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupFamiliesRef on AutoDisposeFutureProviderRef<List<GroupFamily>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupFamiliesProviderElement
    extends AutoDisposeFutureProviderElement<List<GroupFamily>>
    with GroupFamiliesRef {
  _GroupFamiliesProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupFamiliesProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
