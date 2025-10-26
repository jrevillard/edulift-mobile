import 'package:equatable/equatable.dart';

/// Core Child domain entity - TRUTH-ALIGNED with backend API
/// Only contains fields that actually exist in the backend ChildDto
class Child extends Equatable {
  final String id;
  final String familyId;
  final String name;
  final int? age;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Child({
    required this.id,
    required this.familyId,
    required this.name,
    this.age,
    this.createdAt,
    this.updatedAt,
  });

  Child copyWith({
    String? id,
    String? familyId,
    String? name,
    int? age,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Child(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get child's initials for avatar display
  String get initials {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return '';

    final parts = trimmedName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';

    if (parts.length == 1) {
      return parts[0].isEmpty ? '' : parts[0].substring(0, 1).toUpperCase();
    }

    final firstInitial = parts[0].isEmpty ? '' : parts[0].substring(0, 1);
    final secondInitial = parts[1].isEmpty ? '' : parts[1].substring(0, 1);
    return '$firstInitial$secondInitial'.toUpperCase();
  }

  @override
  List<Object?> get props => [id, familyId, name, age, createdAt, updatedAt];
}
