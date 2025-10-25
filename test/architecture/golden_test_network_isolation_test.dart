// Golden Test Network Isolation Architecture Test
//
// This test ensures that ALL golden tests properly mock network dependencies
// to prevent real API calls during visual regression testing.
//
// CRITICAL REQUIREMENT: Golden tests must NEVER make real network calls.
// This is enforced by requiring all golden test files to:
// 1. Import network_mocking.dart
// 2. Include getAllNetworkMockOverrides() in provider overrides

import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('Golden Test Network Isolation Architecture Rules', () {
    late List<File> goldenTestFiles;

    setUp(() {
      // Find all golden test files
      final goldenTestDir = Directory('test/golden_tests');
      goldenTestFiles = goldenTestDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('_golden_test.dart'))
          .toList();
    });

    test(
      'All golden test files must import network_mocking.dart OR not use provider overrides',
      () {
        final violations = <String>[];

        for (final file in goldenTestFiles) {
          final content = file.readAsStringSync();

          // Check if file uses provider overrides
          final usesProviderOverrides =
              content.contains('providerOverrides:') ||
                  content.contains('providerOverrides =');

          if (usesProviderOverrides) {
            // If it uses provider overrides, it must import network_mocking
            final hasNetworkMockingImport = content.contains(
              "import '../../support/network_mocking.dart'",
            );

            if (!hasNetworkMockingImport) {
              violations.add(
                '${file.path}: Uses providerOverrides but does not import network_mocking.dart',
              );
            }
          }
        }

        if (violations.isNotEmpty) {
          fail(
            'Golden test files must import network_mocking.dart when using provider overrides:\n'
            '${violations.join('\n')}\n\n'
            'Fix: Add this import to each file:\n'
            "import '../../support/network_mocking.dart';",
          );
        }
      },
    );

    test(
      'All golden test files with provider overrides must call getAllNetworkMockOverrides()',
      () {
        final violations = <String>[];

        for (final file in goldenTestFiles) {
          final content = file.readAsStringSync();

          // Check if file uses provider overrides
          final usesProviderOverrides =
              content.contains('providerOverrides:') ||
                  content.contains('providerOverrides =') ||
                  content.contains('final overrides = [') ||
                  content.contains('overrides = [');

          if (usesProviderOverrides) {
            // It must call getAllNetworkMockOverrides()
            final callsGetAllNetworkMockOverrides = content.contains(
              'getAllNetworkMockOverrides()',
            );

            if (!callsGetAllNetworkMockOverrides) {
              violations.add(
                '${file.path}: Uses provider overrides but does not call getAllNetworkMockOverrides()',
              );
            }
          }
        }

        if (violations.isNotEmpty) {
          fail(
            'Golden test files MUST include network mock overrides to prevent real API calls:\n'
            '${violations.join('\n')}\n\n'
            'Fix: Add this to your provider overrides array:\n'
            '  ...getAllNetworkMockOverrides(),\n\n'
            'Example:\n'
            '  final overrides = [\n'
            '    currentUserProvider.overrideWith((ref) => testUser),\n'
            '    // ... other overrides ...\n'
            '    // CRITICAL: Prevent all real network calls during golden tests\n'
            '    ...getAllNetworkMockOverrides(),\n'
            '  ];',
          );
        }
      },
    );

    test('No golden test file should reference localhost URLs', () {
      final violations = <String>[];

      for (final file in goldenTestFiles) {
        final content = file.readAsStringSync();

        // Check for any localhost references
        if (content.contains('localhost:3001') ||
            content.contains('http://localhost') ||
            content.contains('ws://localhost')) {
          violations.add(
            '${file.path}: Contains hardcoded localhost URL references',
          );
        }
      }

      if (violations.isNotEmpty) {
        fail(
          'Golden test files must NOT contain hardcoded localhost URLs:\n'
          '${violations.join('\n')}\n\n'
          'Use getAllNetworkMockOverrides() instead, which provides mock URLs.',
        );
      }
    });

    test('Found at least some golden test files to validate', () {
      expect(
        goldenTestFiles.length,
        greaterThan(0),
        reason: 'Should find golden test files in test/golden_tests',
      );
    });
  });
}
