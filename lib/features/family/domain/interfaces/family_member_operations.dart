import 'package:edulift/core/domain/entities/family.dart';

/// Interface for family member operations following Interface Segregation Principle
/// Separates member-related concerns from core family data
abstract class FamilyMemberOperations {
  /// Get all family members
  List<FamilyMember> getMembers();

  /// Get total number of members
  int getTotalMembers();

  /// Get family members by role
  List<FamilyMember> getMembersByRole(FamilyRole role);

  /// Get administrators
  List<FamilyMember> getAdministrators();

  /// Get regular members
  List<FamilyMember> getRegularMembers();

  /// Check if a user is a member of the family
  bool isMember(String userId);

  /// Get member by user ID
  FamilyMember? getMemberByUserId(String userId);

  /// Check if user has admin role
  bool isAdmin(String userId);
}

/// Implementation of family member operations
class FamilyMemberOperationsImpl implements FamilyMemberOperations {
  final List<FamilyMember> _members;

  const FamilyMemberOperationsImpl(this._members);

  @override
  List<FamilyMember> getMembers() => List.unmodifiable(_members);

  @override
  int getTotalMembers() => _members.length;

  @override
  List<FamilyMember> getMembersByRole(FamilyRole role) {
    return _members.where((member) => member.role == role).toList();
  }

  @override
  List<FamilyMember> getAdministrators() => getMembersByRole(FamilyRole.admin);

  @override
  List<FamilyMember> getRegularMembers() => getMembersByRole(FamilyRole.member);

  @override
  bool isMember(String userId) {
    return _members.any((member) => member.userId == userId);
  }

  @override
  FamilyMember? getMemberByUserId(String userId) {
    try {
      return _members.firstWhere((member) => member.userId == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  bool isAdmin(String userId) {
    final member = getMemberByUserId(userId);
    return member?.role == FamilyRole.admin;
  }
}
