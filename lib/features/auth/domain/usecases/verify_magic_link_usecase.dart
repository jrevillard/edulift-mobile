import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/services/auth_service.dart';

class VerifyMagicLinkUsecase {
  final AuthService _authService;

  VerifyMagicLinkUsecase(this._authService);

  Future<Result<AuthResult, ApiFailure>> call(
    VerifyMagicLinkParams params,
  ) async {
    // Direct delegation to AuthService
    final result = await _authService.authenticateWithMagicLink(params.token);
    return result.when(
      ok: (authResult) => Result.ok(authResult),
      err: (failure) => Result.err(failure as ApiFailure),
    );
  }
}

class VerifyMagicLinkParams {
  final String token;

  VerifyMagicLinkParams({required this.token});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerifyMagicLinkParams && other.token == token;
  }

  @override
  int get hashCode {
    return token.hashCode;
  }
}
