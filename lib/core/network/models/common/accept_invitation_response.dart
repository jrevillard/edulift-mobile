import 'package:json_annotation/json_annotation.dart';

part 'accept_invitation_response.g.dart';

/// Simple response for invitation acceptance
/// Backend returns minimal data since frontends only use success flag
@JsonSerializable()
class AcceptInvitationResponse {
  final bool success;
  final String? error;
  final String? message;

  const AcceptInvitationResponse({
    required this.success,
    this.error,
    this.message,
  });

  factory AcceptInvitationResponse.fromJson(Map<String, dynamic> json) =>
      _$AcceptInvitationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptInvitationResponseToJson(this);
}
