import 'package:dartz/dartz.dart';

import '../errors/failures.dart';
import '../network/auth_api_client.dart';
import '../network/requests/auth_requests.dart';
import '../domain/entities/user.dart';

/// Service for checking user status and handling new vs existing user flows

class UserStatusService {
  final AuthApiClient _apiClient;

  UserStatusService(this._apiClient);

  /// Validates email format
  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Checks if a user exists in the system by email
  /// Returns true if user exists, false if new user
  Future<Either<Failure, bool>> checkUserExists(String email) async {
    try {
      // Check if user exists by attempting to get user info by email
      final response = await _apiClient.checkUserExists(email);
      return Right(response.exists);
    } catch (e) {
      if (e.toString().contains('404')) {
        // User not found = new user
        return const Right(false);
      }
      return Left(NetworkFailure(message: 'Network error: ${e.toString()}'));
    }
  }

  /// Checks user status and returns detailed information
  /// Used to determine if name is required for new users
  Future<Either<Failure, UserStatus>> checkUserStatus(String email) async {
    try {
      // Make API call to check if user exists
      final existsResult = await checkUserExists(email);
      return existsResult.fold(
        (failure) => Right(
          UserStatus(
            exists: false, // Assume new user on API failure
            hasProfile: false,
            requiresName: true,
            email: email,
          ),
        ),
        (userExists) => Right(
          UserStatus(
            exists: userExists,
            hasProfile: userExists, // If user exists, assume has profile
            requiresName: !userExists, // Only require name for new users
            email: email,
          ),
        ),
      );
    } catch (e) {
      // On unexpected errors, assume new user to not block registration
      return Right(
        UserStatus(
          exists: false,
          hasProfile: false,
          requiresName: true,
          email: email,
        ),
      );
    }
  }

  /// Creates a new user profile with name during magic link flow
  Future<Either<Failure, User>> createUserProfile({
    required String email,
    required String name,
    String? token,
  }) async {
    try {
      final request = CreateUserProfileRequest(email: email, name: name);
      final response = await _apiClient.createUserProfile(request);
      return Right(
        User(
          id: response.id,
          email: response.email,
          name: response.name,
          createdAt: response.createdAt,
          updatedAt: response.updatedAt,
        ),
      );
    } catch (e) {
      return Left(NetworkFailure(message: 'Network error: ${e.toString()}'));
    }
  }
}

/// Model for user status information
class UserStatus {
  final bool exists;
  final bool hasProfile;
  final bool requiresName;
  final String email;

  const UserStatus({
    required this.exists,
    required this.hasProfile,
    required this.requiresName,
    required this.email,
  });

  bool get isNewUser => !exists;
  bool get needsProfileSetup => !hasProfile || requiresName;
}