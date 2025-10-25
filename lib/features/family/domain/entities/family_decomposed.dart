import 'package:equatable/equatable.dart';

import 'family_core.dart' as local_core;
import 'package:edulift/core/domain/entities/family.dart';
import '../interfaces/family_member_operations.dart' as local;
import '../interfaces/family_children_operations.dart' as local;
import '../interfaces/family_vehicle_operations.dart' as local;

/// Decomposed Family entity using composition and Interface Segregation Principle
/// Instead of having one god object, it composes focused operations
class FamilyDecomposed extends Equatable {
  final local_core.FamilyCore _core;
  final local.FamilyMemberOperations _memberOperations;
  final local.FamilyChildrenOperations _childrenOperations;
  final local.FamilyVehicleOperations _vehicleOperations;

  const FamilyDecomposed._({
    required local_core.FamilyCore core,
    required local.FamilyMemberOperations memberOperations,
    required local.FamilyChildrenOperations childrenOperations,
    required local.FamilyVehicleOperations vehicleOperations,
  })  : _core = core,
        _memberOperations = memberOperations,
        _childrenOperations = childrenOperations,
        _vehicleOperations = vehicleOperations;

  /// Factory constructor to create family with all operations
  factory FamilyDecomposed({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    List<FamilyMember> members = const [],
    List<Child> children = const [],
    List<Vehicle> vehicles = const [],
    String? description,
  }) {
    final core = local_core.FamilyCore(
      id: id,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      description: description,
    );
    final memberOperations = local.FamilyMemberOperationsImpl(members);
    final childrenOperations = local.FamilyChildrenOperationsImpl(children);
    final vehicleOperations = local.FamilyVehicleOperationsImpl(vehicles);
    return FamilyDecomposed._(
      core: core,
      memberOperations: memberOperations,
      childrenOperations: childrenOperations,
      vehicleOperations: vehicleOperations,
    );
  }
  // Core properties (delegation to FamilyCore)
  String get id => _core.id;
  String get name => _core.name;
  DateTime get createdAt => _core.createdAt;
  DateTime get updatedAt => _core.updatedAt;
  String? get description => _core.description;

  // Member operations (delegation to FamilyMemberOperations)
  List<FamilyMember> get members => _memberOperations.getMembers();
  int get totalMembers => _memberOperations.getTotalMembers();
  List<FamilyMember> get administrators =>
      _memberOperations.getAdministrators();
  List<FamilyMember> get regularMembers =>
      _memberOperations.getRegularMembers();
  List<FamilyMember> getMembersByRole(FamilyRole role) =>
      _memberOperations.getMembersByRole(role);
  bool isMember(String userId) => _memberOperations.isMember(userId);
  FamilyMember? getMemberByUserId(String userId) =>
      _memberOperations.getMemberByUserId(userId);
  bool isAdmin(String userId) => _memberOperations.isAdmin(userId);

  // Children operations (delegation to FamilyChildrenOperations)
  List<Child> get children => _childrenOperations.getChildren();
  int get totalChildren => _childrenOperations.getTotalChildren();
  bool get hasChildren => _childrenOperations.hasChildren();
  List<String> get childrenNames => _childrenOperations.getChildrenNames();
  List<Child> getChildrenByAgeRange(int minAge, int maxAge) =>
      _childrenOperations.getChildrenByAgeRange(minAge, maxAge);
  Child? getChildById(String childId) =>
      _childrenOperations.getChildById(childId);

  // Vehicle operations (delegation to FamilyVehicleOperations)
  List<Vehicle> get vehicles => _vehicleOperations.getVehicles();
  int get totalVehicles => _vehicleOperations.getTotalVehicles();
  bool get hasVehicles => _vehicleOperations.hasVehicles();
  List<String> get vehicleNames => _vehicleOperations.getVehicleNames();
  Vehicle? getVehicleById(String vehicleId) =>
      _vehicleOperations.getVehicleById(vehicleId);

  /// Create a copy with updated fields (preserves Interface Segregation)
  FamilyDecomposed copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<FamilyMember>? members,
    List<Child>? children,
    List<Vehicle>? vehicles,
    String? description,
  }) {
    return FamilyDecomposed(
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

  @override
  List<Object?> get props => [_core, members, children, vehicles];

  /// Convert Family to JSON for API calls

  /// Create Family from JSON response

  @override
  String toString() {
    return 'FamilyDecomposed(id: $id, name: $name, members: $totalMembers, children: $totalChildren, vehicles: $totalVehicles)';
  }
}
