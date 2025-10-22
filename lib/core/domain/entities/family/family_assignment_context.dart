import 'package:equatable/equatable.dart';
import 'interfaces/assignment_interfaces.dart';

/// Family assignment context entity containing family-specific view data
///
/// This entity provides family-related contextual information for assignments,
/// implementing Interface Segregation for family display concerns.
class FamilyAssignmentContext extends Equatable implements IFamilyContext {
  @override
  final String? childName;

  @override
  final String? familyId;

  @override
  final String? familyName;

  const FamilyAssignmentContext({
    this.childName,
    this.familyId,
    this.familyName,
  });

  /// Factory for complete family context
  factory FamilyAssignmentContext.complete({
    required String childName,
    required String familyId,
    required String familyName,
  }) {
    return FamilyAssignmentContext(
      childName: childName,
      familyId: familyId,
      familyName: familyName,
    );
  }

  /// Check if context has all required family information
  bool get isComplete =>
      childName != null &&
      familyId != null &&
      familyName != null &&
      childName!.isNotEmpty &&
      familyId!.isNotEmpty &&
      familyName!.isNotEmpty;

  /// Get display name for the assignment
  String get displayName => childName ?? 'Unknown Child';

  /// Get family display name
  String get familyDisplayName => familyName ?? 'Unknown Family';

  FamilyAssignmentContext copyWith({
    String? childName,
    String? familyId,
    String? familyName,
  }) {
    return FamilyAssignmentContext(
      childName: childName ?? this.childName,
      familyId: familyId ?? this.familyId,
      familyName: familyName ?? this.familyName,
    );
  }

  @override
  List<Object?> get props => [childName, familyId, familyName];

  @override
  String toString() {
    return 'FamilyAssignmentContext(childName: $childName, familyId: $familyId, familyName: $familyName)';
  }
}