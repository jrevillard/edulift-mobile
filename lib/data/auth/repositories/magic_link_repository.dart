// EduLift Mobile - Magic Link Repository Implementation
// Data layer implementation of IMagicLinkService
// Migrated to NetworkErrorHandler for unified error handling, retry logic, and cache strategies

import 'package:dartz/dartz.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/errors/failures.dart';
import '../../../core/domain/services/magic_link_service.dart';
import '../../../core/storage/auth_local_datasource.dart';
import '../../../core/domain/entities/auth_entities.dart' as domain;
import '../../../core/network/auth_api_client.dart';
import '../../../core/network/requests/auth_requests.dart';
import '../../../core/utils/pkce_utils.dart';
import '../../../features/family/domain/repositories/family_repository.dart';
import '../../../core/network/network_error_handler.dart';

/// Magic link repository - data layer implementation of domain interface
///
/// All network operations now use NetworkErrorHandler for:
/// - Automatic retry with exponential backoff
/// - Circuit breaker protection
/// - Unified error handling
/// - AUTH: Always uses CacheStrategy.networkOnly (no caching for sensitive auth data)
class MagicLinkRepositoryImpl implements IMagicLinkService {
  final AuthApiClient _authApiClient;
  final IAuthLocalDatasource _authLocalDatasource;
  final FamilyRepository _familyRepository;
  final NetworkErrorHandler _networkErrorHandler;

  MagicLinkRepositoryImpl(
    this._authApiClient,
    this._authLocalDatasource,
    this._familyRepository,
    this._networkErrorHandler,
  );

  /// Request a magic link to be sent to the specified email
  @override
  Future<Either<Failure, void>> requestMagicLink(
    String email,
    domain.MagicLinkContext context,
  ) async {
    // Mask email for security in logs (show only first char and domain)
    final maskedEmail = _maskEmail(email);
    AppLogger.info('[AUTH] Requesting magic link for email: $maskedEmail');

    // STEP 1: Generate PKCE pair for security
    AppLogger.info('[AUTH] PKCE: Generating PKCE pair for security validation');
    final pkcePair = PKCEUtils.generatePKCEPair();
    final codeVerifier = pkcePair['code_verifier']!;
    final codeChallenge = pkcePair['code_challenge']!;

    AppLogger.debug(
      '[AUTH] PKCE: Generated code_verifier length: ${codeVerifier.length}',
    );
    AppLogger.debug(
      '[AUTH] PKCE: Generated code_challenge length: ${codeChallenge.length}',
    );

    // STEP 2: Store code_verifier securely for later verification
    AppLogger.info('[AUTH] PKCE: Storing code_verifier in secure storage');
    final storeResult = await _authLocalDatasource.storePKCEVerifier(
      codeVerifier,
    );

    if (storeResult.isErr) {
      AppLogger.warning(
        '[AUTH] PKCE: Failed to store code_verifier',
        storeResult.error,
      );
      return const Left(
        ApiFailure(
          code: 'auth.pkce_storage_failed',
          message: 'Failed to store PKCE verifier',
          statusCode: 500,
        ),
      );
    }

    // STEP 3: Create request with PKCE challenge
    final request = MagicLinkRequest(
      email: email,
      name: context.name,
      inviteCode: context.inviteCode,
      codeChallenge: codeChallenge,
    );

    AppLogger.info(
      '[AUTH] PKCE: Including code_challenge in magic link request',
    );

    // STEP 4: Send request via NetworkErrorHandler
    final result =
        await _networkErrorHandler.executeRepositoryOperation<String>(
      () => _authApiClient.sendMagicLink(request),
      operationName: 'auth.sendMagicLink',
      strategy: CacheStrategy.networkOnly, // AUTH: never cache
      serviceName: 'auth',
      config: RetryConfig.quick,
      context: {
        'feature': 'authentication',
        'operation_type': 'create',
        'email': maskedEmail, // Masked email for security
        'has_invite_code': context.inviteCode?.isNotEmpty ?? false,
      },
    );

    return result.when(
      ok: (response) {
        if (response.isNotEmpty) {
          AppLogger.info(
            '[AUTH] Magic link sent successfully with PKCE security',
          );
          return const Right(null);
        } else {
          AppLogger.warning('[AUTH] Magic link failed: empty response');
          return const Left(
            ApiFailure(
              code: 'auth.empty_response',
              message: 'Failed to send magic link - empty response',
              statusCode: 500,
            ),
          );
        }
      },
      err: (failure) {
        AppLogger.error('[AUTH] Magic link request failed: ${failure.message}');
        return Left(failure);
      },
    );
  }

  /// Verify a magic link token and authenticate the user
  @override
  Future<Either<Failure, domain.MagicLinkVerificationResult>> verifyMagicLink(
    String token, {
    String? inviteCode,
  }) async {
    // STEP 1: Retrieve stored PKCE code_verifier for security validation
    AppLogger.info(
      '[AUTH] PKCE: Retrieving stored code_verifier for magic link verification',
    );

    String? codeVerifier;
    final pkceResult = await _authLocalDatasource.getPKCEVerifier();
    if (pkceResult.isOk) {
      final verifier = pkceResult.value;
      if (verifier != null) {
        codeVerifier = verifier;
        final preview =
            verifier.length > 20 ? '${verifier.substring(0, 20)}...' : verifier;
        AppLogger.info(
          '[AUTH] PKCE: Successfully retrieved code_verifier: $preview (${verifier.length} chars)',
        );
      } else {
        AppLogger.warning(
          '[AUTH] PKCE: Retrieved code_verifier is NULL - backend will reject this request',
        );
      }
    }

    final request = VerifyTokenRequest(
      token: token,
      codeVerifier: codeVerifier,
    );

    if (codeVerifier != null) {
      AppLogger.info(
        '[AUTH] PKCE: Including code_verifier in magic link verification request',
      );
    } else {
      AppLogger.warning(
        '[AUTH] PKCE: Sending magic link verification WITHOUT code_verifier - will likely fail',
      );
    }

    // STEP 2: Verify magic link via NetworkErrorHandler
    final result = await _networkErrorHandler.executeRepositoryOperation(
      () => _authApiClient.verifyMagicLink(request, null),
      operationName: 'auth.verifyMagicLink',
      strategy: CacheStrategy.networkOnly, // AUTH: never cache
      serviceName: 'auth',
      config: RetryConfig.quick,
      context: {
        'feature': 'authentication',
        'operation_type': 'verify',
        'has_pkce': codeVerifier != null,
        'has_invite_code': inviteCode?.isNotEmpty ?? false,
        // NEVER log token or verifier values
      },
    );

    return result.when(
      ok: (response) async {
        AppLogger.info('[AUTH] API returned success, processing response...');
        // NEVER log token values - only length for debugging
        AppLogger.debug(
          '[AUTH] Response data: token length=${response.accessToken.length}',
        );

        try {
          // STEP 2.5: CRITICAL FIX - Store tokens BEFORE processing invitation
          // This is required because joinFamily needs authenticated API calls
          final expiresAt = DateTime.now().add(
            Duration(seconds: response.expiresIn),
          );
          final storeTokensResult = await _authLocalDatasource.storeTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresAt: expiresAt,
          );

          if (storeTokensResult.isErr) {
            AppLogger.error(
              '[AUTH] CRITICAL: Failed to store tokens before invitation processing',
            );
            return const Left(
              ApiFailure(
                code: 'auth.token_storage_failed',
                message: 'Failed to store authentication tokens',
                statusCode: 500,
              ),
            );
          }

          AppLogger.info(
            '[AUTH] ✅ Tokens stored successfully - proceeding with invitation processing',
          );

          // STEP 3: Process invitation if inviteCode is present
          // NOTE: Token storage must happen BEFORE invitation processing (done above)
          Map<String, dynamic>? invitationResult;
          if (inviteCode != null && inviteCode.isNotEmpty) {
            AppLogger.info(
              '[AUTH] Magic Link Invitation: Processing invitation with code: $inviteCode',
            );
            try {
              // Accept the family invitation using FamilyRepository
              final invitationResponse = await _familyRepository.joinFamily(
                inviteCode: inviteCode,
              );
              invitationResponse.fold(
                (failure) {
                  AppLogger.warning(
                    '[AUTH] Magic Link Invitation: Failed to join family: ${failure.message}',
                  );
                  invitationResult = {
                    'processed': false,
                    'invitationType': 'FAMILY',
                    'reason': failure.message,
                    'canRetry': true,
                  };
                },
                (family) {
                  AppLogger.info(
                    '[AUTH] Magic Link Invitation: Successfully joined family: ${family.name}',
                  );
                  invitationResult = {
                    'processed': true,
                    'invitationType': 'FAMILY',
                    'familyId': family.id,
                    'familyName': family.name,
                    'redirectUrl': '/dashboard',
                  };
                },
              );
            } catch (e) {
              AppLogger.error(
                '[AUTH] Magic Link Invitation: Exception processing invitation',
                e,
              );
              invitationResult = {
                'processed': false,
                'invitationType': 'FAMILY',
                'reason': 'Failed to process invitation: $e',
                'canRetry': true,
              };
            }
          }

          // STEP 5: Return MagicLinkVerificationResult with user data and invitation result
          AppLogger.info('[AUTH] Magic link verification successful');
          return Right(
            domain.MagicLinkVerificationResult(
              user: {
                'id': response.user.id,
                'email': response.user.email,
                'name': response.user.name,
                'createdAt': (response.user.createdAt ?? DateTime.now())
                    .toIso8601String(),
                'updatedAt': (response.user.updatedAt ?? DateTime.now())
                    .toIso8601String(),
                'isBiometricEnabled': response.user.isBiometricEnabled,
              },
              token: response.accessToken,
              refreshToken:
                  response.refreshToken, // PHASE 2: Include refresh token
              expiresIn:
                  response.expiresIn, // PHASE 2: Include expiration in seconds
              expiresAt: DateTime.now().add(
                Duration(seconds: response.expiresIn),
              ),
              invitationResult: invitationResult,
            ),
          );
        } catch (innerError, innerStack) {
          AppLogger.error(
            '[AUTH] Error processing successful response',
            innerError,
            innerStack,
          );
          return const Left(
            ApiFailure(
              code: 'auth.processing_error',
              message: 'magic_link.errors.processing_error',
              statusCode: 500,
            ),
          );
        }
      },
      err: (failure) {
        AppLogger.error(
          '[AUTH] Magic link verification failed: ${failure.message}',
        );
        return Left(failure);
      },
    );
  }

  /// Mask email for security in logs
  /// Example: "user@example.com" -> "u***@example.com"
  String _maskEmail(String email) {
    if (email.isEmpty) return '***';
    final parts = email.split('@');
    if (parts.length != 2) return '***';

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.isEmpty) return '***@$domain';
    final maskedLocal = '${localPart[0]}***';
    return '$maskedLocal@$domain';
  }

  /// Clean up resources
  @override
  void dispose() {
    // Clean up any listeners or resources
  }
}
