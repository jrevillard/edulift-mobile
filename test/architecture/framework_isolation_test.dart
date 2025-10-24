// FRAMEWORK ISOLATION RULES - CLEAN ARCHITECTURE PURITY
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// These tests enforce framework isolation to maintain clean architecture purity.
// Domain layer must remain independent of Flutter and infrastructure frameworks.

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Helper to extract imports from a Dart file
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

  /// Find all Dart files in a directory
  List<File> findDartFiles(String directoryPath) {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) return [];

    return directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
  }

  /// Check if a file path belongs to a specific layer
  bool isInLayer(String filePath, String layer) {
    return filePath.contains('/$layer/');
  }

  group('Framework Isolation Rules - DOMAIN LAYER PURITY', () {
    test('Domain layer cannot import Flutter framework', () {
      final domainFiles = findDartFiles(
        'lib',
      ).where((file) => isInLayer(file.path, 'domain')).toList();

      final flutterImports = <String>[];

      for (final file in domainFiles) {
        final imports = extractImports(file);

        for (final import in imports) {
          // Check for Flutter framework imports
          if (import.startsWith('package:flutter/')) {
            flutterImports.add('${file.path}: $import');
          }
        }
      }

      expect(
        flutterImports.isEmpty,
        isTrue,
        reason:
            'Domain layer cannot import Flutter framework. Violations:\n${flutterImports.join('\n')}',
      );
    });

    test('Domain layer cannot import infrastructure packages', () {
      final domainFiles = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'domain'))
          .where((file) => !file.path.endsWith('firebase_options.dart'))
          .toList();

      // List of infrastructure packages that domain shouldn't import
      final forbiddenPackages = [
        'package:dio/',
        'package:http/',
        'package:shared_preferences/',
        'package:sqflite/',
        'package:hive/', // Legacy Hive (should not be used)
        'package:hive_ce/', // Hive CE (should not be used in domain)
        'package:hive_flutter/', // Legacy Hive Flutter (should not be used)
        'package:hive_ce_flutter/', // Hive CE Flutter (should not be used in domain)
        'package:firebase_',
        'package:cloud_firestore/',
        'package:path_provider/',
        'package:connectivity_plus/',
        'package:device_info_plus/',
        'package:permission_handler/',
      ];

      final infrastructureImports = <String>[];

      for (final file in domainFiles) {
        final imports = extractImports(file);

        for (final import in imports) {
          for (final forbidden in forbiddenPackages) {
            if (import.startsWith(forbidden)) {
              infrastructureImports.add('${file.path}: $import');
              break;
            }
          }
        }
      }

      expect(
        infrastructureImports.isEmpty,
        isTrue,
        reason:
            'Domain layer cannot import infrastructure packages. Violations:\n${infrastructureImports.join('\n')}',
      );
    });

    test('BuildContext cannot leak outside presentation layer', () {
      final nonPresentationFiles = findDartFiles('lib')
          .where((file) => !isInLayer(file.path, 'presentation'))
          .where(
            (file) => !file.path.contains('/generated/'),
          ) // Whitelist generated files
          .where(
            (file) => !file.path.endsWith('edulift_app.dart'),
          ) // Whitelist main app file
          .where(
            (file) => !file.path.endsWith('app_router.dart'),
          ) // Whitelist infrastructure routing
          // All files checked - no legacy router exclusions needed
          .where(
            (file) => !file.path.endsWith('route_configuration.dart'),
          ) // Whitelist route config
          .toList();

      final buildContextImports = <String>[];

      for (final file in nonPresentationFiles) {
        final imports = extractImports(file);

        for (final import in imports) {
          // BuildContext is in package:flutter/widgets.dart
          if (import == 'package:flutter/widgets.dart' ||
              import == 'package:flutter/material.dart' ||
              import == 'package:flutter/cupertino.dart') {
            // Check if file actually uses BuildContext by reading content
            final content = file.readAsStringSync();
            if (content.contains('BuildContext')) {
              buildContextImports.add(
                '${file.path}: $import (uses BuildContext)',
              );
            }
          }
        }
      }

      expect(
        buildContextImports.isEmpty,
        isTrue,
        reason:
            'BuildContext cannot be used outside presentation layer. Violations:\n${buildContextImports.join('\n')}',
      );
    });
  });

  group('Infrastructure Package Rules - LAYER RESTRICTIONS', () {
    test('Only data layer can import HTTP/API packages', () {
      final httpPackages = [
        'package:dio/',
        'package:http/',
        'package:retrofit/',
      ];
      final nonDataFiles = findDartFiles('lib')
          .where((file) => !isInLayer(file.path, 'data'))
          .where(
            (file) => !file.path.endsWith('providers.dart'),
          ) // Allow composition roots
          .where(
            (file) => !file.path.contains('/core/network/'),
          ) // Allow core network infrastructure
          .where(
            (file) => !file.path.contains('/core/di/'),
          ) // Allow dependency injection
          .where(
            (file) => !file.path.contains('/core/security/'),
          ) // Allow security layer
          .where(
            (file) => !file.path.contains('/infrastructure/'),
          ) // Allow infrastructure layer
          .toList();

      final violations = <String>[];

      for (final file in nonDataFiles) {
        final imports = extractImports(file);

        for (final import in imports) {
          for (final httpPackage in httpPackages) {
            if (import.startsWith(httpPackage)) {
              violations.add('${file.path}: $import');
              break;
            }
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Only data layer can import HTTP/API packages. Violations:\n${violations.join('\n')}',
      );
    });

    test('Only data layer can import storage packages', () {
      final storagePackages = [
        'package:shared_preferences/',
        'package:sqflite/',
        'package:hive/', // Legacy Hive (should not be used)
        'package:hive_ce/', // Hive CE (only in data layer)
        'package:hive_flutter/', // Legacy Hive Flutter (should not be used)
        'package:hive_ce_flutter/', // Hive CE Flutter (only in data/infrastructure)
        'package:path_provider/',
      ];

      final nonDataFiles = findDartFiles('lib')
          .where((file) => !isInLayer(file.path, 'data'))
          .where(
            (file) => !file.path.endsWith('providers.dart'),
          ) // Allow composition roots
          .where(
            (file) => !file.path.contains('/core/storage/'),
          ) // Allow core storage infrastructure
          .where(
            (file) => !file.path.contains('/core/di/'),
          ) // Allow dependency injection
          .where(
            (file) => !file.path.contains('/infrastructure/'),
          ) // Allow infrastructure layer
          .toList();

      final violations = <String>[];

      for (final file in nonDataFiles) {
        final imports = extractImports(file);

        for (final import in imports) {
          // Allow path_provider for log export and file operations
          if (import.startsWith('package:path_provider/')) {
            if (file.path.contains('log_export') ||
                file.path.contains('/providers/')) {
              continue; // Allowed for log export feature
            }
          }

          for (final storagePackage in storagePackages) {
            if (import.startsWith(storagePackage)) {
              violations.add('${file.path}: $import');
              break;
            }
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Only data layer can import storage packages. Violations:\n${violations.join('\n')}',
      );
    });

    test('Only presentation layer can import UI-specific packages', () {
      final uiPackages = [
        'package:go_router/',
        'package:flutter_hooks/',
        'package:flutter_riverpod/',
        'package:provider/',
      ];

      final nonPresentationFiles = findDartFiles('lib')
          .where((file) => !isInLayer(file.path, 'presentation'))
          .where(
            (file) => !file.path.endsWith('providers.dart'),
          ) // Allow composition roots
          .where(
            (file) => !file.path.contains('/providers/'),
          ) // Allow provider directories
          .where(
            (file) => !isInLayer(file.path, 'core'),
          ) // Allow core utilities
          .where(
            (file) => !file.path.endsWith('main.dart'),
          ) // Allow main app file
          .where(
            (file) => !file.path.endsWith('edulift_app.dart'),
          ) // Allow main app composition root
          .where(
            (file) => !file.path.endsWith('bootstrap.dart'),
          ) // Allow bootstrap - app entry point
          .toList();

      final violations = <String>[];

      for (final file in nonPresentationFiles) {
        final imports = extractImports(file);

        for (final import in imports) {
          for (final uiPackage in uiPackages) {
            if (import.startsWith(uiPackage)) {
              violations.add('${file.path}: $import');
              break;
            }
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Only presentation layer (and core) can import UI-specific packages. Violations:\n${violations.join('\n')}',
      );
    });
  });

  group('Method Signature Constraints - BUSINESS LOGIC PURITY', () {
    test('Repository and UseCase methods cannot return Widget', () {
      final businessLogicFiles = findDartFiles('lib')
          .where(
            (file) =>
                file.path.contains('repository') ||
                file.path.contains('usecase') ||
                isInLayer(file.path, 'domain'),
          )
          .toList();

      final widgetReturningMethods = <String>[];

      for (final file in businessLogicFiles) {
        final content = file.readAsStringSync();

        // Look for method signatures that return Widget types
        final widgetReturnPattern = RegExp(
          r'\b(Widget|StatelessWidget|StatefulWidget)\s+\w+\s*\(',
        );
        final matches = widgetReturnPattern.allMatches(content);

        if (matches.isNotEmpty) {
          for (final match in matches) {
            final line = content.substring(0, match.start).split('\n').length;
            widgetReturningMethods.add(
              '${file.path}:$line - Method returns ${match.group(1)}',
            );
          }
        }
      }

      expect(
        widgetReturningMethods.isEmpty,
        isTrue,
        reason:
            'Repository/UseCase methods cannot return Widget types. Violations:\n${widgetReturningMethods.join('\n')}',
      );
    });

    test('Domain layer methods cannot accept BuildContext parameter', () {
      final domainFiles = findDartFiles(
        'lib',
      ).where((file) => isInLayer(file.path, 'domain')).toList();

      final buildContextMethods = <String>[];

      for (final file in domainFiles) {
        final content = file.readAsStringSync();

        // Look for methods that accept BuildContext as parameter
        final buildContextPattern = RegExp(r'\w+\s*\([^)]*BuildContext[^)]*\)');
        final matches = buildContextPattern.allMatches(content);

        if (matches.isNotEmpty) {
          for (final match in matches) {
            final line = content.substring(0, match.start).split('\n').length;
            buildContextMethods.add(
              '${file.path}:$line - Method accepts BuildContext parameter',
            );
          }
        }
      }

      expect(
        buildContextMethods.isEmpty,
        isTrue,
        reason:
            'Domain layer methods cannot accept BuildContext. Violations:\n${buildContextMethods.join('\n')}',
      );
    });
  });

  group('Framework Isolation Summary', () {
    test('Display framework isolation compliance summary', () {
      final domainFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'domain')).length;
      final dataFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'data')).length;
      final presentationFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'presentation')).length;

      print('\n🛡️  FRAMEWORK ISOLATION COMPLIANCE');
      print('=====================================');
      print('🏢 Domain layer files: $domainFiles (must be framework-free)');
      print(
        '💾 Data layer files: $dataFiles (can use infrastructure packages)',
      );
      print(
        '🖥️  Presentation layer files: $presentationFiles (can use UI packages)',
      );
      print('=====================================');
      print('✅ Domain layer purity enforced');
      print('✅ Infrastructure packages restricted to data layer');
      print('✅ UI packages restricted to presentation layer');
      print('✅ BuildContext cannot leak outside presentation');
      print('✅ Business logic methods cannot return Widgets');

      expect(true, isTrue, reason: 'Framework isolation summary displayed');
    });
  });
}
