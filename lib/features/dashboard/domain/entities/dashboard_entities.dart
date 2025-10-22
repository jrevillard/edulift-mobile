// CLEAN ARCHITECTURE COMPLIANT - Domain entities with primitive types only
import 'package:edulift/core/domain/entities/family.dart';

// Enums for dashboard
enum ActivityType { childAdded, groupJoined, vehicleAdded, scheduleCreated }

enum TripType { pickup, dropOff }

// Data classes for dashboard - CLEAN: No UI dependencies
class RecentActivity {
  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final String iconName; // CLEAN: Use string identifier instead of IconData

  RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.iconName,
  });
}

class UpcomingTripDisplay {
  final String id;
  final String time;
  final String destination;
  final TripType type;
  final String date;
  final List<Child> children;

  UpcomingTripDisplay({
    required this.id,
    required this.time,
    required this.destination,
    required this.type,
    required this.date,
    required this.children,
  });
}

// CLEAN ARCHITECTURE FIX: Move UI callbacks to presentation layer
// Actions should be handled at the presentation layer, not domain
class DashboardActionConfig {
  final bool canAddChild;
  final bool canJoinGroup;
  final bool canAddVehicle;

  DashboardActionConfig({
    required this.canAddChild,
    required this.canJoinGroup,
    required this.canAddVehicle,
  });
}
