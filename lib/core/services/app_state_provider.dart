import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Global application state that tracks loading states, errors, and sync status
@immutable
class AppState extends Equatable {
  final bool isLoading;
  final String? error;
  final bool isSyncing;
  final Map<String, int>
      featureLoading; // FIXED: Reference counting for race condition
  final int pendingSyncItems;
  final DateTime? lastSyncTime;

  const AppState({
    this.isLoading = false,
    this.error,
    this.isSyncing = false,
    this.featureLoading = const {},
    this.pendingSyncItems = 0,
    this.lastSyncTime,
  });

  AppState copyWith({
    bool? isLoading,
    String? error,
    bool? isSyncing,
    Map<String, int>? featureLoading, // FIXED: Reference counting type
    int? pendingSyncItems,
    DateTime? lastSyncTime,
    bool clearError = false,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSyncing: isSyncing ?? this.isSyncing,
      featureLoading: featureLoading ?? this.featureLoading,
      pendingSyncItems: pendingSyncItems ?? this.pendingSyncItems,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        isSyncing,
        featureLoading,
        pendingSyncItems,
        lastSyncTime,
      ];
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// FIXED: Reference counting to prevent race conditions in concurrent operations
  void setFeatureLoading(String feature, bool loading) {
    var newFeatureLoading = Map<String, int>.from(state.featureLoading);
    final currentCount = newFeatureLoading[feature] ?? 0;

    if (loading) {
      // Increment the counter
      newFeatureLoading[feature] = currentCount + 1;
    } else if (currentCount > 1) {
      // Decrement the counter
      newFeatureLoading[feature] = currentCount - 1;
    } else {
      // Remove the key when the counter reaches zero - immutable pattern
      newFeatureLoading = Map<String, int>.from(newFeatureLoading)
        ..removeWhere((key, value) => key == feature);
    }
    state = state.copyWith(featureLoading: newFeatureLoading);
  }

  void setSyncing(bool syncing) {
    state = state.copyWith(isSyncing: syncing);
  }

  void setPendingSyncItems(int count) {
    state = state.copyWith(pendingSyncItems: count);
  }

  void updateLastSyncTime() {
    state = state.copyWith(lastSyncTime: DateTime.now());
  }

  /// FIXED: Check if feature is loading (reference count > 0)
  bool isFeatureLoading(String feature) {
    return (state.featureLoading[feature] ?? 0) > 0;
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier();
});
