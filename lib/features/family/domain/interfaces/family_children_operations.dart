import 'package:edulift/core/domain/entities/family.dart';

/// Interface for family children operations following Interface Segregation Principle
/// Separates children-related concerns from core family data
abstract class FamilyChildrenOperations {
  /// Get all family children
  List<Child> getChildren();

  /// Get total number of children
  int getTotalChildren();

  /// Get children by age range
  List<Child> getChildrenByAgeRange(int minAge, int maxAge);

  /// Find child by ID
  Child? getChildById(String childId);

  /// Check if family has any children
  bool hasChildren();

  /// Get children names for display
  List<String> getChildrenNames();
}

/// Implementation of family children operations
class FamilyChildrenOperationsImpl implements FamilyChildrenOperations {
  final List<Child> _children;

  // Create defensive copy to ensure immutability
  FamilyChildrenOperationsImpl(List<Child> children)
    : _children = List.from(children);

  @override
  List<Child> getChildren() => List.unmodifiable(_children);

  @override
  int getTotalChildren() => _children.length;

  @override
  List<Child> getChildrenByAgeRange(int minAge, int maxAge) {
    return _children.where((child) {
      final age = child.age;
      return age != null && age >= minAge && age <= maxAge;
    }).toList();
  }

  @override
  Child? getChildById(String childId) {
    try {
      return _children.firstWhere((child) => child.id == childId);
    } catch (_) {
      return null;
    }
  }

  @override
  bool hasChildren() => _children.isNotEmpty;

  @override
  List<String> getChildrenNames() {
    return _children.map((child) => child.name).toList();
  }
}
