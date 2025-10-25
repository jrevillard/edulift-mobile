// FIXED: Removed Flutter import to maintain clean architecture - core layer isolation
// import 'package:flutter/material.dart'; // REMOVED

/// Abstract route configuration to avoid direct feature dependencies in core router
abstract class RouteConfiguration {
  String get path;
  String get name;
  Function
      get builder; // FIXED: Removed Flutter widget dependency for clean architecture
  List<RouteConfiguration> get routes => [];
}

/// Route configurations registry - to be injected from main app
/// FIXED: Removed Flutter-specific types for clean architecture compliance
abstract class RouteRegistry {
  List<RouteConfiguration> get authRoutes;
  List<RouteConfiguration> get familyRoutes;
  List<RouteConfiguration> get groupRoutes;
  List<RouteConfiguration> get scheduleRoutes;
  List<RouteConfiguration> get onboardingRoutes;
  List<RouteConfiguration> get invitationRoutes;
  Function get dashboardPage; // FIXED: Removed Flutter widget dependency
  Function get profilePage; // FIXED: Removed Flutter widget dependency
  Function get familyManagementPage; // FIXED: Removed Flutter widget dependency
  Function get groupsPage; // FIXED: Removed Flutter widget dependency
  Function get schedulePage; // FIXED: Removed Flutter widget dependency
}
