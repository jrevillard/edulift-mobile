import 'package:equatable/equatable.dart';

/// Domain request model for creating a new child
/// Aligned with actual backend API structure (single name field)
class CreateChildRequest extends Equatable {
  final String name;
  final int? age;

  const CreateChildRequest({required this.name, this.age});

  @override
  List<Object?> get props => [name, age];

  // JSON methods removed - moved to CreateChildRequestDto in data layer
  // This maintains domain layer purity
}

/// Domain request model for updating an existing child
class UpdateChildRequest extends Equatable {
  final String? name;
  final int? age;

  const UpdateChildRequest({this.name, this.age});

  @override
  List<Object?> get props => [name, age];

  // JSON methods removed - moved to UpdateChildRequestDto in data layer
  // This maintains domain layer purity
}

/// Parameter wrapper for UpdateChildUsecase
class UpdateChildParams extends Equatable {
  final String childId;
  final UpdateChildRequest request;

  const UpdateChildParams({required this.childId, required this.request});

  @override
  List<Object> get props => [childId, request];
}

/// Parameter wrapper for RemoveChildUsecase
class RemoveChildParams extends Equatable {
  final String childId;

  const RemoveChildParams({required this.childId});

  @override
  List<Object> get props => [childId];
}

/// Domain request model for bulk updating a child
class BulkUpdateChildRequest extends Equatable {
  final String childId;
  final String? name;
  final int? age;

  const BulkUpdateChildRequest({required this.childId, this.name, this.age});

  @override
  List<Object?> get props => [childId, name, age];

  // JSON methods removed - moved to BulkUpdateChildRequestDto in data layer
  // This maintains domain layer purity
}

/// Request model for children search operations
class SearchChildrenRequest extends Equatable {
  final String query;
  final String? groupId;
  final int? minAge;
  final int? maxAge;
  final List<String>? requirements;
  final bool? hasRequirements;

  const SearchChildrenRequest({
    required this.query,
    this.groupId,
    this.minAge,
    this.maxAge,
    this.requirements,
    this.hasRequirements,
  });

  @override
  List<Object?> get props => [
    query,
    groupId,
    minAge,
    maxAge,
    requirements,
    hasRequirements,
  ];

  // JSON methods removed - moved to SearchChildrenRequestDto in data layer
  // This maintains domain layer purity
}
