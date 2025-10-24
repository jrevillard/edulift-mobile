import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/services/auth_service.dart';

class SendMagicLinkUsecase {
  final AuthService _authService;

  SendMagicLinkUsecase(this._authService);

  Future<Result<void, ApiFailure>> call(SendMagicLinkParams params) async {
    // Direct delegation to AuthService with all parameters
    final result = await _authService.sendMagicLink(
      params.email,
      name: params.name,
      inviteCode: params.inviteCode,
    );

    if (result.isSuccess) {
      return const Result.ok(null);
    } else {
      return Result.err(result.error! as ApiFailure);
    }
  }
}

class SendMagicLinkParams {
  final String email;
  final String? name;
  final String? redirectUrl;
  final String? inviteCode;

  SendMagicLinkParams({
    required this.email,
    this.name,
    this.redirectUrl,
    this.inviteCode,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SendMagicLinkParams &&
        other.email == email &&
        other.redirectUrl == redirectUrl &&
        other.inviteCode == inviteCode;
  }

  @override
  int get hashCode {
    return email.hashCode ^ redirectUrl.hashCode ^ inviteCode.hashCode;
  }
}
