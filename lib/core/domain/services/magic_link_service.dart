// EduLift Mobile - Magic Link Service Interface (Domain Layer)
// Abstract interface for magic link authentication operations

import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../entities/auth_entities.dart';

/// Magic link service interface providing secure authentication methods
/// This belongs in the domain layer as it defines business rules for magic link operations
abstract class IMagicLinkService {
  /// Request a magic link to be sent to the specified email
  Future<Either<Failure, void>> requestMagicLink(
    String email,
    MagicLinkContext context,
  );

  /// Verify a magic link token and authenticate the user
  Future<Either<Failure, MagicLinkVerificationResult>> verifyMagicLink(
    String token, {
    String? inviteCode,
  });

  /// Clean up resources
  void dispose();
}
