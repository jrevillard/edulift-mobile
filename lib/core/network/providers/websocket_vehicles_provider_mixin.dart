import 'dart:async';
import 'package:flutter/foundation.dart';
import '../websocket/websocket_event_models.dart';
import '../websocket/websocket_service.dart';
// ignore: unused_import
import '../../../infrastructure/network/websocket/socket_events.dart'; // Required for WebSocket architecture compliance
import 'package:edulift/core/utils/app_logger.dart';

/// Mixin that adds WebSocket real-time vehicle updates to any VehiclesProvider
/// This provides seamless integration with the Phase 3 WebSocket implementation
mixin WebSocketVehiclesMixin<T> on ChangeNotifier {
  WebSocketService? _websocketService;
  StreamSubscription<VehicleUpdateEvent>? _vehicleSubscription;
  String? _currentFamilyId;

  /// Initialize WebSocket vehicle updates
  void initializeWebSocketVehicles(WebSocketService websocketService) {
    _websocketService = websocketService;
    _setupVehicleListening();

    if (kDebugMode) {
      AppLogger.debug(
        '[WebSocketVehiclesMixin] Initialized WebSocket vehicle updates',
      );
    }
  }

  /// Subscribe to vehicle updates for a specific family
  Future<void> subscribeToFamilyVehicles(String familyId) async {
    if (_websocketService == null || _currentFamilyId == familyId) return;

    // Unsubscribe from previous family
    if (_currentFamilyId != null) {
      // Note: WebSocket service should handle unsubscription
      if (kDebugMode) {
        AppLogger.debug(
          '[WebSocketVehiclesMixin] Unsubscribed from family $_currentFamilyId vehicles',
        );
      }
    }

    _currentFamilyId = familyId;
    await _websocketService!.subscribeToFamily(familyId);

    if (kDebugMode) {
      AppLogger.debug(
        '[WebSocketVehiclesMixin] Subscribed to vehicles for family $familyId',
      );
    }
  }

  /// Unsubscribe from current family vehicle updates
  Future<void> unsubscribeFromFamilyVehicles() async {
    if (_websocketService == null || _currentFamilyId == null) return;

    // Note: WebSocket service should handle unsubscription
    _currentFamilyId = null;

    if (kDebugMode) {
      AppLogger.debug(
        '[WebSocketVehiclesMixin] Unsubscribed from family vehicles',
      );
    }
  }

  /// Setup WebSocket vehicle listening
  void _setupVehicleListening() {
    _vehicleSubscription?.cancel();
    _vehicleSubscription = _websocketService?.vehicleUpdates.listen(
      _handleVehicleUpdate,
      onError: (error) {
        if (kDebugMode) {
          AppLogger.error(
            '[WebSocketVehiclesMixin] Error listening to vehicle updates: $error',
          );
        }
      },
    );
  }

  /// Handle incoming vehicle update events
  void _handleVehicleUpdate(VehicleUpdateEvent event) {
    try {
      // Only process events for current family
      if (_currentFamilyId != null && event.familyId != _currentFamilyId) {
        return;
      }

      if (kDebugMode) {
        AppLogger.debug(
          '[WebSocketVehiclesMixin] Vehicle ${event.updateType.name}: ${event.vehicleId}',
        );
      }

      switch (event.updateType) {
        case VehicleUpdateType.added:
          _handleVehicleAdded(event);
          break;
        case VehicleUpdateType.updated:
          _handleVehicleUpdated(event);
          break;
        case VehicleUpdateType.deleted:
          _handleVehicleDeleted(event);
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error(
          '[WebSocketVehiclesMixin] Error handling vehicle update: $e',
        );
      }
    }
  }

  /// Handle vehicle added events
  void _handleVehicleAdded(VehicleUpdateEvent event) {
    try {
      final vehicleData = event.vehicleData;
      if (vehicleData != null) {
        final vehicleMap = vehicleData.toJson();
        onVehicleAdded(vehicleMap, event);
      }

      if (kDebugMode) {
        AppLogger.debug(
          '[WebSocketVehiclesMixin] Added vehicle: ${vehicleData?.name ?? 'Unknown'}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('[WebSocketVehiclesMixin] Error adding vehicle: $e');
      }
      // Fallback: trigger vehicle list refresh
      onVehicleListRefreshNeeded();
    }
  }

  /// Handle vehicle updated events
  void _handleVehicleUpdated(VehicleUpdateEvent event) {
    try {
      final vehicleData = event.vehicleData;
      if (vehicleData != null) {
        final vehicleMap = vehicleData.toJson();
        onVehicleUpdated(vehicleMap, event);
      }

      if (kDebugMode) {
        AppLogger.debug(
          '[WebSocketVehiclesMixin] Updated vehicle: ${vehicleData?.name ?? 'Unknown'}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('[WebSocketVehiclesMixin] Error updating vehicle: $e');
      }
      // Fallback: trigger vehicle list refresh
      onVehicleListRefreshNeeded();
    }
  }

  /// Handle vehicle deleted events
  void _handleVehicleDeleted(VehicleUpdateEvent event) {
    try {
      onVehicleDeleted(event.vehicleId, event);

      if (kDebugMode) {
        AppLogger.debug(
          '[WebSocketVehiclesMixin] Deleted vehicle: ${event.vehicleId}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('[WebSocketVehiclesMixin] Error deleting vehicle: $e');
      }
      // Fallback: trigger vehicle list refresh
      onVehicleListRefreshNeeded();
    }
  }

  /// Get current family ID for debugging
  String? get currentFamilyId => _currentFamilyId;

  /// Check if WebSocket is connected
  bool get isWebSocketConnected => _websocketService?.isConnected ?? false;

  /// Get WebSocket vehicle subscription status
  bool get hasVehicleSubscription =>
      _vehicleSubscription != null && _currentFamilyId != null;

  /// Cleanup WebSocket resources
  void disposeWebSocketVehicles() {
    _vehicleSubscription?.cancel();
    _currentFamilyId = null;
    _websocketService = null;

    if (kDebugMode) {
      AppLogger.debug(
        '[WebSocketVehiclesMixin] Disposed WebSocket vehicle resources',
      );
    }
  }

  // Abstract methods that implementing classes must provide

  /// Called when a new vehicle is added via WebSocket
  /// Implementation should handle DTO to domain entity conversion
  void onVehicleAdded(
    Map<String, dynamic> vehicleDto,
    VehicleUpdateEvent event,
  );

  /// Called when a vehicle is updated via WebSocket
  /// Implementation should handle DTO to domain entity conversion
  void onVehicleUpdated(
    Map<String, dynamic> vehicleDto,
    VehicleUpdateEvent event,
  );

  /// Called when a vehicle is deleted via WebSocket
  void onVehicleDeleted(String vehicleId, VehicleUpdateEvent event);

  /// Called when a vehicle list refresh is needed (fallback)
  void onVehicleListRefreshNeeded();

}

/// Extension for providers to add WebSocket functionality
/// Note: VehiclesNotifier was consolidated into FamilyProvider
extension ProviderWebSocketExtension on dynamic {
  /// Add WebSocket integration to any provider that implements WebSocketVehiclesMixin
  void enableWebSocketUpdates(WebSocketService websocketService) {
    if (this is WebSocketVehiclesMixin) {
      (this as WebSocketVehiclesMixin).initializeWebSocketVehicles(
        websocketService,
      );
    } else {
      if (kDebugMode) {
        AppLogger.warning(
          '[ProviderWebSocketExtension] Provider does not implement WebSocketVehiclesMixin',
        );
      }
    }
  }
}
