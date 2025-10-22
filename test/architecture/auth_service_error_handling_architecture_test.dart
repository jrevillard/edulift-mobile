import 'package:test/test.dart';
import 'dart:io';

/// Architectural compliance test for AuthService error handling integration
///
/// This test verifies that:
/// 1. AuthService properly depends on ErrorHandlerService
/// 2. Error handling follows clean architecture principles
/// 3. No direct API error handling bypasses the infrastructure
/// 4. Proper separation of concerns is maintained

void main() {
  group('AuthService Error Handling Architecture Tests', () {
    test('AuthService should import ErrorHandlerService', () async {
      final authServiceFile = File('lib/core/services/auth_service.dart');
      final content = await authServiceFile.readAsString();

      // Verify ErrorHandlerService is imported
      expect(
        content.contains("import '../network/error_handler_service.dart';"),
        isTrue,
        reason: 'AuthService must import ErrorHandlerService for proper error handling',
      );
    });

    test('AuthService should declare ErrorHandlerService dependency', () async {
      final authServiceFile = File('lib/core/services/auth_service.dart');
      final content = await authServiceFile.readAsString();

      // Verify ErrorHandlerService is declared as dependency
      expect(
        content.contains('final ErrorHandlerService _errorHandlerService;'),
        isTrue,
        reason: 'AuthService must declare ErrorHandlerService as a dependency',
      );

      // Verify it's included in constructor
      expect(
        content.contains('this._errorHandlerService,'),
        isTrue,
        reason: 'ErrorHandlerService must be injected through constructor',
      );
    });

    test('AuthService should use ErrorContext.authOperation for error context', () async {
      final authServiceFile = File('lib/core/services/auth_service.dart');
      final content = await authServiceFile.readAsString();

      // Verify proper error context usage
      expect(
        content.contains('ErrorContext.authOperation('),
        isTrue,
        reason: 'AuthService must use ErrorContext.authOperation for auth-specific error context',
      );
    });

    test('AuthService should use ErrorHandlerService.handleError in catch blocks', () async {
      final authServiceFile = File('lib/core/services/auth_service.dart');
      final content = await authServiceFile.readAsString();

      // Verify ErrorHandlerService is used for error handling
      expect(
        content.contains('_errorHandlerService.handleError('),
        isTrue,
        reason: 'AuthService must use ErrorHandlerService.handleError instead of basic error handling',
      );
    });

    test('AuthService should have conversion method for ErrorHandlingResult to Failure', () async {
      final authServiceFile = File('lib/core/services/auth_service.dart');
      final content = await authServiceFile.readAsString();

      // Verify conversion method exists
      expect(
        content.contains('_convertToFailure('),
        isTrue,
        reason: 'AuthService must have conversion method from ErrorHandlingResult to Failure types',
      );

      // Verify proper failure type mapping
      expect(
        content.contains('ValidationFailure('),
        isTrue,
        reason: 'Conversion must map validation errors to ValidationFailure',
      );

      expect(
        content.contains('NetworkFailure('),
        isTrue,
        reason: 'Conversion must map network errors to NetworkFailure',
      );

      expect(
        content.contains('AuthFailure('),
        isTrue,
        reason: 'Conversion must map auth errors to AuthFailure',
      );
    });

    test('Service providers should inject ErrorHandlerService into AuthService', () async {
      final providersFile = File('lib/core/di/providers/service_providers.dart');
      final content = await providersFile.readAsString();

      // Verify ErrorHandlerService is provided
      expect(
        content.contains('ErrorHandlerService coreErrorHandlerService'),
        isTrue,
        reason: 'ErrorHandlerService must be provided in DI container',
      );

      // Verify ErrorHandlerService is injected into AuthService
      expect(
        content.contains('ref.watch(coreErrorHandlerServiceProvider)'),
        isTrue,
        reason: 'ErrorHandlerService must be injected into AuthService via dependency injection',
      );
    });

    test('AuthService should not use basic string matching error handling', () async {
      final authServiceFile = File('lib/core/services/auth_service.dart');
      final content = await authServiceFile.readAsString();

      // Verify no basic string matching error handling remains (from poor fix)
      final basicErrorHandlingPatterns = [
        'if (e.toString().toLowerCase().contains(',
        '.toString().toLowerCase().contains(',
      ];

      for (final pattern in basicErrorHandlingPatterns) {
        expect(
          content.contains(pattern),
          isFalse,
          reason: 'AuthService should not use basic string matching for error handling - should use ErrorHandlerService instead',
        );
      }
    });

    test('Architecture should follow clean architecture principles', () async {
      final authServiceFile = File('lib/core/services/auth_service.dart');
      final content = await authServiceFile.readAsString();

      // Verify imports follow clean architecture - no direct UI dependencies
      final forbiddenImports = [
        'package:flutter/material.dart',
        'package:flutter/widgets.dart',
        'package:flutter/cupertino.dart',
      ];

      for (final import in forbiddenImports) {
        expect(
          content.contains("import '$import'"),
          isFalse,
          reason: 'AuthService should not directly import UI packages - violates clean architecture',
        );
      }

      // Verify proper domain/infrastructure separation
      expect(
        content.contains("import '../domain/"),
        isTrue,
        reason: 'AuthService should depend on domain abstractions',
      );

      expect(
        content.contains("import '../errors/"),
        isTrue,
        reason: 'AuthService should use infrastructure error handling',
      );
    });
  });
}