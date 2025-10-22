import 'package:equatable/equatable.dart';

/// Core Family entity following Single Responsibility Principle
/// Only contains essential family identification and basic properties
class FamilyCore extends Equatable {
  /// Unique identifier for the family
  final String id;

  /// Family name
  final String name;

  /// When family was created
  final DateTime createdAt;

  /// Last updated timestamp
  final DateTime updatedAt;

  /// Optional family description
  final String? description;

  const FamilyCore({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  /// Create a copy with updated fields
  FamilyCore copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
  }) {
    return FamilyCore(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt, description];

  /// Convert FamilyCore to JSON for API calls

  /// Create FamilyCore from JSON response

  @override
  String toString() {
    return 'FamilyCore(id: $id, name: $name)';
  }
}
