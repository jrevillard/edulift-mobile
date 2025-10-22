// =============================================================================
// AUTH SERVICE 422 SURGICAL FIX TEST
// =============================================================================
// Teste que le fix chirurgical pour les erreurs 422 dans sendMagicLink()
// préserve le message backend original "name is required for new users"

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/errors/api_exception.dart';
import 'package:edulift/core/services/auth_service.dart';

import '../../../test_mocks/test_mocks.mocks.dart';

void main() {
  group('AuthService 422 Surgical Fix Tests', () {
    late AuthServiceImpl authService;
    late MockAuthApiClient mockApiClient;
    late MockIAuthLocalDatasource mockAuthDatasource;
    late MockUserStatusService mockUserStatusService;
    // MockComprehensiveFamilyDataService removed - Clean Architecture: auth domain separated from family domain
    late MockErrorHandlerService mockErrorHandlerService;

    setUp(() {
      mockApiClient = MockAuthApiClient();
      mockAuthDatasource = MockIAuthLocalDatasource();
      mockUserStatusService = MockUserStatusService();
      // mockFamilyService removed - Clean Architecture separation
      mockErrorHandlerService = MockErrorHandlerService();

      authService = AuthServiceImpl(
        mockApiClient,
        mockAuthDatasource,
        mockUserStatusService,
        mockErrorHandlerService,
      );
    });

    test('SURGICAL FIX: 422 magic link preserves backend message "name is required for new users"', () async {
      // ARRANGE
      const email = 'new.user@example.com';
      const backendMessage = 'name is required for new users';

      // Setup valid email
      when(mockUserStatusService.isValidEmail(email)).thenReturn(true);

      // Setup PKCE storage
      when(mockAuthDatasource.storePKCEVerifier(any))
          .thenAnswer((_) async => const Result.ok(null));
      when(mockAuthDatasource.storeMagicLinkEmail(email))
          .thenAnswer((_) async => const Result.ok(null));

      // Setup 422 error with backend message
      const apiException = ApiException(
        message: backendMessage,
        statusCode: 422,
        details: {
          'error': backendMessage,
          'code': 'VALIDATION_ERROR',
        },
      );

      when(mockApiClient.sendMagicLink(any)).thenThrow(apiException);

      // ACT
      final result = await authService.sendMagicLink(email);

      // ASSERT
      expect(result.isError, true);
      final failure = result.error!;

      // Vérifier que c'est une ValidationFailure avec le message préservé
      expect(failure, isA<ValidationFailure>());
      final validationFailure = failure as ValidationFailure;

      // CRITIAL: Le message doit être EXACTEMENT celui du backend
      expect(validationFailure.message, equals(backendMessage));
      expect(validationFailure.statusCode, equals(422));

      // Vérifier les détails spéciaux pour la préservation
      expect(validationFailure.details, isNotNull);
      expect(validationFailure.details!['original_message'], equals(backendMessage));
      expect(validationFailure.details!['error_source'], equals('auth_magic_link'));
      expect(validationFailure.details!['preserve_backend_message'], equals(true));

      // Vérifier que ErrorHandlerService N'A PAS été appelé pour 422
      verifyNever(mockErrorHandlerService.handleError(any, any, stackTrace: anyNamed('stackTrace')));
    });

    test('SURGICAL FIX: 422 preserves message from details when direct message is empty', () async {
      // ARRANGE
      const email = 'new.user@example.com';
      const backendMessage = 'name field is missing for new user registration';

      when(mockUserStatusService.isValidEmail(email)).thenReturn(true);
      when(mockAuthDatasource.storePKCEVerifier(any))
          .thenAnswer((_) async => const Result.ok(null));
      when(mockAuthDatasource.storeMagicLinkEmail(email))
          .thenAnswer((_) async => const Result.ok(null));

      // Exception avec message vide mais details contenant le vrai message
      const apiException = ApiException(
        message: '', // Message vide
        statusCode: 422,
        details: {
          'message': backendMessage, // Message dans details
          'code': 'VALIDATION_ERROR',
        },
      );

      when(mockApiClient.sendMagicLink(any)).thenThrow(apiException);

      // ACT
      final result = await authService.sendMagicLink(email);

      // ASSERT
      expect(result.isError, true);
      final failure = result.error! as ValidationFailure;

      // Le message des details doit être extrait
      expect(failure.message, equals(backendMessage));
    });

    test('SURGICAL FIX: Fallback message works when no message available', () async {
      // ARRANGE
      const email = 'user@example.com';

      when(mockUserStatusService.isValidEmail(email)).thenReturn(true);
      when(mockAuthDatasource.storePKCEVerifier(any))
          .thenAnswer((_) async => const Result.ok(null));
      when(mockAuthDatasource.storeMagicLinkEmail(email))
          .thenAnswer((_) async => const Result.ok(null));

      // Setup 422 error with no meaningful message
      const apiException = ApiException(
        message: '',
        statusCode: 422,
        details: {}, // Empty details
      );

      when(mockApiClient.sendMagicLink(any)).thenThrow(apiException);

      // ACT
      final result = await authService.sendMagicLink(email);

      // ASSERT
      expect(result.isError, true);
      final failure = result.error! as ValidationFailure;

      // Should use fallback message
      expect(failure.message, equals('Validation error occurred'));
      expect(failure.statusCode, equals(422));
    });
  });
}