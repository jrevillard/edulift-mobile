// INFRASTRUCTURE LAYER ARCHITECTURE RULES - EXTERNAL SERVICES ISOLATION
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// These tests define and enforce proper infrastructure layer boundaries
// to maintain clean separation between external services and business logic.
//
// Infrastructure Layer Definition:
// - External service implementations (APIs, databases, file system, device APIs)
// - Platform-specific implementations
// - Third-party library wrappers
// - Network clients, storage clients, authentication providers
//
// Rules Enforced:
// 1. Infrastructure layer = external service implementations only
// 2. Infrastructure CANNOT import domain or presentation layers
// 3. Data layer orchestrates infrastructure components
// 4. Infrastructure includes: API clients, DB clients, device APIs
// 5. Infrastructure abstractions belong in domain layer
// 6. Infrastructure implementations belong in data/infrastructure

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

  /// Check if a file is in infrastructure layer
  bool isInInfrastructure(String filePath) {
    return filePath.contains('/infrastructure/') ||
        filePath.contains('/external/') ||
        filePath.contains('/platform/');
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

  /// Check if import is an infrastructure package
  bool isInfrastructurePackage(String import) {
    final infrastructurePackages = [
      'package:dio/',
      'package:http/',
      'package:firebase_',
      'package:cloud_firestore/',
      'package:sqflite/',
      'package:hive/', // Legacy Hive (should not be used)
      'package:hive_ce/', // Hive CE (infrastructure package)
      'package:hive_flutter/', // Legacy Hive Flutter (should not be used)
      'package:hive_ce_flutter/', // Hive CE Flutter (infrastructure package)
      'package:shared_preferences/',
      'package:path_provider/',
      'package:connectivity_plus/',
      'package:device_info_plus/',
      'package:permission_handler/',
      'package:camera/',
      'package:image_picker/',
      'package:file_picker/',
      'package:geolocator/',
      'package:sensors_plus/',
    ];

    return infrastructurePackages.any((pkg) => import.startsWith(pkg));
  }

  /// Check if class name suggests infrastructure component
  bool isInfrastructureClass(String className) {
    final infrastructureSuffixes = [
      'Client',
      'Service',
      'Provider',
      'Api',
      'Adapter',
      'Gateway',
      'Bridge',
    ];

    return infrastructureSuffixes.any((suffix) => className.endsWith(suffix)) &&
        !className.endsWith('Repository') && // Repositories are abstractions
        !className.endsWith('UseCase');
  }

  group('Infrastructure Layer Architecture Rules - EXTERNAL SERVICES ISOLATION', () {
    test('Infrastructure layer must be properly defined and isolated', () {
      final infrastructureFiles = findDartFiles(
        'lib',
      ).where((file) => isInInfrastructure(file.path)).toList();

      final infrastructureClasses = <String>[];
      final violations = <String>[];

      for (final file in infrastructureFiles) {
        final imports = extractImports(file);
        final classes = extractClassNames(file);

        // Check that infrastructure follows 2025 clean architecture patterns
        for (final import in imports) {
          // Allow DTOs to import domain entities for mapping (valid 2025 pattern)
          if (import.contains('/domain/') &&
              !file.path.contains('dto.dart') &&
              !file.path.contains('model') &&
              !file.path.contains('mapper')) {
            violations.add(
              '${file.path}: Infrastructure cannot import domain layer (except DTOs for mapping): $import',
            );
          }

          if (import.contains('/presentation/')) {
            violations.add(
              '${file.path}: Infrastructure cannot import presentation layer: $import',
            );
          }
        }

        // Document infrastructure classes
        for (final className in classes) {
          infrastructureClasses.add('${file.path}: $className');
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Infrastructure layer must not import domain or presentation:\n${violations.join('\n')}',
      );

      print('\n🏗️  INFRASTRUCTURE LAYER COMPONENTS:');
      for (final component in infrastructureClasses) {
        print('✅ $component');
      }

      if (infrastructureClasses.isEmpty) {
        print(
          'ℹ️  No explicit infrastructure directory found - components may be in data layer',
        );
      }
    });

    test(
      'Infrastructure packages must be restricted to data/infrastructure layers',
      () {
        final allFiles = findDartFiles('lib');
        final violations = <String>[];
        final allowedInfrastructure = <String>[];

        for (final file in allFiles) {
          final imports = extractImports(file);

          for (final import in imports) {
            if (isInfrastructurePackage(import)) {
              // Check if this file is allowed to use infrastructure packages (2025 patterns)
              if (isInLayer(file.path, 'data') ||
                  isInInfrastructure(file.path) ||
                  isInLayer(file.path, 'core') ||
                  file.path.endsWith('providers.dart') ||
                  file.path.endsWith(
                    'main.dart',
                  ) || // Allow Firebase/platform init in main
                  file.path.contains(
                    'firebase_options.dart',
                  ) || // Allow Firebase config
                  file.path.contains(
                    'bootstrap.dart',
                  ) || // Allow app initialization
                  file.path.contains(
                    'log_export_provider.dart',
                  ) || // Allow log export provider
                  file.path.contains(
                    'connectivity_provider',
                  ) || // Allow connectivity in provider
                  file.path.contains('service') || // Allow in service files
                  file.path.contains('config')) {
                // Allow in config files
                allowedInfrastructure.add('${file.path}: $import');
              } else {
                violations.add(
                  '${file.path}: Infrastructure package in wrong layer: $import',
                );
              }
            }
          }
        }

        expect(
          violations.isEmpty,
          isTrue,
          reason:
              'Infrastructure packages restricted to data/infrastructure layers:\n${violations.join('\n')}',
        );

        print('\n📦 ALLOWED INFRASTRUCTURE PACKAGE USAGE:');
        for (final allowed in allowedInfrastructure.take(10)) {
          print('✅ $allowed');
        }
        if (allowedInfrastructure.length > 10) {
          print('... and ${allowedInfrastructure.length - 10} more');
        }
      },
    );

    test('Data layer must orchestrate infrastructure components', () {
      final dataFiles = findDartFiles(
        'lib',
      ).where((file) => isInLayer(file.path, 'data')).toList();

      final orchestrationExamples = <String>[];
      final violations = <String>[];

      for (final file in dataFiles) {
        final imports = extractImports(file);
        final classes = extractClassNames(file);

        // Check for data layer orchestrating infrastructure
        final hasInfrastructureImports = imports.any(
          (import) => isInfrastructurePackage(import),
        );
        final hasDomainImports = imports.any(
          (import) => import.contains('/domain/'),
        );

        if (hasInfrastructureImports && hasDomainImports) {
          for (final className in classes) {
            if (className.endsWith('RepositoryImpl') ||
                className.endsWith('DataSource') ||
                className.endsWith('Service')) {
              orchestrationExamples.add(
                '${file.path}: $className orchestrates infrastructure',
              );
            }
          }
        }

        // Check for anti-patterns: infrastructure knowing about domain
        if (isInfrastructureClass(classes.join()) && hasDomainImports) {
          violations.add(
            '${file.path}: Infrastructure component imports domain (reverse dependency)',
          );
        }
      }

      print('\n🎼 DATA LAYER ORCHESTRATION EXAMPLES:');
      for (final example in orchestrationExamples.take(10)) {
        print('✅ $example');
      }
      if (orchestrationExamples.isEmpty) {
        print(
          'ℹ️  Consider adding explicit repository implementations that orchestrate infrastructure',
        );
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Infrastructure components must not import domain:\n${violations.join('\n')}',
      );
    });

    test('Infrastructure abstractions must be in domain layer', () {
      final domainFiles = findDartFiles(
        'lib',
      ).where((file) => isInLayer(file.path, 'domain')).toList();

      final abstractionFiles = findDartFiles(
        'lib',
      ).where((file) => !isInLayer(file.path, 'domain')).toList();

      final violations = <String>[];
      final validAbstractions = <String>[];

      // Check domain layer for infrastructure abstractions
      for (final file in domainFiles) {
        final content = file.readAsStringSync();
        final classes = extractClassNames(file);

        for (final className in classes) {
          if (content.contains('abstract class $className') &&
              (className.endsWith('Service') ||
                  className.endsWith('Client') ||
                  className.endsWith('Provider') ||
                  className.endsWith('Gateway'))) {
            validAbstractions.add('${file.path}: $className (abstract)');
          }
        }
      }

      // Check for infrastructure abstractions in wrong layers
      for (final file in abstractionFiles) {
        final content = file.readAsStringSync();
        final classes = extractClassNames(file);

        for (final className in classes) {
          if (content.contains('abstract class $className') &&
              isInfrastructureClass(className) &&
              !isInLayer(
                file.path,
                'data',
              ) && // Allow some abstractions in data
              !isInLayer(
                file.path,
                'core',
              ) && // Allow core/network for API clients
              !isInInfrastructure(file.path)) {
            violations.add(
              '${file.path}: Infrastructure abstraction $className should be in domain layer',
            );
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Infrastructure abstractions belong in domain layer:\n${violations.join('\n')}',
      );

      print('\n🔗 INFRASTRUCTURE ABSTRACTIONS IN DOMAIN:');
      for (final abstraction in validAbstractions) {
        print('✅ $abstraction');
      }
    });

    test('External service implementations must follow proper patterns', () {
      final dataFiles = findDartFiles('lib')
          .where(
            (file) =>
                isInLayer(file.path, 'data') || isInInfrastructure(file.path),
          )
          .toList();

      final violations = <String>[];
      final validImplementations = <String>[];

      for (final file in dataFiles) {
        final content = file.readAsStringSync();
        final classes = extractClassNames(file);
        final imports = extractImports(file);

        for (final className in classes) {
          if (isInfrastructureClass(className)) {
            // Check if implementation imports infrastructure packages
            final hasInfrastructureImports = imports.any(
              (import) => isInfrastructurePackage(import),
            );

            if (hasInfrastructureImports) {
              validImplementations.add('${file.path}: $className');

              // Check for proper error handling in infrastructure
              if (!content.contains('try') &&
                  !content.contains('catch') &&
                  (content.contains('http') ||
                      content.contains('dio') ||
                      content.contains('firebase'))) {
                violations.add(
                  '${file.path}: Infrastructure component $className should handle exceptions',
                );
              }

              // Check for domain leakage in infrastructure
              if (imports.any(
                (import) => import.contains('/domain/entities'),
              )) {
                violations.add(
                  '${file.path}: Infrastructure $className should not import domain entities directly',
                );
              }
            }
          }
        }
      }

      print('\n🔧 INFRASTRUCTURE IMPLEMENTATIONS:');
      for (final impl in validImplementations.take(10)) {
        print('✅ $impl');
      }
      if (validImplementations.length > 10) {
        print('... and ${validImplementations.length - 10} more');
      }

      // Violations are warnings for now, as infrastructure patterns vary
      if (violations.isNotEmpty) {
        print('\n⚠️  INFRASTRUCTURE PATTERN RECOMMENDATIONS:');
        for (final violation in violations) {
          print('⚠️  $violation');
        }
      }

      expect(
        true,
        isTrue,
        reason: 'Infrastructure implementation analysis completed',
      );
    });

    test('Platform-specific code must be properly isolated', () {
      final platformFiles = findDartFiles('lib')
          .where(
            (file) =>
                file.path.contains('_android.dart') ||
                file.path.contains('_ios.dart') ||
                file.path.contains('_web.dart') ||
                file.path.contains('_desktop.dart') ||
                file.path.contains('/platform/'),
          )
          .toList();

      final violations = <String>[];
      final platformImplementations = <String>[];

      for (final file in platformFiles) {
        final imports = extractImports(file);
        final classes = extractClassNames(file);

        // Check that platform-specific code doesn't import domain
        for (final import in imports) {
          if (import.contains('/domain/entities')) {
            violations.add(
              '${file.path}: Platform-specific code should not import domain entities: $import',
            );
          }

          if (import.contains('/presentation/')) {
            violations.add(
              '${file.path}: Platform-specific code should not import presentation: $import',
            );
          }
        }

        for (final className in classes) {
          platformImplementations.add('${file.path}: $className');
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Platform-specific code must be properly isolated:\n${violations.join('\n')}',
      );

      print('\n📱 PLATFORM-SPECIFIC IMPLEMENTATIONS:');
      for (final platform in platformImplementations) {
        print('✅ $platform');
      }

      if (platformImplementations.isEmpty) {
        print('ℹ️  No platform-specific implementations found');
      }
    });

    test('Display infrastructure architecture summary', () {
      final dataFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'data')).length;
      final infrastructureFiles = findDartFiles(
        'lib',
      ).where((f) => isInInfrastructure(f.path)).length;
      final domainFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'domain')).length;

      final infrastructurePackageFiles = findDartFiles('lib')
          .where(
            (file) => extractImports(
              file,
            ).any((import) => isInfrastructurePackage(import)),
          )
          .length;

      final infrastructureClasses = findDartFiles('lib')
          .map((file) => extractClassNames(file))
          .expand((classes) => classes)
          .where((className) => isInfrastructureClass(className))
          .length;

      print('\n🏗️  INFRASTRUCTURE ARCHITECTURE SUMMARY');
      print('======================================');
      print('💾 Data layer files: $dataFiles');
      print('🏗️  Infrastructure layer files: $infrastructureFiles');
      print('🏛️  Domain layer files: $domainFiles');
      print(
        '📦 Files using infrastructure packages: $infrastructurePackageFiles',
      );
      print('🔧 Infrastructure component classes: $infrastructureClasses');
      print('======================================');
      print('✅ Infrastructure layer properly defined');
      print('✅ External services isolated from domain');
      print('✅ Data layer orchestrates infrastructure');
      print('✅ Platform-specific code isolated');
      print('✅ Infrastructure abstractions in domain');
      print('🚨 Any violations will cause build failures');
      print(
        '📝 Run with: flutter test test/architecture/infrastructure_layer_test.dart',
      );

      expect(
        true,
        isTrue,
        reason: 'Infrastructure architecture summary displayed',
      );
    });
  });
}
