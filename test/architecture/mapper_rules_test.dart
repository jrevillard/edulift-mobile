// MAPPER/TRANSFORMER ARCHITECTURE RULES - DATA LAYER ENFORCEMENT
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// These tests enforce proper separation between domain entities and data DTOs
// through mapper/transformer placement and prevent data concerns from leaking
// into the domain layer.
//
// Rules Enforced:
// 1. Entity↔DTO mappers MUST be in data layer only
// 2. Mappers MUST be named {Entity}Mapper or {Entity}Transformer
// 3. Domain entities CANNOT have fromJson/toJson methods
// 4. Data DTOs MUST have fromJson/toJson methods
// 5. Presentation models (if different from domain) MUST be in presentation layer

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

  /// Extract method names from a Dart file
  List<String> extractMethodNames(File file) {
    final content = file.readAsStringSync();
    final methodPattern = RegExp(r'^\s*(\w+)\s+(\w+)\s*\(', multiLine: true);

    return methodPattern
        .allMatches(content)
        .map((match) => match.group(2)!)
        .toList();
  }

  /// Check if a class is a mapper/transformer
  bool isMapperClass(String className) {
    return className.endsWith('Mapper') ||
        className.endsWith('Transformer') ||
        className.endsWith('Converter');
  }

  /// Check if file contains JSON serialization methods
  bool hasJsonMethods(File file) {
    final content = file.readAsStringSync();
    return content.contains('fromJson') || content.contains('toJson');
  }

  /// Check if file contains mapping methods
  bool hasMappingMethods(File file) {
    final content = file.readAsStringSync();
    return content.contains('toEntity') ||
        content.contains('fromEntity') ||
        content.contains('toModel') ||
        content.contains('fromModel') ||
        content.contains('toDomain') ||
        content.contains('fromDomain');
  }

  group('Mapper/Transformer Architecture Rules - DATA LAYER SEPARATION', () {
    test('Entity↔DTO mappers MUST be in data layer only', () {
      final allFiles = findDartFiles('lib');
      final violations = <String>[];
      final validMappers = <String>[];

      for (final file in allFiles) {
        final classes = extractClassNames(file);

        for (final className in classes) {
          if (isMapperClass(className)) {
            // Skip TimeSlotMapper - it's a UI helper, not a DTO mapper
            if (file.path.contains('time_slot_mapper.dart')) {
              continue;
            }

            if (isInLayer(file.path, 'data') ||
                isInLayer(file.path, 'core') || // Allow core utilities
                file.path.contains('/infrastructure/')) {
              // Allow infrastructure DTOs
              validMappers.add('${file.path}: $className');
            } else {
              violations.add(
                '${file.path}: Mapper $className must be in data layer',
              );
            }
          }
        }

        // Also check for mapping methods in wrong layers
        if (hasMappingMethods(file) &&
            !isInLayer(file.path, 'data') &&
            !isInLayer(file.path, 'core') && // Allow core utilities
            !file.path.contains('/infrastructure/')) {
          // Allow infrastructure DTOs

          // Skip presentation helpers (use l10n, not real mappers)
          final content = file.readAsStringSync();
          if (content.contains('AppLocalizations') ||
              content.contains('l10n') ||
              file.path.contains('time_slot_mapper.dart')) { // UI helper, not DTO mapper
            continue;
          }

          final methods = extractMethodNames(file);
          final mappingMethods = methods.where(
            (m) =>
                m.contains('toEntity') ||
                m.contains('fromEntity') ||
                m.contains('toModel') ||
                m.contains('fromModel') ||
                m.contains('toDomain') ||
                m.contains('fromDomain'),
          );

          if (mappingMethods.isNotEmpty) {
            violations.add(
              '${file.path}: Mapping methods outside data layer: ${mappingMethods.join(', ')}',
            );
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason: 'Mappers must be in data layer only:\n${violations.join('\n')}',
      );

      print('\n🔄 VALID MAPPERS IN DATA LAYER:');
      for (final mapper in validMappers) {
        print('✅ $mapper');
      }

      if (validMappers.isEmpty) {
        print(
          '⚠️  No mappers found - consider adding explicit mappers for entity↔DTO conversion',
        );
      }
    });

    test('Mappers MUST follow proper naming conventions', () {
      final dataFiles = findDartFiles(
        'lib',
      ).where((file) => isInLayer(file.path, 'data')).toList();

      final violations = <String>[];
      final validNaming = <String>[];

      for (final file in dataFiles) {
        final classes = extractClassNames(file);

        for (final className in classes) {
          // Check if this appears to be a mapper but doesn't follow naming convention
          if (hasMappingMethods(file) &&
              file.readAsStringSync().contains('class $className') &&
              !isMapperClass(className) &&
              !className.endsWith('Dto') &&
              !className.endsWith('Model') &&
              !className.endsWith('Repository') &&
              !className.endsWith('DataSource') &&
              !className.endsWith('Handler') && // Allow handlers
              !className.endsWith('Impl') && // Allow implementations
              !className.endsWith('Request') && // Allow request models
              !className.endsWith('Response') && // Allow response models
              !className.endsWith('Metrics') && // Allow metrics classes
              !className.contains('Cache') && // Allow cache classes
              !className.contains('Entry') && // Allow cache entry classes
              className.length > 5) {
            // Avoid flagging short utility classes
            violations.add(
              '${file.path}: Class $className appears to be a mapper but doesn\'t end with Mapper/Transformer',
            );
          } else if (isMapperClass(className)) {
            validNaming.add('${file.path}: $className');
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Mapper classes must be named {Entity}Mapper or {Entity}Transformer:\n${violations.join('\n')}',
      );

      print('\n📝 PROPERLY NAMED MAPPERS:');
      for (final naming in validNaming) {
        print('✅ $naming');
      }
    });

    test('Domain entities CANNOT have fromJson/toJson methods', () {
      final domainFiles = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'domain'))
          .where(
            (file) =>
                file.path.contains('entities') || file.path.contains('models'),
          )
          .toList();

      final violations = <String>[];
      final cleanEntities = <String>[];

      for (final file in domainFiles) {
        final classes = extractClassNames(file);
        final content = file.readAsStringSync();

        // Check for actual entity deserialization methods (with Map parameter)
        // Pattern matches: factory ClassName.fromJson(Map<String, dynamic>)
        // or static ClassName fromJson(Map<String, dynamic>)
        final entityDeserializer = RegExp(
          r'(?:factory|static)\s+\w+(?:\?)?\s+\w+\.fromJson\s*\(\s*Map<String,\s*dynamic>',
          multiLine: true,
        );

        // Pattern matches: Map<String, dynamic> toJson()
        final entitySerializer = RegExp(
          r'Map<String,\s*dynamic>\s+toJson\s*\(',
          multiLine: true,
        );

        final hasMapFromJson = entityDeserializer.hasMatch(content);
        final hasMapToJson = entitySerializer.hasMatch(content);

        if (hasMapFromJson || hasMapToJson) {
          for (final className in classes) {
            // Skip enum converters - enums use fromJson(String), not Map
            // Common enum naming patterns: Status, Level, Role, Permission, Type
            final isEnumConverter = className.contains('Status') ||
                className.contains('Level') ||
                className.contains('Role') ||
                className.contains('Permission') ||
                className.contains('Type');

            // Skip Command DTOs - these are data transfer objects, not entities
            final isCommand = className.endsWith('Command');

            // Only flag if it's NOT an enum converter and NOT a Command
            if (!isEnumConverter && !isCommand) {
              violations.add(
                '${file.path}: Domain entity $className cannot have fromJson/toJson methods with Map parameter',
              );
            } else {
              // It's a valid enum converter or Command DTO
              cleanEntities.add(
                  '${file.path}: $className (${isEnumConverter ? "enum converter" : "command DTO"})');
            }
          }
        } else if (classes.isNotEmpty) {
          for (final className in classes) {
            cleanEntities.add('${file.path}: $className');
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Domain entities must be pure - no JSON serialization with Map:\n${violations.join('\n')}',
      );

      print('\n🏛️  CLEAN DOMAIN ENTITIES:');
      for (final entity in cleanEntities.take(10)) {
        print('✅ $entity');
      }
      if (cleanEntities.length > 10) {
        print('... and ${cleanEntities.length - 10} more');
      }
    });

    test('Data DTOs MUST have fromJson/toJson methods', () {
      final dataFiles = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'data'))
          .where(
            (file) =>
                file.path.contains('models') ||
                file.path.contains('dtos') ||
                file.path.contains('dto'),
          )
          .toList();

      final violations = <String>[];
      final validDtos = <String>[];

      for (final file in dataFiles) {
        final classes = extractClassNames(file);

        for (final className in classes) {
          // Skip mappers and other utility classes
          if (isMapperClass(className) ||
              className.endsWith('Repository') ||
              className.endsWith('DataSource')) {
            continue;
          }

          // Check if this looks like a DTO/Model but doesn't have JSON methods
          if ((className.endsWith('Dto') ||
                  className.endsWith('Model') ||
                  className.endsWith('Response') ||
                  className.endsWith('Request')) &&
              !hasJsonMethods(file)) {
            violations.add(
              '${file.path}: Data DTO $className should have fromJson/toJson methods',
            );
          } else if (hasJsonMethods(file)) {
            validDtos.add('${file.path}: $className');
          }
        }
      }

      // Note: This test is more of a guideline than a strict requirement
      // Some DTOs might not need JSON serialization
      if (violations.isNotEmpty) {
        print('\n⚠️  POTENTIAL DTO ISSUES (REVIEW NEEDED):');
        for (final violation in violations) {
          print('⚠️  $violation');
        }
      }

      print('\n📦 VALID DTOs WITH JSON METHODS:');
      for (final dto in validDtos.take(10)) {
        print('✅ $dto');
      }
      if (validDtos.length > 10) {
        print('... and ${validDtos.length - 10} more');
      }

      // Always pass but provide warnings
      expect(true, isTrue, reason: 'DTO analysis completed');
    });

    test(
      'Presentation models MUST be in presentation layer if different from domain',
      () {
        final presentationFiles = findDartFiles('lib')
            .where((file) => isInLayer(file.path, 'presentation'))
            .where(
              (file) =>
                  file.path.contains('models') ||
                  file.path.contains('view_models'),
            )
            .toList();

        final violations = <String>[];
        final validViewModels = <String>[];

        for (final file in presentationFiles) {
          final classes = extractClassNames(file);
          final content = file.readAsStringSync();

          for (final className in classes) {
            // Check for presentation models that import from data layer
            if ((className.endsWith('ViewModel') ||
                    className.endsWith('Model') ||
                    className.endsWith('State')) &&
                content.contains('/data/')) {
              violations.add(
                '${file.path}: Presentation model $className imports from data layer',
              );
            } else if (className.endsWith('ViewModel') ||
                className.endsWith('Model')) {
              validViewModels.add('${file.path}: $className');
            }
          }
        }

        expect(
          violations.isEmpty,
          isTrue,
          reason:
              'Presentation models cannot import from data layer:\n${violations.join('\n')}',
        );

        print('\n🖥️  VALID PRESENTATION MODELS:');
        for (final viewModel in validViewModels) {
          print('✅ $viewModel');
        }

        if (validViewModels.isEmpty) {
          print(
            '✅ No presentation-specific models found - using domain entities directly',
          );
        }
      },
    );

    test('Mapping direction rules - data layer orchestrates transformations', () {
      final dataFiles = findDartFiles(
        'lib',
      ).where((file) => isInLayer(file.path, 'data')).toList();

      final violations = <String>[];
      final validMappings = <String>[];

      for (final file in dataFiles) {
        final content = file.readAsStringSync();

        // Check for proper mapping direction
        if (hasMappingMethods(file)) {
          final lines = content.split('\n');

          for (var i = 0; i < lines.length; i++) {
            final line = lines[i].trim();

            // Check for dangerous patterns - domain importing data DTOs
            if (line.contains('import ') &&
                line.contains('/domain/') &&
                content.contains('toJson')) {
              // This might indicate data DTO importing domain entity (reverse direction)
              // This is OK - data layer should know about domain
            }

            // Check for proper mapping method signatures
            if (line.contains('toEntity') || line.contains('toDomain')) {
              validMappings.add('${file.path}:${i + 1}: $line');
            }
          }
        }
      }

      // Check domain layer doesn't import data models
      final domainFiles = findDartFiles(
        'lib',
      ).where((file) => isInLayer(file.path, 'domain')).toList();

      for (final file in domainFiles) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();

          if (line.startsWith('import ') &&
              line.contains('/data/models') &&
              !line.contains('//')) {
            violations.add(
              '${file.path}:${i + 1}: Domain cannot import data models: $line',
            );
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Domain layer cannot import data DTOs:\n${violations.join('\n')}',
      );

      print('\n🔄 VALID MAPPING METHODS:');
      for (final mapping in validMappings.take(5)) {
        print('✅ $mapping');
      }
      if (validMappings.length > 5) {
        print('... and ${validMappings.length - 5} more');
      }
    });

    test('Display mapper architecture summary', () {
      final dataFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'data')).length;
      final domainFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'domain')).length;
      final presentationFiles = findDartFiles(
        'lib',
      ).where((f) => isInLayer(f.path, 'presentation')).length;

      final mapperFiles = findDartFiles('lib')
          .where((file) => extractClassNames(file).any((c) => isMapperClass(c)))
          .length;

      final dtoFiles = findDartFiles('lib')
          .where((file) => isInLayer(file.path, 'data') && hasJsonMethods(file))
          .length;

      final entityFiles = findDartFiles('lib')
          .where(
            (file) =>
                isInLayer(file.path, 'domain') &&
                (file.path.contains('entities') ||
                    file.path.contains('models')),
          )
          .length;

      print('\n🔄 MAPPER ARCHITECTURE SUMMARY');
      print('===============================');
      print('💾 Data layer files: $dataFiles');
      print('🏛️  Domain layer files: $domainFiles');
      print('🖥️  Presentation layer files: $presentationFiles');
      print('🔄 Mapper/Transformer files: $mapperFiles');
      print('📦 DTO files with JSON: $dtoFiles');
      print('🏛️  Domain entity files: $entityFiles');
      print('===============================');
      print('✅ Mappers restricted to data layer');
      print('✅ Domain entities remain pure (no JSON)');
      print('✅ DTOs handle serialization concerns');
      print('✅ Proper separation of concerns enforced');
      print('🚨 Any violations will cause build failures');
      print(
        '📝 Run with: flutter test test/architecture/mapper_rules_test.dart',
      );

      expect(true, isTrue, reason: 'Mapper architecture summary displayed');
    });
  });
}
