/// Development-safe NetworkInfo implementation for EduLift Mobile
/// Handles DBus socket errors that occur in containerized environments
/// This implementation assumes network connectivity in development when DBus is unavailable

import 'package:connectivity_plus/connectivity_plus.dart';
import 'network_info.dart';

/// Development-safe NetworkInfo that handles DBus errors gracefully
/// Used in development/testing environments where DBus may not be available
class DevNetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  const DevNetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    // In development/container environments, always return true
    // This completely avoids any DBus socket calls that would fail
    // ignore: avoid_print
    print(
      '[DevNetworkInfo] Development mode: assuming network connected (no DBus calls)',
    );
    return true;
  }

  @override
  Stream<bool> get connectionStream {
    // In development, provide a simple stream that always indicates connected
    // This completely avoids any connectivity checks that might trigger DBus
    return Stream.periodic(const Duration(seconds: 30), (_) => true);
  }
}
