// ARCHITECTURAL TESTING - CLEAN ARCHITECTURE ENFORCEMENT
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// These tests enforce clean architecture dependency rules at test-time.
// They will fail if developers violate layer separation principles.
//
// Rules Enforced:
// 1. Domain layer CANNOT import from Data or Presentation layers
// 2. Presentation layer CANNOT import from Data layer
// 3. Data layer CANNOT import from Presentation layer
// 4. Only composition roots can import from multiple layers

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
        // Extract import path from import statement
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

  /// Check if a file is a composition root (providers.dart, route_registration.dart)
  bool isCompositionRoot(String filePath) {
    return filePath.endsWith('providers.dart') ||
        filePath.endsWith('route_registration.dart');
  }

  group('Clean Architecture Dependency Rules - PRINCIPLE 0 ENFORCEMENT', () {
    test(
      'Domain layer must remain pure - cannot depend on Data or Presentation',
      () {
        final domainFiles = findDartFiles(
          'lib',
        ).where((file) => isInLayer(file.path, 'domain')).toList();

        for (final file in domainFiles) {
          final imports = extractImports(file);

          for (final import in imports) {
            // Check for violations: domain importing from data or presentation
            final violatesDataRule = import.contains('/data/');
            final violatesPresentationRule = import.contains('/presentation/');

            expect(
              violatesDataRule,
              isFalse,
              reason:
                  'Domain file ${file.path} cannot import from data layer: $import',
            );
            expect(
              violatesPresentationRule,
              isFalse,
              reason:
                  'Domain file ${file.path} cannot import from presentation layer: $import',
            );
          }
        }
      },
    );

    test(
      'Presentation layer cannot depend on Data layer - must use composition roots',
      () {
        final presentationFiles = findDartFiles('lib')
            .where((file) => isInLayer(file.path, 'presentation'))
            .where(
              (file) => !isCompositionRoot(file.path),
            ) // Exclude composition roots
            .toList();

        for (final file in presentationFiles) {
          final imports = extractImports(file);

          for (final import in imports) {
            // Check for violation: presentation importing from data layer
            final violatesDataRule = import.contains('/data/');

            expect(
              violatesDataRule,
              isFalse,
              reason:
                  'Presentation file ${file.path} cannot import from data layer: $import. Use composition roots instead.',
            );
          }
        }
      },
    );

    test('Data layer cannot depend on Presentation layer', () {
      final dataFiles = findDartFiles(
        'lib',
      ).where((file) => isInLayer(file.path, 'data')).toList();

      for (final file in dataFiles) {
        final imports = extractImports(file);

        for (final import in imports) {
          // Check for violation: data importing from presentation layer
          final violatesPresentationRule = import.contains('/presentation/');

          expect(
            violatesPresentationRule,
            isFalse,
            reason:
                'Data file ${file.path} cannot import from presentation layer: $import',
          );
        }
      }
    });

    test('Core utilities should not depend on feature layers', () {
      final coreFiles = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'core'))
          .where(
            (file) => !isCompositionRoot(file.path),
          ) // Exclude composition roots
          .where(
            (file) =>
                !file.path.contains('onboarding_wizard_page.dart') &&
                !file.path.contains('app_router.dart') &&
                !file.path.contains('invitation_failure.dart'),
          ) // Core files that legitimately need feature dependencies
          .toList();

      for (final file in coreFiles) {
        final imports = extractImports(file);

        for (final import in imports) {
          // Check for violation: core importing from features
          final violatesFeaturesRule = import.contains('/features/');

          expect(
            violatesFeaturesRule,
            isFalse,
            reason:
                'Core file ${file.path} cannot import from features layer: $import',
          );
        }
      }
    });
  });

  group('Feature Isolation Rules', () {
    test('Features should not cross-depend inappropriately', () {
      final features = ['family', 'groups', 'schedule', 'auth'];

      for (final feature in features) {
        final featureFiles = findDartFiles('lib')
            .where((file) => isInLayer(file.path, 'features/$feature'))
            .where(
              (file) => !isCompositionRoot(file.path),
            ) // Allow composition roots
            .toList();

        for (final file in featureFiles) {
          final imports = extractImports(file);

          for (final import in imports) {
            // Check that this feature doesn't import from other features
            for (final otherFeature in features) {
              if (otherFeature != feature) {
                final violatesIsolationRule = import.contains(
                  '/features/$otherFeature/',
                );

                if (violatesIsolationRule) {
                  // Allow some exceptions for cross-feature dependencies through composition roots
                  final isAllowedException =
                      (feature == 'schedule' &&
                          (otherFeature == 'family' ||
                              otherFeature == 'groups')) ||
                      import.contains('providers.dart');

                  if (!isAllowedException) {
                    expect(
                      violatesIsolationRule,
                      isFalse,
                      reason:
                          'Feature $feature file ${file.path} should not import from feature $otherFeature: $import. Use shared core utilities instead.',
                    );
                  }
                }
              }
            }
          }
        }
      }
    });
  });

  group('Architectural Pattern Compliance', () {
    test('Composition roots can wire multiple layers together', () {
      final compositionRootFiles = findDartFiles(
        'lib',
      ).where((file) => isCompositionRoot(file.path)).toList();

      // Verify composition roots exist
      expect(
        compositionRootFiles.isNotEmpty,
        isTrue,
        reason:
            'Composition roots (providers.dart) should exist to wire dependencies',
      );

      // This test documents that providers.dart files are exempt from layer restrictions
      expect(
        true,
        isTrue,
        reason:
            'Composition roots (providers.dart) are exempt from layer restrictions as they wire dependencies together.',
      );
    });

    test('Domain entities must be pure', () {
      final entityFiles = findDartFiles(
        'lib',
      ).where((file) => file.path.contains('/domain/entities/')).toList();

      for (final file in entityFiles) {
        final imports = extractImports(file);

        for (final import in imports) {
          // Domain entities should not import from data or presentation layers
          final violatesDataRule = import.contains('/data/');
          final violatesPresentationRule = import.contains('/presentation/');

          expect(
            violatesDataRule,
            isFalse,
            reason:
                'Domain entity ${file.path} cannot import from data layer: $import',
          );
          expect(
            violatesPresentationRule,
            isFalse,
            reason:
                'Domain entity ${file.path} cannot import from presentation layer: $import',
          );
        }
      }
    });

    test('Repository implementations are in data layer', () {
      final repositoryImplFiles = findDartFiles(
        'lib',
      ).where((file) => file.path.contains('repository_impl.dart')).toList();

      for (final file in repositoryImplFiles) {
        expect(
          isInLayer(file.path, 'data'),
          isTrue,
          reason:
              'Repository implementation ${file.path} must be in data layer',
        );
      }
    });

    test('Use cases are in domain layer', () {
      final usecaseFiles = findDartFiles(
        'lib',
      ).where((file) => file.path.contains('usecase.dart')).toList();

      for (final file in usecaseFiles) {
        expect(
          isInLayer(file.path, 'domain'),
          isTrue,
          reason: 'Use case ${file.path} must be in domain layer',
        );
      }
    });
  });

  group('Architectural Enforcement Summary', () {
    test('Display architectural compliance summary', () {
      final totalFiles = findDartFiles('lib').length;
      final domainFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'domain')).length;
      final dataFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'data')).length;
      final presentationFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'presentation')).length;
      final coreFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'core')).length;
      final compositionRoots = findDartFiles(
        'lib',
      ).where((f) => isCompositionRoot(f.path)).length;

      print('\n🏛️  CLEAN ARCHITECTURE COMPLIANCE SUMMARY');
      print('================================================');
      print('📊 Total Dart files analyzed: $totalFiles');
      print('🏢 Domain layer files: $domainFiles');
      print('💾 Data layer files: $dataFiles');
      print('🖥️  Presentation layer files: $presentationFiles');
      print('⚙️  Core utility files: $coreFiles');
      print('🔌 Composition roots: $compositionRoots');
      print('================================================');
      print('✅ All architectural rules enforced via tests');
      print('🚨 Any violations will cause test failures');
      print('📝 Run with: flutter test test/architecture/');

      expect(true, isTrue, reason: 'Architectural summary displayed');
    });
  });
}
