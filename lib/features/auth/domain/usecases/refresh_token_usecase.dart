import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/entities/user.dart';
import '../../../../core/domain/services/auth_service.dart';

class RefreshTokenUsecase {
  final AuthService _authService;

  RefreshTokenUsecase(this._authService);

  Future<Result<User, ApiFailure>> call(RefreshTokenParams params) async {
    // Direct delegation to AuthService - getCurrentUser refreshes tokens internally
    final result = await _authService.getCurrentUser();
    return result.when(
      ok: (user) => Result.ok(user),
      err: (failure) => Result.err(failure as ApiFailure),
    );
  }
}

class RefreshTokenParams {
  final String refreshToken;

  RefreshTokenParams({required this.refreshToken});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RefreshTokenParams && other.refreshToken == refreshToken;
  }

  @override
  int get hashCode {
    return refreshToken.hashCode;
  }
}
