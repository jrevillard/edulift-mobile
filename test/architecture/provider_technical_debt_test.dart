// PROVIDER ARCHITECTURE ENFORCEMENT - PREVENTING ARCHITECTURAL DEBT
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// This test ENFORCES provider architecture rules to prevent duplication,
// circular dependencies, and state management anti-patterns.

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('Provider Architecture Enforcement - PREVENTING ARCHITECTURAL DEBT',
      () {
    test('ENFORCE: No circular dependencies between providers', () {
      final providerFiles = _findDartFiles(
        'lib',
      ).where((file) => file.path.contains('_provider.dart')).toList();

      final circularDependencies = <String>[];

      for (final file in providerFiles) {
        final content = file.readAsStringSync();
        final imports = _extractImports(content);
        final fileName = file.path.split('/').last.replaceAll('.dart', '');

        // Check if this provider imports other providers
        for (final import in imports) {
          if (import.contains('_provider.dart') && !import.contains(fileName)) {
            final importedProvider =
                import.split('/').last.replaceAll('.dart', '');

            // Check for reverse dependency (circular)
            final importedFile = providerFiles
                .where((f) => f.path.contains(importedProvider))
                .firstOrNull;
            if (importedFile != null) {
              final importedContent = importedFile.readAsStringSync();
              final reverseImports = _extractImports(importedContent);

              if (reverseImports.any((imp) => imp.contains(fileName))) {
                circularDependencies.add(
                  '$fileName ↔ $importedProvider (CIRCULAR DEPENDENCY)',
                );
              }
            }
          }
        }
      }

      expect(
        circularDependencies.isEmpty,
        isTrue,
        reason:
            'CRITICAL: Circular dependencies detected between providers:\n${circularDependencies.join('\n')}',
      );

      print('\n🔄 CIRCULAR DEPENDENCY CHECK PASSED');
      print('✅ No circular dependencies between providers');
    });

    test('ENFORCE: No same-domain entity state duplication', () {
      final providerFiles = _findDartFiles(
        'lib',
      ).where((file) => file.path.contains('_provider.dart')).toList();

      final entityDuplication = <String>[];
      final entityStateByDomain = <String, Map<String, List<String>>>{};

      for (final file in providerFiles) {
        final content = file.readAsStringSync();
        final providerName = file.path.split('/').last.replaceAll('.dart', '');
        final domain = _extractDomain(
          file.path,
        ); // e.g., 'family', 'auth', 'schedule'

        // Look for specific entity state patterns (not generic loading/error)
        final entityFields = _extractEntityFields(content);

        if (entityFields.isNotEmpty) {
          entityStateByDomain.putIfAbsent(domain, () => {});
          entityStateByDomain[domain]![providerName] = entityFields;
        }
      }

      // Check for entity duplication within SAME domain
      entityStateByDomain.forEach((domain, providers) {
        if (providers.length > 1) {
          final allFields = <String>{};
          providers.forEach((providerName, fields) {
            allFields.addAll(fields);
          });

          // Check if multiple providers in same domain manage same entity
          for (final field in allFields) {
            final providersWithField = providers.entries
                .where((entry) => entry.value.contains(field))
                .map((entry) => entry.key)
                .toList();

            if (providersWithField.length > 1) {
              entityDuplication.add(
                'Domain "$domain": Entity field "$field" managed by: ${providersWithField.join(", ")}',
              );
            }
          }
        }
      });

      expect(
        entityDuplication.isEmpty,
        isTrue,
        reason:
            'CRITICAL: Same-domain entity duplication detected:\n${entityDuplication.join('\n')}',
      );

      if (entityDuplication.isEmpty) {
        print('\n📋 ENTITY STATE DUPLICATION CHECK PASSED');
        print('✅ No entity state duplication within same domain');
      }
    });

    test('ENFORCE: No same-domain business logic duplication', () {
      final providerFiles = _findDartFiles(
        'lib',
      ).where((file) => file.path.contains('_provider.dart')).toList();

      final methodDuplication = <String>[];
      final methodsByDomain = <String, Map<String, List<String>>>{};

      for (final file in providerFiles) {
        final content = file.readAsStringSync();
        final providerName = file.path.split('/').last.replaceAll('.dart', '');
        final domain = _extractDomain(file.path);

        // Extract business methods (CRUD operations on domain entities)
        final businessMethods = _extractBusinessMethods(content);

        if (businessMethods.isNotEmpty) {
          methodsByDomain.putIfAbsent(domain, () => {});
          methodsByDomain[domain]![providerName] = businessMethods;
        }
      }

      // Check for method duplication within SAME domain
      methodsByDomain.forEach((domain, providers) {
        if (providers.length > 1) {
          final allMethods = <String>{};
          providers.forEach((providerName, methods) {
            allMethods.addAll(methods);
          });

          // Check if multiple providers in same domain have same business methods
          for (final method in allMethods) {
            final providersWithMethod = providers.entries
                .where((entry) => entry.value.contains(method))
                .map((entry) => entry.key)
                .toList();

            if (providersWithMethod.length > 1) {
              methodDuplication.add(
                'Domain "$domain": Method "$method" duplicated in: ${providersWithMethod.join(", ")}',
              );
            }
          }
        }
      });

      expect(
        methodDuplication.isEmpty,
        isTrue,
        reason:
            'CRITICAL: Same-domain business logic duplication detected:\n${methodDuplication.join('\n')}',
      );

      if (methodDuplication.isEmpty) {
        print('\n🔧 BUSINESS LOGIC DUPLICATION CHECK PASSED');
        print('✅ No same-domain business method duplication');
      }
    });

    test('Document provider usage patterns (WARNING ONLY)', () {
      final providerFiles = _findDartFiles('lib')
          .where(
            (file) =>
                file.path.contains('_provider.dart') ||
                file.path.endsWith('providers.dart'),
          )
          .toList();

      final multipleProviderFiles = <String>[];

      for (final file in providerFiles) {
        final content = file.readAsStringSync();
        final providerCount = _countProviders(content);

        if (providerCount > 1) {
          multipleProviderFiles.add(
            '${file.path}: $providerCount providers (TECHNICAL DEBT)',
          );
        }
      }

      // Document but do NOT fail the test
      if (multipleProviderFiles.isNotEmpty) {
        print('\n⚠️  PROVIDER TECHNICAL DEBT (WARNINGS ONLY)');
        print('===========================================');
        for (final file in multipleProviderFiles) {
          print('📄 $file');
        }
        print('===========================================');
        print('✅ This is documented technical debt, not a failure');
        print('🔄 Consider refactoring when time permits');
        print('===========================================\n');
      }

      // Always pass - this is documentation, not enforcement
      expect(
        true,
        isTrue,
        reason: 'Provider technical debt documented successfully',
      );
    });

    test('Summary of provider architecture patterns', () {
      final totalProviderFiles = _findDartFiles(
        'lib',
      ).where((file) => file.path.contains('provider')).length;
      final compositionRoots = _findDartFiles(
        'lib',
      ).where((file) => file.path.endsWith('providers.dart')).length;
      final featureProviders = _findDartFiles(
        'lib',
      ).where((file) => file.path.contains('_provider.dart')).length;

      print('\n📊 PROVIDER ARCHITECTURE SUMMARY');
      print('================================');
      print('🔌 Total provider files: $totalProviderFiles');
      print('🏗️  Composition roots: $compositionRoots');
      print('🎯 Feature providers: $featureProviders');
      print('================================');
      print('✅ Provider patterns documented');
      print('⚠️  Technical debt tracked as warnings');
      print('================================\n');

      expect(true, isTrue, reason: 'Provider summary displayed');
    });
  });
}

/// Helper functions
List<File> _findDartFiles(String directoryPath) {
  final directory = Directory(directoryPath);
  if (!directory.existsSync()) return [];

  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
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

List<String> _extractImports(String content) {
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

/// Extract domain from file path (e.g., 'family', 'auth', 'schedule')
String _extractDomain(String filePath) {
  // Extract domain from path like lib/features/family/presentation/providers/
  final pathParts = filePath.split('/');
  final featuresIndex = pathParts.indexOf('features');

  if (featuresIndex != -1 && featuresIndex + 1 < pathParts.length) {
    return pathParts[featuresIndex + 1]; // Return the feature domain
  }

  // Fallback for shared providers
  if (filePath.contains('shared/')) {
    return 'shared';
  }

  return 'unknown';
}

/// Extract entity-specific fields (not generic loading/error states) - FIELD DEFINITIONS ONLY
List<String> _extractEntityFields(String content) {
  final entityFields = <String>[];

  // Look for ACTUAL FIELD DEFINITIONS (not dependencies or parameters)
  // Focus on domain entity state fields, not service dependencies
  final fieldDefPatterns = [
    RegExp(r'final\s+List<(\w+)>\s+(\w+);'), // final List<Vehicle> vehicles;
    RegExp(r'final\s+(\w+)\?\s+(\w+);'), // final Vehicle? selectedVehicle;
    RegExp(r'final\s+(\w+)\s+(\w+);'), // final Vehicle vehicle;
  ];

  for (final pattern in fieldDefPatterns) {
    final matches = pattern.allMatches(content);
    for (final match in matches) {
      String? type;
      String? fieldName;

      if (match.groupCount == 2) {
        type = match.group(1)!;
        fieldName = match.group(2)!;
      }

      if (type != null && fieldName != null) {
        // Skip service dependencies (like _authService, _appStateNotifier)
        if (!_isServiceDependency(fieldName, type) &&
            !_isGenericField(fieldName, type)) {
          // Only include domain entity fields
          if (_isDomainEntity(type)) {
            entityFields.add('$type:$fieldName');
          }
        }
      }
    }
  }

  return entityFields;
}

/// Check if a field is generic (loading, error) vs domain-specific
bool _isGenericField(String fieldName, String type) {
  const genericFields = [
    'isLoading',
    'loading',
    'error',
    'isSubmitting',
    'hasError',
    'errorMessage',
    'state',
    'status',
  ];

  const genericTypes = ['bool', 'String', 'int', 'double'];

  return genericFields.contains(fieldName) || genericTypes.contains(type);
}

/// Extract business methods (CRUD operations on domain entities) - METHOD DEFINITIONS ONLY
List<String> _extractBusinessMethods(String content) {
  final businessMethods = <String>[];

  // Look for ACTUAL METHOD DEFINITIONS (not calls or references)
  // Must have "Future<" or "void" or return type before method name
  final methodDefPatterns = [
    RegExp(
      r'Future<[^>]*>\s+(add|create|update|delete|remove|get|fetch|load|submit)(\w+)\s*\([^)]*\)\s*async\s*\{',
    ),
    RegExp(
      r'Future<[^>]*>\s+(add|create|update|delete|remove|get|fetch|load|submit)(\w+)\s*\([^)]*\)\s*\{',
    ),
    RegExp(
      r'void\s+(add|create|update|delete|remove|get|fetch|load|submit)(\w+)\s*\([^)]*\)\s*\{',
    ),
    // Also catch method definitions without explicit return type in class context
    RegExp(
      r'^\s*(add|create|update|delete|remove|get|fetch|load|submit)(\w+)\s*\([^)]*\)\s*async\s*\{',
      multiLine: true,
    ),
  ];

  for (final pattern in methodDefPatterns) {
    final matches = pattern.allMatches(content);
    for (final match in matches) {
      final action = match.group(1) ?? match.group(1);
      final entity = match.group(2) ?? match.group(2);

      if (action != null && entity != null) {
        final methodName = '$action$entity';

        // Skip generic methods - focus on entity operations
        if (!_isGenericMethod(methodName)) {
          businessMethods.add(methodName);
        }
      }
    }
  }

  return businessMethods;
}

/// Check if a method is generic vs domain-specific business logic
bool _isGenericMethod(String methodName) {
  const genericMethods = [
    'getState',
    'setState',
    'loadData',
    'saveData',
    'clearError',
    'clearState',
    'dispose',
    'init',
  ];

  return genericMethods.contains(methodName) ||
      methodName.length < 4; // Skip very short method names
}

/// Check if a field is a service dependency (should be ignored in duplication detection)
bool _isServiceDependency(String fieldName, String type) {
  // Service dependency patterns
  const serviceTypes = [
    'AppStateNotifier',
    'AuthService',
    'ErrorHandlerService',
    'VehiclesRepository',
    'FamilyRepository',
    'InvitationRepository',
  ];

  const serviceSuffixes = ['Service', 'Repository', 'Notifier', 'Handler'];

  return serviceTypes.contains(type) ||
      serviceSuffixes.any((suffix) => type.endsWith(suffix)) ||
      fieldName.startsWith('_'); // Private dependency fields
}

/// Check if a type represents a domain entity (not a service or primitive)
bool _isDomainEntity(String type) {
  const domainEntityTypes = [
    'Vehicle',
    'Family',
    'Child',
    'Invitation',
    'User',
    'Group',
    'Schedule',
    'TimeSlot',
    'Assignment',
  ];

  const excludedTypes = [
    'String',
    'int',
    'bool',
    'double',
    'DateTime',
    'Map',
    'List',
  ];

  return domainEntityTypes.contains(type) && !excludedTypes.contains(type);
}
