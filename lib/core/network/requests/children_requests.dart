// EduLift Mobile - Children Request Models
// Matches backend /api/children/* endpoints

import 'package:json_annotation/json_annotation.dart';

part 'children_requests.g.dart';

/// Create child request model
@JsonSerializable(includeIfNull: false)
class CreateChildInlineRequest {
  final String name;
  final String? dateOfBirth;
  final String? notes;

  CreateChildInlineRequest({
    required this.name,
    this.dateOfBirth,
    this.notes,
  });

  factory CreateChildInlineRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateChildInlineRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateChildInlineRequestToJson(this);
}

/// Update child request model
@JsonSerializable(includeIfNull: false)
class UpdateChildInlineRequest {
  final String? name;
  final String? dateOfBirth;
  final String? notes;

  UpdateChildInlineRequest({
    this.name,
    this.dateOfBirth,
    this.notes,
  });

  factory UpdateChildInlineRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateChildInlineRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateChildInlineRequestToJson(this);
}
