// EduLift Mobile - Vehicle Domain Entity (Truthful Implementation)
// Only API-backed properties - no fake functionality

import 'package:equatable/equatable.dart';

/// Vehicle domain entity with only API-backed fields
/// Truthful implementation - no fake properties
class Vehicle extends Equatable {
  /// Unique identifier for the vehicle
  final String id;

  /// Vehicle name/identifier
  final String name;

  /// Family ID this vehicle belongs to
  final String familyId;

  /// Seating capacity
  final int capacity;

  /// Vehicle description (optional)
  final String? description;

  /// Vehicle creation timestamp
  final DateTime createdAt;

  /// Last updated timestamp
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.name,
    required this.familyId,
    required this.capacity,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  /// Create a copy of Vehicle with updated fields
  Vehicle copyWith({
    String? id,
    String? name,
    String? familyId,
    int? capacity,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      familyId: familyId ?? this.familyId,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get vehicle initials for display
  String get initials {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return 'V';

    final parts = trimmedName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'V';

    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }

  /// Get available seats for passengers (excluding driver)
  int get availablePassengerSeats => capacity - 1;

  /// Check if vehicle can accommodate number of children
  bool canAccommodate(int childrenCount) {
    return availablePassengerSeats >= childrenCount;
  }

  /// Get vehicle display name with capacity
  String get displayNameWithCapacity => '$name (${capacity} seats)';

  @override
  List<Object?> get props => [
    id,
    name,
    familyId,
    capacity,
    description,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Vehicle(id: $id, name: $name, capacity: $capacity)';
  }
}
