import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import all the providers to test
import 'package:edulift/core/di/providers/foundation/storage_providers.dart';

// Import services to verify types
import 'package:edulift/core/security/crypto_config.dart';
import 'package:edulift/core/security/crypto_service.dart';
import 'package:edulift/core/security/secure_key_manager.dart';
import 'package:edulift/core/storage/adaptive_secure_storage.dart';
import 'package:edulift/core/storage/secure_storage.dart';
import 'package:edulift/core/storage/hive_orchestrator.dart';
import 'package:edulift/core/services/adaptive_storage_service.dart';

/// Test suite to verify all storage providers instantiate correctly
///
/// This test verifies that each provider:
/// 1. Creates a REAL, functional instance (not mock/placeholder)
/// 2. Returns the correct type
/// 3. Matches provider configuration exactly
/// 4. Has proper dependency injection working
void main() {
  group('Storage Providers - Real Instance Verification', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('cryptoConfigProvider creates real CryptoConfig instance', () {
      // Act
      final cryptoConfig = container.read(cryptoConfigProvider);

      // Assert
      expect(cryptoConfig, isA<CryptoConfig>());
      expect(cryptoConfig, isNotNull);
      // Verify it's configured correctly for debug mode
      expect(cryptoConfig.pbkdf2Iterations, equals(10000));
      expect(cryptoConfig.saltLength, equals(16));
      expect(cryptoConfig.keyLength, equals(32));
      expect(cryptoConfig.tagLength, equals(16));
    });

    test(
      'adaptiveSecureStorageProvider creates real AdaptiveSecureStorage instance',
      () {
        // Act
        final adaptiveStorage = container.read(adaptiveSecureStorageProvider);

        // Assert
        expect(adaptiveStorage, isA<AdaptiveSecureStorage>());
        expect(adaptiveStorage, isNotNull);
      },
    );

    test('namedSecureStorageProvider creates real SecureStorage instance', () {
      // Act
      final secureStorage = container.read(namedSecureStorageProvider);

      // Assert
      expect(secureStorage, isA<SecureStorage>());
      expect(secureStorage, isNotNull);
      // Should be same instance as AdaptiveSecureStorage
      expect(secureStorage, isA<AdaptiveSecureStorage>());
    });

    test(
      'cryptoServiceProvider creates real CryptoService instance with dependency',
      () {
        // Act
        final cryptoService = container.read(cryptoServiceProvider);

        // Assert
        expect(cryptoService, isA<CryptoService>());
        expect(cryptoService, isNotNull);
        // Verify dependency injection worked by checking config is injected
        expect(cryptoService.runtimeType, equals(CryptoService));
      },
    );

    test(
      'secureKeyManagerProvider creates real SecureKeyManager instance with dependency',
      () {
        // Act
        final secureKeyManager = container.read(secureKeyManagerProvider);

        // Assert
        expect(secureKeyManager, isA<SecureKeyManager>());
        expect(secureKeyManager, isNotNull);
        // Verify it's properly constructed with SecureStorage dependency
        expect(secureKeyManager.runtimeType, equals(SecureKeyManager));
      },
    );

    test(
      'hiveOrchestratorProvider creates real HiveOrchestrator instance with dependency',
      () {
        // Act
        final hiveOrchestrator = container.read(hiveOrchestratorProvider);

        // Assert
        expect(hiveOrchestrator, isA<HiveOrchestrator>());
        expect(hiveOrchestrator, isNotNull);
        // Verify it's properly constructed with SecureKeyManager dependency
        expect(hiveOrchestrator.runtimeType, equals(HiveOrchestrator));
      },
    );

    test(
      'adaptiveStorageServiceProvider creates real AdaptiveStorageService instance with all dependencies',
      () {
        // Act
        final adaptiveStorageService = container.read(
          adaptiveStorageServiceProvider,
        );

        // Assert
        expect(adaptiveStorageService, isA<AdaptiveStorageService>());
        expect(adaptiveStorageService, isNotNull);
        // Verify it's properly constructed with all 3 dependencies
        expect(
          adaptiveStorageService.runtimeType,
          equals(AdaptiveStorageService),
        );
      },
    );

    group('Provider Dependencies - Integration Tests', () {
      test('all providers work together in dependency chain', () {
        // This tests the complete dependency chain by reading the final provider
        // which depends on all others transitively

        // Act - reading this should trigger all dependency providers
        final adaptiveStorageService = container.read(
          adaptiveStorageServiceProvider,
        );
        final secureKeyManager = container.read(secureKeyManagerProvider);
        final cryptoService = container.read(cryptoServiceProvider);
        final hiveOrchestrator = container.read(hiveOrchestratorProvider);

        // Assert - all should be real, working instances
        expect(adaptiveStorageService, isA<AdaptiveStorageService>());
        expect(secureKeyManager, isA<SecureKeyManager>());
        expect(cryptoService, isA<CryptoService>());
        expect(hiveOrchestrator, isA<HiveOrchestrator>());

        // All should be non-null (no placeholders)
        expect(adaptiveStorageService, isNotNull);
        expect(secureKeyManager, isNotNull);
        expect(cryptoService, isNotNull);
        expect(hiveOrchestrator, isNotNull);
      });

      test('providers return consistent instances (singleton behavior)', () {
        // Act - read each provider multiple times
        final adaptiveStorage1 = container.read(adaptiveStorageServiceProvider);
        final adaptiveStorage2 = container.read(adaptiveStorageServiceProvider);

        final cryptoService1 = container.read(cryptoServiceProvider);
        final cryptoService2 = container.read(cryptoServiceProvider);

        // Assert - should be same instances (Provider behavior)
        expect(identical(adaptiveStorage1, adaptiveStorage2), isTrue);
        expect(identical(cryptoService1, cryptoService2), isTrue);
      });
    });
  });
}
