/// Network connectivity interface for EduLift Mobile Application
/// Provides abstraction for network state checking

import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for checking network connectivity
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get connectionStream;
}

/// Implementation of NetworkInfo using connectivity_plus package
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  const NetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return _isConnectionActive(result.first);
  }

  @override
  Stream<bool> get connectionStream {
    return connectivity.onConnectivityChanged.map(
      (results) => _isConnectionActive(results.first),
    );
  }

  bool _isConnectionActive(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return true;
      case ConnectivityResult.none:
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.vpn:
      case ConnectivityResult.other:
        return false;
    }
  }
}
