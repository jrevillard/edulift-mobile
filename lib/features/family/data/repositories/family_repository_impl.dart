// EduLift Mobile - Family Repository Implementation (Composition Pattern)
// Clean, maintainable implementation using composition instead of inheritance
// Migrated to NetworkErrorHandler for unified error handling, retry logic, and cache strategies

import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/network/requests/index.dart' show DeleteResponseDto;
import '../../../../core/network/models/family/family_dto.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../../domain/requests/child_requests.dart';
import '../../domain/repositories/family_repository.dart';
import '../../domain/repositories/family_invitation_repository.dart';
import '../datasources/family_remote_datasource.dart';
import '../datasources/family_local_datasource.dart';
import '../../../../core/network/network_error_handler.dart';

/// Clean Family Repository Implementation using Composition Pattern
///
/// All network operations now use NetworkErrorHandler for:
/// - Automatic retry with exponential backoff
/// - Circuit breaker protection
/// - Unified error handling
/// - Cache strategies (networkOnly, networkFirst, staleWhileRevalidate)
/// - HTTP 0 detection and proper offline support
class FamilyRepositoryImpl implements FamilyRepository {
  final FamilyRemoteDataSource _remoteDataSource;
  final FamilyLocalDataSource _localDataSource;
  final InvitationRepository _invitationsRepository;
  final NetworkErrorHandler _networkErrorHandler;

  const FamilyRepositoryImpl({
    required FamilyRemoteDataSource remoteDataSource,
    required FamilyLocalDataSource localDataSource,
    required InvitationRepository invitationsRepository,
    required NetworkErrorHandler networkErrorHandler,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _invitationsRepository = invitationsRepository,
       _networkErrorHandler = networkErrorHandler;

  // ========================================
  // CORE FAMILY OPERATIONS
  // ========================================

  @override
  Future<Result<Family?, ApiFailure>> getCurrentFamily() async {
    // CLEAN ARCHITECTURE: Repository is responsible for business logic decisions
    // 404 = user has no family yet = functional success (not an error)
    final result = await _networkErrorHandler
        .executeRepositoryOperation<FamilyDto>(
          () => _remoteDataSource.getCurrentFamily(),
          operationName: 'family.getCurrentFamily',
          strategy: CacheStrategy.staleWhileRevalidate,
          serviceName: 'family',
          config: RetryConfig.quick,
          cacheOperation: () async {
            final cachedFamily = await _localDataSource.getCurrentFamily();
            if (cachedFamily == null) {
              throw Exception('No cached family available');
            }
            // Convert domain entity back to DTO for type consistency
            return FamilyDto.fromDomain(cachedFamily);
          },
          // NEW: Automatic cache update via onSuccess callback
          onSuccess: (familyDto) async {
            final family = familyDto.toDomain();
            await _localDataSource.cacheCurrentFamily(family);
            AppLogger.info(
              '[FAMILY] Family cached successfully after network success',
            );
          },
          context: {
            'feature': 'family_management',
            'operation_type': 'read',
            'cache_strategy': 'stale_while_revalidate',
            'expected_404': true, // Document that 404 is expected and valid
          },
        );

    return result.when(
      ok: (familyDto) {
        // Transform DTO to Domain Entity (no manual caching needed anymore)
        final family = familyDto.toDomain();
        return Result.ok(family);
      },
      err: (failure) {
        // BUSINESS LOGIC: 404 means user has no family - this is a valid state, not an error
        if (failure.statusCode == 404 || failure.code == 'api.not_found') {
          AppLogger.info('[FAMILY] User has no family (404) - valid state');
          try {
            _localDataSource.clearCurrentFamily();
          } catch (e) {
            AppLogger.warning('[FAMILY] Failed to clear family cache', e);
          }
          return const Result.ok(null);
        }

        // Authentication/Authorization errors
        if (failure.statusCode == 401 || failure.statusCode == 403) {
          AppLogger.warning(
            '[FAMILY] Authentication/Authorization error (${failure.statusCode}) - token likely expired/invalid',
          );
          return Result.err(
            ApiFailure(
              code: 'family.auth_failed',
              details: {
                'error': failure.message,
                'statusCode': failure.statusCode,
                'isAuthError': true,
              },
              statusCode: failure.statusCode ?? 401,
            ),
          );
        }

        // Other errors (network, server, etc.)
        return Result.err(failure);
      },
    );
  }

  @override
  Future<Result<Family, ApiFailure>> createFamily({
    required String name,
  }) async {
    // CLEAN ARCHITECTURE: Basic validation before network call
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return Result.err(
        ApiFailure.validationError(code: 'validation.field_required'),
      );
    }

    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<FamilyDto>(
          () => _remoteDataSource.createFamily(name: trimmedName),
          operationName: 'family.createFamily',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'family',
          config: RetryConfig.quick,
          onSuccess: (familyDto) async {
            // CACHE AUTO-UPDATE: Update cache automatically on network success
            final family = familyDto.toDomain();
            await _localDataSource.cacheCurrentFamily(family);
            AppLogger.info('Family created and cached successfully', {
              'familyId': family.id,
              'name': trimmedName,
            });
          },
          context: {
            'feature': 'family_management',
            'operation_type': 'create',
            'name': trimmedName,
          },
        );

    return result.when(
      ok: (familyDto) => Result.ok(familyDto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<Family, ApiFailure>> updateFamilyName({
    required String familyId,
    required String name,
  }) async {
    // CLEAN ARCHITECTURE: Basic validation before network call
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return Result.err(
        ApiFailure.validationError(code: 'validation.field_required'),
      );
    }

    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<FamilyDto>(
          () => _remoteDataSource.updateFamilyName(name: trimmedName),
          operationName: 'family.updateFamilyName',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'family',
          config: RetryConfig.quick,
          onSuccess: (familyDto) async {
            // CACHE AUTO-UPDATE: Update cache automatically on network success
            final family = familyDto.toDomain();
            await _localDataSource.cacheCurrentFamily(family);
            AppLogger.info('Family name updated and cached successfully', {
              'familyId': familyId,
              'newName': trimmedName,
            });
          },
          context: {
            'feature': 'family_management',
            'operation_type': 'update',
            'familyId': familyId,
            'newName': trimmedName,
          },
        );

    return result.when(
      ok: (familyDto) => Result.ok(familyDto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<void, ApiFailure>> leaveFamily({
    required String familyId,
  }) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation<void>(
      () => _remoteDataSource.leaveFamily(familyId),
      operationName: 'family.leaveFamily',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'family',
      config: RetryConfig.quick,
      onSuccess: (_) async {
        // CACHE AUTO-UPDATE: Clear cache on successful leave
        await _localDataSource.clearCurrentFamily();
        AppLogger.info('Family left and cache cleared successfully', {
          'familyId': familyId,
        });
      },
      context: {
        'feature': 'family_management',
        'operation_type': 'delete',
        'familyId': familyId,
      },
    );

    return result;
  }

  // ========================================
  // MEMBER OPERATIONS
  // ========================================

  @override
  Future<Result<FamilyMember, ApiFailure>> updateMemberRole({
    required String familyId,
    required String memberId,
    required String role,
  }) async {
    // Use NetworkErrorHandler for the update operation
    final updateResult = await _networkErrorHandler
        .executeRepositoryOperation<void>(
          () => _remoteDataSource.updateMemberRole(
            familyId: familyId,
            memberId: memberId,
            role: role,
          ),
          operationName: 'family.updateMemberRole',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'family',
          config: RetryConfig.quick,
          context: {
            'feature': 'family_management',
            'operation_type': 'update',
            'familyId': familyId,
            'memberId': memberId,
            'newRole': role,
          },
        );

    // If update failed, return error
    if (updateResult.isErr) {
      return Result.err(updateResult.error!);
    }

    // Refresh family data from server to get updated state
    final familyResult = await getCurrentFamily();
    if (familyResult.isErr) {
      AppLogger.error(
        'Failed to refresh family after role update: familyId=$familyId, memberId=$memberId',
        familyResult.error,
      );
      return Result.err(familyResult.error!);
    }

    final updatedFamily = familyResult.value;
    if (updatedFamily == null) {
      return const Result.err(
        ApiFailure(
          code: 'family.not_found',
          message: 'Family not found after member role update',
          statusCode: 404,
        ),
      );
    }

    // Find and return the updated member
    try {
      final updatedMember = updatedFamily.members.firstWhere(
        (m) => m.id == memberId,
      );

      AppLogger.info('Member role updated successfully', {
        'familyId': familyId,
        'memberId': memberId,
        'newRole': role,
      });

      return Result.ok(updatedMember);
    } catch (e) {
      return const Result.err(
        ApiFailure(
          code: 'family.member_not_found',
          message: 'Member not found after update',
          statusCode: 404,
        ),
      );
    }
  }

  @override
  Future<Result<void, ApiFailure>> removeMember({
    required String familyId,
    required String memberId,
  }) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation<void>(
      () => _remoteDataSource.removeMember(
        familyId: familyId,
        memberId: memberId,
      ),
      operationName: 'family.removeMember',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'family',
      config: RetryConfig.quick,
      onSuccess: (_) async {
        // CACHE AUTO-UPDATE: Update cache automatically on network success
        final currentFamily = await _localDataSource.getCurrentFamily();
        if (currentFamily != null) {
          final updatedMembers = currentFamily.members
              .where((m) => m.id != memberId)
              .toList();
          final updatedFamily = currentFamily.copyWith(members: updatedMembers);
          await _localDataSource.cacheCurrentFamily(updatedFamily);
        }
        AppLogger.info('Member removed and cache updated successfully', {
          'familyId': familyId,
          'memberId': memberId,
        });
      },
      context: {
        'feature': 'family_management',
        'operation_type': 'delete',
        'familyId': familyId,
        'memberId': memberId,
      },
    );

    return result;
  }

  // ========================================
  // INVITATION OPERATIONS (Delegated)
  // ========================================

  @override
  Future<Result<FamilyInvitationValidation, ApiFailure>> validateInvitation({
    required String inviteCode,
  }) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation(
      () => _remoteDataSource.validateInvitation(inviteCode: inviteCode),
      operationName: 'family.validateInvitation',
      strategy:
          CacheStrategy.networkOnly, // Validation must be fresh from server
      serviceName: 'family',
      config: RetryConfig.quick,
      context: {
        'feature': 'family_management',
        'operation_type': 'read',
        'inviteCode': inviteCode,
      },
    );

    return result.when(
      ok: (validationDto) {
        final validation = FamilyInvitationValidation(
          valid: validationDto.valid,
          familyId: validationDto.familyId,
          familyName: validationDto.familyName,
          role: validationDto.role,
          inviterEmail: validationDto.inviterName,
          expiresAt: validationDto.expiresAt,
          error: validationDto.error,
          invitedByName: validationDto.inviterName,
        );
        return Result.ok(validation);
      },
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<Family, ApiFailure>> joinFamily({
    required String inviteCode,
  }) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<FamilyDto>(
          () => _remoteDataSource.joinFamily(inviteCode: inviteCode),
          operationName: 'family.joinFamily',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'family',
          config: RetryConfig.quick,
          onSuccess: (familyDto) async {
            // CACHE AUTO-UPDATE: Mirror API operation in cache
            final family = familyDto.toDomain();
            await _localDataSource.cacheCurrentFamily(family);
            AppLogger.info('Family joined and cached successfully', {
              'familyId': family.id,
              'inviteCode': inviteCode,
            });
          },
          context: {
            'feature': 'family_management',
            'operation_type': 'create',
            'inviteCode': inviteCode,
          },
        );

    return result.when(
      ok: (familyDto) => Result.ok(familyDto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<FamilyInvitation, ApiFailure>> inviteMember({
    required String familyId,
    required String email,
    required String role,
    String? personalMessage,
  }) async {
    // Delegate to invitation repository which already uses NetworkErrorHandler
    final result = await _invitationsRepository.sendFamilyInvitation(
      email: email,
      familyId: familyId,
      role: role,
      message: personalMessage,
    );

    if (result.isOk) {
      AppLogger.info('Family member invited successfully', {
        'familyId': familyId,
        'email': email,
        'role': role,
      });
    } else {
      AppLogger.error('Failed to invite family member', {
        'familyId': familyId,
        'email': email,
        'error': result.error?.toString(),
      });
    }

    return result;
  }

  @override
  Future<Result<List<FamilyInvitation>, ApiFailure>> getPendingInvitations({
    required String familyId,
  }) async {
    // Delegate to invitation repository which already uses NetworkErrorHandler
    final result = await _invitationsRepository.getPendingInvitations(
      familyId: familyId,
    );

    if (result.isOk) {
      AppLogger.info('Pending family invitations retrieved successfully', {
        'familyId': familyId,
        'count': result.value!.length,
      });
    } else {
      AppLogger.error('Failed to get pending family invitations', {
        'familyId': familyId,
        'error': result.error?.toString(),
      });
    }

    return result;
  }

  @override
  Future<Result<void, ApiFailure>> cancelInvitation({
    required String familyId,
    required String invitationId,
  }) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation<void>(
      () => _remoteDataSource.cancelInvitation(
        familyId: familyId,
        invitationId: invitationId,
      ),
      operationName: 'family.cancelInvitation',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'family',
      config: RetryConfig.quick,
      context: {
        'feature': 'family_management',
        'operation_type': 'delete',
        'familyId': familyId,
        'invitationId': invitationId,
      },
    );

    if (result.isOk) {
      AppLogger.info('Invitation cancelled successfully', {
        'familyId': familyId,
        'invitationId': invitationId,
      });
    }

    return result;
  }

  // ========================================
  // CHILD OPERATIONS
  // ========================================

  @override
  Future<Result<Child, ApiFailure>> addChildFromRequest(
    String familyId,
    CreateChildRequest request,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation(
      () => _remoteDataSource.addChild(name: request.name, age: request.age),
      operationName: 'family.addChild',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'family',
      config: RetryConfig.quick,
      onSuccess: (childDto) async {
        // CACHE AUTO-UPDATE: Update cache automatically on network success
        final child = childDto.toDomain();
        await _localDataSource.cacheChild(child);
        AppLogger.info('Child added and cached successfully', {
          'familyId': familyId,
          'childId': child.id,
          'childName': request.name,
        });
      },
      context: {
        'feature': 'family_management',
        'operation_type': 'create',
        'familyId': familyId,
        'childName': request.name,
      },
    );

    return result.when(
      ok: (childDto) => Result.ok(childDto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<Child, ApiFailure>> updateChildFromRequest(
    String familyId,
    String childId,
    UpdateChildRequest request,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation(
      () => _remoteDataSource.updateChild(
        childId: childId,
        name: request.name,
        age: request.age,
      ),
      operationName: 'family.updateChild',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'family',
      config: RetryConfig.quick,
      onSuccess: (childDto) async {
        // CACHE AUTO-UPDATE: Update cache automatically on network success
        final child = childDto.toDomain();
        await _localDataSource.cacheChild(child);
        AppLogger.info('Child updated and cached successfully', {
          'familyId': familyId,
          'childId': childId,
          'childName': request.name,
        });
      },
      context: {
        'feature': 'family_management',
        'operation_type': 'update',
        'familyId': familyId,
        'childId': childId,
        'childName': request.name,
      },
    );

    return result.when(
      ok: (childDto) => Result.ok(childDto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<void, ApiFailure>> deleteChild({
    required String familyId,
    required String childId,
  }) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<DeleteResponseDto>(
          () => _remoteDataSource.deleteChild(childId: childId),
          operationName: 'family.deleteChild',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'family',
          config: RetryConfig.quick,
          onSuccess: (deleteResult) async {
            // Validate deletion success
            if (!deleteResult.success) {
              AppLogger.warning('Delete operation returned success=false', {
                'childId': childId,
                'message': deleteResult.message,
              });
              return;
            }

            // CACHE AUTO-UPDATE: Remove from cache on successful delete
            await _localDataSource.removeChild(childId);
            AppLogger.info('Child deleted and cache updated successfully', {
              'familyId': familyId,
              'childId': childId,
            });
          },
          context: {
            'feature': 'family_management',
            'operation_type': 'delete',
            'familyId': familyId,
            'childId': childId,
          },
        );

    // Transform the result from DeleteResponseDto to void
    return result.when(
      ok: (deleteResult) {
        if (!deleteResult.success) {
          return Result.err(
            ApiFailure(
              code: 'family.delete_child_failed',
              message: 'Delete operation failed: ${deleteResult.message}',
              statusCode: 500,
            ),
          );
        }
        return const Result.ok(null);
      },
      err: (failure) => Result.err(failure),
    );
  }

  // ========================================
  // VEHICLE OPERATIONS
  // ========================================

  @override
  Future<Result<Vehicle, ApiFailure>> addVehicle({
    required String name,
    required int capacity,
    String? description,
  }) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation(
      () => _remoteDataSource.addVehicle(
        name: name,
        capacity: capacity,
        description: description,
      ),
      operationName: 'family.addVehicle',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'family',
      config: RetryConfig.quick,
      onSuccess: (vehicleDto) async {
        // CACHE AUTO-UPDATE: Update cache automatically on network success
        final vehicle = vehicleDto.toDomain();
        await _localDataSource.cacheVehicle(vehicle);
        AppLogger.info('Vehicle added and cached successfully', {
          'vehicleId': vehicle.id,
          'vehicleName': name,
          'capacity': capacity,
        });
      },
      context: {
        'feature': 'family_management',
        'operation_type': 'create',
        'vehicleName': name,
        'capacity': capacity,
      },
    );

    return result.when(
      ok: (vehicleDto) => Result.ok(vehicleDto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<Vehicle, ApiFailure>> updateVehicle({
    required String vehicleId,
    String? name,
    int? capacity,
    String? description,
  }) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation(
      () => _remoteDataSource.updateVehicle(
        vehicleId: vehicleId,
        name: name,
        capacity: capacity,
        description: description,
      ),
      operationName: 'family.updateVehicle',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'family',
      config: RetryConfig.quick,
      onSuccess: (vehicleDto) async {
        // CACHE AUTO-UPDATE: Update cache automatically on network success
        final vehicle = vehicleDto.toDomain();
        await _localDataSource.cacheVehicle(vehicle);
        AppLogger.info('Vehicle updated and cached successfully', {
          'vehicleId': vehicleId,
          'vehicleName': name,
          'capacity': capacity,
        });
      },
      context: {
        'feature': 'family_management',
        'operation_type': 'update',
        'vehicleId': vehicleId,
        'vehicleName': name,
        'capacity': capacity,
      },
    );

    return result.when(
      ok: (vehicleDto) => Result.ok(vehicleDto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<void, ApiFailure>> deleteVehicle({
    required String vehicleId,
  }) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<DeleteResponseDto>(
          () => _remoteDataSource.deleteVehicle(vehicleId: vehicleId),
          operationName: 'family.deleteVehicle',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'family',
          config: RetryConfig.quick,
          onSuccess: (deleteResult) async {
            // Validate deletion success
            if (!deleteResult.success) {
              AppLogger.warning('Delete operation returned success=false', {
                'vehicleId': vehicleId,
                'message': deleteResult.message,
              });
              return;
            }

            // CACHE AUTO-UPDATE: Remove from cache on successful delete
            await _localDataSource.removeVehicle(vehicleId);
            AppLogger.info('Vehicle deleted and cache updated successfully', {
              'vehicleId': vehicleId,
            });
          },
          context: {
            'feature': 'family_management',
            'operation_type': 'delete',
            'vehicleId': vehicleId,
          },
        );

    // Transform the result from DeleteResponseDto to void
    return result.when(
      ok: (deleteResult) {
        if (!deleteResult.success) {
          return Result.err(
            ApiFailure(
              code: 'family.delete_vehicle_failed',
              message: 'Delete operation failed: ${deleteResult.message}',
              statusCode: 500,
            ),
          );
        }
        return const Result.ok(null);
      },
      err: (failure) => Result.err(failure),
    );
  }

  // ========================================
  // INTERFACE COMPLIANCE
  // ========================================

  @override
  Future<Result<Family?, ApiFailure>> getFamily() => getCurrentFamily();
}
