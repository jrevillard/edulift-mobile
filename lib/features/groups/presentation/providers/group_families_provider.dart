// EduLift Mobile - Group Families Provider
// Riverpod provider for managing group families state using code generation

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/domain/entities/groups/group_family.dart';
import '../../../../core/di/providers/providers.dart';

part 'group_families_provider.g.dart';

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
@riverpod
Future<List<GroupFamily>> groupFamilies(Ref ref, String groupId) async {
  // Get repository from dependency injection
  final repository = ref.watch(groupRepositoryProvider);

  // Fetch group families from repository
  final result = await repository.getGroupFamilies(groupId);

  // Handle result using pattern matching
  return result.when(
    ok: (families) => families,
    err: (failure) {
      // Convert ApiFailure to Exception for Riverpod error handling
      // The failure message will be caught by AsyncValue.error
      throw Exception(failure.message ?? 'Failed to load group families');
    },
  );
}
