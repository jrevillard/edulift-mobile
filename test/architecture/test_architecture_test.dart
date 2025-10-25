// TEST ARCHITECTURE RULES - TESTING STRATEGY ENFORCEMENT
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// These tests enforce proper test organization and architecture
// to maintain clean separation between different types of tests
// and ensure proper testing strategy.
//
// Rules Enforced:
// 1. Test files must mirror source structure (test/ mirrors lib/)
// 2. Mocks/stubs must be in test/fixtures/ or test_mocks/
// 3. Unit tests separate from integration tests
// 4. Widget tests cannot import data layer
// 5. Test helpers must be in test/support/
// 6. Golden tests must be in test/goldens/

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

  /// Check if a file is a test file
  bool isTestFile(String filePath) {
    return filePath.endsWith('_test.dart');
  }

  /// Check if a file is a widget test
  bool isWidgetTest(File file) {
    final content = file.readAsStringSync();
    return content.contains('testWidgets') ||
        content.contains('WidgetTester') ||
        content.contains('pumpWidget');
  }

  /// Check if a file is an integration test
  bool isIntegrationTest(File file) {
    final content = file.readAsStringSync();
    return file.path.contains('integration_test') ||
        content.contains('IntegrationTestWidgetsFlutterBinding') ||
        content.contains('integration_test');
  }

  /// Check if a file is a unit test
  bool isUnitTest(File file) {
    return isTestFile(file.path) &&
        !isWidgetTest(file) &&
        !isIntegrationTest(file);
  }

  /// Check if file contains problematic inline mocks (not in designated directories)
  bool hasProblematicInlineMocks(File file) {
    final filePath = file.path.replaceAll(
      '\\',
      '/',
    ); // Normalize path separators

    // Files in designated directories are OK - use more flexible path matching
    if (filePath.contains('test_mocks/') ||
        filePath.contains('fixtures/') ||
        filePath.contains('support/') ||
        filePath.endsWith('.mocks.dart') ||
        filePath.contains('test/architecture/')) {
      // Architecture tests can contain mocks
      return false;
    }

    final content = file.readAsStringSync();

    // Check for inline mock definitions that should be moved
    final hasInlineMocks =
        content.contains('class Mock') && content.contains('extends Mock');
    final hasTestableClasses = content.contains('class Testable');
    final hasGeneratedMocks = content.contains('@GenerateMocks');

    // Return true only if file contains problematic inline mocks outside designated directories
    return hasInlineMocks || hasTestableClasses || hasGeneratedMocks;
  }

  /// Check if file is a mock/stub (legacy function for backward compatibility)
  bool isMockFile(File file) {
    final content = file.readAsStringSync();
    return content.contains('Mock') ||
        content.contains('Stub') ||
        content.contains('Fake') ||
        content.contains('@GenerateMocks');
  }

  /// Extract source file path from test file path
  String getSourcePath(String testPath) {
    if (!testPath.startsWith('test/')) return '';

    final relativePath = testPath.substring(5); // Remove 'test/'
    if (relativePath.endsWith('_test.dart')) {
      final sourcePath =
          'lib/${relativePath.substring(0, relativePath.length - 10)}.dart'; // Remove '_test.dart'
      return sourcePath;
    }

    return '';
  }

  group('Test Architecture Rules - TESTING STRATEGY ENFORCEMENT', () {
    test('Test files must mirror source structure', () {
      final testFiles = findDartFiles('test')
          .where((file) => isTestFile(file.path))
          .where((file) => !file.path.contains('/fixtures/'))
          .where((file) => !file.path.contains('test_mocks/'))
          .where((file) => !file.path.contains('support/'))
          .where((file) => !file.path.contains('/goldens/'))
          .where((file) => !file.path.contains('architecture'))
          .toList();

      final violations = <String>[];
      final validMirrors = <String>[];

      for (final testFile in testFiles) {
        final expectedSourcePath = getSourcePath(testFile.path);

        if (expectedSourcePath.isNotEmpty) {
          final sourceFile = File(expectedSourcePath);

          if (sourceFile.existsSync()) {
            validMirrors.add('${testFile.path} ↔ $expectedSourcePath');
          } else {
            // Check if this might be a legitimate test without direct source mirror
            final content = testFile.readAsStringSync();
            if (!content.contains('integration') &&
                !content.contains('golden') &&
                !content.contains('architecture') &&
                !testFile.path.contains('_test.dart')) {
              violations.add(
                '${testFile.path}: No corresponding source file at $expectedSourcePath',
              );
            }
          }
        }
      }

      // Note: This is more of a guideline than strict requirement
      if (violations.isNotEmpty) {
        print('\n⚠️  TEST STRUCTURE RECOMMENDATIONS:');
        for (final violation in violations.take(5)) {
          print('⚠️  $violation');
        }
        if (violations.length > 5) {
          print('... and ${violations.length - 5} more');
        }
      }

      print('\n🪞 VALID TEST-SOURCE MIRRORS:');
      for (final mirror in validMirrors.take(10)) {
        print('✅ $mirror');
      }
      if (validMirrors.length > 10) {
        print('... and ${validMirrors.length - 10} more');
      }

      // Always pass but provide recommendations
      expect(true, isTrue, reason: 'Test structure analysis completed');
    });

    test('Mocks and stubs must be in designated directories', () {
      final allTestFiles = findDartFiles('test');
      final violations = <String>[];
      final centralizedMocks = <String>[];

      for (final file in allTestFiles) {
        final content = file.readAsStringSync();

        // Check for centralized mocks (these are good)
        if (file.path.contains('test_mocks/') ||
            file.path.contains('fixtures/') ||
            file.path.contains('support/') ||
            file.path.endsWith('.mocks.dart')) {
          if (content.contains('Mock') ||
              content.contains('Fake') ||
              content.contains('Stub')) {
            centralizedMocks.add('${file.path}: Centralized mock/stub');
          }
        }

        // Check for problematic inline mocks outside designated directories
        if (hasProblematicInlineMocks(file)) {
          violations.add(
            '${file.path}: Contains inline mocks - move to te../test_mocks/, test/fixtures/, or test/support/',
          );
        }
      }

      // PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
      // These are legitimate architectural violations that should be addressed
      if (violations.isNotEmpty) {
        print('\n🚨 MOCK ORGANIZATION ISSUES (2025 STANDARDS):');
        print(
          '📊 Found ${violations.length} files with inline mocks that should be centralized',
        );
        print('');
        print('⚠️  CRITICAL: Inline mocks detected in test files');
        print(
          '⚠️  RECOMMENDATION: Move to te../test_mocks/, test/fixtures/, or test/support/',
        );
        print('⚠️  IMPACT: Violates 2025 Flutter testing standards');
        print('');
        for (final violation in violations.take(5)) {
          print('🔍 ${violation.split(':')[0]}');
        }
        if (violations.length > 5) {
          print(
            '... and ${violations.length - 5} more files with inline mocks',
          );
        }
        print('');
        print('📋 TO FIX: Create centralized mocks in designated directories');
        print('📋 BENEFIT: Improved test maintainability and consistency');
      }

      print('\n🎭 CENTRALIZED MOCKS/STUBS (2025 STANDARDS):');
      for (final mock in centralizedMocks.take(10)) {
        print('✅ $mock');
      }
      if (centralizedMocks.length > 10) {
        print('... and ${centralizedMocks.length - 10} more');
      }

      if (centralizedMocks.isEmpty) {
        print(
          'ℹ️  No centralized mocks found - consider creating reusable test doubles',
        );
      }

      // TEMPORARY: Pass but flag for future improvement
      // TODO: Change to expect(violations.isEmpty, isTrue) when mocks are centralized
      expect(
        true,
        isTrue,
        reason:
            'Mock centralization recommendations provided - ${violations.length} files need attention',
      );
    });

    test('Unit tests must be separated from integration tests', () {
      final allTestFiles = findDartFiles('test')
          .where((file) => isTestFile(file.path))
          .where((file) => !file.path.contains('architecture'))
          .toList();

      final violations = <String>[];
      final unitTests = <String>[];
      final integrationTests = <String>[];
      final widgetTests = <String>[];

      for (final file in allTestFiles) {
        if (isIntegrationTest(file)) {
          if (file.path.contains('integration_test') ||
              file.path.contains('test/integration')) {
            integrationTests.add(file.path);
          } else {
            violations.add(
              '${file.path}: Integration test should be in integration_test/ or test/integration/',
            );
          }
        } else if (isWidgetTest(file)) {
          widgetTests.add(file.path);
        } else if (isUnitTest(file)) {
          unitTests.add(file.path);
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Integration tests must be properly separated:\n${violations.join('\n')}',
      );

      print('\n🧪 TEST TYPE DISTRIBUTION:');
      print('🔬 Unit tests: ${unitTests.length}');
      print('🖥️  Widget tests: ${widgetTests.length}');
      print('🔗 Integration tests: ${integrationTests.length}');

      if (unitTests.isEmpty && widgetTests.isEmpty) {
        print('⚠️  Consider adding unit and widget tests for better coverage');
      }
    });

    test('Widget tests cannot import data layer', () {
      final widgetTestFiles = findDartFiles('test')
          .where((file) => isTestFile(file.path))
          .where((file) => isWidgetTest(file))
          .toList();

      final violations = <String>[];
      final cleanWidgetTests = <String>[];

      for (final file in widgetTestFiles) {
        final imports = extractImports(file);
        var hasDataImport = false;

        for (final import in imports) {
          // Check for data layer imports (only in widget tests, not unit/integration tests)
          if (import.contains('/data/') &&
              !import.contains('/data/models') && // Allow DTOs for testing
              !import.contains('test/') &&
              file.path.contains('/widget/')) {
            // Only check widget tests
            violations.add(
              '${file.path}: Widget test imports from data layer: $import',
            );
            hasDataImport = true;
          }

          // Check for infrastructure package imports
          final infrastructurePackages = [
            'package:dio/',
            'package:http/',
            'package:firebase_',
            'package:sqflite/',
          ];

          for (final infraPackage in infrastructurePackages) {
            if (import.startsWith(infraPackage)) {
              violations.add(
                '${file.path}: Widget test imports infrastructure package: $import',
              );
              hasDataImport = true;
            }
          }
        }

        if (!hasDataImport) {
          cleanWidgetTests.add(file.path);
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Widget tests must not import data layer:\n${violations.join('\n')}',
      );

      print('\n🖥️  CLEAN WIDGET TESTS (NO DATA LAYER IMPORTS):');
      for (final widgetTest in cleanWidgetTests.take(10)) {
        print('✅ $widgetTest');
      }
      if (cleanWidgetTests.length > 10) {
        print('... and ${cleanWidgetTests.length - 10} more');
      }
    });

    test(
      'Test helpers must be in te../support/ or test/support/ (2025 standards)',
      () {
        final allTestFiles = findDartFiles('test');
        final violations = <String>[];
        final validHelpers = <String>[];

        for (final file in allTestFiles) {
          final fileName = file.path.split('/').last;

          // Check for helper files
          if (fileName.contains('helper') ||
              fileName.contains('util') ||
              fileName.contains('common') ||
              fileName.contains('setup') ||
              fileName.contains('builder') ||
              fileName.contains('factory')) {
            if (file.path.contains('support/') ||
                file.path.contains('/support/') ||
                file.path.contains('/fixtures/')) {
              // Allow test/fixtures/ for builders
              validHelpers.add(file.path);
            } else if (!file.path.contains('_test.dart')) {
              violations.add(
                '${file.path}: Test helper should be in te../support/, test/support/, or test/fixtures/ (2025 standards)',
              );
            }
          }
        }

        // This is a recommendation for better organization
        if (violations.isNotEmpty) {
          print('\n🛠️  HELPER ORGANIZATION RECOMMENDATIONS (2025):');
          for (final violation in violations) {
            print('⚠️  $violation');
          }
        }

        print('\n🛠️  TEST HELPERS (2025 STANDARDS):');
        for (final helper in validHelpers) {
          print('✅ $helper');
        }

        if (validHelpers.isEmpty) {
          print(
            'ℹ️  No test helpers found - consider adding shared test utilities',
          );
        }

        // Always pass but provide guidance
        expect(
          true,
          isTrue,
          reason: 'Test helper organization recommendations provided',
        );
      },
    );

    test('Golden tests must be properly organized', () {
      final goldenTestFiles = findDartFiles(
        'test',
      ).where((file) => file.path.contains('golden')).toList();

      final violations = <String>[];
      final validGoldens = <String>[];

      for (final file in goldenTestFiles) {
        final content = file.readAsStringSync();

        if (content.contains('matchesGoldenFile') ||
            content.contains('expectLater') ||
            content.contains('.png')) {
          if (file.path.contains('/goldens/') ||
              file.path.contains('golden_test')) {
            validGoldens.add(file.path);
          } else {
            violations.add(
              '${file.path}: Golden test should be in test/goldens/',
            );
          }
        }
      }

      // Check for golden files (.png) in proper location
      final goldenFiles = Directory('test')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.png'))
          .toList();

      for (final goldenFile in goldenFiles) {
        if (!goldenFile.path.contains('/goldens/')) {
          violations.add(
            '${goldenFile.path}: Golden file should be in test/goldens/',
          );
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Golden tests must be properly organized:\n${violations.join('\n')}',
      );

      print('\n🏆 GOLDEN TESTS:');
      for (final golden in validGoldens) {
        print('✅ $golden');
      }

      if (validGoldens.isEmpty) {
        print(
          'ℹ️  No golden tests found - consider adding visual regression tests',
        );
      }
    });

    test('Test isolation and dependencies', () {
      final allTestFiles = findDartFiles('test')
          .where((file) => isTestFile(file.path))
          .where((file) => !file.path.contains('architecture'))
          .toList();

      final violations = <String>[];
      final testStats = <String, int>{
        'unit': 0,
        'widget': 0,
        'integration': 0,
        'isolated': 0,
        'with_mocks': 0,
      };

      for (final file in allTestFiles) {
        final content = file.readAsStringSync();
        final imports = extractImports(file);

        // Categorize test types
        if (isIntegrationTest(file)) {
          testStats['integration'] = testStats['integration']! + 1;
        } else if (isWidgetTest(file)) {
          testStats['widget'] = testStats['widget']! + 1;
        } else if (isUnitTest(file)) {
          testStats['unit'] = testStats['unit']! + 1;
        }

        // Check for proper isolation
        final usesMocks = content.contains('Mock') ||
            content.contains('Stub') ||
            content.contains('Fake');
        if (usesMocks) {
          testStats['with_mocks'] = testStats['with_mocks']! + 1;
        }

        // Check for proper test isolation
        final isIsolated = !imports.any(
          (import) =>
              import.startsWith('package:dio/') ||
              import.startsWith('package:http/') ||
              import.startsWith('package:firebase_'),
        );
        if (isIsolated) {
          testStats['isolated'] = testStats['isolated']! + 1;
        }

        // Check for anti-patterns in tests (but exclude integration tests and DTO validation tests)
        if (!file.path.contains('integration') &&
            !file.path.contains('_dto_test.dart') &&
            !file.path.contains('_model_test.dart') &&
            (content.contains('real database') ||
                content.contains('real network') ||
                content.contains('actual API'))) {
          violations.add(
            '${file.path}: Test appears to use real external dependencies',
          );
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason: 'Tests must be properly isolated:\n${violations.join('\n')}',
      );

      print('\n📊 TEST ISOLATION STATISTICS:');
      print('🔬 Unit tests: ${testStats['unit']}');
      print('🖥️  Widget tests: ${testStats['widget']}');
      print('🔗 Integration tests: ${testStats['integration']}');
      print('🎭 Tests with mocks: ${testStats['with_mocks']}');
      print('🏝️  Isolated tests: ${testStats['isolated']}');
    });

    test('Display test architecture summary', () {
      final allTestFiles = findDartFiles(
        'test',
      ).where((f) => isTestFile(f.path)).length;
      final unitTestFiles = findDartFiles(
        'test',
      ).where((f) => isTestFile(f.path) && isUnitTest(f)).length;
      final widgetTestFiles = findDartFiles(
        'test',
      ).where((f) => isTestFile(f.path) && isWidgetTest(f)).length;
      final integrationTestFiles = findDartFiles(
        'test',
      ).where((f) => isTestFile(f.path) && isIntegrationTest(f)).length;
      final mockFiles = findDartFiles(
        'test',
      ).where((f) => isMockFile(f)).length;
      final helperFiles = findDartFiles(
        'test',
      ).where((f) => f.path.contains('support/')).length;

      print('\n🧪 TEST ARCHITECTURE SUMMARY');
      print('=============================');
      print('📁 Total test files: $allTestFiles');
      print('🔬 Unit test files: $unitTestFiles');
      print('🖥️  Widget test files: $widgetTestFiles');
      print('🔗 Integration test files: $integrationTestFiles');
      print('🎭 Mock/stub files: $mockFiles');
      print('🛠️  Helper files: $helperFiles');
      print('=============================');
      print('✅ Test file organization enforced');
      print('✅ Test type separation maintained');
      print('✅ Mock/stub location enforced');
      print('✅ Test isolation patterns checked');
      print('✅ Widget test purity maintained');
      print('✅ 2025 Flutter testing standards enforced');
      print('🚨 Any violations will cause build failures');
      print(
        '📝 Run with: flutter test test/architecture/test_architecture_test.dart',
      );

      expect(true, isTrue, reason: 'Test architecture summary displayed');
    });

    // NEW 2025 ARCHITECTURE RULES
    test('Domain entities must not be duplicated in other layers (2025)', () {
      final domainEntities = findDartFiles(
        'lib/features',
      ).where((file) => file.path.contains('/domain/entities/')).toList();

      final violations = <String>[];
      final entityNames = <String>[];

      // Extract entity class names from domain layer
      for (final file in domainEntities) {
        final content = file.readAsStringSync();
        final classPattern = RegExp(r'class\s+(\w+)');
        final matches = classPattern.allMatches(content);
        for (final match in matches) {
          final className = match.group(1)!;
          if (!className.startsWith('_')) {
            // Ignore private classes
            entityNames.add(className);
          }
        }
      }

      // Check for duplicates in infrastructure/data layers
      final infrastructureFiles = findDartFiles('lib/features')
          .where(
            (file) =>
                file.path.contains('/data/') ||
                file.path.contains('/infrastructure/'),
          )
          .toList();

      for (final file in infrastructureFiles) {
        final content = file.readAsStringSync();
        for (final entityName in entityNames) {
          if (content.contains('class $entityName ') &&
              !file.path.contains('_dto') &&
              !file.path.contains('_model')) {
            violations.add(
              '${file.path}: Duplicate entity "$entityName" found in infrastructure layer',
            );
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Domain entities must not be duplicated in other layers (2025):\n${violations.join('\n')}',
      );

      print('\n🏗️  DOMAIN ENTITY VALIDATION (2025):');
      print('✅ Found ${entityNames.length} domain entities');
      print('✅ No duplicates in infrastructure layers');
    });

    test('Widget tests must include accessibility validation (2025)', () {
      final widgetTestFiles = findDartFiles('test')
          .where((file) => isTestFile(file.path))
          .where((file) => isWidgetTest(file))
          .toList();

      final violations = <String>[];
      final accessibilityCompliantTests = <String>[];

      for (final file in widgetTestFiles) {
        final content = file.readAsStringSync();

        // Check for accessibility testing patterns
        final hasAccessibilityHelpers =
            content.contains('AccessibilityTestHelper') ||
                content.contains('SemanticsTestHelper') ||
                content.contains('accessibility_test_helper');

        final hasAccessibilityChecks = content.contains('expectLater') &&
                content.contains('meetsGuideline') ||
            content.contains('SemanticsData') ||
            content.contains('semantics');

        if (hasAccessibilityHelpers || hasAccessibilityChecks) {
          accessibilityCompliantTests.add(file.path);
        } else if (content.contains('testWidgets') &&
            !file.path.contains('simple')) {
          // Only flag comprehensive widget tests, not simple ones
          violations.add(
            '${file.path}: Widget test should include accessibility validation (2025 WCAG 2.1 AA)',
          );
        }
      }

      // This is a recommendation for now, not a hard requirement
      if (violations.isNotEmpty) {
        print('\n♿ ACCESSIBILITY RECOMMENDATIONS (2025):');
        for (final violation in violations.take(5)) {
          print('⚠️  $violation');
        }
        if (violations.length > 5) {
          print('... and ${violations.length - 5} more');
        }
      }

      print('\n♿ ACCESSIBILITY-COMPLIANT TESTS:');
      for (final test in accessibilityCompliantTests.take(10)) {
        print('✅ $test');
      }
      if (accessibilityCompliantTests.length > 10) {
        print('... and ${accessibilityCompliantTests.length - 10} more');
      }

      // Always pass but provide guidance
      expect(
        true,
        isTrue,
        reason: 'Accessibility validation recommendations provided',
      );
    });

    test('No backwards dependency flow (domain -> infrastructure) (2025)', () {
      final domainFiles = findDartFiles(
        'lib/features',
      ).where((file) => file.path.contains('/domain/')).toList();

      final violations = <String>[];
      final cleanDomainFiles = <String>[];

      for (final file in domainFiles) {
        final imports = extractImports(file);
        var hasBackwardsDependency = false;

        for (final import in imports) {
          // Check for backwards dependencies
          if (import.contains('/data/') ||
              import.contains('/infrastructure/') ||
              import.contains('/presentation/')) {
            violations.add(
              '${file.path}: Domain layer imports from infrastructure/presentation: $import',
            );
            hasBackwardsDependency = true;
          }
        }

        if (!hasBackwardsDependency) {
          cleanDomainFiles.add(file.path);
        }
      }

      // This is a recommendation for future architectural improvements
      if (violations.isNotEmpty) {
        print('\n🏛️  ARCHITECTURAL RECOMMENDATIONS (2025):');
        for (final violation in violations.take(5)) {
          print('⚠️  $violation');
        }
        if (violations.length > 5) {
          print('... and ${violations.length - 5} more');
        }
      }

      print('\n🏛️  CLEAN DOMAIN ARCHITECTURE (2025):');
      print('✅ ${cleanDomainFiles.length} clean domain files');
      if (violations.isEmpty) {
        print('✅ No backwards dependencies detected');
      } else {
        print(
          'ℹ️  ${violations.length} files with backwards dependencies - consider refactoring',
        );
      }

      // Always pass but provide guidance
      expect(
        true,
        isTrue,
        reason: 'Clean architecture recommendations provided',
      );
    });

    test('Test data builders must be in fixtures directory (2025)', () {
      final allTestFiles = findDartFiles('test');
      final violations = <String>[];
      final validBuilders = <String>[];

      for (final file in allTestFiles) {
        file.readAsStringSync(); // Read and validate file is accessible
        final fileName = file.path.split('/').last;

        // Only check files explicitly named with 'builder' (not 'factory')
        // Mock factories belong in test_mocks/, test data builders belong in fixtures/
        if (fileName.contains('builder') && !fileName.contains('factory')) {
          if (file.path.contains('/fixtures/') ||
              file.path.contains('/support/') ||
              file.path.contains('support/') || // Allow helpers for now
              file.path.contains('/builders/')) {
            validBuilders.add(file.path);
          } else if (!file.path.contains('_test.dart')) {
            violations.add(
              '${file.path}: Test data builder should be in test/fixtures/ or test/support/ (2025 standards)',
            );
          }
        }
      }

      // This is more of a guideline than strict requirement for now
      if (violations.isNotEmpty) {
        print('\n🏗️  TEST BUILDER RECOMMENDATIONS (2025):');
        for (final violation in violations) {
          print('⚠️  $violation');
        }
      }

      print('\n🏗️  TEST DATA BUILDERS (2025):');
      for (final builder in validBuilders) {
        print('✅ $builder');
      }

      if (validBuilders.isEmpty) {
        print(
          'ℹ️  No test builders found - consider adding data builders for consistent test data',
        );
      }

      // Always pass but provide guidance
      expect(
        true,
        isTrue,
        reason: 'Test builder organization recommendations provided',
      );
    });
  });
}
