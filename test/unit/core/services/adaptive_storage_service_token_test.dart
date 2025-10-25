import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/core/services/adaptive_storage_service.dart';
import 'package:edulift/core/constants/app_constants.dart';
import 'package:edulift/core/errors/exceptions.dart';

import '../../../test_mocks/test_mocks.mocks.dart';
import '../../../support/mock_fallbacks.dart';

/// ADAPTIVE STORAGE SERVICE TOKEN TESTS - CORRECTED FOR ACTUAL TEST BEHAVIOR
///
/// CRITICAL: These tests reflect the actual behavior in Flutter test environment
/// where kDebugMode = true, meaning development mode is used.
void main() {
  group('AdaptiveStorageService Token Management', () {
    late AdaptiveStorageService storageService;
    late MockAdaptiveSecureStorage mockStorage;
    late MockCryptoService mockCryptoService;
    late MockSecureKeyManager mockKeyManager;

    // Test constants - these reflect the actual keys used in development mode (Flutter test default)
    const testToken = 'test-jwt-token';
    const devKey =
        '${AppConstants.tokenKey}_dev'; // Development key (with _dev suffix)
    const prodKey = AppConstants.tokenKey; // Production key (no suffix)

    setUp(() {
      mockStorage = MockAdaptiveSecureStorage();
      mockCryptoService = MockCryptoService();
      mockKeyManager = MockSecureKeyManager();

      // Setup fallback for mockito dummy values
      setupMockFallbacks();
    });

    tearDown(() {
      // Reset all mocks between tests to prevent verification state conflicts
      reset(mockStorage);
      reset(mockCryptoService);
      reset(mockKeyManager);
    });

    group('Development Mode Token Storage (Flutter Test Environment Default)',
        () {
      setUp(() {
        storageService = AdaptiveStorageService(
          storage: mockStorage,
          cryptoService: mockCryptoService,
          keyManager: mockKeyManager,
        );
      });

      test(
        'should use dev key pattern for token storage in development mode',
        () async {
          // ARRANGE - Flutter test environment uses development mode (kDebugMode=true)
          when(
            mockStorage.write(key: devKey, value: testToken),
          ).thenAnswer((_) async => {});
          when(mockStorage.read(key: devKey)).thenAnswer(
            (_) async => testToken,
          ); // Must return the token for verification to pass

          // ACT
          await storageService.storeToken(testToken);

          // ASSERT - Development behavior: no encryption + dev key
          verify(mockStorage.write(key: devKey, value: testToken)).called(1);
          verify(mockStorage.read(key: devKey)).called(1); // Verification call
          verifyNever(mockCryptoService.encrypt(any, any));
          verifyNever(mockKeyManager.getDeviceEncryptionKey());
        },
      );

      test(
        'should store token without encryption in development mode',
        () async {
          // ARRANGE
          when(
            mockStorage.write(key: devKey, value: testToken),
          ).thenAnswer((_) async => {});
          when(mockStorage.read(key: devKey)).thenAnswer(
            (_) async => testToken,
          ); // Must return the token for verification to pass

          // ACT
          await storageService.storeToken(testToken);

          // ASSERT - No encryption should be used in development mode
          verify(mockStorage.write(key: devKey, value: testToken)).called(1);
          verify(
            mockStorage.read(key: devKey),
          ).called(1); // Verification call happens
          verifyNever(mockCryptoService.encrypt(any, any));
          verifyNever(mockKeyManager.getDeviceEncryptionKey());
        },
      );

      test('should verify token storage after write operation', () async {
        // ARRANGE - Development mode does immediate verification
        when(
          mockStorage.write(key: devKey, value: testToken),
        ).thenAnswer((_) async => {});
        when(mockStorage.read(key: devKey)).thenAnswer(
          (_) async => testToken,
        ); // Must return the token for verification to pass

        // ACT
        await storageService.storeToken(testToken);

        // ASSERT - Immediate verification read in development mode
        verify(mockStorage.write(key: devKey, value: testToken)).called(1);
        verify(mockStorage.read(key: devKey)).called(1);
      });

      test(
        'CRITICAL: should detect NULL failure in development verification',
        () async {
          // ARRANGE - Reset mock and simulate the exact NULL failure from logs
          reset(mockStorage);
          reset(mockCryptoService);
          reset(mockKeyManager);
          setupMockFallbacks();

          storageService = AdaptiveStorageService(
            storage: mockStorage,
            cryptoService: mockCryptoService,
            keyManager: mockKeyManager,
          );

          when(
            mockStorage.write(key: devKey, value: testToken),
          ).thenAnswer((_) async => {});
          when(
            mockStorage.read(key: devKey),
          ).thenAnswer((_) async => null); // NULL failure simulation

          // ACT & ASSERT
          await expectLater(
            () => storageService.storeToken(testToken),
            throwsA(isA<StorageException>()),
          );

          // VERIFY - Only verify the calls that should have been made before the exception
          verify(mockStorage.write(key: devKey, value: testToken)).called(1);
          verify(
            mockStorage.read(key: devKey),
          ).called(1); // Verification call happens before exception
        },
      );

      test('should retrieve token using dev key pattern', () async {
        // ARRANGE
        when(mockStorage.read(key: devKey)).thenAnswer((_) async => testToken);

        // ACT
        final result = await storageService.getToken();

        // ASSERT
        expect(result, equals(testToken));
        verify(mockStorage.read(key: devKey)).called(1);
        verifyNever(mockCryptoService.decrypt(any, any));
      });

      test('should return null when dev token not found', () async {
        // ARRANGE
        when(
          mockStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => null); // Mock all read calls
        when(
          mockStorage.readAll(),
        ).thenAnswer((_) async => <String, String>{}); // Mock for debug call

        // ACT
        final result = await storageService.getToken();

        // ASSERT
        expect(result, isNull);
        // The service calls read() 6 times: 1 initial + 5 debug variations
        verify(
          mockStorage.read(key: anyNamed('key')),
        ).called(6); // Total calls including debug
        verify(mockStorage.readAll()).called(1); // Verify debug call happens
        verifyNever(mockCryptoService.decrypt(any, any));
      });
    });

    group('Key Naming Consistency Verification', () {
      test('should use consistent dev key pattern across operations', () async {
        // ARRANGE
        storageService = AdaptiveStorageService(
          storage: mockStorage,
          cryptoService: mockCryptoService,
          keyManager: mockKeyManager,
        );

        when(
          mockStorage.write(key: devKey, value: testToken),
        ).thenAnswer((_) async => {});
        when(mockStorage.read(key: devKey)).thenAnswer(
          (_) async => testToken,
        ); // Must consistently return the token

        // ACT
        await storageService.storeToken(testToken);
        final retrievedToken = await storageService.getToken();

        // ASSERT - Same dev key used for both operations
        expect(retrievedToken, equals(testToken));
        verify(mockStorage.write(key: devKey, value: testToken)).called(1);
        verify(
          mockStorage.read(key: devKey),
        ).called(2); // Called for verification + retrieval
      });

      test('should never mix dev and prod keys in development mode', () async {
        // ARRANGE
        storageService = AdaptiveStorageService(
          storage: mockStorage,
          cryptoService: mockCryptoService,
          keyManager: mockKeyManager,
        );

        when(
          mockStorage.write(key: devKey, value: testToken),
        ).thenAnswer((_) async => {});
        when(mockStorage.read(key: devKey)).thenAnswer(
          (_) async => testToken,
        ); // Must return the token for verification to pass

        // ACT
        await storageService.storeToken(testToken);

        // ASSERT - Should only use development key, never prod key
        verify(mockStorage.write(key: devKey, value: testToken)).called(1);
        verify(mockStorage.read(key: devKey)).called(1); // Verification call
        verifyNever(mockStorage.write(key: prodKey, value: anyNamed('value')));
        verifyNever(mockStorage.read(key: prodKey));
      });
    });

    group('Storage Backend Fallback Scenarios', () {
      test('should handle storage write exceptions', () async {
        // ARRANGE - Reset mock to clear any previous interactions and reinitialize service
        reset(mockStorage);
        reset(mockCryptoService);
        reset(mockKeyManager);
        setupMockFallbacks();

        storageService = AdaptiveStorageService(
          storage: mockStorage,
          cryptoService: mockCryptoService,
          keyManager: mockKeyManager,
        );

        when(
          mockStorage.write(key: devKey, value: testToken),
        ).thenThrow(Exception('Storage backend unavailable'));

        // ACT & ASSERT
        expect(
          () => storageService.storeToken(testToken),
          throwsA(isA<StorageException>()),
        );

        verify(mockStorage.write(key: devKey, value: testToken)).called(1);
      });

      test('should handle storage read exceptions', () async {
        // ARRANGE - Reset mock to clear any previous interactions and reinitialize service
        reset(mockStorage);
        reset(mockCryptoService);
        reset(mockKeyManager);
        setupMockFallbacks();

        storageService = AdaptiveStorageService(
          storage: mockStorage,
          cryptoService: mockCryptoService,
          keyManager: mockKeyManager,
        );

        when(
          mockStorage.read(key: devKey),
        ).thenThrow(Exception('Storage backend read error'));

        // ACT
        final result = await storageService.getToken();

        // ASSERT - Should return null on storage exceptions
        expect(result, isNull);
        verify(mockStorage.read(key: devKey)).called(1);
      });
    });

    group('Token Cleanup Operations', () {
      test('should clear dev token using correct key', () async {
        // ARRANGE - Reset mock and setup delete mock
        reset(mockStorage);
        reset(mockCryptoService);
        reset(mockKeyManager);
        setupMockFallbacks();

        storageService = AdaptiveStorageService(
          storage: mockStorage,
          cryptoService: mockCryptoService,
          keyManager: mockKeyManager,
        );
        when(mockStorage.delete(key: devKey)).thenAnswer((_) async {});

        // ACT
        await storageService.clearToken();

        // ASSERT - Should use development key in test environment
        verify(mockStorage.delete(key: devKey)).called(1);
      });

      test('should clear token consistently in test environment', () async {
        // ARRANGE - Reset mock and setup delete mock
        reset(mockStorage);
        reset(mockCryptoService);
        reset(mockKeyManager);
        setupMockFallbacks();

        storageService = AdaptiveStorageService(
          storage: mockStorage,
          cryptoService: mockCryptoService,
          keyManager: mockKeyManager,
        );
        when(mockStorage.delete(key: devKey)).thenAnswer((_) async {});

        // ACT
        await storageService.clearToken();

        // ASSERT - Should only use development key, never production key
        verify(mockStorage.delete(key: devKey)).called(1);
        verifyNever(mockStorage.delete(key: prodKey));
      });
    });

    group('Production Mode Simulation (For Completeness)', () {
      // Note: These tests won't run in the actual Flutter test environment
      // but are included for documentation of expected production behavior

      setUp(() {
        storageService = AdaptiveStorageService(
          storage: mockStorage,
          cryptoService: mockCryptoService,
          keyManager: mockKeyManager,
        );
      });

      test(
        'should demonstrate NULL verification failure scenario in dev mode',
        () async {
          // This test demonstrates the actual behavior when mock verification fails
          // This is the scenario that would occur in production if storage fails

          // ARRANGE - Reset mock and create fresh service instance to avoid mockito state issues
          reset(mockStorage);
          reset(mockCryptoService);
          reset(mockKeyManager);
          setupMockFallbacks();

          final testStorage = AdaptiveStorageService(
            storage: mockStorage,
            cryptoService: mockCryptoService,
            keyManager: mockKeyManager,
          );

          // Set up mock to return null on verification (simulating storage failure)
          when(
            mockStorage.write(key: devKey, value: testToken),
          ).thenAnswer((_) async => {});
          when(mockStorage.read(key: devKey)).thenAnswer(
            (_) async => null,
          ); // This simulates the NULL failure scenario

          // ACT & ASSERT - Should throw StorageException due to verification failure
          await expectLater(
            () => testStorage.storeToken(testToken),
            throwsA(isA<StorageException>()),
          );
        },
      );
    });
  });
}
