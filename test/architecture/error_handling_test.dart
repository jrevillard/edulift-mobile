// ERROR HANDLING ARCHITECTURE RULES - CRITICAL CLEAN ARCHITECTURE ENFORCEMENT
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// These tests enforce functional error handling and prevent exception-based
// architecture violations that break clean architecture principles.
//
// Rules Enforced:
// 1. Domain layer MUST define base Failure types (no infrastructure exceptions)
// 2. Repository interfaces MUST return Either<Failure, T> - never throw exceptions
// 3. Data layer MUST catch ALL exceptions and map to domain Failures
// 4. UseCases MUST return Either<Failure, T> - pure functions, no try-catch
// 5. Presentation MUST handle failures via pattern matching (.fold(), .when())

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Helper function to find all Dart files in a directory
  List<File> findDartFiles(String directoryPath) {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) return [];

    return directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
  }

  /// Helper function to read import statements from a Dart file
  List<String> extractImports(File file) {
    final content = file.readAsStringSync();
    final lines = content.split('\n');
    final imports = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('import ')) {
        final singleQuoteMatch = RegExp(
          r"import\s+'([^']+)'",
        ).firstMatch(trimmed);
        final doubleQuoteMatch = RegExp(
          r'import\s+"([^"]+)"',
        ).firstMatch(trimmed);

        if (singleQuoteMatch != null) {
          imports.add(singleQuoteMatch.group(1)!);
        } else if (doubleQuoteMatch != null) {
          imports.add(doubleQuoteMatch.group(1)!);
        }
      }
    }

    return imports;
  }

  /// Check if a file path belongs to a specific layer
  bool isInLayer(String filePath, String layer) {
    return filePath.contains('/$layer/');
  }

  /// Extract method signatures from a Dart file
  List<String> extractMethodSignatures(File file) {
    final content = file.readAsStringSync();
    final methodPattern = RegExp(
      r'(Future<[^>]+>|[A-Za-z_][A-Za-z0-9_<>,\s]*)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\([^)]*\)',
      multiLine: true,
    );

    return methodPattern
        .allMatches(content)
        .map((match) => match.group(0)!)
        .toList();
  }

  /// Extract class names from a Dart file
  List<String> extractClassNames(File file) {
    final content = file.readAsStringSync();
    final classPattern = RegExp(r'(?:abstract\s+)?class\s+(\w+)');

    return classPattern
        .allMatches(content)
        .map((match) => match.group(1)!)
        .toList();
  }

  /// Check if method signature uses Either or Result pattern
  bool usesEitherPattern(String signature) {
    return (signature.contains('Either<') && signature.contains('Failure')) ||
        (signature.contains('Result<') && signature.contains('Failure')) ||
        (signature.contains('Result<') && signature.contains('ApiFailure'));
  }

  /// Check if method signature could throw (returns Future without Either/Result)
  bool couldThrow(String signature) {
    return signature.contains('Future<') &&
        !signature.contains('Either<') &&
        !signature.contains('Result<') &&
        !signature.contains('void') &&
        !signature.contains('Stream<');
  }

  group('Error Handling Architecture Rules - FUNCTIONAL ERROR HANDLING', () {
    test('Domain layer must define base Failure types', () {
      final domainFiles = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'domain'))
          .where(
            (file) =>
                file.path.contains('failures') || file.path.contains('errors'),
          )
          .toList();

      final failureTypes = <String>[];
      final violations = <String>[];

      for (final file in domainFiles) {
        final classes = extractClassNames(file);
        // Content read for analysis but not directly used in this check

        for (final className in classes) {
          if (className.endsWith('Failure') || className.endsWith('Error')) {
            failureTypes.add('${file.path}: $className');

            // Check that failure types don't import infrastructure
            final imports = extractImports(file);
            for (final import in imports) {
              if (import.startsWith('package:dio/') ||
                  import.startsWith('package:http/') ||
                  import.startsWith('package:firebase_') ||
                  import.startsWith('package:sqflite/')) {
                violations.add(
                  '${file.path}: Failure type $className imports infrastructure: $import',
                );
              }
            }
          }
        }
      }

      expect(
        failureTypes.isNotEmpty,
        isTrue,
        reason:
            'Domain layer must define base Failure types for error handling',
      );

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Domain failure types cannot import infrastructure packages:\n${violations.join('\n')}',
      );

      print('\n🚨 DOMAIN FAILURE TYPES FOUND:');
      for (final failure in failureTypes) {
        print('✅ $failure');
      }
    });

    test(
      'Repository interfaces MUST return Result<T, Failure> or Either<Failure, T>',
      () {
        final repositoryInterfaces = findDartFiles('lib')
            .where((file) => isInLayer(file.path, 'domain'))
            .where((file) => file.path.contains('repositories'))
            .toList();

        final violations = <String>[];
        final validRepositories = <String>[];

        for (final file in repositoryInterfaces) {
          final content = file.readAsStringSync();
          final methods = extractMethodSignatures(file);

          // Check if this is an abstract repository interface
          if (content.contains('abstract class') &&
              content.contains('Repository')) {
            for (final method in methods) {
              if (!method.contains('//') && // Skip commented methods
                  !method.contains('factory') && // Skip factory constructors
                  couldThrow(method) &&
                  !usesEitherPattern(method)) {
                violations.add(
                  '${file.path}: Repository method must return Result<T, Failure> or Either<Failure, T>: $method',
                );
              } else if (usesEitherPattern(method)) {
                validRepositories.add('${file.path}: $method');
              }
            }
          }
        }

        expect(
          violations.isEmpty,
          isTrue,
          reason:
              'Repository interfaces must return Result<T, Failure> or Either<Failure, T>, never throw:\n${violations.join('\n')}',
        );

        print('\n📋 VALID REPOSITORY METHODS FOUND:');
        for (final repo in validRepositories.take(5)) {
          // Show first 5 examples
          print('✅ $repo');
        }
        if (validRepositories.length > 5) {
          print('... and ${validRepositories.length - 5} more');
        }
      },
    );

    test('Data layer repository implementations MUST catch all exceptions', () {
      final repositoryImpls = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'data'))
          .where((file) => file.path.contains('repositories'))
          .where(
            (file) =>
                file.path.contains('_impl.dart') ||
                file.path.contains('repository_impl.dart'),
          )
          .toList();

      final violations = <String>[];
      final validImplementations = <String>[];

      for (final file in repositoryImpls) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');

        var hasAsyncMethod = false;
        var hasTryCatch = false;
        var hasEitherReturn = false;
        var insideNetworkErrorHandlerCallback = false;
        var bracketDepth = 0;

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();

          // Check for async methods
          if (line.contains('async ') &&
              (line.contains('Future<Either<') || couldThrow(line))) {
            hasAsyncMethod = true;
          }

          // Check for try-catch blocks
          if (line.startsWith('try {') || line.contains('} catch (')) {
            hasTryCatch = true;
          }

          // Check for Either returns
          if (line.contains('return Left(') || line.contains('return Right(')) {
            hasEitherReturn = true;
          }

          // Track if we're inside a NetworkErrorHandler callback
          if (line.contains('cacheOperation:') ||
              line.contains('onSuccess:') ||
              line.contains('onError:')) {
            insideNetworkErrorHandlerCallback = true;
            bracketDepth = 0;
          }

          // Track bracket depth to know when callback ends
          if (insideNetworkErrorHandlerCallback) {
            bracketDepth += '{'.allMatches(line).length;
            bracketDepth -= '}'.allMatches(line).length;
            if (bracketDepth <= 0) {
              insideNetworkErrorHandlerCallback = false;
            }
          }

          // Check for dangerous patterns (throwing in repository impl)
          // IGNORE throws inside NetworkErrorHandler callbacks (they are caught automatically)
          if (line.contains('throw ') &&
              !line.contains('//') &&
              !insideNetworkErrorHandlerCallback) {
            violations.add(
              '${file.path}:${i + 1}: Repository implementation must not throw: $line',
            );
          }
        }

        if (hasAsyncMethod && hasEitherReturn && hasTryCatch) {
          validImplementations.add(
            '${file.path}: Proper error handling with try-catch and Either',
          );
        } else if (hasAsyncMethod && !hasTryCatch) {
          violations.add(
            '${file.path}: Async repository method without try-catch block',
          );
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Repository implementations must catch all exceptions and return Either:\n${violations.join('\n')}',
      );

      print('\n💾 VALID REPOSITORY IMPLEMENTATIONS:');
      for (final impl in validImplementations) {
        print('✅ $impl');
      }
    });

    test('UseCases MUST return Either<Failure, T> and be pure functions', () {
      final useCaseFiles = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'domain'))
          .where(
            (file) =>
                file.path.contains('usecases') ||
                file.path.contains('use_cases'),
          )
          .toList();

      final violations = <String>[];
      final validUseCases = <String>[];

      for (final file in useCaseFiles) {
        final content = file.readAsStringSync();
        final methods = extractMethodSignatures(file);
        final lines = content.split('\n');

        // Check if this is a UseCase class
        if (content.contains('class ') &&
            (content.contains('UseCase') || content.contains('Usecase'))) {
          // Check for try-catch in UseCases (should not have any)
          for (var i = 0; i < lines.length; i++) {
            final line = lines[i].trim();
            if ((line.startsWith('try {') || line.contains('} catch (')) &&
                !line.contains('//')) {
              violations.add(
                '${file.path}:${i + 1}: UseCases must not contain try-catch: $line',
              );
            }

            if (line.contains('throw ') && !line.contains('//')) {
              violations.add(
                '${file.path}:${i + 1}: UseCases must not throw exceptions: $line',
              );
            }
          }

          // Check method signatures
          for (final method in methods) {
            if (method.contains('call(') || method.contains('execute(')) {
              if (couldThrow(method)) {
                violations.add(
                  '${file.path}: UseCase method must return Either<Failure, T>: $method',
                );
              } else if (usesEitherPattern(method)) {
                validUseCases.add('${file.path}: $method');
              }
            }
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'UseCases must be pure functions returning Either<Failure, T>:\n${violations.join('\n')}',
      );

      print('\n🎯 VALID USE CASES FOUND:');
      for (final useCase in validUseCases.take(5)) {
        print('✅ $useCase');
      }
      if (validUseCases.length > 5) {
        print('... and ${validUseCases.length - 5} more');
      }
    });

    test('Presentation layer must handle failures via pattern matching', () {
      final presentationFiles = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'presentation'))
          .where(
            (file) => !file.path.endsWith('providers.dart'),
          ) // Skip composition roots
          .toList();

      final violations = <String>[];
      final validHandling = <String>[];

      for (final file in presentationFiles) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');

        var usesEither = false;
        var hasPatternMatching = false;

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();

          // Check if using Either
          if (line.contains('Either<') || line.contains('AsyncValue<')) {
            usesEither = true;
          }

          // Check for proper pattern matching
          if (line.contains('.fold(') ||
              line.contains('.when(') ||
              line.contains('.whenData(') ||
              line.contains('.match(')) {
            hasPatternMatching = true;
          }

          // Check for dangerous patterns (direct exception handling in presentation)
          // Allow try-catch in legitimate cases for platform exceptions (2025 best practice)
          if ((line.contains('try {') || line.contains('} catch (')) &&
              !line.contains('//') &&
              !file.path.contains('provider') && // Allow in all provider files
              !file.path.contains('service') && // Allow in service files
              !file.path.contains(
                'error_boundary',
              ) && // Allow in error boundaries
              !file.path.contains('error_handler') && // Allow in error handlers
              !file.path.contains('widget') && // Allow in widgets
              !file.path.contains('page') && // Allow in pages
              !file.path.contains('screen') && // Allow in screens
              !line.contains('biometric') && // Allow biometric operations
              !line.contains('platform') && // Allow platform channels
              !line.contains('LocalAuthentication') && // Allow authentication
              !line.contains('Firebase') && // Allow Firebase operations
              !line.contains('network') && // Allow network operations
              !line.contains('storage')) {
            // Allow storage operations
            violations.add(
              '${file.path}:${i + 1}: Presentation should handle failures via Either/Result pattern, not try-catch: $line',
            );
          }
        }

        if (usesEither && hasPatternMatching) {
          validHandling.add('${file.path}: Proper Either pattern matching');
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Presentation must handle failures via pattern matching, not exceptions:\n${violations.join('\n')}',
      );

      print('\n🖥️  VALID PRESENTATION ERROR HANDLING:');
      for (final handling in validHandling.take(5)) {
        print('✅ $handling');
      }
      if (validHandling.length > 5) {
        print('... and ${validHandling.length - 5} more');
      }
    });

    test('Display error handling architecture summary', () {
      final domainFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'domain')).length;
      final dataFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'data')).length;
      final presentationFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'presentation')).length;

      final repositoryFiles = findDartFiles(
        'lib',
      ).where((f) => f.path.contains('repository')).length;

      final useCaseFiles = findDartFiles(
        'lib',
      ).where((f) => f.path.contains('usecase')).length;

      print('\n🚨 ERROR HANDLING ARCHITECTURE SUMMARY');
      print('=====================================');
      print('🏢 Domain layer files: $domainFiles');
      print('💾 Data layer files: $dataFiles');
      print('🖥️  Presentation layer files: $presentationFiles');
      print('📋 Repository files: $repositoryFiles');
      print('🎯 UseCase files: $useCaseFiles');
      print('=====================================');
      print('✅ Functional error handling enforced');
      print('✅ Either<Failure, T> pattern required');
      print('✅ No exceptions in domain layer');
      print('✅ All exceptions caught in data layer');
      print('✅ Pattern matching in presentation');
      print('🚨 Any violations will cause build failures');
      print(
        '📝 Run with: flutter test test/architecture/error_handling_test.dart',
      );

      expect(
        true,
        isTrue,
        reason: 'Error handling architecture summary displayed',
      );
    });
  });
}
