// PRESENTATION LAYER - Icon mapping service for Clean Architecture compliance
import 'package:flutter/material.dart';

/// Helper service for mapping string icon names to IconData
/// CLEAN ARCHITECTURE: Bridges domain layer (string identifiers) with presentation layer (IconData)
class IconMappingHelper {
  /// Map of icon name strings to IconData - centralized icon management
  static const Map<String, IconData> _iconMap = {
    // Activity icons
    'person_add': Icons.person_add,
    'group': Icons.group,
    'directions_car': Icons.directions_car,
    'schedule': Icons.schedule,

    // Trip type icons
    'arrow_downward': Icons.arrow_downward, // Pickup
    'arrow_upward': Icons.arrow_upward, // Drop-off
    // Common action icons
    'add': Icons.add,
    'edit': Icons.edit,
    'delete': Icons.delete,
    'settings': Icons.settings,
    'home': Icons.home,
    'school': Icons.school,
    'sports_soccer': Icons.sports_soccer,
    'local_hospital': Icons.local_hospital,

    // Navigation icons
    'dashboard': Icons.dashboard,
    'family': Icons.family_restroom,
    'calendar_today': Icons.calendar_today,
    'groups': Icons.groups,

    // Status icons
    'check_circle': Icons.check_circle,
    'error': Icons.error,
    'warning': Icons.warning,
    'info': Icons.info,
  };

  /// Get IconData from string icon name with fallback
  static IconData getIcon(
    String iconName, {
    IconData fallback = Icons.help_outline,
  }) {
    return _iconMap[iconName] ?? fallback;
  }

  /// Check if icon name exists in mapping
  static bool hasIcon(String iconName) {
    return _iconMap.containsKey(iconName);
  }

  /// Get all available icon names
  static List<String> get availableIcons => _iconMap.keys.toList();

  /// Get icon for activity type - convenience method
  static IconData getActivityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'childadded':
        return _iconMap['person_add']!;
      case 'groupjoined':
        return _iconMap['group']!;
      case 'vehicleadded':
        return _iconMap['directions_car']!;
      case 'schedulecreated':
        return _iconMap['schedule']!;
      default:
        return Icons.help_outline;
    }
  }

  /// Get icon for trip type - convenience method
  static IconData getTripTypeIcon(String tripType) {
    switch (tripType.toLowerCase()) {
      case 'pickup':
        return _iconMap['arrow_downward']!;
      case 'dropoff':
        return _iconMap['arrow_upward']!;
      default:
        return Icons.help_outline;
    }
  }
}
