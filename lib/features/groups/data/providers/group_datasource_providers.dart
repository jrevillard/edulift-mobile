// Group DataSource Providers
// Clean Architecture dependency injection for Group domain datasources

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers/foundation/network_providers.dart';
import '../datasources/group_remote_datasource.dart';
import '../datasources/group_remote_datasource_impl.dart';
import '../datasources/group_local_datasource.dart';
import '../datasources/group_local_datasource_impl.dart';

part 'group_datasource_providers.g.dart';

/// Provides GroupRemoteDataSource with GroupApiClient dependency
@riverpod
GroupRemoteDataSource groupRemoteDataSource(Ref ref) {
  final groupApiClient = ref.watch(groupApiClientProvider);
  return GroupRemoteDataSourceImpl(groupApiClient);
}

/// Provides GroupLocalDataSource with Hive storage
@riverpod
GroupLocalDataSource groupLocalDataSource(Ref ref) {
  return GroupLocalDataSourceImpl();
}
