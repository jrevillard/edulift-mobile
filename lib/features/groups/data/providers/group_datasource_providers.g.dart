// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_datasource_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupRemoteDataSourceHash() =>
    r'9060ed2facfc1893cf682c96fb1705b4970c5fc0';

/// Provides GroupRemoteDataSource with GroupApiClient dependency
///
/// Copied from [groupRemoteDataSource].
@ProviderFor(groupRemoteDataSource)
final groupRemoteDataSourceProvider =
    AutoDisposeProvider<GroupRemoteDataSource>.internal(
  groupRemoteDataSource,
  name: r'groupRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groupRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroupRemoteDataSourceRef
    = AutoDisposeProviderRef<GroupRemoteDataSource>;
String _$groupLocalDataSourceHash() =>
    r'24df2d92591e44fe88ece70fee18b546da8ce955';

/// Provides GroupLocalDataSource with Hive storage
///
/// Copied from [groupLocalDataSource].
@ProviderFor(groupLocalDataSource)
final groupLocalDataSourceProvider =
    AutoDisposeProvider<GroupLocalDataSource>.internal(
  groupLocalDataSource,
  name: r'groupLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groupLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroupLocalDataSourceRef = AutoDisposeProviderRef<GroupLocalDataSource>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
