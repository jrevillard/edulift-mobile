import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityNotifier extends StateNotifier<AsyncValue<bool>> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityNotifier() : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Listen to connectivity changes
      _subscription = Connectivity().onConnectivityChanged.listen((results) {
        final isConnected = results.any(
          (result) => result != ConnectivityResult.none,
        );
        state = AsyncValue.data(isConnected);
      });
      // Get initial connectivity status
      final results = await Connectivity().checkConnectivity();
      final isConnected = results.any(
        (result) => result != ConnectivityResult.none,
      );
      state = AsyncValue.data(isConnected);
    } catch (e) {
      // Fallback for container environments where D-Bus is not available
      // Log error in debug mode only, assume connected in development/container environments
      assert(() {
        // Only available in debug mode
        // ignore: avoid_print
        print('Connectivity check failed (container environment): $e');
        return true;
      }());
      // Assume connected in development/container environments
      state = const AsyncValue.data(true);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, AsyncValue<bool>>((ref) {
  final notifier = ConnectivityNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
