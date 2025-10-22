import 'package:equatable/equatable.dart';

import 'child.dart';
import 'family_member.dart';
import 'vehicle.dart';

/// Core Family domain entity - matches backend schema exactly
/// This is the single source of truth for Family entity
class Family extends Equatable {
  /// Unique identifier for the family
  final String id;

  /// Family name
  final String name;

  /// When family was created
  final DateTime createdAt;

  /// Last updated timestamp
  final DateTime updatedAt;

  /// Family members (from backend include)
  final List<FamilyMember> members;

  /// Family children (from backend include)
  final List<Child> children;

  /// Family vehicles (from backend include)
  final List<Vehicle> vehicles;

  /// Optional family description
  final String? description;

  const Family({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.members = const [],
    this.children = const [],
    this.vehicles = const [],
    this.description,
  });

  /// Create a copy with updated fields
  Family copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<FamilyMember>? members,
    List<Child>? children,
    List<Vehicle>? vehicles,
    String? description,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      members: members ?? this.members,
      children: children ?? this.children,
      vehicles: vehicles ?? this.vehicles,
      description: description ?? this.description,
    );
  }

  /// Get total number of members
  int get totalMembers => members.length;

  /// Get total number of children
  int get totalChildren => children.length;

  /// Get total number of vehicles
  int get totalVehicles => vehicles.length;

  /// Get family members by role
  List<FamilyMember> getMembersByRole(FamilyRole role) {
    return members.where((member) => member.role == role).toList();
  }

  /// Get administrators
  List<FamilyMember> get administrators => getMembersByRole(FamilyRole.admin);

  /// Get regular members
  List<FamilyMember> get regularMembers => getMembersByRole(FamilyRole.member);

  @override
  List<Object?> get props => [
    id,
    name,
    createdAt,
    updatedAt,
    members,
    children,
    vehicles,
    description,
  ];

  @override
  String toString() {
    return 'Family(id: $id, name: $name, members: $totalMembers, children: $totalChildren, vehicles: $totalVehicles)';
  }
}
