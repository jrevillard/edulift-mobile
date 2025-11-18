// STATE MANAGEMENT RULES - FLUTTER-SPECIFIC ARCHITECTURAL PATTERNS
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// These tests enforce proper state management patterns and prevent
// architectural violations in Flutter-specific state handling.

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('State Management Rules - FLUTTER ARCHITECTURAL PATTERNS', () {
    test('Widgets cannot directly instantiate UseCases or Repositories', () {
      final widgetFiles = _findDartFiles(
        'lib',
      ).where((file) => _isInLayer(file.path, 'presentation')).toList();

      final violations = <String>[];

      for (final file in widgetFiles) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();

          // Check for direct instantiation of business logic
          if (_containsDirectInstantiation(line)) {
            violations.add(
              '${file.path}:${i + 1}: Direct instantiation in widget: ${line}',
            );
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'WIDGET DEPENDENCY VIOLATIONS: Widgets directly instantiating business logic:\n${violations.join('\n')}',
      );
    });

    test('State classes must be annotated with @immutable', () {
      final stateFiles = _findDartFiles('lib')
          .where(
            (file) =>
                file.path.contains('state') || file.path.contains('provider'),
          )
          .toList();

      final violations = <String>[];

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
              violations.add(
                '${file.path}:${i + 1}: State class without @immutable: ${line}',
              );
            }
            foundImmutableAnnotation = false; // Reset for next class
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'IMMUTABLE STATE VIOLATIONS: State classes without @immutable:\n${violations.join('\n')}',
      );
    });

    test('Provider files should only be in designated locations', () {
      final providerFiles = _findDartFiles('lib')
          .where(
            (file) =>
                file.path.contains('_provider.dart') ||
                file.path.endsWith('providers.dart'),
          )
          .toList();

      final violations = <String>[];

      for (final file in providerFiles) {
        // Check if provider is in correct location
        if (!file.path.contains('/providers/') &&
            !file.path.endsWith('providers.dart') &&
            !file.path.contains('/services/') &&
            !_isCompositionRoot(file.path)) {
          violations.add(
            '${file.path}: Provider should be in /providers/ or /services/ directory or be a composition root',
          );
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason: 'PROVIDER LOCATION VIOLATIONS:\n${violations.join('\n')}',
      );
    });

    test('StateNotifier/BLoC classes cannot import Flutter material', () {
      final stateManagementFiles = _findDartFiles('lib')
          .where(
            (file) =>
                file.path.contains('bloc') ||
                file.path.contains('notifier') ||
                file.path.contains('provider'),
          )
          .toList();

      final violations = <String>[];

      for (final file in stateManagementFiles) {
        final imports = _extractImports(file);

        for (final import in imports) {
          if (import.startsWith('package:flutter/material.dart')) {
            // Exception: Theme providers legitimately need Material types
            if (!file.path.contains('theme') && !file.path.contains('Theme')) {
              violations.add(
                '${file.path}: State management importing material.dart: $import',
              );
            }
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'STATE MANAGEMENT MATERIAL VIOLATIONS:\n${violations.join('\n')}',
      );
    });

    test('Presentation widgets must use proper dependency injection', () {
      final widgetFiles = _findDartFiles('lib')
          .where(
            (file) =>
                _isInLayer(file.path, 'presentation') &&
                (file.path.contains('widget') || file.path.contains('page')),
          )
          .toList();

      final violations = <String>[];

      for (final file in widgetFiles) {
        final content = file.readAsStringSync();

        // Check for getter injection pattern (proper DI)
        final hasLegacyDIUsage =
            content.contains('legacy_di') ||
            content.contains('sl(') ||
            content.contains('ref.watch(') ||
            content.contains('ref.read(');
        final hasProviderUsage =
            content.contains('Provider.of') ||
            content.contains('context.read') ||
            content.contains('context.watch');

        // Check for constructor injection
        final hasConstructorInjection = _hasConstructorInjection(content);

        // If it uses business logic but doesn't follow DI patterns
        if (_usesBusinessLogic(content) &&
            !hasLegacyDIUsage &&
            !hasProviderUsage &&
            !hasConstructorInjection) {
          violations.add(
            '${file.path}: Widget uses business logic without proper DI pattern',
          );
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason: 'DEPENDENCY INJECTION VIOLATIONS:\n${violations.join('\n')}',
      );
    });

    test('State mutations must be handled properly', () {
      final stateFiles = _findDartFiles('lib')
          .where(
            (file) =>
                file.path.contains('provider') ||
                file.path.contains('bloc') ||
                file.path.contains('notifier'),
          )
          .toList();

      final violations = <String>[];

      for (final file in stateFiles) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();

          // Skip comments
          if (line.startsWith('//')) continue;

          // Check for direct state mutations (dangerous patterns)
          // Exception: AsyncNotifier and StateNotifier can assign states with proper patterns
          if (line.contains('state =') &&
              !line.contains('state ==') && // Skip comparisons
              !line.contains('return state ==') && // Skip calculated returns
              !line.contains('state = state.copyWith') &&
              !line.contains(
                'Set<String>.from(state)',
              ) && // Immutable set creation
              !line.contains('.toSet()') && // Immutable set transformation
              !line.contains('.toList()') && // Immutable list transformation
              !line.contains(
                'List<',
              ) && // List type annotations (not mutations)
              !line.contains('Map<') && // Map type annotations (not mutations)
              !line.contains(
                '=> state =',
              ) && // Lambda/arrow function assignment (Notifier pattern)
              !line.contains('AsyncValue') &&
              !line.contains('AsyncData') &&
              !line.contains('AsyncError') &&
              !line.contains('AsyncLoading') &&
              !line.contains('.when(') &&
              !line.contains('.whenData(') &&
              !line.contains('const ') &&
              !line.contains('result.when') &&
              !line.contains(
                'State(',
              ) && // Allow immutable State constructor calls (e.g., GroupInvitationState(...))
              !line.contains(
                '{...state,',
              ) && // Allow spread operator for immutable sets
              !_isCompleteObjectReplacement(line) &&
              !_isNotifierObjectCreation(line)) {
            // Allow complete immutable object replacement
            violations.add(
              '${file.path}:${i + 1}: Direct state mutation: ${line}',
            );
          }

          // Check for mutable collections being mutated (only on state or fields)
          // Skip immutable collection creation patterns like Set.from() or List.from()
          if ((line.contains('.add(') ||
                  line.contains('.remove(') ||
                  line.contains('.clear()')) &&
              (line.contains('state.') ||
                  line.contains('_state.') ||
                  line.contains('this.')) &&
              !line.contains(
                'Set<String>.from(state)',
              ) && // Immutable set pattern
              !line.contains('List.from(') && // Immutable list pattern
              !line.contains('.where(') &&
              !_isNotifierObjectCreation(line)) {
            // Functional collection transformation
            violations.add(
              '${file.path}:${i + 1}: Direct collection mutation on state: ${line}',
            );
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason: 'STATE MUTATION VIOLATIONS:\n${violations.join('\n')}',
      );
    });

    test('Async state changes must be handled properly', () {
      final stateFiles = _findDartFiles('lib')
          .where(
            (file) =>
                file.path.contains('provider') || file.path.contains('bloc'),
          )
          .toList();

      final violations = <String>[];

      for (final file in stateFiles) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');

        var inAsyncMethod = false;

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();

          if (line.contains('async ') &&
              (line.contains('void ') || line.contains('Future'))) {
            inAsyncMethod = true;
          }

          if (line.contains('}') && inAsyncMethod) {
            inAsyncMethod = false;
          }

          // Check for improper async state updates
          if (inAsyncMethod &&
              line.contains('notifyListeners()') &&
              !_hasProperAsyncHandling(content, i)) {
            violations.add(
              '${file.path}:${i + 1}: Async state update without proper handling: ${line}',
            );
          }
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason: 'ASYNC STATE VIOLATIONS:\n${violations.join('\n')}',
      );
    });

    test('Display comprehensive state management analysis', () {
      final providerFiles = _findDartFiles(
        'lib',
      ).where((f) => f.path.contains('provider')).length;
      final blocFiles = _findDartFiles(
        'lib',
      ).where((f) => f.path.contains('bloc')).length;
      final notifierFiles = _findDartFiles(
        'lib',
      ).where((f) => f.path.contains('notifier')).length;
      final widgetFiles = _findDartFiles(
        'lib',
      ).where((f) => _isInLayer(f.path, 'presentation')).length;

      print('\n🎛️  STATE MANAGEMENT ANALYSIS');
      print('============================');
      print('🔌 Provider files: $providerFiles');
      print('🧱 BLoC files: $blocFiles');
      print('🔔 Notifier files: $notifierFiles');
      print('🖥️  Widget files: $widgetFiles');
      print('============================');
      print('✅ State management patterns enforced');
      print('🚨 Pattern violations will cause test failures');
      print(
        '📝 Run with: flutter test test/architecture/state_management_test.dart',
      );
      print('============================\n');

      expect(true, isTrue, reason: 'State management analysis displayed');
    });
  });
}

/// Helper functions
bool _containsDirectInstantiation(String line) {
  final patterns = [
    RegExp(r'new\s+\w*UseCase'),
    RegExp(r'new\s+\w*Repository'),
    RegExp(r'\w*UseCase\('),
    RegExp(r'\w*Repository\('),
  ];

  return patterns.any((pattern) => pattern.hasMatch(line));
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

bool _usesBusinessLogic(String content) {
  // Allow domain entities for display (valid 2025 pattern)
  if (content.contains('/domain/entities/') &&
      !content.contains('UseCase') &&
      !content.contains('Repository')) {
    return false; // Entities for display are not business logic
  }

  return content.contains('UseCase') ||
      content.contains('Repository') ||
      (content.contains('.call(') &&
          !content.contains('widget.') &&
          !content.contains('onError?.call') &&
          !content.contains('errorBuilder?.call'));
}

bool _hasConstructorInjection(String content) {
  return content.contains('required ') &&
      (content.contains('UseCase') || content.contains('Repository'));
}

bool _hasProperAsyncHandling(String content, int lineIndex) {
  final lines = content.split('\n');

  // Check previous lines for try-catch or proper async patterns
  for (var i = Math.max(0, lineIndex - 5); i < lineIndex; i++) {
    final line = lines[i].trim();
    if (line.contains('try') ||
        line.contains('await') ||
        line.contains('Future')) {
      return true;
    }
  }

  return false;
}

bool _isInLayer(String filePath, String layer) {
  return filePath.contains('/$layer/');
}

bool _isCompositionRoot(String filePath) {
  return filePath.endsWith('providers.dart') ||
      filePath.contains('/di/') ||
      filePath.contains('injection');
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

/// Check if a line represents a complete immutable object replacement
/// (e.g., "state = newStatus;" where newStatus is a complete immutable object)
/// This is a legitimate pattern for StateNotifier where we replace the entire state
/// with a new immutable object, not mutate existing state.
bool _isCompleteObjectReplacement(String line) {
  // Pattern: "state = identifier;" where identifier is a variable name (not a property access)
  // Examples:
  //   ✅ state = newStatus;
  //   ✅ state = updatedFamily;
  //   ❌ state.field = value; (property mutation - should be caught)
  //   ❌ state = {...}; (inline object - allowed by other checks)

  final trimmed = line.trim();

  // Must contain "state ="
  if (!trimmed.contains('state =')) return false;

  // Extract the assignment part (everything after "state = ")
  final parts = trimmed.split('state =');
  if (parts.length < 2) return false;

  final assignmentPart = parts[1].trim();

  // Check if it's a simple variable name (identifier) followed by semicolon
  // Pattern: word characters followed by optional semicolon
  final simpleAssignmentPattern = RegExp(r'^[a-zA-Z_]\w*;?$');

  return simpleAssignmentPattern.hasMatch(assignmentPart);
}

bool _isNotifierObjectCreation(String line) {
  // Allow common Notifier state creation patterns that are completely immutable
  // Examples:
  //   ✅ state = DateTime(year, month, day);
  //   ✅ state = someFunction();
  //   ✅ state = !state; (boolean negation)
  //   ✅ state = state.add(duration); (immutable DateTime arithmetic)

  final trimmed = line.trim();

  // Must contain "state ="
  if (!trimmed.contains('state =')) return false;

  // Extract the assignment part (everything after "state = ")
  final parts = trimmed.split('state =');
  if (parts.length < 2) return false;

  final assignmentPart = parts[1].trim();

  // Allow constructor calls with parentheses
  if (assignmentPart.startsWith('DateTime(') ||
      assignmentPart.startsWith('DateUtils.') ||
      assignmentPart.contains('(') && assignmentPart.contains(')')) {
    return true;
  }

  // Allow boolean negation
  if (assignmentPart.startsWith('!state')) {
    return true;
  }

  // Allow immutable arithmetic on state (DateTime.add/subtract)
  if (assignmentPart.startsWith('state.add(') ||
      assignmentPart.startsWith('state.subtract(')) {
    return true;
  }

  // Allow function calls (complete object creation)
  if (assignmentPart.contains('(') &&
      !assignmentPart.contains('state.') && // Not state.property()
      assignmentPart.endsWith(')')) {
    return true;
  }

  return false;
}

class Math {
  static int max(int a, int b) => a > b ? a : b;
}
