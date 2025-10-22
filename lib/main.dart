// EduLift Mobile - Unified Entry Point
// Single entry point for all flavors across all platforms (Android, iOS, Web, Linux)
//
// All initialization logic is now handled in bootstrap.dart for consistency
// between production app and tests. This keeps main.dart simple and focused.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bootstrap.dart';
import 'edulift_app.dart';

/// Main application entry point for all flavors and platforms
///
/// Delegates all initialization to bootstrap.dart which handles:
/// • Flavor detection and configuration
/// • Firebase initialization
/// • AppLogger setup
/// • Error handling setup
/// • Provider container creation
Future<void> main() async {
  // Bootstrap handles all initialization (flavor detection, logging, Firebase, etc.)
  final container = await bootstrap();

  // Start the app with the configured container
  runApp(
    UncontrolledProviderScope(container: container, child: const EduLiftApp()),
  );
}
