// USECASE ARCHITECTURE RULES - DOMAIN LAYER PURITY ENFORCEMENT
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// These tests enforce UseCase purity and proper functional patterns
// to maintain clean separation between business logic and infrastructure.
//
// Rules Enforced:
// 1. ALL UseCases MUST return Future<Either<Failure, T>>
// 2. UseCases CANNOT return void (must be functional)
// 3. UseCases CANNOT throw exceptions (pure functions)
// 4. UseCases MUST have single public method (call or execute)
// 5. UseCases MUST be in domain layer only
// 6. UseCases CANNOT import from data or presentation layers

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

  /// Extract class names from a Dart file
  List<String> extractClassNames(File file) {
    final content = file.readAsStringSync();
    final classPattern = RegExp(r'class\s+(\w+)');

    return classPattern
        .allMatches(content)
        .map((match) => match.group(1)!)
        .toList();
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

  /// Check if method signature uses Either or Result pattern (both valid in 2025)
  bool usesEitherPattern(String signature) {
    return (signature.contains('Either<') &&
            signature.contains('Failure') &&
            signature.contains('>')) ||
        (signature.contains('Result<') &&
            signature.contains('Failure') &&
            signature.contains('>'));
  }

  /// Check if method signature returns void
  bool returnsVoid(String signature) {
    return signature.trim().startsWith('void ');
  }

  /// Check if method signature could throw (returns Future without Either/Result)
  bool couldThrow(String signature) {
    return signature.contains('Future<') &&
        !signature.contains('Either<') &&
        !signature.contains('Result<') &&
        !signature.contains('void') &&
        !signature.contains('Stream<');
  }

  /// Check if class is a UseCase
  bool isUseCaseClass(String className) {
    return className.endsWith('UseCase') || className.endsWith('Usecase');
  }

  /// Count public methods in a class
  int countPublicMethods(File file, String className) {
    final content = file.readAsStringSync();
    final classMatch = RegExp(
      'class\\s+$className[^{]*\\{([^}]*(?:\\{[^}]*\\}[^}]*)*)\\}',
    ).firstMatch(content);

    if (classMatch == null) return 0;

    final classBody = classMatch.group(1)!;
    final publicMethodPattern = RegExp(
      r'^\s*(?!_)[A-Za-z_][A-Za-z0-9_<>,\s]*\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\([^)]*\)\s*(?:async\s*)?{',
      multiLine: true,
    );

    return publicMethodPattern.allMatches(classBody).length;
  }

  group('UseCase Architecture Rules - DOMAIN LAYER BUSINESS LOGIC', () {
    test('UseCases MUST be in domain layer only', () {
      final allFiles = findDartFiles('lib');
      final violations = <String>[];
      final validUseCases = <String>[];

      for (final file in allFiles) {
        final classes = extractClassNames(file);

        for (final className in classes) {
          if (isUseCaseClass(className)) {
            if (isInLayer(file.path, 'domain')) {
              validUseCases.add('${file.path}: $className');
            } else {
              violations.add(
                '${file.path}: UseCase $className must be in domain layer',
              );
            }
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'UseCases must be in domain layer only:\n${violations.join('\n')}',
      );

      print('\n🎯 VALID USECASES IN DOMAIN LAYER:');
      for (final useCase in validUseCases) {
        print('✅ $useCase');
      }

      if (validUseCases.isEmpty) {
        print(
          '⚠️  No UseCases found - consider adding business logic encapsulation',
        );
      }
    });

    test(
      'UseCases MUST return Future<Result<T, Failure>> or Future<Either<Failure, T>>',
      () {
        final useCaseFiles = findDartFiles('lib')
            .where((file) => isInLayer(file.path, 'domain'))
            .where(
              (file) =>
                  file.path.contains('usecases') ||
                  file.path.contains('use_cases'),
            )
            .toList();

        final violations = <String>[];
        final validReturnTypes = <String>[];

        for (final file in useCaseFiles) {
          final classes = extractClassNames(file);

          for (final className in classes) {
            if (isUseCaseClass(className)) {
              final methods = extractMethodSignatures(file);

              for (final method in methods) {
                // Check main execution methods
                if (method.contains('call(') ||
                    method.contains('execute(') ||
                    method.contains('invoke(')) {
                  if (returnsVoid(method)) {
                    violations.add(
                      '${file.path}: UseCase $className method cannot return void: $method',
                    );
                  } else if (couldThrow(method)) {
                    violations.add(
                      '${file.path}: UseCase $className must return Result<T, Failure> or Either<Failure, T>: $method',
                    );
                  } else if (usesEitherPattern(method)) {
                    validReturnTypes.add('${file.path}: $className.$method');
                  }
                }
              }
            }
          }
        }

        expect(
          violations.isEmpty,
          isTrue,
          reason:
              'UseCases must return Future<Either<Failure, T>>:\n${violations.join('\n')}',
        );

        print('\n✅ VALID USECASE RETURN TYPES:');
        for (final returnType in validReturnTypes.take(10)) {
          print('✅ $returnType');
        }
        if (validReturnTypes.length > 10) {
          print('... and ${validReturnTypes.length - 10} more');
        }
      },
    );

    test('UseCases CANNOT throw exceptions (pure functions)', () {
      final useCaseFiles = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'domain'))
          .where(
            (file) =>
                file.path.contains('usecases') ||
                file.path.contains('use_cases'),
          )
          .toList();

      final violations = <String>[];
      final pureUseCases = <String>[];

      for (final file in useCaseFiles) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');
        final classes = extractClassNames(file);

        var hasTryCatch = false;
        var hasThrow = false;

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();

          // Check for try-catch blocks
          if ((line.startsWith('try {') || line.contains('} catch (')) &&
              !line.contains('//')) {
            hasTryCatch = true;
            violations.add(
              '${file.path}:${i + 1}: UseCases must not contain try-catch: $line',
            );
          }

          // Check for throw statements
          if (line.contains('throw ') && !line.contains('//')) {
            hasThrow = true;
            violations.add(
              '${file.path}:${i + 1}: UseCases must not throw exceptions: $line',
            );
          }
        }

        if (!hasTryCatch &&
            !hasThrow &&
            classes.any((c) => isUseCaseClass(c))) {
          pureUseCases.add('${file.path}: Pure UseCase (no exceptions)');
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'UseCases must be pure functions without exceptions:\n${violations.join('\n')}',
      );

      print('\n🧘 PURE USECASES (NO EXCEPTIONS):');
      for (final pureUseCase in pureUseCases) {
        print('✅ $pureUseCase');
      }
    });

    test('UseCases MUST have single public method (single responsibility)', () {
      final useCaseFiles = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'domain'))
          .where(
            (file) =>
                file.path.contains('usecases') ||
                file.path.contains('use_cases'),
          )
          .toList();

      final violations = <String>[];
      final validSingleMethods = <String>[];

      for (final file in useCaseFiles) {
        final classes = extractClassNames(file);

        for (final className in classes) {
          if (isUseCaseClass(className)) {
            final publicMethodCount = countPublicMethods(file, className);

            if (publicMethodCount > 1) {
              violations.add(
                '${file.path}: UseCase $className has $publicMethodCount public methods (should have 1)',
              );
            } else if (publicMethodCount == 1) {
              validSingleMethods.add('${file.path}: $className');
            }
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'UseCases must have single public method (call/execute):\n${violations.join('\n')}',
      );

      print('\n🎯 USECASES WITH SINGLE RESPONSIBILITY:');
      for (final singleMethod in validSingleMethods) {
        print('✅ $singleMethod');
      }
    });

    test('UseCases CANNOT import from data or presentation layers', () {
      final useCaseFiles = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'domain'))
          .where(
            (file) =>
                file.path.contains('usecases') ||
                file.path.contains('use_cases'),
          )
          .toList();

      final violations = <String>[];
      final cleanUseCases = <String>[];

      for (final file in useCaseFiles) {
        final imports = extractImports(file);
        final classes = extractClassNames(file);

        var hasViolation = false;

        for (final import in imports) {
          // Check for data layer imports
          if (import.contains('/data/')) {
            violations.add(
              '${file.path}: UseCase imports from data layer: $import',
            );
            hasViolation = true;
          }

          // Check for presentation layer imports
          if (import.contains('/presentation/')) {
            violations.add(
              '${file.path}: UseCase imports from presentation layer: $import',
            );
            hasViolation = true;
          }

          // Check for Flutter imports (should be domain-pure)
          if (import.startsWith('package:flutter/') &&
              !import.contains('foundation.dart')) {
            // Allow @immutable
            violations.add(
              '${file.path}: UseCase imports Flutter framework: $import',
            );
            hasViolation = true;
          }
        }

        if (!hasViolation && classes.any((c) => isUseCaseClass(c))) {
          cleanUseCases.add(
            '${file.path}: Clean UseCase (domain-only imports)',
          );
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'UseCases must only import from domain layer:\n${violations.join('\n')}',
      );

      print('\n🧼 CLEAN USECASES (DOMAIN-ONLY IMPORTS):');
      for (final cleanUseCase in cleanUseCases) {
        print('✅ $cleanUseCase');
      }
    });

    test('UseCases MUST follow proper constructor injection', () {
      final useCaseFiles = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'domain'))
          .where(
            (file) =>
                file.path.contains('usecases') ||
                file.path.contains('use_cases'),
          )
          .toList();

      final violations = <String>[];
      final validInjection = <String>[];

      for (final file in useCaseFiles) {
        final content = file.readAsStringSync();
        final classes = extractClassNames(file);

        for (final className in classes) {
          if (isUseCaseClass(className)) {
            // Check for constructor injection pattern
            final constructorPattern = RegExp('$className\\s*\\([^)]*\\)');
            final constructorMatch = constructorPattern.firstMatch(content);

            if (constructorMatch != null) {
              final constructor = constructorMatch.group(0)!;

              // Check if constructor uses dependency injection
              if (constructor.contains('this.') ||
                  constructor.contains('required ')) {
                validInjection.add(
                  '${file.path}: $className uses constructor injection',
                );
              } else if (!constructor.contains('()')) {
                // Has parameters but not following DI pattern
                violations.add(
                  '${file.path}: UseCase $className constructor should use dependency injection',
                );
              }
            }

            // Check for static dependencies (anti-pattern)
            if (content.contains('static ') &&
                content.contains('Repository') &&
                !content.contains('//')) {
              violations.add(
                '${file.path}: UseCase $className uses static dependencies (use injection)',
              );
            }

            // Check for direct instantiation of repositories (improved detection)
            // Look for patterns like: Repository() or new Repository()
            // But exclude: this._repository or _repository or Repository _repo
            final instantiationPattern = RegExp(
              r'(?<!this\.|_)\b[A-Z]\w*Repository\s*\(',
            );
            if (instantiationPattern.hasMatch(content) &&
                !content.contains('final') &&
                !content.contains('required')) {
              // Check if it's actually instantiation, not just a constructor parameter
              final matches = instantiationPattern.allMatches(content);
              for (final match in matches) {
                final matchStr = match.group(0)!;
                // Skip if it's in a type annotation or parameter list
                if (!matchStr.contains('this.') &&
                    !matchStr.contains('required')) {
                  violations.add(
                    '${file.path}: UseCase $className directly instantiates repository (use injection)',
                  );
                  break;
                }
              }
            }
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'UseCases must use proper dependency injection:\n${violations.join('\n')}',
      );

      print('\n💉 USECASES WITH PROPER DEPENDENCY INJECTION:');
      for (final injection in validInjection) {
        print('✅ $injection');
      }
    });

    test('Display UseCase architecture summary', () {
      final domainFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'domain')).length;

      final useCaseFiles = findDartFiles('lib')
          .where(
            (file) =>
                isInLayer(file.path, 'domain') &&
                (file.path.contains('usecases') ||
                    file.path.contains('use_cases')),
          )
          .length;

      final totalUseCases = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'domain'))
          .map((file) => extractClassNames(file))
          .expand((classes) => classes)
          .where((className) => isUseCaseClass(className))
          .length;

      final repositoryFiles = findDartFiles('lib')
          .where(
            (file) =>
                isInLayer(file.path, 'domain') &&
                file.path.contains('repositories'),
          )
          .length;

      print('\n🎯 USECASE ARCHITECTURE SUMMARY');
      print('================================');
      print('🏛️  Domain layer files: $domainFiles');
      print('📁 UseCase directories: $useCaseFiles');
      print('🎯 Total UseCase classes: $totalUseCases');
      print('📋 Repository interfaces: $repositoryFiles');
      print('================================');
      print('✅ UseCases restricted to domain layer');
      print('✅ Functional error handling enforced (Either)');
      print('✅ Pure functions (no exceptions)');
      print('✅ Single responsibility principle');
      print('✅ Proper dependency injection');
      print('✅ Layer isolation maintained');
      print('🚨 Any violations will cause build failures');
      print(
        '📝 Run with: flutter test test/architecture/usecase_rules_test.dart',
      );

      expect(true, isTrue, reason: 'UseCase architecture summary displayed');
    });
  });
}
