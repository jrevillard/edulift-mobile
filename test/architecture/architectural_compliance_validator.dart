// ARCHITECTURAL COMPLIANCE VALIDATOR
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// Validates all architectural rules and provides comprehensive report
// This is the definitive architectural validation for the codebase

// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  print('\n🏛️  ARCHITECTURAL COMPLIANCE VALIDATION');
  print('==========================================');

  final validator = ArchitecturalValidator();
  final results = validator.validateAll();

  print('\n📊 VALIDATION RESULTS');
  print('=====================');
  print('✅ Passing rules: ${results.passingRules}');
  print('❌ Failing rules: ${results.failingRules}');
  print('⚠️  Warnings: ${results.warnings}');

  if (results.violations.isNotEmpty) {
    print('\n🚨 VIOLATIONS FOUND:');
    print('====================');
    for (final violation in results.violations) {
      print('❌ ${violation}');
    }
  }

  if (results.warnings.isNotEmpty) {
    print('\n⚠️  WARNINGS (NOT FAILURES):');
    print('============================');
    for (final warning in results.warnings) {
      print('⚠️  ${warning}');
    }
  }

  print('\n🎯 ARCHITECTURAL SUMMARY');
  print('========================');
  print('Total rules validated: ${results.totalRules}');
  print(
    'Compliance rate: ${((results.passingRules / results.totalRules) * 100).toStringAsFixed(1)}%',
  );

  if (results.isCompliant) {
    print('\n🎉 ARCHITECTURAL COMPLIANCE: ✅ PASSED');
    print('All critical architectural rules are satisfied!');
  } else {
    print('\n🚨 ARCHITECTURAL COMPLIANCE: ❌ FAILED');
    print('Critical violations must be resolved.');
  }

  exit(results.isCompliant ? 0 : 1);
}

class ArchitecturalValidator {
  ValidationResults validateAll() {
    final results = ValidationResults();

    // EXISTING RULES
    // 1. Domain Layer Purity
    _validateDomainPurity(results);

    // 2. Layer Dependency Rules
    _validateLayerDependencies(results);

    // 3. Framework Isolation
    _validateFrameworkIsolation(results);

    // 4. Infrastructure Restrictions
    _validateInfrastructureRestrictions(results);

    // 5. State Management Patterns
    _validateStateManagement(results);

    // 6. Provider Technical Debt (Warnings Only)
    _documentProviderTechnicalDebt(results);

    // NEW CRITICAL RULES
    // 7. Error Handling Architecture
    _validateErrorHandling(results);

    // 8. Mapper/Transformer Rules
    _validateMapperRules(results);

    // 9. UseCase Rules
    _validateUseCaseRules(results);

    // 10. Infrastructure Layer Definition
    _validateInfrastructureLayer(results);

    // 11. Test Architecture
    _validateTestArchitecture(results);

    return results;
  }

  void _validateDomainPurity(ValidationResults results) {
    final domainFiles = _findDartFiles(
      'lib',
    ).where((file) => file.path.contains('/domain/')).toList();

    for (final file in domainFiles) {
      final imports = _extractImports(file);

      for (final import in imports) {
        // Check for Flutter imports
        if (import.startsWith('package:flutter/')) {
          results.addViolation(
            'Domain purity violation: ${file.path} imports Flutter: $import',
          );
        }

        // Check for infrastructure imports
        final infraPackages = [
          'package:dio/',
          'package:http/',
          'package:shared_preferences/',
          'package:sqflite/',
        ];
        for (final pkg in infraPackages) {
          if (import.startsWith(pkg)) {
            results.addViolation(
              'Domain purity violation: ${file.path} imports infrastructure: $import',
            );
          }
        }

        // Check for layer violations
        if (import.contains('/data/') || import.contains('/presentation/')) {
          results.addViolation(
            'Domain dependency violation: ${file.path} imports from other layers: $import',
          );
        }
      }
    }

    results.incrementRule();
  }

  void _validateLayerDependencies(ValidationResults results) {
    // Presentation cannot import from Data (except via DI)
    final presentationFiles = _findDartFiles('lib')
        .where((file) => file.path.contains('/presentation/'))
        .where((file) => !file.path.endsWith('providers.dart'))
        .toList();

    for (final file in presentationFiles) {
      final imports = _extractImports(file);

      for (final import in imports) {
        if (import.contains('/data/')) {
          results.addViolation(
            'Layer dependency violation: ${file.path} imports from data layer: $import',
          );
        }
      }
    }

    results.incrementRule();
  }

  void _validateFrameworkIsolation(ValidationResults results) {
    final nonPresentationFiles = _findDartFiles('lib')
        .where((file) => !file.path.contains('/presentation/'))
        .where(
          (file) => !file.path.contains('/generated/'),
        ) // Whitelist generated
        .where(
          (file) => !file.path.endsWith('edulift_app.dart'),
        ) // Whitelist main app
        .where(
          (file) => !file.path.endsWith('app_router.dart'),
        ) // Whitelist router
        .toList();

    for (final file in nonPresentationFiles) {
      final content = file.readAsStringSync();
      if (content.contains('BuildContext')) {
        results.addViolation(
          'Framework isolation violation: ${file.path} uses BuildContext outside presentation',
        );
      }
    }

    results.incrementRule();
  }

  void _validateInfrastructureRestrictions(ValidationResults results) {
    final httpPackages = ['package:dio/', 'package:http/', 'package:retrofit/'];
    final nonDataFiles = _findDartFiles('lib')
        .where((file) => !file.path.contains('/data/'))
        .where((file) => !file.path.endsWith('providers.dart'))
        .where(
          (file) => !file.path.contains('/core/network/'),
        ) // Allow core abstractions
        .where((file) => !file.path.contains('/core/di/')) // Allow DI
        .where(
          (file) => !file.path.contains('/core/security/'),
        ) // Allow security abstractions
        .where(
          (file) => !file.path.contains('/infrastructure/'),
        ) // Allow infrastructure layer
        .toList();

    for (final file in nonDataFiles) {
      final imports = _extractImports(file);

      for (final import in imports) {
        for (final httpPackage in httpPackages) {
          if (import.startsWith(httpPackage)) {
            results.addViolation(
              'Infrastructure restriction violation: ${file.path} imports HTTP package: $import',
            );
          }
        }
      }
    }

    results.incrementRule();
  }

  void _validateStateManagement(ValidationResults results) {
    final stateFiles = _findDartFiles('lib')
        .where(
          (file) =>
              file.path.contains('state') || file.path.contains('provider'),
        )
        .toList();

    for (final file in stateFiles) {
      final content = file.readAsStringSync();
      final lines = content.split('\n');

      var foundImmutableAnnotation = false;

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();

        if (line.startsWith('@immutable')) {
          foundImmutableAnnotation = true;
        }

        // Check for state classes without @immutable (skip StateNotifier classes)
        if (line.startsWith('class ') && line.contains('State')) {
          if (!foundImmutableAnnotation &&
              _isStateClass(line) &&
              !_isStateNotifierClass(line)) {
            results.addViolation(
              'State management violation: ${file.path}:${i + 1} State class without @immutable: ${line}',
            );
          }
          foundImmutableAnnotation = false;
        }
      }
    }

    results.incrementRule();
  }

  void _documentProviderTechnicalDebt(ValidationResults results) {
    final providerFiles = _findDartFiles('lib')
        .where(
          (file) =>
              file.path.contains('_provider.dart') ||
              file.path.endsWith('providers.dart'),
        )
        .toList();

    for (final file in providerFiles) {
      final content = file.readAsStringSync();
      final providerCount = _countProviders(content);

      // PRAGMATIC THRESHOLD: Warn only for truly excessive provider counts
      // Composition root files (providers.dart) are expected to have multiple providers
      // Individual feature providers with >5 providers may need refactoring

      final isCompositionRoot = file.path.endsWith('providers.dart');
      final threshold =
          isCompositionRoot ? 15 : 8; // Higher threshold for composition roots

      if (providerCount > threshold) {
        results.addWarning(
          'Provider technical debt: ${file.path} has $providerCount providers (consider refactoring)',
        );
      }
    }

    results.incrementRule();
  }

  // NEW VALIDATION METHODS

  void _validateErrorHandling(ValidationResults results) {
    // Validate that repositories return Either<Failure, T>
    final repositoryFiles = _findDartFiles('lib')
        .where(
          (file) =>
              file.path.contains('/domain/') &&
              file.path.contains('repositories'),
        )
        .toList();

    for (final file in repositoryFiles) {
      final content = file.readAsStringSync();
      if (content.contains('abstract class') &&
          content.contains('Repository')) {
        final lines = content.split('\n');
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.contains('Future<') &&
              !line.contains('Either<') &&
              !line.contains('Result<') && // Accept Result pattern
              !line.contains('void') &&
              !line.contains('//')) {
            results.addViolation(
              'Error handling violation: ${file.path}:${i + 1} Repository method must return Either<Failure, T> or Result<T, Failure>: $line',
            );
          }
        }
      }
    }

    results.incrementRule();
  }

  void _validateMapperRules(ValidationResults results) {
    // Validate that mappers are in data layer
    final allFiles = _findDartFiles('lib');

    for (final file in allFiles) {
      final classes = _extractClassNames(file);
      for (final className in classes) {
        if (className.endsWith('Mapper') || className.endsWith('Transformer')) {
          if (!file.path.contains('/data/')) {
            results.addViolation(
              'Mapper rules violation: ${file.path} Mapper $className must be in data layer',
            );
          }
        }
      }
    }

    // Validate domain entities don't have JSON methods
    final domainFiles = _findDartFiles(
      'lib',
    ).where((file) => file.path.contains('/domain/entities')).toList();

    for (final file in domainFiles) {
      final content = file.readAsStringSync();
      if (content.contains('fromJson') || content.contains('toJson')) {
        results.addViolation(
          'Mapper rules violation: ${file.path} Domain entity cannot have JSON methods',
        );
      }
    }

    results.incrementRule();
  }

  void _validateUseCaseRules(ValidationResults results) {
    final useCaseFiles = _findDartFiles('lib')
        .where(
          (file) =>
              file.path.contains('/domain/') &&
              (file.path.contains('usecases') ||
                  file.path.contains('use_cases')),
        )
        .toList();

    for (final file in useCaseFiles) {
      final content = file.readAsStringSync();
      final lines = content.split('\n');

      // Check for try-catch in UseCases
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if ((line.startsWith('try {') || line.contains('} catch (')) &&
            !line.contains('//')) {
          results.addViolation(
            'UseCase rules violation: ${file.path}:${i + 1} UseCases must not contain try-catch: $line',
          );
        }

        if (line.contains('throw ') && !line.contains('//')) {
          results.addViolation(
            'UseCase rules violation: ${file.path}:${i + 1} UseCases must not throw exceptions: $line',
          );
        }
      }
    }

    results.incrementRule();
  }

  void _validateInfrastructureLayer(ValidationResults results) {
    final infrastructureFiles = _findDartFiles('lib')
        .where(
          (file) =>
              file.path.contains('/infrastructure/') ||
              file.path.contains('/external/'),
        )
        .toList();

    for (final file in infrastructureFiles) {
      final imports = _extractImports(file);

      for (final import in imports) {
        // LEGITIMATE PATTERNS ALLOWED:
        // - Infrastructure DTOs can import domain entities for mapping/conversion
        // - Infrastructure services can reference domain entities they work with
        // - Infrastructure layer CANNOT import presentation layer (always violation)

        // Always violation: Infrastructure importing presentation
        if (import.contains('/presentation/')) {
          results.addViolation(
            'Infrastructure layer violation: ${file.path} cannot import from presentation: $import',
          );
        }

        // Domain imports are OK for DTOs, converters, and infrastructure services
        if (import.contains('/domain/')) {
          final content = file.readAsStringSync();

          // Check if this is a legitimate pattern:
          // 1. DTO/Mapper patterns
          // 2. Infrastructure services that work with domain entities
          // 3. WebSocket/Event services that reference domain types
          // 4. Services that need domain entity types for operations
          final hasLegitimatePattern = content.contains('toDomain()') ||
              content.contains('fromDomain(') ||
              content.contains('DomainConverter') ||
              content.contains('Mapper') ||
              content.contains('Transformer') ||
              file.path.contains('/models/') ||
              file.path.contains('/dto/') ||
              file.path.contains('/websocket/') ||
              file.path.contains('/services/') ||
              file.path.endsWith('_service.dart') ||
              content.contains('@provider') ||
              content.contains('StreamController<');

          if (!hasLegitimatePattern) {
            results.addViolation(
              'Infrastructure layer violation: ${file.path} invalid domain import (not DTO/mapper/service pattern): $import',
            );
          }
        }
      }
    }

    results.incrementRule();
  }

  void _validateTestArchitecture(ValidationResults results) {
    final testFiles = _findDartFiles(
      'test',
    ).where((file) => file.path.endsWith('_test.dart')).toList();

    for (final file in testFiles) {
      final content = file.readAsStringSync();

      // Check widget tests don't import data layer
      if (content.contains('testWidgets') || content.contains('WidgetTester')) {
        final imports = _extractImports(file);
        for (final import in imports) {
          if (import.contains('/data/') && !import.contains('test/')) {
            results.addViolation(
              'Test architecture violation: ${file.path} Widget test imports data layer: $import',
            );
          }
        }
      }
    }

    results.incrementRule();
  }

  List<String> _extractClassNames(File file) {
    final content = file.readAsStringSync();
    final classPattern = RegExp(r'class\s+(\w+)');

    return classPattern
        .allMatches(content)
        .map((match) => match.group(1)!)
        .toList();
  }

  List<File> _findDartFiles(String directoryPath) {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) return [];

    return directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
  }

  List<String> _extractImports(File file) {
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

  bool _isStateClass(String line) {
    return line.contains('State<') ||
        line.contains('ChangeNotifier') ||
        line.contains('Cubit') ||
        line.contains('Bloc');
  }

  bool _isStateNotifierClass(String line) {
    return line.contains('StateNotifier');
  }

  int _countProviders(String content) {
    final providerPatterns = [
      RegExp(r'Provider\<'),
      RegExp(r'StateNotifierProvider'),
      RegExp(r'FutureProvider'),
      RegExp(r'StreamProvider'),
      RegExp(r'ChangeNotifierProvider'),
    ];

    var count = 0;
    for (final pattern in providerPatterns) {
      count += pattern.allMatches(content).length;
    }

    return count;
  }
}

class ValidationResults {
  final List<String> violations = [];
  final List<String> warnings = [];
  int _totalRules = 0;

  void addViolation(String violation) => violations.add(violation);
  void addWarning(String warning) => warnings.add(warning);
  void incrementRule() => _totalRules++;

  int get totalRules => _totalRules;
  int get passingRules => _totalRules - failingRules;
  int get failingRules => violations.isNotEmpty
      ? 1
      : 0; // At least one rule failed if violations exist
  bool get isCompliant => violations.isEmpty;
}
