// Flutter Test DI Configuration (2025 Best Practices)
//
// Provides test-specific dependency injection setup for isolated testing
// Following FLUTTER_TESTING_RESEARCH_2025.md - Service Registration

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

// Domain entities and interfaces
import 'package:edulift/core/domain/entities/auth_entities.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

// Provider imports - Core providers
import 'package:edulift/core/di/providers/providers.dart';

// Service interfaces needed for typing
import 'package:edulift/core/domain/services/auth_service.dart';
import 'package:edulift/core/domain/services/magic_link_service.dart';

// Repository interfaces
import 'package:edulift/features/family/domain/repositories/family_repository.dart';
// Removed obsolete children_repository and vehicles_repository imports
import 'package:edulift/features/family/domain/repositories/family_invitation_repository.dart';

// Service interfaces - NEW ARCHITECTURE

// Deep link services

// Import mock classes
import '../test_mocks/test_mocks.dart' show setupMockFallbacks;
import '../test_mocks/test_specialized_mocks.dart';
import '../test_mocks/test_mocks.mocks.dart';

// REMOVED: MockComprehensiveFamilyDataService no longer needed after Clean Architecture separation

/// Test dependency injection configuration
class TestDIConfig {
  /// Get standard test provider overrides for consistent testing
  static List<Override> getTestProviderOverrides() {
    return [
      // Add standard overrides that should be applied in all provider tests
      // This ensures consistent mock behavior across all provider tests

      // Example: Override providers that depend on external services
      // TODO: Add provider overrides when fully migrated
    ];
  }

  /// Create mock provider overrides for family-related providers
  static List<Override> getFamilyProviderOverrides({
    FamilyRepository? mockFamilyRepository,
    InvitationRepository? mockInvitationRepository,
  }) {
    return [
      // Override family-related providers with mocks
      // This would be used when family providers are converted to proper StateNotifierProviders
      // Note: Children and vehicle operations are now part of FamilyRepository
    ];
  }

  /// Configure provider overrides for authentication testing
  static List<Override> getAuthProviderOverrides({
    AuthService? mockAuthService,
    IMagicLinkService? mockMagicLinkService,
  }) {
    return [
      // Override auth-related providers with mocks
      // Note: These would be used when auth providers are converted to proper StateNotifierProviders
      // if (mockAuthService != null)
      //   authServiceProvider.overrideWithValue(mockAuthService),
      // if (mockMagicLinkService != null)
      //   magicLinkServiceProvider.overrideWithValue(mockMagicLinkService),
    ];
  }

  /// Reset all provider states for clean testing
  static Future<void> resetProviderStates(ProviderContainer container) async {
    // Reset any cached provider states
    await Future.delayed(const Duration(milliseconds: 10));

    // Force garbage collection of disposed providers
    await Future.delayed(Duration.zero);
  }

  static ProviderContainer? _testContainer;

  /// Get the current test container (creates if needed)
  static ProviderContainer getTestContainer([List<Override>? overrides]) {
    _testContainer ??= ProviderContainer(overrides: overrides ?? []);
    return _testContainer!;
  }

  /// Create test container with all required provider overrides
  static ProviderContainer setupTestDependencies({
    List<Override>? additionalOverrides,
  }) {
    // Dispose existing container if any
    disposeTestContainer();

    // Configure dummy values for complex types FIRST
    setupMockFallbacks();

    // Create container with all mock overrides
    final overrides = <Override>[
      ..._getMockServiceOverrides(),
      ..._getTestServiceOverrides(),
      ...additionalOverrides ?? [],
    ];

    _testContainer = ProviderContainer(overrides: overrides);
    return _testContainer!;
  }

  /// Dispose the test container
  static void disposeTestContainer() {
    _testContainer?.dispose();
    _testContainer = null;
  }

  /// Get provider overrides for all mock services
  static List<Override> _getMockServiceOverrides() {
    // Create mocks
    final mockAuthService = MockAuthService();
    final mockStorageService = MockAdaptiveStorageService();
    final mockFamilyRepository = MockFamilyRepository();
    // Note: Children and vehicle operations are now part of FamilyRepository
    final mockInvitationRepository = MockInvitationRepository();
    // MockFamilyMembersRepository removed - family members accessed via family.members
    final mockBiometricService = TestMockFactory.createMockBiometricService();
    final mockUserStatusService = MockUserStatusService();
    final mockSecureStorage = MockAdaptiveSecureStorage();
    final mockMagicLinkService = MockIMagicLinkService();
    // mockFamilyDataService removed - Clean Architecture: auth tests separated from family services

    // Configure MagicLinkService
    _configureMagicLinkService(mockMagicLinkService);

    // Return provider overrides using the actual providers from imports
    return [
      // Core service providers
      authServiceProvider.overrideWithValue(mockAuthService),
      adaptiveStorageServiceProvider.overrideWithValue(mockStorageService),
      userStatusServiceProvider.overrideWithValue(mockUserStatusService),
      biometricServiceProvider.overrideWithValue(mockBiometricService),
      magicLinkServiceProvider.overrideWithValue(mockMagicLinkService),
      // REMOVED: comprehensiveFamilyDataServiceProvider - Clean Architecture separation complete

      // Repository providers
      familyRepositoryProvider.overrideWithValue(mockFamilyRepository),
      // Note: Children and vehicle operations are now part of FamilyRepository
      invitationRepositoryProvider.overrideWithValue(mockInvitationRepository),
      // familyMembersRepositoryProvider removed - family members accessed via family.members

      // Storage providers
      adaptiveSecureStorageProvider.overrideWithValue(mockSecureStorage),
    ];
  }

  /// Get provider overrides for test-specific services that need real implementations
  static List<Override> _getTestServiceOverrides() {
    return [
      // Real services that tests need with mock dependencies
      // TODO: Re-enable GetFamilyUsecase when userFamilyServiceProvider is available
      // getFamilyUsecaseProvider.overrideWith(
      //   (ref) => GetFamilyUsecase(
      //     ref.read(familyRepositoryProvider),
      //     // userFamilyServiceProvider - removed, doesn't exist yet
      //     // Note: Children and vehicle operations are now part of FamilyRepository
      //     // familyMembersRepositoryProvider removed - family members accessed via family.members
      //   ),
      // ),
    ];
  }

  /// Configure MockIMagicLinkService with proper stubbing
  static void _configureMagicLinkService(MockIMagicLinkService mockService) {
    // Create realistic test data
    final successResult = MagicLinkVerificationResult(
      token: 'test_jwt_token_success',
      refreshToken: 'test_refresh_token_success',
      expiresIn: 900,
      user: const {
        'id': 'test_user_123',
        'email': 'test@example.com',
        'name': 'Test User',
      },
      expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
      invitationResult: const {
        'processed': true,
        'invitationType': 'family',
        'familyId': 'fam456',
        'redirectUrl': '/family/dashboard',
        'requiresFamilyOnboarding': false,
      },
    );

    final invitationResult = MagicLinkVerificationResult(
      token: 'test_jwt_token_with_invite',
      refreshToken: 'test_refresh_token_with_invite',
      expiresIn: 900,
      user: const {
        'id': 'test_user_456',
        'email': 'invited@example.com',
        'name': 'Invited User',
      },
      expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
      invitationResult: const {
        'processed': true,
        'invitationType': 'family',
        'familyId': 'fam456',
        'redirectUrl': '/family/onboarding',
        'requiresFamilyOnboarding': true,
      },
      isNewUser: true,
    );

    // CRITICAL: Stub the verifyMagicLink method with proper responses
    when(
      mockService.verifyMagicLink(any, inviteCode: anyNamed('inviteCode')),
    ).thenAnswer((invocation) async {
      final token = invocation.positionalArguments[0] as String?;
      final inviteCode = invocation.namedArguments[#inviteCode] as String?;

      // Return different results based on input parameters
      if (token == 'invalid_token') {
        return const Left(
          ValidationFailure(
            message: 'Invalid magic link token',
            details: {'code': 'INVALID_TOKEN'},
          ),
        );
      }

      if (inviteCode != null && inviteCode.isNotEmpty) {
        return Right(invitationResult);
      }

      return Right(successResult);
    });

    // Stub other MagicLinkService methods
    when(
      mockService.requestMagicLink(any, any),
    ).thenAnswer((_) async => const Right(null));

    // Mock interface methods will be added when available in the interface
  }

  /// Clean up test dependencies
  static Future<void> cleanup() async {
    disposeTestContainer();
  }
}


void main() {
  // Test DI configuration is a support utility - no direct tests needed
  // This file provides dependency injection setup for other test files
}
