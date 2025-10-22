// EduLift Mobile - Family Member Request Models
// Request DTOs for family member operations

import 'package:equatable/equatable.dart';

/// Create family member request model
class CreateFamilyMemberRequest extends Equatable {
  final String name;
  final String role;
  final String? email;
  final String? phone;

  const CreateFamilyMemberRequest({
    required this.name,
    required this.role,
    this.email,
    this.phone,
  });

  factory CreateFamilyMemberRequest.fromJson(Map<String, dynamic> json) {
    return CreateFamilyMemberRequest(
      name: json['name'] as String,
      role: json['role'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };
  }

  @override
  List<Object?> get props => [name, role, email, phone];
}

/// Update family member request model
class UpdateFamilyMemberRequest extends Equatable {
  final String? name;
  final String? role;
  final String? email;
  final String? phone;

  const UpdateFamilyMemberRequest({
    this.name,
    this.role,
    this.email,
    this.phone,
  });

  factory UpdateFamilyMemberRequest.fromJson(Map<String, dynamic> json) {
    return UpdateFamilyMemberRequest(
      name: json['name'] as String?,
      role: json['role'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };
  }

  @override
  List<Object?> get props => [name, role, email, phone];
}
