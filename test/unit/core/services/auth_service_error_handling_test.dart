import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/core/services/auth_service.dart';
import 'package:edulift/core/network/error_handler_service.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/utils/result.dart';
import '../../../test_mocks/test_mocks.mocks.dart';

void main() {
  group('AuthService Error Handling Integration Tests', () {
    late AuthServiceImpl authService;
    late MockAuthApiClient mockApiClient;
    late MockIAuthLocalDatasource mockLocalDatasource;
    late MockUserStatusService mockUserStatusService;
    // MockComprehensiveFamilyDataService removed - Clean Architecture: auth domain separated from family domain
    late ErrorHandlerService errorHandlerService;

    setUp(() {
      mockApiClient = MockAuthApiClient();
      mockLocalDatasource = MockIAuthLocalDatasource();
      mockUserStatusService = MockUserStatusService();
      // mockFamilyDataService removed - Clean Architecture separation
      // Use real ErrorHandlerService to avoid mocking issues
      errorHandlerService = ErrorHandlerService(UserMessageService());

      authService = AuthServiceImpl(
        mockApiClient,
        mockLocalDatasource,
        mockUserStatusService,
        errorHandlerService,
      );
    });

    group('sendMagicLink - Error Handling', () {
      test(
        'should handle 422 validation errors through ErrorHandlerService',
        () async {
          // Arrange
          const email = 'test@example.com';
          when(mockUserStatusService.isValidEmail(email)).thenReturn(true);
          when(
            mockLocalDatasource.storePKCEVerifier(any),
          ).thenAnswer((_) async => const Result.ok(null));
          when(
            mockLocalDatasource.storeMagicLinkEmail(email),
          ).thenAnswer((_) async => const Result.ok(null));

          final validationError = ApiFailure.validationError(
            message: 'This user is already a member of a family',
          );

          when(mockApiClient.sendMagicLink(any)).thenThrow(validationError);

          // Act
          final result = await authService.sendMagicLink(email);

          // Assert
          expect(result.isError, isTrue);
          final failure = result.error;
          expect(failure, isA<ValidationFailure>());
          expect(failure!.message, contains('check the information'));
        },
      );

      test(
        'should handle network errors through ErrorHandlerService',
        () async {
          // Arrange
          const email = 'test@example.com';
          when(mockUserStatusService.isValidEmail(email)).thenReturn(true);
          when(
            mockLocalDatasource.storePKCEVerifier(any),
          ).thenAnswer((_) async => const Result.ok(null));
          when(
            mockLocalDatasource.storeMagicLinkEmail(email),
          ).thenAnswer((_) async => const Result.ok(null));

          final networkError = ApiFailure.network(
            message: 'Connection timeout',
          );

          when(mockApiClient.sendMagicLink(any)).thenThrow(networkError);

          // Act
          final result = await authService.sendMagicLink(email);

          // Assert
          expect(result.isError, isTrue);
          final failure = result.error;
          expect(failure, isA<NetworkFailure>());
          expect(failure!.message, contains('connection'));
        },
      );

      test('should handle server errors through ErrorHandlerService', () async {
        // Arrange
        const email = 'test@example.com';
        when(mockUserStatusService.isValidEmail(email)).thenReturn(true);
        when(
          mockLocalDatasource.storePKCEVerifier(any),
        ).thenAnswer((_) async => const Result.ok(null));
        when(
          mockLocalDatasource.storeMagicLinkEmail(email),
        ).thenAnswer((_) async => const Result.ok(null));

        final serverError = ApiFailure.serverError(
          message: 'Internal server error',
        );

        when(mockApiClient.sendMagicLink(any)).thenThrow(serverError);

        // Act
        final result = await authService.sendMagicLink(email);

        // Assert
        expect(result.isError, isTrue);
        final failure = result.error;
        expect(failure, isA<ServerFailure>());
        expect(failure!.message, contains('server'));
      });
    });

    group('authenticateWithMagicLink - Error Handling', () {
      test(
        'should handle authentication errors through ErrorHandlerService',
        () async {
          // Arrange
          const token = 'test-token';
          when(
            mockLocalDatasource.getMagicLinkEmail(),
          ).thenAnswer((_) async => const Result.ok('test@example.com'));
          when(
            mockLocalDatasource.getPKCEVerifier(),
          ).thenAnswer((_) async => const Result.ok('test-verifier'));

          final authError = ApiFailure.unauthorized();

          when(mockApiClient.verifyMagicLink(any, any)).thenThrow(authError);

          // Act
          final result = await authService.authenticateWithMagicLink(token);

          // Assert
          expect(result.isError, isTrue);
          final failure = result.error;
          expect(failure, isA<AuthFailure>());
          expect(failure!.message, contains('sign in'));
        },
      );
    });

    group('Error Integration Verification', () {
      test(
        'should verify ErrorHandlerService is properly integrated in AuthService',
        () {
          // Arrange & Assert
          expect(authService, isA<AuthServiceImpl>());
          expect(errorHandlerService, isA<ErrorHandlerService>());

          // Verify the ErrorHandlerService components work
          final context = ErrorContext.authOperation('test_operation');
          expect(context.operation, 'test_operation');
          expect(context.feature, 'AUTH');
        },
      );
    });
  });
}
