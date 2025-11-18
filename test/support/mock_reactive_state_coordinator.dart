import 'package:edulift/core/utils/app_logger.dart';

/// Mock ReactiveStateCoordinator for testing that avoids timer creation
///
/// This mock implements the same interface as ReactiveStateCoordinator
/// but skips the async coordination to prevent timer creation in tests.
mixin MockReactiveStateCoordinator {
  /// Mock coordinateCriticalState that doesn't create timers
  Future<void> coordinateCriticalState(
    void Function() stateUpdate, {
    required String description,
    bool withFrameCallback = false,
  }) async {
    AppLogger.info(
      '🔄 MOCK-STATE-COORDINATION: Skipping critical state update: $description',
    );

    // Apply the state update immediately without timer
    stateUpdate();

    // Skip the Future.delayed(Duration.zero) that creates timers
    // and skip frame callbacks in tests

    AppLogger.info(
      '🔄 MOCK-STATE-COORDINATION: Completed mock state update: $description',
    );
  }
}

/// Test-specific FamilyNotifier that uses MockReactiveStateCoordinator
class TestFamilyNotifier {
  /// Mock coordinateCriticalState for testing
  static Future<void> mockCoordinateCriticalState(
    void Function() stateUpdate, {
    required String description,
    bool withFrameCallback = false,
  }) async {
    AppLogger.info('🔄 TEST-STATE-COORDINATION: Mock update: $description');

    // Apply state update immediately
    stateUpdate();

    // No timer creation
  }
}
